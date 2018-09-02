import Vector::*;
import Randomizable::*;
import Multi::*;
import Multiplier::*;

(* synthesize *)
module mkTestReferenceMultiplier ();
    Reg#(Bit#(16)) num1 <- mkReg(0);
    Reg#(Bit#(16)) num2 <- mkReg(0);
    Reg#(Bit#(32)) out <- mkReg(0);
    Reg#(Bool) stepLoop <- mkReg(True);
    Reg#(Bit#(32)) numTests <- mkReg(1000);
    // Randomize#(Bit#(16)) random <- mkGenericRandomizer;
    
    Multiplier_IFC multi <- mkMulti();

rule loop if (stepLoop == True);
    stepLoop <= False;
    if (numTests == 0) begin
        $display ("SUCCESS");
        $finish(0);
    end

    numTests <= numTests - 1;
    multi.start(num1, num2);
endrule

rule display if (stepLoop == False);
    out <= multi.result();
    // You need to acknowledge it so it "unlatches" and lets you feed
    // it a new value.. smh
    $display("CALCULATED: %d * %d = %d", num1, num2, out);
    Bit#(32) zext_num1 = zeroExtend(num1);
    Bit#(32) zext_num2 = zeroExtend(num2);
    multi.acknowledge();

    if (zext_num1 * zext_num2 != out) begin
        $display("EXPECTED:   %d * %d = %d", zext_num1, zext_num2, zext_num1 * zext_num2);
        $finish(1);
    end

    num1 <= num1 + 2;
    num2 <= num2 + 3;
    stepLoop <= True;
endrule

endmodule 

(* synthesize *)
module mkTestSingleCycleMultiplier();
endmodule 
