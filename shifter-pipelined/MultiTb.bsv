package MultiTb;

// testbench for Mult1

import Multiplier::*;
import Multi::*;



Tin notestinputs = 6;

(* synthesize *)
module mkMultiTb (Empty);

   Reg#(int) cycle <- mkReg(0);
   Reg#(Tin) x    <- mkReg(1);
   Reg#(Tin) y    <- mkReg(0);
   
   // The dut
   Multiplier_IFC dut <- mkMulti;
   
   // RULES ----------------
   rule cyclecount;
	$display("------Cycle %0d------", cycle);
	cycle <= cycle + 1;
   endrule 
   
   rule rule_tb_1 (x < notestinputs);
      $display("Rule tb1 fired");
      $display ("Test Input: x = %0d, y = %0d", x, y);
      dut.start (x, y);
      x <= x + 1;
      y <= y + 1;
   endrule
   
   rule rule_tb_2 (x < notestinputs);
      $display("Rule tb2 fired");
      let z = dut.result();
      dut.acknowledge();
      Tout expected = extend (x-1) * extend (y-1);
      $display("    Result = %0d Expected = %0d", z, expected);
      if (z != expected) 
	begin
		$display("Error"); 
		$finish(0);
	end
      $display("-------------------------------");
   endrule

   // TASK: Add a rule to invoke $finish(0) at the appropriate moment
   rule stop (x >= notestinputs);
       $display("\t finish");
       $finish(0);
   endrule
      
   
endmodule : mkMultiTb

endpackage : MultiTb
