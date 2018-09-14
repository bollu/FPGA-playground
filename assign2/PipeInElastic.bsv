package PipeInElastic; 
    import FIFO :: * ;

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
        Reg#(Bit#(16)) a <- mkReg(0);
        Reg#(Bit#(16)) b <- mkReg(0);

        FIFO#(Bit#(32)) in;
        FIFO#(Bit#(32)) out;

        Reg#(Maybe#(Bit#(32))) fifo[17];

        // Initialize all of the FIFOs
        for(Integer i = 0; i < 17; i = i + 1) begin
            in <- mkFIFO();
            out<- mkFIFO();
        end


        // generate pipeline rules
        rule pipeline if (True) ;
            //Maybe#(Bit#(32)) mcur = tagged Valid fifo[0].first;
            //fifo[0].deq();
        
            //for(Integer i = 0; i < 16; i = i + 1) begin
            //    // b << i
            //    Bit#(32) b_shifted = extend(b) << i;
            //    // cur + b << i
            //    Bit#(33) sum = addn(cur, b_shifted, 0);

            //    Bit#(32) next = multiplexer_n(a[i], cur, sum[31:0]);

            //    $display("i: %d |  %d + (%d ? %d) = %d ", i, 
            //      cur, a[i], b_shifted,next);
            //    fifo[i+1].enq(next);
            //end
        endrule

        method Action start(Tin ain, Tin bin);
            a <=  ain;
            b <= bin;
            in.enq(0);
            $display("===");
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
