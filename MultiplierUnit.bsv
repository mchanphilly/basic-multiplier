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
        Bit#(34) p_ = signExtend(p);
        Bit#(34) b_ = signExtend(b);
        Bit#(34) b2_ = signExtend(Bit#(33)'{b, 0});
        // Mux choosing between 5; default is optimized out.
        Bit#(34) new_p = case ({a[1:0], last_a})
            3'b111, 3'b000: {p_};
            3'b001, 3'b010: {p_ + b_};
            3'b101, 3'b110: {p_ - b_};
            3'b011: {p_ + b2_};
            3'b100: {p_ - b2_};
            default: {0};  // never happens
        endcase;
        
        p <= {new_p[33:2]};
        a <= {new_p[1:0], a[31:2]};
        last_a <= a[1];
        index <= index + 2;

        if (index == 30) state <= Ready;  // on last step
    endrule

    method Action start(Pair in) if (state == Idle);
        a <= in[0];
        b <= in[1];
        last_a <= 0;
        p <= 0;
        index <= 0;
        state <= Busy;
    endmethod

    method ActionValue#(Pair) result if (state == Ready);
        state <= Idle;
        return unpack({p, a});
    endmethod
endmodule



