package Single; 

//single-cycle multiplier

import Multiplier::*;


function Bit#(1) fa_sum( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return a ^ b ^ c_in;
endfunction

function Bit#(1) fa_carry( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return   (a & b) | ((a ^ b) & c_in);
endfunction

// 4 Bit full adder
function Bit#(TAdd#(n,1)) add4( Bit#(n) a, Bit#(n) b, Bit#(1) c_in );
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
module mkSingle( Multiplier_IFC );
   Reg#(Bool)    available <- mkReg(True);
   Reg#(Tout)     product      <- mkReg(0);
   Reg#(Bit#(1)) grid [16][16];


   method Action start(Tin m1, Tin m2) if (available);
       available <= False;
   endmethod

   method Tout result();
      return product;
   endmethod

   method Action acknowledge() if (!available);
      available <= True;
   endmethod
   
endmodule : mkSingle
   
endpackage : Single
