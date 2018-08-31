package Multiplier; 

// Multiplier IFC

typedef Bit#(16) Tin;
typedef Bit#(32) Tout;

interface Multiplier_IFC;
    method Action  start (Tin m1, Tin m2);
    method Tout    result();
    method Action acknowledge();
endinterface
        
endpackage
