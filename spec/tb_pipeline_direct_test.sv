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

    File         : tb_pipeline_direct_test.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : testbench for pipeline module without UVM

==============================================================================*/

module tb_pipeline_direct_test;

  localparam integer CLOCK_PERIOD = 10, // 100Mhz -> 10ns
                     MAX_RANDOM_DELAY = 10;

  localparam integer NUMS = 20, BITS = 10;

  typedef bit [BITS - 1:0] value_t;

  logic clock, reset_n;

  handshake_if #(BITS, 0, 0) pi (clock, reset_n);
  handshake_if #(BITS, 0, 0) po (clock, reset_n);

  setter_if #(BITS) setter (pi);
  getter_if #(BITS) getter (po);

  pipeline #(NUMS, BITS) pipeline (.i(pi), .o(po));

  task automatic reset ();
    setter.clear();
    getter.clear();

    reset_n = 1'b1;
    setter.ticks(10);
    reset_n = 1'b0;
    setter.ticks(10);
    reset_n = 1'b1;
  endtask

  task automatic test (input bit verbose);
    mailbox #(value_t) queue = new;

    if (verbose) begin
      $display("test pipeline");
    end

    fork
      repeat (100) begin
        value_t org = $urandom_range(0, 100);

        queue.put(org);
        setter.ticks(random());
        setter.set(org);
      end
      repeat (100) begin
        value_t val, org;
        getter.ticks(random());
        getter.get(val);
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

    test(verbose);

    $finish;
  end

  function automatic int random ();
    int zero_delay = MAX_RANDOM_DELAY == 0 || $urandom_range(0, 1);
    return zero_delay ? 0 : $urandom_range(1, MAX_RANDOM_DELAY);
  endfunction

endmodule
