import Vector::*;
import FIFO::*;
import Adder::*;

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
    Reg#(Bit#(35)) b3_ <- mkRegU;
    Reg#(Word) p <- mkRegU;
    Reg#(Bit#(1)) last_a <- mkRegU;
    Reg#(Bit#(5)) index <- mkRegU;  // only need 0 through 31
    Adder#(Bit#(35)) adder <- mkAdder35;
    // Constants
    Bit#(35) b_ = signExtend(b);
    Bit#(35) b2_ = signExtend({b, 1'b0});  // compiler expands lone 0
    Bit#(35) b4_ = signExtend({b, 2'b0});
    Bit#(35) p_ = signExtend(p);

    rule work(state == Busy);
        // Booth recoding
        // Mux choosing between 9; default is optimized out.
        // {magnitude (0 through 4), sign (bit)}
        Bit#(35) operand = case ({a[2:0], last_a})
            4'b100_0:           b4_;
            4'b101_0, 4'b100_1: b3_;     
            4'b110_0, 4'b101_1: b2_;     
            4'b111_0, 4'b110_1: b_;     
            4'b000_0, 4'b111_1: 0;
            4'b001_0, 4'b000_1: b_;    
            4'b010_0, 4'b001_1: b2_;     
            4'b011_0, 4'b010_1: b3_;     
            4'b011_1:           b4_;
        endcase;

        Bool is_add = case ({a[2:0], last_a})
            4'b100_0, 4'b101_0, 4'b100_1,
            4'b110_0, 4'b101_1, 4'b111_0,
            4'b110_1, 4'b000_0, 4'b111_1: False;
            4'b001_0, 4'b000_1, 4'b010_0,
            4'b001_1, 4'b011_0, 4'b010_1,
            4'b011_1:                     True;
        endcase;

        let new_p = (is_add) ? adder.add(p_, operand) :
                               adder.sub(p_, operand);

        p <= {new_p[34:3]};
        a <= {new_p[2:0], a[31:3]};
        last_a <= a[2];
        index <= index + 3;

        if (index == 27) state <= Ready;  // on last step
    endrule

    method Action start(Pair in) if (state == Idle);
        a <= in[0];
        b <= in[1];
        let op1 = signExtend(in[1]);
        let op2 = {signExtend(in[1]), 1'b0};
        b3_ <= adder.add(op1, op2);
        last_a <= 0;
        p <= 0;
        index <= 0;
        state <= Busy;
    endmethod

    method ActionValue#(Pair) result if (state == Ready);
        state <= Idle;
        
        Bit#(35) operand = case ({a[1:0], last_a})
            3'b111, 3'b000: {0};
            3'b001, 3'b010: {b_};
            3'b101, 3'b110: {- b_};
            3'b011: {b2_};
            3'b100: {- b2_};
            default: {0};  // never happens
        endcase;
        let new_p = adder.add(p_, operand);

        let p_ = {new_p[33:2]};
        let a_ = {new_p[1:0], a[31:2]};

        return unpack({p_, a_});
    endmethod
endmodule



