/*==============================================================================

The MIT License (MIT)

Copyright (c) 2015 Luuvish

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

================================================================================

    File         : tb_handshake_direct_test.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : testbench for handshake interface without UVM

==============================================================================*/

module tb_handshake_direct_test;

  localparam integer CLOCK_PERIOD = 10, // 100Mhz -> 10ns
                     MAX_RANDOM_DELAY = 10;

  localparam integer BITS = 10;

  typedef bit [BITS - 1:0] value_t;

  logic clock, reset_n;

  handshake_if #(BITS, 0, 0) handshake_v0r0 (clock, reset_n);
  handshake_if #(BITS, 1, 0) handshake_v1r0 (clock, reset_n);
  handshake_if #(BITS, 1, 1) handshake_v1r1 (clock, reset_n);

  driver_if #(BITS) driver_v0r0 (handshake_v0r0);
  driver_if #(BITS) driver_v1r0 (handshake_v1r0);
  driver_if #(BITS) driver_v1r1 (handshake_v1r1);

  task automatic reset ();
    driver_v0r0.clear();
    driver_v1r0.clear();
    driver_v1r1.clear();

    reset_n = 1'b1;
    driver_v0r0.ticks(10);
    reset_n = 1'b0;
    driver_v0r0.ticks(10);
    reset_n = 1'b1;
  endtask

  task automatic test (input bit v = 0, r = 0, bit verbose);
    mailbox #(value_t) queue = new;

    if (verbose) begin
      $display("test handshake_if #(VALID=%0d, READY=%0d)", v, r);
    end

    fork
      repeat (100) begin
        value_t org = $urandom_range(0, 100);

        queue.put(org);
        case ({v, r})
          2'b00: driver_v0r0.ticks(random());
          2'b10: driver_v1r0.ticks(random());
          2'b11: driver_v1r1.ticks(random());
        endcase
        case ({v, r})
          2'b00: driver_v0r0.set(org);
          2'b10: driver_v1r0.set(org);
          2'b11: driver_v1r1.set(org);
        endcase
      end
      repeat (100) begin
        value_t val, org;
        case ({v, r})
          2'b00: driver_v0r0.ticks(random());
          2'b10: driver_v1r0.ticks(random());
          2'b11: driver_v1r1.ticks(random());
        endcase
        case ({v, r})
          2'b00: driver_v0r0.get(val);
          2'b10: driver_v1r0.get(val);
          2'b11: driver_v1r1.get(val);
        endcase
        queue.get(org);

        if (verbose) begin
          $display("@%t: o_value -> %0h", $time, val);
        end
        if (val != org) begin
          $display("@%t: o_value error %0h != %0h", $time, val, org);
          $finish;
        end
      end
    join
  endtask

  initial begin
    clock = 1'b0;
    forever #(CLOCK_PERIOD / 2) clock = ~clock;
  end

  initial begin
    automatic bit verbose = $test$plusargs("verbose");
    automatic bit waveform = $test$plusargs("waveform");

    if (waveform) begin
      $shm_open("waveform");
      $shm_probe("arms");
    end
    $timeformat(-9, 2, "ns", 12);

    reset();

    test(0, 0, verbose);
    test(1, 0, verbose);
    test(1, 1, verbose);

    $finish;
  end

  function automatic int random ();
    int zero_delay = MAX_RANDOM_DELAY == 0 || $urandom_range(0, 1);
    return zero_delay ? 0 : $urandom_range(1, MAX_RANDOM_DELAY);
  endfunction

endmodule
