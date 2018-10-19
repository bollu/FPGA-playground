import Vector::*;
import Randomizable::*;
import Multi::*;
import Multiplier::*;

// A module that is supposed to vary over choices of multiplier, but
// I can't figure out how. What I want is something like this
// (written in haskell syntax)
//
// mkTester :: Multiplier_IFC a => Tester a
//
// If only these guys had used haskell syntax :(
module mkTester;
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