import Multiplexer::*;
import BasicGates::*;
// Full adder functions


// 8 Bit ripple carry adder
function Bit#(9) add8( Bit#(8) a, Bit#(8) b, Bit#(1) c_in );

    let firstout = add4(a[3:0], b[3:0], c_in);

    let secondout = add4(a[7:4], b[7:4], firstout[4]);
    
    return { secondout , firstout[3:0] };
endfunction

// 8 Bit carry select adder
function Bit#(9) cs_add8( Bit#(8) a, Bit#(8) b, Bit#(1) c_in );
    Bit#(5) firstout = add4(a[3:0], b[3:0], c_in);

    Bit#(5) spec0 = add4(a[7:4], b[7: 4], 0);
    Bit#(5) spec1 = add4(a[7:4], b[7: 4], 1);

    return { multiplexer_n(firstout[4], spec0, spec1), firstout[3:0] };
endfunction
