import MultiplierUnit::*;
import Vector::*;
import BRAM::*;
import FIFO::*;

typedef Bit#(10) MaxTestAddress;  // 10 bits for 1024 tests
typedef Vector#(4, Word) TestPacket;

module mkMultiplierUnitTest(Empty);
    let cfg = defaultValue;
    cfg.loadFormat = tagged Hex "test_cases.vmh";
    MultiplierUnit dut <- mkMultiplierUnit;

    BRAM1Port#(MaxTestAddress, TestPacket) tests <- mkBRAM1Server(cfg);
    Reg#(MaxTestAddress) request_index <- mkReg(0);
    FIFO#(Pair) expected <- mkFIFO;
    Reg#(Word) cycles <- mkReg(0);
    Reg#(Word) last_solved <- mkReg(0);

    function Action conclude;
        action
        $display("Ended at %0d cycles after solving the %0d test", cycles, last_solved);
        $finish;
        endaction
    endfunction

    rule tick;
        cycles <= cycles + 1;
    endrule

    // This rule keeps us requesting
    rule puts;
        request_index <= request_index + 1;
        let request = BRAMRequest{
            write: unpack(0),
            address: request_index
        };
        tests.portA.request.put(request);
    endrule

    // This rule 
    rule question;
        TestPacket current_test <- tests.portA.response.get();
        current_test = reverse(current_test);  // Reverse order because of the way the vmh is written/read
        
        // $display("%x times %x get %x%x",
        //     current_test[0],
        //     current_test[1],
        //     current_test[2],
        //     current_test[3]);

        Pair operands = unpack({current_test[0], current_test[1]});
        Pair results = unpack({current_test[2], current_test[3]});

        dut.start(operands);  // Reverse order because of the way things are stored
        expected.enq(results);

        if (current_test[3] == 'hdeadbeef) begin
            $display("deadbeef detected; finishing at %0d cycles", cycles);
            conclude;
        end
    endrule

    rule answer;
        Pair result <- dut.result;
        last_solved <= last_solved + 1;
        if (result != expected.first) begin
            $display("Result was %x but expected %x", result, expected.first);
            conclude;
        end
        expected.deq;
    endrule

    rule terminate if (cycles > 'hFFFF);
        $display("Emergency exit");
        $finish;
    endrule
endmodule