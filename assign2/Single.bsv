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

       Reg#(Bit#(1)) grid [16][16];

       Bit#(16) partials[16];

       // find partial sums of rows
       // a3 a2 a1 a0
       // b3 b2 b1 b0
       // -----------
       //                     (C)
       //                      |
       //                      v
       //            a3 a2 a1 a0  | b0
       //         a3 a2 a1 a0     | b1
       //      a3 a2 a1 a0        | b2
       //   a3 a2 a1 a0           | b3
       //  -----------------------*---
       // 
       //  ---------------------------

       for(Integer i = 0; i < 16; i = i + 1) begin
           partials[i] = extend(b[i]) & a;
       end


       Bit#(1) cur_carry = 0;
       Bit#(1) cur_val = 0;

       Bit#(1) next_carry = 0;
       Bit#(1) next_val = 0;

       Bit#(32) mulfinal[32];

       // 0-initialize
       for(Integer i = 0; i < 32; i = i + 1) begin
           mulfinal[i] = 0;
       end

/*
       // Iterate on columns
       // a0 .. a16
       for(Integer c = 1; c <= 16; c = c + 1) begin
//           cur_val = 0;
//           next_val = 0;

           for(Integer r = 0; r < c; r += 1) begin
//               next_val = fa_sum(cur_val, partials[r][c], cur_carry);
//               next_carry = fa_carry(cur_val, partial[r][c], cur_carry);
//
               cur_val = next_val;
               cur_carry = next_carry;
        end
 //       mulfinal[c] = cur_val[c];
       end
       */

       // a16..a32
       /*
       for(Integer c = 0; c < 16; c = c + 1) begin
       end
       */

       product <= mulfinal[0];

   endmethod

   method Tout result();
      return product;
   endmethod

   method Action acknowledge() if (!available);
      available <= True;
   endmethod
   
endmodule : mkSingle
   
endpackage : Single
