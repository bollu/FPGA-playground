package FirstAttempt;
    // My first design in the cool Bluespec language
    String s = "Hello world";
    (* synthesize *)
    module mkAttempt(Empty);
    rule say_hello;
        $display(s);
    endrule
    endmodule
endpackage
