import Vector::*;


function Bit#(32) multiplexer32(Bit#(1) sel, Bit#(32) a, Bit#(32) b);
    
	return (sel == 0)?a:b; 

endfunction

function Bit#(32) mkLogicalRightShifter(Bit#(32) operand, Integer shiftamt);
    Bit#(32) shifted = 0;
    // i + shiftedamt = 31
    // i = 31 - shiftedamt
    for(Integer i = 0; i <= 31 - shiftamt; i = i + 1)
    begin
        shifted[i] = operand[i + shiftamt];
    end

    return shifted;
endfunction


function Bit#(32) mkArithmeticRightShifter(Bit#(32) operand, Integer shiftamt);
    Bit#(32) shifted;
    for (Integer i = 0; i <= 31; i = i + 1)
    begin
        shifted[i] = operand[31];
    end
    // i + shiftedamt = 31
    // i = 31 - shiftedamt
    for(Integer i = 0; i <= 31 - shiftamt; i = i + 1)
    begin
        shifted[i] = operand[i + shiftamt];
    end

    return shifted;
endfunction

function Integer powerOfTwo(Integer i);
    return (i == 0) ? 1 : 2 * powerOfTwo(i - 1);
endfunction

// NOTE: this perform a RIGHT SHIFT!
function Bit#(32) logicalBarrelShifter(Bit#(32) operand, Bit#(5) shamt);
    Bit#(32) outs = operand;

    for(Integer shiftbit = 0; shiftbit < 5; shiftbit = shiftbit + 1) 
    begin
        outs = multiplexer32(shamt[shiftbit], outs, 
        mkLogicalRightShifter(outs, powerOfTwo(shiftbit)));
    end
    return outs;
endfunction

function Bit#(32) arithmeticBarrelShifter(Bit#(32) operand, Bit#(5) shamt);
    Bit#(32) outs = operand;

    for(Integer shiftbit = 0; shiftbit < 5; shiftbit = shiftbit + 1) 
    begin
        outs = multiplexer32(shamt[shiftbit], outs, 
        mkArithmeticRightShifter(outs, powerOfTwo(shiftbit)));
    end
    return outs;
endfunction

function Bit#(32) logicalLeftRightBarrelShifter(Bit#(1) shiftLeft, Bit#(32) operand, Bit#(5) shamt);
    // fill your code here
    return 0;
endfunction

