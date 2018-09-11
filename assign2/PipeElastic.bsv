package PipeElastic; 
import FIFO :: * ;

//single-cycle multiplier

import Multiplier::*;


function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    let picka = ~sel & a;
    let pickb = sel & b;

    return picka | pickb;
endfunction

function Bit#(n) multiplexer_n(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    Bit#(n) out = ?;

    for(Integer i = 0; i < valueOf(n); i = i + 1)
    begin
        out[i] = multiplexer1(sel, a[i], b[i]);
    end

    return out;
endfunction

function Bit#(1) fa_sum( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return a ^ b ^ c_in;
endfunction

function Bit#(1) fa_carry( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return   (a & b) | ((a ^ b) & c_in);
endfunction

// n Bit full adder
function Bit#(TAdd#(n,1)) addn( Bit#(n) a, Bit#(n) b, Bit#(1) c_in );
    Bit#(TAdd#(n, 1)) carries = ?;
    Bit#(n) outs;

    carries[0] = c_in;

    for(Integer i = 0; i < valueOf(n); i = i + 1)
    begin
        outs[i] = fa_sum(a[i], b[i], carries[i]);
        carries[i+1] = fa_carry(a[i], b[i], carries[i]);
    end

    return { carries[valueOf(n)], outs };
endfunction

(* synthesize *)
module mkPipeElastic( Multiplier_IFC );
   Reg#(Bool) available <- mkReg(True);
   Reg#(Bit#(16)) a <- mkReg(0);
   FIFO#(Bit#(32)) fifo[32];

   Reg#(Tout) product <- mkReg(0);

   // Initialize all of the FIFOs
   for(Integer i = 0; i < 32; i = i + 1) begin
       fifo[i] <- mkFIFO();
   end

   // generate pipeline rules
   for(Integer i = 0; i < 15; i = i + 1) begin
       rule stage if (True);
           Bit#(32) cur = fifo[i].first[31:0];
           Bit#(1) carry = fifo[i].first[32];
           fifo[i].deq();

           Bit#(32) cur_mul = extend(cur) << i;
           Bit#(32) next = multiplexer_n(a[i], cur, cur_mul);
           fifo[i].enq(next);
       endrule
   end

   method Action start(Tin ain, Tin b) if (available);
       available <= False;
       a <=  ain;
       fifo[0].enq({0, b});
   endmethod

   method Tout result();
       Bit#(32) cur = fifo[31].first;
       // chop off carry.
      return cur;
   endmethod

   method Action acknowledge() if (!available);
      available <= True;
   endmethod
   

   
endmodule : mkPipeElastic
   
endpackage : PipeElastic
