import Vector::*;
import Randomizable::*;
import Adders::*;
import Multiplexer::*;
// Mux testbenches

(* synthesize *)
module mkTbMux1Simple();
    Reg#(Bit#(32)) cycle <- mkReg(0);

    Vector#(8, Bit#(1)) val1s = replicate( 0 );
    Vector#(8, Bit#(1)) val2s = replicate( 0 );
    Vector#(8, Bit#(1)) sels = replicate( 0 );
    val1s[0] = 0;     val2s[0] = 0;   sels[0] = 0;
    val1s[1] = 0;     val2s[1] = 0;   sels[1] = 1;
    val1s[2] = 0;     val2s[2] = 1;   sels[2] = 0;
    val1s[3] = 0;     val2s[3] = 1;   sels[3] = 1;
    val1s[4] = 1;     val2s[4] = 0;   sels[4] = 0;
    val1s[5] = 1;     val2s[5] = 0;   sels[5] = 1;
    val1s[6] = 1;     val2s[6] = 1;   sels[6] = 0;
    val1s[7] = 1;     val2s[7] = 1;   sels[7] = 1;

    rule test;
        if(cycle == 8) begin
            $display("PASSED");
            $finish;
        end else begin
            let val1 = val1s[cycle];
            let val2 = val2s[cycle];
            let sel = sels[cycle];
            let test = multiplexer1(sel, val1, val2);
            let realAns = sel == 0? val1: val2;
            if(test != realAns) begin
                $display("FAILED Sel %b from %d, %d gave %d instead of %d", sel, val1, val2, test, realAns);
                $finish;
            end else begin 
                $display("Sel %b from %d, %d is %d", sel, val1, val2, test);
            end
            cycle <= cycle + 1;
        end
    endrule
endmodule

(* synthesize *)
module mkTbMuxSimple();
    Reg#(Bit#(32)) cycle <- mkReg(0);

    Vector#(8, Bit#(4)) val1s = replicate( 0 );
    Vector#(8, Bit#(4)) val2s = replicate( 0 );
    Vector#(8, Bit#(1)) sels = replicate( 0 );
    val1s[0] = 0;     val2s[0] = 1;   sels[0] = 0;
    val1s[1] = 4;     val2s[1] = 7;   sels[1] = 1;
    val1s[2] = 15;    val2s[2] = 15;  sels[2] = 0;
    val1s[3] = 0;     val2s[3] = 15;  sels[3] = 1;
    val1s[4] = 0;     val2s[4] = 15;  sels[4] = 0;
    val1s[5] = 8;     val2s[5] = 0;   sels[5] = 0;
    val1s[6] = 11;    val2s[6] = 13;  sels[6] = 1;
    val1s[7] = 5;     val2s[7] = 6;   sels[7] = 1;

    rule test;
        if(cycle == 8) begin
            $display("PASSED");
            $finish;
        end else begin
            let val1 = val1s[cycle];
            let val2 = val2s[cycle];
            let sel = sels[cycle];
            let test = multiplexer4(sel, val1, val2);
            let realAns = sel == 0? val1: val2;
            if(test != realAns) begin
                $display("FAILED Sel %b from %d, %d gave %d instead of %d", sel, val1, val2, test, realAns);
                $finish;
            end else begin 
                $display("Sel %b from %d, %d is %d", sel, val1, val2, test);
            end
            cycle <= cycle + 1;
        end
    endrule
endmodule

(* synthesize *)
module mkTbMuxNSimple();
    Reg#(Bit#(32)) cycle <- mkReg(0);

    Vector#(8, Bit#(4)) val1s = replicate( 0 );
    Vector#(8, Bit#(4)) val2s = replicate( 0 );
    Vector#(8, Bit#(1)) sels = replicate( 0 );
    val1s[0] = 0;     val2s[0] = 1;   sels[0] = 0;
    val1s[1] = 4;     val2s[1] = 7;   sels[1] = 1;
    val1s[2] = 15;    val2s[2] = 15;  sels[2] = 0;
    val1s[3] = 0;     val2s[3] = 15;  sels[3] = 1;
    val1s[4] = 0;     val2s[4] = 15;  sels[4] = 0;
    val1s[5] = 8;     val2s[5] = 0;   sels[5] = 0;
    val1s[6] = 11;    val2s[6] = 13;  sels[6] = 1;
    val1s[7] = 5;     val2s[7] = 6;   sels[7] = 1;

    rule test;
        if(cycle == 8) begin
            $display("PASSED");
            $finish;
        end else begin
            let val1 = val1s[cycle];
            let val2 = val2s[cycle];
            let sel = sels[cycle];
            let test = multiplexer_n(sel, val1, val2);
            let realAns = sel == 0? val1: val2;
            if(test != realAns) begin
                $display("FAILED Sel %b from %d, %d gave %d instead of %d", sel, val1, val2, test, realAns);
                $finish;
            end else begin 
                $display("Sel %b from %d, %d is %d", sel, val1, val2, test);
            end
            cycle <= cycle + 1;
        end
    endrule
endmodule

// ripple carry adder testbenches

(* synthesize *)
module mkTbAdd4Simple();
    Reg#(Bit#(32)) cycle <- mkReg(0);

    Vector#(8, Bit#(4)) as = replicate( 0 );
    Vector#(8, Bit#(4)) bs = replicate( 0 );
    as[0] = 1;    bs[0] = 1;
    as[1] = 4;    bs[1] = 4;
    as[2] = 6;    bs[2] = 11;
    as[3] = 9;    bs[3] = 2;
    as[4] = 1;    bs[4] = 7;
    as[5] = 8;    bs[5] = 8;
    as[6] = 15;   bs[6] = 1;
    as[7] = 15;   bs[7] = 15;

    rule test;
        if(cycle == 8) begin
            $display("PASSED");
            $finish;
        end else begin
            let val1 = as[cycle];
            let val2 = bs[cycle];
            let test = add4( val1, val2, 0 );
            Bit#(5) realAns = zeroExtend(val1) + zeroExtend(val2);
            if(test != realAns) begin
                $display("FAILED %d + %d gave %d instead of %d", val1, val2, test, realAns);
                $finish;
            end else begin
                $display("%d + %d = %d", val1, val2, test);
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule


// ripple carry adder testbenches

(* synthesize *)
module mkTbRCASimple();
    Reg#(Bit#(32)) cycle <- mkReg(0);

    Vector#(8, Bit#(8)) as = replicate( 0 );
    Vector#(8, Bit#(8)) bs = replicate( 0 );
    as[0] = 1;    bs[0] = 1;
    as[1] = 8;    bs[1] = 8;
    as[2] = 63;   bs[2] = 27;
    as[3] = 102;  bs[3] = 92;
    as[4] = 177;  bs[4] = 202;
    as[5] = 128;  bs[5] = 128;
    as[6] = 255;  bs[6] = 1;
    as[7] = 255;  bs[7] = 255;

    rule test;
        if(cycle == 8) begin
            $display("PASSED");
            $finish;
        end else begin
            let val1 = as[cycle];
            let val2 = bs[cycle];
            let test = add8( val1, val2, 0 );
            Bit#(9) realAns = zeroExtend(val1) + zeroExtend(val2);
            if(test != realAns) begin
                $display("FAILED %d + %d gave %d instead of %d", val1, val2, test, realAns);
                $finish;
            end else begin
                $display("%d + %d = %d", val1, val2, test);
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule

// carry select adder testbenches

(* synthesize *)
module mkTbCSASimple();
    Reg#(Bit#(32)) cycle <- mkReg(0);

    Vector#(8, Bit#(8)) as = replicate( 0 );
    Vector#(8, Bit#(8)) bs = replicate( 0 );
    as[0] = 1;    bs[0] = 1;
    as[1] = 8;    bs[1] = 8;
    as[2] = 63;   bs[2] = 27;
    as[3] = 102;  bs[3] = 92;
    as[4] = 177;  bs[4] = 202;
    as[5] = 128;  bs[5] = 128;
    as[6] = 255;  bs[6] = 1;
    as[7] = 255;  bs[7] = 255;

    rule test;
        if(cycle == 8) begin
            $display("PASSED");
            $finish;
        end else begin
            let val1 = as[cycle];
            let val2 = bs[cycle];
            let test = cs_add8( val1, val2, 0 );
            Bit#(9) realAns = zeroExtend(val1) + zeroExtend(val2);
            if(test != realAns) begin
                $display("FAILED %d + %d gave %d instead of %d", val1, val2, test, realAns);
                $finish;
            end else begin
                $display("%d + %d = %d", val1, val2, test);
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule
