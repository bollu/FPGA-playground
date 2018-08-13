package Question;
    // My first design in the cool Bluespec language
    String s = "Hello world";
    (* synthesize *)
    module question(Empty);
    rule say_hello;
        $display(s);
        $finish(0);
    endrule
    endmodule
endpackage
