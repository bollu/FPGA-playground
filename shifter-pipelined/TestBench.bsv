// The implementation of the test bench. I tried to generalize this
// but failed, so copy-pasting will have to suffice.
import Vector::*;
import Randomizable::*;
import Multi::*;
import Multiplier::*;
import PipeElastic::*;
//import PipeInElastic::*;
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
    $display("CALCULATED: %d(%b) * %d(%b) = %d(%b)", num1, num1, num2, num2, multi.result(), multi.result());
    multi.acknowledge();

    if (num1 << num2 != out) begin
        $display("EXPECTED:   %d(%b) * %d(%b) = %d(%b)", num1, num1, num2, num2, num1 << num2, num1 << num2);
        $finish(1);
    end
    stepLoop <= True;
    num1 <= num1 + 1;
    num2 <= num2 + 2;
endrule

endmodule 

(* synthesize *)
module mkTestElasticPipeline();
    LFSR#(Bit#(16)) rand1 <- mkLFSR_16;
    LFSR#(Bit#(16)) rand2 <- mkLFSR_16;
    Reg#(Bool) seeded <- mkReg(False);

    FIFOF#(Bit#(16)) num1vals <- mkSizedFIFOF(100);
    FIFOF#(Bit#(16)) num2vals <- mkSizedFIFOF(100);
    Reg#(Bit#(16)) npushed <- mkReg(0);
    

    Reg#(Bit#(32)) numTestsInBatchWaiting <- mkReg(0);
    Reg#(Bit#(32)) numTestsTotal <- mkReg(0);

    Reg#(Bit#(32)) nCycles <- mkReg(0);
    Reg#(Bit#(32)) nCyclesMax <- mkReg(0);
    Reg#(Bit#(32)) nCyclesMin <- mkReg(9999);
    Reg#(Bit#(32)) nCyclesTotal <- mkReg(0);
    
    // single cycle multiplier
    Multiplier_Pipelined_IFC multi <- mkPipeElastic();

    // (* descending_urgency = "seed, loop, display, bumpCycleCount" *)
    (* descending_urgency = "seed, loop, display" *)
    rule seed (seeded == False);
        seeded <= True;
        rand1.seed(20);
        rand2.seed(10);
    endrule

    rule loop if (numTestsInBatchWaiting == 0 && seeded);

        for(Integer i = 0; i < 20; i = i + 1) begin
            $display("========");
        end
        
        $display("RULE: LOOP");
        if (numTestsTotal >= 10) begin
            $display("SUCCESS");
            $finish(0);
        end

        if (npushed == 3) begin
            $display("DONE PUSHING(%d) | NUM TESTS(%d)", npushed, numTestsTotal);
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
            $display("pushed: %d", npushed);
        end
    endrule

    rule display if (seeded && numTestsInBatchWaiting > 0);
        $display("> RULE: DISPLAY");
        numTestsInBatchWaiting <= numTestsInBatchWaiting - 1;

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
        $display("CALCULATED: %d(%b) << %d(%b) = %d(%b) | correct: %d(%b) ", 
        curnum1, curnum1, curnum2, curnum2, multi.result(), multi.result(), curnum1 << curnum2, curnum1 << curnum2);
        multi.acknowledge();

        if (curnum1 << curnum2 != out) begin
            $display("***FAIL!***");
            $display("EXPECTED:   %d(%b)  << %d(%b) = %d(%b)", 
            curnum1, curnum1, curnum2, curnum2, curnum1 << curnum2, curnum1 << curnum2);
            $finish(1);
        end
    endrule
endmodule 

// 
// (* synthesize *)
// module mkTestInelasticPipeline();
//     LFSR#(Bit#(16)) rand1 <- mkLFSR_16;
//     LFSR#(Bit#(16)) rand2 <- mkLFSR_16;
//     Reg#(Bool) seeded <- mkReg(False);
// 
//     FIFO#(Bit#(16)) num1vals <- mkFIFO();
//     FIFO#(Bit#(16)) num2vals <- mkFIFO();
//     Reg#(Bit#(16)) npushed <- mkReg(0);
//     
// 
//     Reg#(Bit#(32)) numTestsInBatchWaiting <- mkReg(0);
//     Reg#(Bit#(32)) numTestsTotal <- mkReg(0);
// 
//     Reg#(Bit#(32)) nCycles <- mkReg(0);
//     Reg#(Bit#(32)) nCyclesMax <- mkReg(0);
//     Reg#(Bit#(32)) nCyclesMin <- mkReg(9999);
//     Reg#(Bit#(32)) nCyclesTotal <- mkReg(0);
//     
//     // single cycle multiplier
//     Multiplier_IFC multi <- mkPipeInElastic();
// 
// (* descending_urgency = "seed, loop, display, bumpCycleCount" *)
// 
// rule seed (seeded == False);
//     seeded <= True;
//     rand1.seed(20);
//     rand2.seed(10);
// endrule
// 
// rule bumpCycleCount if (numTestsInBatchWaiting != 0 && seeded);
//     $display("RULE: BUMP CYCLE COUNT");
//     nCycles <= nCycles + 1;
//     nCyclesTotal <= nCyclesTotal + 1;
// endrule
// 
// rule loop if (numTestsInBatchWaiting == 0 && seeded);
//     nCycles <= nCycles + 1;
//     nCyclesTotal <= nCyclesTotal + 1;
//     $display("RULE: LOOP");
//     if (numTestsTotal == 1000) begin
//         $display("SUCCESS");
//         $finish(0);
//     end
// 
//     if (npushed == 2) begin
//         $display("DONE LOOP!");
//         npushed <= 0;
//         numTestsTotal <= numTestsTotal + 2;
//         numTestsInBatchWaiting <= 2;
//     end
//     else begin
//         let n1 = rand1.value();
//         let n2 = rand2.value();
// 
//         rand1.next();
//         rand2.next();
// 
//         multi.start(n1, n2);
//         num1vals.enq(n1);
//         num2vals.enq(n2);
//         npushed <= npushed + 1;
//         $display("...end pushing");
//     end
// endrule
// 
// rule display if (seeded);
//     $display("RULE: DISPLAY");
//     let out =  multi.result();
// 
//     let curnum1 = num1vals.first;
//     let curnum2 = num2vals.first;
// 
//     // You need to acknowledge it so it "unlatches" and lets you feed
//     // it a new value.. smh
//     num1vals.deq();
//     num2vals.deq();
// 
//     nCyclesMax <= max(nCycles, nCyclesMax);
//     nCyclesMin <= min(nCycles, nCyclesMin);
// 
//     $display("####NCYCLES: %d(%b)", nCycles);
//     $display("####NCYCLES (MIN): %d(%b)", nCyclesMin);
//     $display("####NCYCLES (MAX): %d(%b)", nCyclesMax);
// 
//      $display("####NCYCLES (Total):%d(%b) / numTests (Total): %d(%b) ", nCyclesTotal, numTestsTotal);
// 
//     nCycles <= 0;
//     $display("CALCULATED: %d(%b) * %d(%b) = %d(%b) | correct: %d(%b) ", curnum1, curnum2, multi.result(), num1 << num2);
//     multi.acknowledge();
// 
//     if (num1  << num2 != out) begin
//         $display("***FAIL!***");
//         $display("EXPECTED:   %d(%b) * %d(%b) = %d(%b)", num1, num2, num1 << num2);
//         $finish(1);
//     end
//     numTestsInBatchWaiting <= numTestsInBatchWaiting - 1;
// endrule
// 
// endmodule 