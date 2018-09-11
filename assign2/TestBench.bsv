// The implementation of the test bench. I tried to generalize this
// but failed, so copy-pasting will have to suffice.
import Vector::*;
import Randomizable::*;
import Multi::*;
import Multiplier::*;
import Single::*;

(* synthesize *)
module mkTestReferenceMultiplier ();
    Reg#(Bit#(16)) num1 <- mkReg(0);
    Reg#(Bit#(16)) num2 <- mkReg(0);
    Reg#(Bool) stepLoop <- mkReg(True);
    Reg#(Bit#(32)) numTests <- mkReg(0);
    // Randomize#(Bit#(16)) random <- mkGenericRandomizer;
    
    Multiplier_IFC multi <- mkMulti();

rule loop if (stepLoop == True);
    stepLoop <= False;
    if (numTests == 100) begin
        $display ("SUCCESS");
        $finish(0);
    end

    numTests <= numTests +1;
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
    Reg#(Bit#(32)) numTests <- mkReg(0);
    
    // single cycle multiplier
    Multiplier_IFC multi <- mkSingle();

rule loop if (stepLoop == True);
    stepLoop <= False;
    if (numTests == 10000) begin
        $display ("SUCCESS");
        $finish(0);
    end

    numTests <= numTests +1;
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
    Reg#(Bit#(16)) num1 <- mkReg(0);
    Reg#(Bit#(16)) num2 <- mkReg(0);
    Reg#(Bool) stepLoop <- mkReg(True);
    Reg#(Bit#(32)) numTests <- mkReg(0);
    
    // single cycle multiplier
    Multiplier_IFC multi <- mkSingle();

rule loop if (stepLoop == True);
    stepLoop <= False;
    if (numTests == 10000) begin
        $display ("SUCCESS");
        $finish(0);
    end

    numTests <= numTests +1;
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
module mkTestInelasticPipeline();
    Reg#(Bit#(16)) num1 <- mkReg(0);
    Reg#(Bit#(16)) num2 <- mkReg(0);
    Reg#(Bool) stepLoop <- mkReg(True);
    Reg#(Bit#(32)) numTests <- mkReg(0);
    
    // single cycle multiplier
    Multiplier_IFC multi <- mkSingle();

rule loop if (stepLoop == True);
    stepLoop <= False;
    if (numTests == 10000) begin
        $display ("SUCCESS");
        $finish(0);
    end

    numTests <= numTests +1;
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
