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
    rule swapANDsub (/*fill condition here*/);
        // fill your code here
    endrule
    rule subtract (/*fill condition here*/ );
	// fill your code here
    endrule
    rule stop (/*fill condition here*/);
	// fill your code here
    endrule

    /*Do not change the signature of the method */
    method Action start(int a, int b); 
	// fill your code here
    endmethod
    method int result();
    	// fill your code here
    endmethod
    method Bool busy;
        // fill your code here
    endmethod

endmodule

