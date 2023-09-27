interface Adder#(type t);
    method t add(t a, t b);
endinterface

module mkAdder(Adder#(t)) provisos (Bits#(t, t_bits), Arith#(t));
    method add(t a, t b) = a + b;
endmodule

(* synthesize *)
module mkAdder35(Adder#(Bit#(35)));
    Adder#(Bit#(35)) adder <- mkAdder;
    return adder;
endmodule