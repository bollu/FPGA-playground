package PipeInElastic; 
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
    module mkPipeInElastic( Multiplier_IFC );
        FIFOF#(Tuple3#(Bit#(16), Bit#(16), Bit#(32))) in;
        FIFOF#(Bit#(32)) out;

        Reg#(Maybe#(Tuple3#(Bit#(16), Bit#(16), Bit#(32)))) fifo[17];

        in <- mkFIFOF();
        out<- mkFIFOF();
        // Initialize all of the FIFOs
        for(Integer i = 0; i < 17; i = i + 1) begin
            fifo[i] <- mkReg(tagged Invalid);
        end


        // generate pipeline rules
        rule pipeline if (True) ;

            if (in.notEmpty())
            begin fifo[0] <= tagged Valid in.first;  in.deq(); end
            else fifo[0] <= tagged Invalid;

        
            for(Integer i = 0; i < 16; i = i + 1) begin
                case (fifo[i]) matches
                    tagged Valid .valtup: begin
                        // Extract components from tuple
                        Bit#(16) a = tpl_1(valtup), b = tpl_2(valtup);
                        Bit#(32) cur = tpl_3(valtup);

                        $display("\tfifo[%0d] VALID: %0d", i, cur);
                        Bit#(32) b_shifted = extend(b) << i;
                        // cur + b << i
                        Bit#(33) sum = addn(cur, b_shifted, 0);

                        Bit#(32) next = multiplexer_n(a[i], cur, sum[31:0]);
                        fifo[i + 1] <= tagged Valid tuple3(a, b, next);
                    end
                    tagged Invalid: begin
                        // $display("\tfifo[%0d] INVALID", i);
                        fifo[i + 1] <= tagged Invalid;
                        end
                endcase
            end

            case(fifo[16]) matches
                tagged Valid .last: out.enq(tpl_3(last));
            endcase
            $display("---");
        endrule

        method Action start(Tin ain, Tin bin);
            in.enq(tuple3(ain, bin, 0));
            $display("%d * %d = ?? ", ain, bin);
        endmethod


        method Tout result();
            return out.first;
        endmethod

        method Action acknowledge();
            out.deq();
        endmethod

    endmodule : mkPipeInElastic
endpackage : PipeInElastic
