import BasicGates::*;

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    let picka = and1(not1(sel), a);
    let pickb = and1(sel, b);

    return or1(picka, pickb);
endfunction

// a0 a2 a3 a2 a3
// b0 b1 b2 v3
function Bit#(4) multiplexer4(Bit#(1) sel, Bit#(4) a, Bit#(4) b);
    Bit#(4) out = ?;

    for(Integer i = 0; i < 4; i = i + 1)
    begin
        out[i] = multiplexer1(sel, a[i], b[i]);
    end

    return out;
endfunction

function Bit#(n) multiplexer_n(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    return 0;
endfunction
