interface LGCD;
    method Action start(int a, int b);
    method int result();
    method Bool busy;
endinterface

module mkLGCD (LGCD);
    /*DO NOT change these registers, remove or add more registers*/
    Reg#(int) x <- mkReg(0);
    Reg#(int) y <- mkReg(0);
    Reg#(Bool) bz <- mkReg(False);

    /*feel FREE to add delete or change the name of the rules*/
    rule swapANDsub ((x > y) && (y != 0));
        x <= y;
        y <= x - y;
    endrule

    rule subtract ((x <= y) && (y != 0));
        y <= y - x;
    endrule

    rule stop (y == 0);
        bz <= False;
	// fill your code here
    endrule

    /*Do not change the signature of the method */
    method Action start(int a, int b); 
        x <= a;
        y <= b;
        bz <= True;
	// fill your code here
    endmethod
    method int result() if (bz == False);
        return x;
    	// fill your code here
    endmethod
    method Bool busy;
        return bz == True;
        // fill your code here
    endmethod

endmodule

