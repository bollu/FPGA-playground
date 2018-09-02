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
   Reg#(Tout)    product   <- mkReg(?);
   Reg#(Tout)    mcand     <- mkReg(?);
   Reg#(Tin)     mplr      <- mkReg(0);

   rule cycle ( mplr != 0 );
      $display("Rule cycle fired mcand=%0d mplr=%0d", mcand, mplr);
      if (mplr[0] == 1) product <= product + mcand;
      mcand   <= mcand << 1;
      mplr    <= mplr  >> 1;
   endrule

   method Action start(Tin m1, Tin m2) if ((mplr == 0) && available);
       product <= 0;
       mcand   <= {0, m1};
       mplr    <= m2;
       available <= False;
   endmethod

   method Tout result() if (mplr == 0);
      return product;
   endmethod

   method Action acknowledge() if ((mplr == 0) && !available);
      available <= True;
   endmethod
   
endmodule : mkSingle
   
endpackage : Single
