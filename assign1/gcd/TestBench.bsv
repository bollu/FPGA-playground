import gcd::*;

(* synthesize *)
module mkTbGCDSimple();
    Reg#(int) state <-mkReg(0);
    LGCD gcd <- mkLGCD();

    rule go (state == 0);
      gcd.start(423, 142);
      state <= 1;
    endrule

    rule finish (state == 1);
       $display("GCD of 423 and 142 =%d", gcd.result());
       state <= 2;
    endrule
    
    rule exit(state == 2);
       $finish(0);
    endrule
endmodule


(* synthesize *)
module mkTbGCDSeq();
    Reg#(int) state <- mkReg(-1);
    Reg#(Int#(4)) c1 <-mkReg(1);
    Reg#(Int#(7)) c2 <-mkReg(1);
    LGCD gcd <- mkLGCD();

    rule init (state==-1);
	state <= 0;
    endrule

    rule req (state==0);
      $display("gcd.start(%d, %d)", c1, c2);
      gcd.start(signExtend(c1), signExtend(c2));
      state <= 1;
    endrule

    rule resp (c2 < 63 && state==1);
      if (!gcd.busy)
      begin
      $display("gcd.result()= %d", gcd.result());
      //$display ("GCD of %d and %d =%d", c1, c2, gcd.getResult());
      if (c1==7) 
	begin 
	  c1 <= 1; 
	  c2 <= c2 + 1; 
          state <= 0; 
	end 
      else 
 	begin 
	  c1 <= c1 + 1; 
          state <= 0; 
        end
    end
    else
	state <= 2;
    endrule

    rule bounce ( state==2);
        state <= 1;
    endrule

    rule terminate (c2==63 && state == 0);
      //$display("gcd.getResult()= %d", gcd.result());
      $finish(0);
    endrule
endmodule

(* synthesize *)
module mkTbGCDZero();
    Reg#(int) state <- mkReg(0);
    LGCD gcd <-mkLGCD();

    rule step1(state==0);
	$display("gcd.start(0,0)");
	gcd.start(0,0);
	state <= 1;
    endrule    
    rule terminate(state==1);
	$finish(0);
    endrule

endmodule

(* synthesize *)
module mkTbLGCD();
    Reg#(int) state <- mkReg(0);
    LGCD gcd <-mkLGCD();

    rule step1(state==0);
	$display("gcd.start(32,7)");
	gcd.start(32,7);
	state <= 1;
    endrule    

    rule step2(state==1);
	if (gcd.busy)
	    begin
		$display("gcd is busy");
		state <= 3;
	    end		
	else
	    begin
	 	$display("gcd.result()=%d", gcd.result());
		state <= 2;
	    end
    endrule

    rule busy(state==3);
	state <= 1;
    endrule

    rule terminate (state==2);
	$finish(0);
    endrule
endmodule

