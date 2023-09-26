import Vector::*;
import FIFO::*;

typedef Bit#(32) Word;
typedef Vector#(2, Word) Pair;

interface MultiplierUnit;
    method Action start(Pair in);
    method ActionValue#(Pair) result;
endinterface

typedef enum {
    Idle,
    Busy,
    Ready
} MultiplierState deriving (Bits, Eq, FShow);

(* synthesize *)
module mkMultiplierUnit(MultiplierUnit);
    Reg#(MultiplierState) state <- mkReg(Idle); 
    FIFO#(Pair) last_inputs <- mkFIFO;

    method Action start(Pair in) if (state == Idle);
        last_inputs.enq(in);
        state <= Ready;
    endmethod

    method ActionValue#(Pair) result if (state == Ready);
        last_inputs.deq;
        state <= Idle;
        return last_inputs.first;
    endmethod
endmodule



