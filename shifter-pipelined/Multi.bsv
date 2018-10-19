package Multi; 

// Simple (naive) binary multiplier

import Multiplier::*;

(* synthesize *)
module mkMulti( Multiplier_IFC );
   Reg#(Bool)    available <- mkReg(True);
   Reg#(Tin)    lhs   <- mkReg(?);
   Reg#(Tin)    rhs     <- mkReg(?);

   method Action start(Tin m1, Tin m2) if (available);
       lhs   <= m1;
       rhs    <= m2;
       available <= False;
   endmethod

   method Tout result();
      return lhs << rhs;
   endmethod

   method Action acknowledge() if (!available);
      available <= True;
   endmethod
   
endmodule : mkMulti
   
endpackage : Multi
