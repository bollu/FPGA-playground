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
       $display("calcuating %d * %d...\n", a, b);

       Bit#(32) partials[16];
       for(Integer i= 0; i < 16; i = i + 1) begin
               $display("b[%d] := %d | a << %d := %d", i, b[i], i, a << i);
               partials[i] = multiplexer_n(b[i], 0, a << i);

       end


       for(Integer i= 0; i < 16; i = i + 1) begin
           $display("partials[%d] = %d", i, partials[i]);
       end

       $display("===");
       for(Integer r = 0; r < 16; r = r + 1) begin
               $display("%x", partials[r]);
       end
       $display("===");


       Bit#(32) mulfinal = 0;
       Bit#(1) carry = 0;
       for(Integer c = 0; c < 32; c = c + 1) begin
           $display(" ** COLUMN: %0d | carry: %d", c, carry);
           Bit#(1) accum = 0;

           for (Integer r = 0; r < 32; r = r + 1) begin
               Bit#(1) cur = partials[r][c];

               if (cur != 0) begin
                   $display("partials[%0d] := 0%d | partials[%0d][%0d] = 1", r, partials[r], r, c, cur);
               end

               Bit#(1) accum_new = fa_sum(accum, cur, carry);
               Bit#(1) carry_new = fa_carry(accum, cur, carry);


               if (cur != 0) begin
                   $display("accum(a:%0d + c:%0d + current:%d) = %d", accum, carry, cur, accum_new);
                   $display("carry(a:%0d + c:%0d + current:%d) = %d", accum, carry, cur, carry_new);
               end

               accum = accum_new;
               carry = carry_new;
           end
           mulfinal[c] = accum;
           $display("mulfinal[%0d] = %0d", c, mulfinal[c]);
           $display("mulfinal = %d", mulfinal);
       end

       product <= mulfinal;


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
