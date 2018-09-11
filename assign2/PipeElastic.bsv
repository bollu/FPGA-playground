
package Single; 

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
   Reg#(Tout) product <- mkReg(0);


   method Action start(Tin a, Tin b) if (available);
       available <= False;
       $display("calcuating %d * %d...\n", a, b);

       //row, col indexing
       Bit#(32) partials[16];
       for(Integer i= 0; i < 16; i = i + 1) begin
               $display("b[%d] := %d | a << %d := %d", i, b[i], i, a << i);
               Bit#(32) a_extend = extend(a) << i;
               partials[i] = multiplexer_n(b[i], 0, a_extend);

       end


       for(Integer i= 0; i < 16; i = i + 1) begin
           $display("partials[%d] = %d", i, partials[i]);
       end

       $display("===");
       for(Integer r = 0; r < 16; r = r + 1) begin
               $display("%x", partials[r]);
       end
       $display("===");


       Bit#(32) add_store[16] ;
       Bit#(1) carry = 0;

       add_store[0] = partials[0];
       for(Integer r = 1; r < 16; r = r + 1) begin
           Bit#(33) next  = addn(add_store[r - 1], partials[r], carry);
           carry = next[32];
           add_store[r] = next[31:0];
       end
       product <= add_store[15];
   endmethod

   method Tout result();
      return product;
   endmethod

   method Action acknowledge() if (!available);
      available <= True;
   endmethod
   
endmodule : mkPipeElastic
   
endpackage : PipeElastic
