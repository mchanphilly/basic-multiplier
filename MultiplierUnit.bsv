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
    Reg#(Word) a <- mkRegU;
    Reg#(Word) b <- mkRegU;
    Reg#(Word) p <- mkRegU;
    Reg#(Bit#(1)) last_a <- mkRegU;
    Reg#(Bit#(5)) index <- mkRegU;  // only need 0 through 31

    rule work(state == Busy);
        // Booth recoding
        Bit#(33) p_ = signExtend(p);
        Bit#(33) b_ = signExtend(b);
        // This turns into a mux choosing between 3.
        Bit#(33) new_p = case ({a[0], last_a}) matches
            2'b01: {p_ + b_};
            2'b10: {p_ - b_};
            default: {p_};  // to massage compiler
        endcase;
        
        p <= {new_p[32:1]};
        a <= {new_p[0], a[31:1]};
        last_a <= a[0];
        index <= index + 1;

        if (index == 31) state <= Ready;
    endrule

    method Action start(Pair in) if (state == Idle);
        a <= in[0];
        last_a <= 0;
        b <= in[1];
        p <= 0;
        index <= 0;
        state <= Busy;
    endmethod

    method ActionValue#(Pair) result if (state == Ready);
        state <= Idle;
        return unpack({p, a});
    endmethod
endmodule



