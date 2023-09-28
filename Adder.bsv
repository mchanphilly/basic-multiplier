interface Adder#(type t);
    method t add(t a, t b, Bool isSub);
endinterface

module mkAdder(Adder#(t)) provisos (Bits#(t, t_bits), Arith#(t), Bitwise#(t));
    method t add(t a, t b, Bool isSub);
        return (isSub) ? a - b :  a + b ;
    endmethod
endmodule

(* synthesize *)
module mkAdder35(Adder#(Bit#(35)));
    Adder#(Bit#(35)) adder <- mkAdder;
    return adder;
endmodule