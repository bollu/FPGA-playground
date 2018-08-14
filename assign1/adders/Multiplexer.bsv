import BasicGates::*;

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    let picka = and1(not1(sel), a);
    let pickb = and1(sel, b);

    return or1(picka, pickb);
endfunction

function Bit#(4) multiplexer4(Bit#(1) sel, Bit#(4) a, Bit#(4) b);
    return 0;
endfunction

function Bit#(n) multiplexer_n(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    return 0;
endfunction
