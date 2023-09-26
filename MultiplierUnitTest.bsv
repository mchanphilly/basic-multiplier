import MultiplierUnit::*;
import Vector::*;
import BRAM::*;

typedef Bit#(10) MaxTestAddress;  // 10 bits for 1024 tests
typedef Vector#(4, Word) TestPacket;

module mkMultiplierUnitTest(Empty);
    let cfg = defaultValue;
    cfg.loadFormat = tagged Hex "test_cases.vmh";

    BRAM1Port#(MaxTestAddress, TestPacket) tests <- mkBRAM1Server(cfg);
    Reg#(MaxTestAddress) test_index <- mkReg(0);

    rule puts;
        test_index <= test_index + 1;
        let request = BRAMRequest{
            write: unpack(0),
            address: test_index
        };
        tests.portA.request.put(request);
    endrule

    rule gets;
        TestPacket current_test <- tests.portA.response.get();
        current_test = reverse(current_test);  // Reverse order because of the way the vmh is written/read
        $display("%x times %x get %x_%x", current_test[0], current_test[1], current_test[2], current_test[3]);

        if (current_test[3] == 'hdeadbeef) $finish;
    endrule

    rule emergency_exit if (test_index > 10000);
        $display("Emergency exit");
        $finish;
    endrule
endmodule