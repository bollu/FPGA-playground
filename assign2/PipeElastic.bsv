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
   FIFO#(int) fifo[32];

   Reg#(Tout) product <- mkReg(0);

   // Initialize all of the FIFOs
   for(Integer i = 0; i < 32; i = i + 1) begin
       fifo[i] <- mkFIFO();
   end

   method Action start(Tin a, Tin b) if (available);
       available <= False;
       $display("calcuating %d * %d...\n", a, b);
       product <= 0;
   endmethod

   method Tout result();
      return product;
   endmethod

   method Action acknowledge() if (!available);
      available <= True;
   endmethod
   
endmodule : mkPipeElastic
   
endpackage : PipeElastic
