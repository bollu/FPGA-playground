import Multiplexer::*;
import BasicGates::*;
// Full adder functions

function Bit#(1) fa_sum( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return xor1( xor1( a, b ), c_in );
endfunction

function Bit#(1) fa_carry( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return or1( and1( a, b ), and1( xor1( a, b ), c_in ) );
endfunction

// 4 Bit full adder
function Bit#(5) add4( Bit#(4) a, Bit#(4) b, Bit#(1) c_in );
    Bit#(5) carries = ?;
    Bit#(4) outs;

    carries[0] = c_in;

    for(Integer i = 0; i < 4; i = i + 1)
    begin
        outs[i] = fa_sum(a[i], b[i], carries[i]);
        carries[i+1] = fa_carry(a[i], b[i], carries[i]);
    end
    return { carries[4], outs };
endfunction

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
