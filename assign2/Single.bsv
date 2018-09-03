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
module mkSingle( Multiplier_IFC );
   Reg#(Bool)    available <- mkReg(True);
   Reg#(Tout)     product      <- mkReg(0);


   method Action start(Tin a, Tin b) if (available);
       available <= False;
       $display("calcuating %d * %d...\n", a, b);

       //row, col indexing
       Bit#(32) partials[16];
       for(Integer i= 0; i < 16; i = i + 1) begin
               $display("b[%d] := %d | a << %d := %d", i, b[i], i, a << i);
               partials[i] = multiplexer_n(b[i], 0, extend(a << i));

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

       /*
       //row, col indexing
       Bit#(32) accum[16];
       Bit#(32) carry[16];
       for(Integer c = 0; c < 32; c = c + 1) begin

           carry[0][c] = c == 0 ? 0 : carry[15][0];
           accum[0][c] = partials[0][c];

           $display("COLUMN: (%0d) | carry: %0d | accum: %0d", c, carry[0][c], accum[0][c]);

           for (Integer r = 1; r < 16; r = r + 1) begin
               // This is NOT how one adds!
               Bit#(1) cur = partials[r][c];
               Bit#(1) cur_carry = carry[r - 1][c];
               Bit#(1) cur_accum = accum[r - 1][c];

               accum[r][c] = fa_sum(cur_accum, cur, cur_carry);
               carry[r][c] = fa_carry(cur_accum, cur, cur_carry);


               $display("\tROW: %0d | carry:%0d + accum:%0d + cur:%d := (carry: %0d, accum:%0d)", r, cur_carry, cur_accum, cur, carry[r][c], accum[r][c]);

           end
           mulfinal[c] = accum[15][c];
           $display("MULFINAL[c] := %0d", accum[15][c]);
           $display("---");
       end
       product <= mulfinal;
       */



       /*
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
           Bit#(16) extend_b = extend(b[i]) << i;
           partials[i] = extend_b & a;
           $display("partials(%d) = %d & %d :=  %d\n", i, extend_b, a, partials[i]);
       end


       Bit#(32) mulfinal = 0;
       Bit#(1) carry = 0;
       for(Integer c = 0; c < 16; c = c + 1) begin
           Bit#(1) accum = 0;

           for (Integer r = 0; r <= c; r = r + 1) begin
               Bit#(1) accum_new = fa_sum(accum, partials[r][c - r], carry);
               Bit#(1) carry_new = fa_carry(accum, partials[r][c - r], carry);

               accum = accum_new;
               carry = carry_new;
           end
           mulfinal[c] = accum;
       end

       product <= mulfinal;
       */

   endmethod

   method Tout result();
      return product;
   endmethod

   method Action acknowledge() if (!available);
      available <= True;
   endmethod
   
endmodule : mkSingle
   
endpackage : Single
