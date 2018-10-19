package PipeElastic; 
    import FIFO :: * ;
    import FIFOF :: * ;

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

        // (cur, b)
        FIFOF#(Tuple2#(Bit#(16), Bit#(16))) fifo[17];


        // Initialize all of the FIFOs
        for(Integer i = 0; i < 17; i = i + 1) begin
            fifo[i] <- mkSizedFIFOF(100);
        end


        // generate pipeline rules
        for(Integer i = 0; i < 16; i = i + 1) begin
            rule stage if (True);
                Bit#(16) b, cur;
                
                cur = tpl_1(fifo[i].first);
                b = tpl_2(fifo[i].first);
                // $display("a: %d | b: %d | cur: %d", a, b, cur);


                Bit#(16) shifted = cur << (1 << i);
                Bit#(16) next = multiplexer_n(b[i], cur, shifted);

                fifo[i+1].enq(tuple2(cur, b));
                fifo[i].deq();
            endrule
        end


        method Action start(Tin ain, Tin bin);
            fifo[0].enq(tuple2(ain, bin));
            $display("===");
            $display("%d * %d = ?? ", ain, bin);
        endmethod


        method Tout result();
            return tpl_1(fifo[16].first);
        endmethod

        method Action acknowledge();
            fifo[16].deq();
        endmethod
    endmodule : mkPipeElastic
endpackage : PipeElastic
