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


   method Action start(Tin a, Tin b) if (available);
       available <= False;

       Bit#(16) partials[16];

       // find partial sums of rows
       // a4 a3 a2 a1 a0
       // b4 b3 b2 b1 b0
       // -----------
       //                      (C)
       //                       |
       //                       v
       //               | a4 a3 a2 a1 a0  & b0 <-(R)
       //            a4 | a3 a2 a1 a0     & b1
       //         a4 a3 | a2 a1 a0        & b2
       //      a4 a3 a2 | a1 a0           & b3
       //   a4 a3 a2 a1 | a0              & b4
       //  -------------+---------------
       //   r8 r7 r6 r5 | r4 r3 r2 r1 r0
       //  -------------+---------------

       for(Integer i = 0; i < 16; i = i + 1) begin
           partials[i] = extend(b[i]) & a;
       end


       Bit#(32) mulfinal = 0;
       for(Integer c = 0; c < 16; c = c + 1) begin
           Bit#(1) accum = 0;
           Bit#(1) carry = 0;

           for (Integer r = 0; r <= c; r = r + 1) begin
               Bit#(1) accum_new = fa_sum(accum, partials[r][c - r], carry);
               Bit#(1) carry_new = fa_carry(accum, partials[r][c - r], carry);

               accum = accum_new;
               carry = carry_new;
           end
           mulfinal[c] = accum;
       end

       product <= mulfinal;

   endmethod

   method Tout result();
      return product;
   endmethod

   method Action acknowledge() if (!available);
      available <= True;
   endmethod
   
endmodule : mkSingle
   
endpackage : Single
