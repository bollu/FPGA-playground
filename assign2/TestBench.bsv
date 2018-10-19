// The implementation of the test bench. I tried to generalize this
// but failed, so copy-pasting will have to suffice.
import Vector::*;
import Randomizable::*;
import Multi::*;
import Multiplier::*;
import Single::*;
import PipeElastic::*;
import PipeInElastic::*;
import FIFO::*;
import FIFOF::*;
import LFSR::*;

(* synthesize *)
module mkTestReferenceMultiplier ();
    Reg#(Bit#(16)) num1 <- mkReg(0);
    Reg#(Bit#(16)) num2 <- mkReg(0);
    Reg#(Bool) stepLoop <- mkReg(True);
    Reg#(Bit#(32)) numTestsTotal <- mkReg(0);
    // Randomize#(Bit#(16)) random <- mkGenericRandomizer;
    
    Multiplier_IFC multi <- mkMulti();

rule loop if (stepLoop == True);
    stepLoop <= False;
    if (numTestsTotal == 100) begin
        $display ("SUCCESS");
        $finish(0);
    end

    numTestsTotal <= numTestsTotal +1;
    multi.start(num1, num2);

endrule

rule display if (stepLoop == False);
    let out =  multi.result();

    // You need to acknowledge it so it "unlatches" and lets you feed
    // it a new value.. smh
    $display("CALCULATED: %d * %d = %d", num1, num2, multi.result());
    Bit#(32) zext_num1 = zeroExtend(num1);
    Bit#(32) zext_num2 = zeroExtend(num2);
    multi.acknowledge();

    if (zext_num1 * zext_num2 != out) begin
        $display("EXPECTED:   %d * %d = %d", zext_num1, zext_num2, zext_num1 * zext_num2);
        $finish(1);
    end
    stepLoop <= True;
    num1 <= num1 + 2;
    num2 <= num2 + 3;
endrule

endmodule 

(* synthesize *)
module mkTestSingleCycleMultiplier();
    Reg#(Bit#(16)) num1 <- mkReg(0);
    Reg#(Bit#(16)) num2 <- mkReg(0);
    Reg#(Bool) stepLoop <- mkReg(True);
    Reg#(Bit#(32)) numTestsTotal <- mkReg(0);
    
    // single cycle multiplier
    Multiplier_IFC multi <- mkSingle();

rule loop if (stepLoop == True);
    stepLoop <= False;
    if (numTestsTotal == 10000) begin
        $display ("SUCCESS");
        $finish(0);
    end

    numTestsTotal <= numTestsTotal +1;
    multi.start(num1, num2);

endrule

rule display if (stepLoop == False);
    let out =  multi.result();

    // You need to acknowledge it so it "unlatches" and lets you feed
    // it a new value.. smh
    $display("CALCULATED: %d * %d = %d", num1, num2, multi.result());
    Bit#(32) zext_num1 = zeroExtend(num1);
    Bit#(32) zext_num2 = zeroExtend(num2);
    multi.acknowledge();

    if (zext_num1 * zext_num2 != out) begin
        $display("***FAIL!***");
        $display("EXPECTED:   %d * %d = %d", zext_num1, zext_num2, zext_num1 * zext_num2);
        $finish(1);
    end
    stepLoop <= True;
    num1 <= (num1 + 1) % (1 << 15 - 1);
    num2 <= (num2 + 3) % (1 << 15 - 1);
endrule
endmodule 

(* synthesize *)
module mkTestElasticPipeline();
    LFSR#(Bit#(16)) rand1 <- mkLFSR_16;
    LFSR#(Bit#(16)) rand2 <- mkLFSR_16;
    Reg#(Bool) seeded <- mkReg(False);

    FIFOF#(Bit#(16)) num1vals <- mkSizedFIFOF(200);
    FIFOF#(Bit#(16)) num2vals <- mkSizedFIFOF(200);
    Reg#(Bit#(16)) npushed <- mkReg(0);
    

    Reg#(Bit#(32)) numTestsInBatchWaiting <- mkReg(0);
    Reg#(Bit#(32)) numTestsTotal <- mkReg(0);

    Reg#(Bit#(32)) nCycles <- mkReg(0);
    Reg#(Bit#(32)) nCyclesMax <- mkReg(0);
    Reg#(Bit#(32)) nCyclesMin <- mkReg(9999);
    Reg#(Bit#(32)) nCyclesTotal <- mkReg(0);
    
    // single cycle multiplier
    Multiplier_IFC multi <- mkPipeElastic();

(* descending_urgency = "seed, loop, display, bumpCycleCount" *)

rule seed (seeded == False);
    seeded <= True;
    rand1.seed(20);
    rand2.seed(10);
endrule

rule bumpCycleCount if (numTestsInBatchWaiting != 0 && seeded);
    $display("RULE: BUMP CYCLE COUNT");
    nCycles <= nCycles + 1;
    nCyclesTotal <= nCyclesTotal + 1;
endrule

rule loop if (numTestsInBatchWaiting == 0 && seeded);
    nCycles <= nCycles + 1;
    nCyclesTotal <= nCyclesTotal + 1;
    $display("RULE: LOOP");
    if (numTestsTotal > 10) begin
        $display("SUCCESS");
        $finish(0);
    end

    if (npushed == 3) begin
        $display("DONE LOOP!");
        npushed <= 0;
        numTestsTotal <= numTestsTotal + 3;
        numTestsInBatchWaiting <= 3;
    end
    else begin
        let n1 = rand1.value();
        let n2 = rand2.value();

        rand1.next();
        rand2.next();

        multi.start(n1, n2);
        num1vals.enq(n1);
        num2vals.enq(n2);
        npushed <= npushed + 1;
        $display("...end pushing");
    end
endrule

rule display if (seeded);
    $display("RULE: DISPLAY");
    let out =  multi.result();

    let curnum1 = num1vals.first;
    let curnum2 = num2vals.first;

    // You need to acknowledge it so it "unlatches" and lets you feed
    // it a new value.. smh
    num1vals.deq();
    num2vals.deq();

    nCyclesMax <= max(nCycles, nCyclesMax);
    nCyclesMin <= min(nCycles, nCyclesMin);

    $display("####NCYCLES: %d", nCycles);
    $display("####NCYCLES (MIN): %d", nCyclesMin);
    $display("####NCYCLES (MAX): %d", nCyclesMax);

     $display("####NCYCLES (Total):%d / numTests (Total): %d ", nCyclesTotal, numTestsTotal);

    nCycles <= 0;
    Bit#(32) zext_num1 = zeroExtend(curnum1);
    Bit#(32) zext_num2 = zeroExtend(curnum2);
    $display("CALCULATED: %d * %d = %d | correct: %d ", curnum1, curnum2, multi.result(), zext_num1 * zext_num2);
    multi.acknowledge();

    if (zext_num1 * zext_num2 != out) begin
        $display("***FAIL!***");
        $display("EXPECTED:   %d * %d = %d", zext_num1, zext_num2, zext_num1 * zext_num2);
        $finish(1);
    end
    numTestsInBatchWaiting <= numTestsInBatchWaiting - 1;
endrule
endmodule 


(* synthesize *)
module mkTestInelasticPipeline();
    LFSR#(Bit#(16)) rand1 <- mkLFSR_16;
    LFSR#(Bit#(16)) rand2 <- mkLFSR_16;
    Reg#(Bool) seeded <- mkReg(False);

    FIFOF#(Bit#(16)) num1vals <- mkSizedFIFOF(200);
    FIFOF#(Bit#(16)) num2vals <- mkSizedFIFOF(200);
    Reg#(Bit#(16)) npushed <- mkReg(0);
    

    Reg#(Bit#(32)) numTestsInBatchWaiting <- mkReg(0);
    Reg#(Bit#(32)) numTestsTotal <- mkReg(0);

    Reg#(Bit#(32)) nCycles <- mkReg(0);
    Reg#(Bit#(32)) nCyclesMax <- mkReg(0);
    Reg#(Bit#(32)) nCyclesMin <- mkReg(9999);
    Reg#(Bit#(32)) nCyclesTotal <- mkReg(0);
    
    // single cycle multiplier
    Multiplier_IFC multi <- mkPipeInElastic();

(* descending_urgency = "seed, loop, display, bumpCycleCount" *)

rule seed (seeded == False);
    seeded <= True;
    rand1.seed(20);
    rand2.seed(10);
endrule

rule bumpCycleCount if (numTestsInBatchWaiting != 0 && seeded);
    $display("RULE: BUMP CYCLE COUNT");
    nCycles <= nCycles + 1;
    nCyclesTotal <= nCyclesTotal + 1;
endrule

rule loop if (numTestsInBatchWaiting == 0 && seeded);
    nCycles <= nCycles + 1;
    nCyclesTotal <= nCyclesTotal + 1;
    $display("RULE: LOOP");
    if (numTestsTotal > 100) begin
        $display("SUCCESS");
        $finish(0);
    end

    if (npushed == 10) begin
        $display("DONE LOOP!");
        npushed <= 0;
        numTestsTotal <= numTestsTotal + 10;
        numTestsInBatchWaiting <= 10;
    end
    else begin
        let n1 = rand1.value();
        let n2 = rand2.value();

        rand1.next();
        rand2.next();

        multi.start(n1, n2);
        num1vals.enq(n1);
        num2vals.enq(n2);
        npushed <= npushed + 1;
        $display("...end pushing");
    end
endrule

rule display if (seeded);
    $display("RULE: DISPLAY");
    let out =  multi.result();

    let curnum1 = num1vals.first;
    let curnum2 = num2vals.first;

    // You need to acknowledge it so it "unlatches" and lets you feed
    // it a new value.. smh
    num1vals.deq();
    num2vals.deq();

    nCyclesMax <= max(nCycles, nCyclesMax);
    nCyclesMin <= min(nCycles, nCyclesMin);

    $display("####NCYCLES: %d", nCycles);
    $display("####NCYCLES (MIN): %d", nCyclesMin);
    $display("####NCYCLES (MAX): %d", nCyclesMax);

     $display("####NCYCLES (Total):%d / numTests (Total): %d ", nCyclesTotal, numTestsTotal);

    nCycles <= 0;
    Bit#(32) zext_num1 = zeroExtend(curnum1);
    Bit#(32) zext_num2 = zeroExtend(curnum2);
    $display("CALCULATED: %d * %d = %d | correct: %d ", curnum1, curnum2, multi.result(), zext_num1 * zext_num2);
    multi.acknowledge();

    if (zext_num1 * zext_num2 != out) begin
        $display("***FAIL!***");
        $display("EXPECTED:   %d * %d = %d", zext_num1, zext_num2, zext_num1 * zext_num2);
        $finish(1);
    end
    numTestsInBatchWaiting <= numTestsInBatchWaiting - 1;
endrule

endmodule 
