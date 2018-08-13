import BarrelShifter::*;
import FIFOF::*;
import LFSR::*;

(* synthesize *)
module mkTestLogicalBarrelShifter();
    Reg#(Bit#(16))  counter <- mkReg(0);
    LFSR#(Bit#(32)) lfsr <- mkLFSR_32(); 
   
    rule testShifter;

        lfsr.next();

        Bit#(5) shamt = truncate(lfsr.value);
        Bit#(32) logicalValue = lfsr.value;

        Bit#(32) logicalExpected =  logicalValue >> shamt;

        Bit#(32) logicalDUT = logicalBarrelShifter(logicalValue, shamt);

        if(logicalExpected != logicalDUT)
        begin
	    $display("Shifter test failed:\n Input:    %b\n arithmetic shifted right by %d\n Expected: %b\n DUT:      %b\n", lfsr.value, shamt, logicalExpected, logicalDUT);	
            $finish;
        end
   
        if(counter + 1 == 0) 
        begin
            $display("PASSED LOGICAL");
            $finish;
        end
        counter <= counter + 1;

    endrule

endmodule

(* synthesize *)
module mkTestArithmeticBarrelShifter();
    Reg#(Bit#(16))  counter <- mkReg(0);
    LFSR#(Bit#(32)) lfsr <- mkLFSR_32(); 
   
    rule testShifter;

        lfsr.next();

        Bit#(5) shamt = truncate(lfsr.value);
        Int#(32) arithmeticValue = unpack(lfsr.value);
        Bit#(32) arithmeticExpected = pack( arithmeticValue >> shamt);
        Bit#(32) arithmeticDUT = arithmeticBarrelShifter(lfsr.value, shamt);

        if(arithmeticExpected != arithmeticDUT)
        begin
            $display("Shifter test failed:\n Input:    %b\n arithmetic shifted right by %d\n Expected: %b\n DUT:      %b\n", lfsr.value, shamt, arithmeticExpected, arithmeticDUT);	
            $finish;
        end
   
        if(counter + 1 == 0) 
        begin
            $display("PASSED ARITHMETIC");
            $finish;
        end
        counter <= counter + 1;

    endrule

endmodule



(* synthesize *)
module mkTestLogicalLeftBarrelShifter();
    Reg#(Bit#(16))  counter <- mkReg(0);
    LFSR#(Bit#(32)) lfsr <- mkLFSR_32(); 
   
    rule testShifter;

        lfsr.next();

        Bit#(5) shamt = truncate(lfsr.value);
        Int#(32) arithmeticValue = unpack(lfsr.value);
        Bit#(32) logicalValue = lfsr.value;

        Bit#(32) logicalExpected =  logicalValue >> shamt;

        Bit#(32) logicalDUT = logicalLeftRightBarrelShifter(0, logicalValue, shamt);

        Bit#(32) logicalLeftExpected =  logicalValue << shamt;

        Bit#(32) logicalLeftDUT = logicalLeftRightBarrelShifter(1, logicalValue, shamt);


        if(logicalExpected != logicalDUT || logicalLeftExpected != logicalLeftDUT)
        begin
            $display("Shifter test failed:\n Input:    %b\n logical shifted right by %d\n Expected: %b\n DUT:      %b\n logical shifted left by %d\n Expected: %b\n DUT:      %b", lfsr.value, shamt, logicalExpected, logicalDUT, shamt, logicalLeftExpected, logicalLeftDUT);            	    
	    $finish;
        end
   
        if(counter + 1 == 0) 
        begin
            $display("PASSED LEFT AND RIGHT");
            $finish;
        end
        counter <= counter + 1;

    endrule

endmodule



