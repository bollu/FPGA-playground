(* synthesize *)
module question(Empty);
function Bit#(1) and1(Bit#(1) a, Bit#(1) b);
    return a & b;
endfunction
function Bit#(1) or1(Bit#(1) a, Bit#(1) b);
    return a | b;
endfunction

function Bit#(1) xor1( Bit#(1) a, Bit#(1) b );
    return a ^ b;
endfunction

function Bit#(1) not1(Bit#(1) a);
    return ~ a;
endfunction

function Bit#(1) sum( Bit#(1) a, Bit#(1) b, Bit#(1) cin );
    return xor1( xor1( a, b ) , cin ) ;
endfunction
function Bit#(1) carry( Bit#(1) a, Bit#(1) b, Bit#(1) cin ) ;
    return or1( and1( a, b ) , and1( xor1( a, b ) , cin ) ) ;
endfunction


function Bit#(5) add4( Bit#(4) a, Bit#(4) b, Bit#(1) cin );
    Bit#(5) carries;
    Bit#(4) sums;
    carries[0] = cin;

    for(Integer i = 0; i < 3; i=i+1) 
    begin
        sums[i] = sum(a[i], b[i], cin[i]);
        carries[i + 1] = carry(a[i], b[i], carries[i]);
    end

    return {carries[4], sums};
endfunction

rule say_hello;
    $display ("hello world");
    $finish(0);
endrule
endmodule
