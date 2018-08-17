import Vector::*;


function Bit#(32) multiplexer32(Bit#(1) sel, Bit#(32) a, Bit#(32) b);
    
	return (sel == 0)?a:b; 

endfunction

function Bit#(32) mkPowerOfTwoRightShifter(Bit#(32) operand, Integer poweroftwo);
    Bit#(32) shifted;
    for (Integer i = 31; i > 31 - poweroftwo+1; i = i - 1) 
    begin
        shifted[i] = 0;
    end

    for(Integer i = 31 - poweroftwo; i >= 0; i = i - 1) 
    begin
        shifted[i] = operand[poweroftwo + i];
    end

    return shifted;
endfunction

function Bit#(32) logicalBarrelShifter(Bit#(32) operand, Bit#(5) shamt);
    Bit#(32) outs = operand;
    //return operand >> shamt;

    for(Integer shiftbit = 0; shiftbit < 5; shiftbit = shiftbit + 1) 
    begin
        outs = multiplexer32(shamt[shiftbit], outs, outs >> (1 << shiftbit));
    end
    return outs;
endfunction

function Bit#(32) arithmeticBarrelShifter(Bit#(32) operand, Bit#(5) shamt);
    // fill your code here 
    return 0;
endfunction

function Bit#(32) logicalLeftRightBarrelShifter(Bit#(1) shiftLeft, Bit#(32) operand, Bit#(5) shamt);
    // fill your code here
    return 0;
endfunction

