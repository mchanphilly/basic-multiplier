import Vector::*;

typedef Bit#(32) Word;
typedef Vector#(2, Word) Pair;

interface MultiplierUnit;
    method Action start(Pair in);
    method ActionValue#(Pair) result;
endinterface

(* synthesize *)
module mkMultiplierUnit(MultiplierUnit);

endmodule



