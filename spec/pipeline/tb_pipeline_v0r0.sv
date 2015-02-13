/*==============================================================================

The MIT License (MIT)

Copyright (c) 2015 Luuvish Hwang

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

    File         : tb_pipeline_v0r0.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : testbench for pipeline v0r0 module

==============================================================================*/

module tb_stage_v0r0 #(VALUE_BITS = 8, STATE_BITS = 8) (
  input  wire [STATE_BITS - 1:0] i_state,
  input  wire [VALUE_BITS - 1:0] i_value,
  output wire [STATE_BITS - 1:0] o_state,
  output wire [VALUE_BITS - 1:0] o_value,
  output wire                    o_ready
);

  assign o_state = i_state;
  assign o_value = i_value;
  assign o_ready = 1'b1;
endmodule

module tb_pipeline_v0r0;

  localparam integer CLOCK_RERIOD = 10, // 100Mhz -> 10ns
                     VALUE_BITS = 8,
                     STATE_BITS = 8,
                     MAX_DELAY = 10;

  typedef bit [VALUE_BITS - 1:0] value_t;

  logic clock, reset_n;

  handshake_if #(VALUE_BITS, MAX_DELAY) hif (clock, reset_n);

  pipeline_v0r0 #(VALUE_BITS, STATE_BITS) dut (
    .clock   (hif.clock),
    .reset_n (hif.reset_n),
    .i_value (hif.i_value),
    .i_valid (hif.i_valid),
    .o_ready (hif.o_ready),
    .o_value (hif.o_value),
    .o_valid (hif.o_valid),
    .i_ready (hif.i_ready)
  );

  bind pipeline_v0r0 tb_stage_v0r0 u_stage (
    .i_state (r_state),
    .i_value (i_value),
    .o_state (n_state),
    .o_value (n_value),
    .o_ready (w_ready)
  );

  initial begin
    clock = 1'b0;
    forever #(CLOCK_RERIOD / 2) clock = ~clock;
  end

  initial begin
    automatic mailbox #(value_t) counts = new;

    if ($test$plusargs("waveform")) begin
      $shm_open("waveform");
      $shm_probe("arms");
    end

    hif.reset();
    reset_n = 1'b1;
    hif.ticks(10);
    reset_n = 1'b0;
    hif.ticks(10);
    reset_n = 1'b1;

    fork
      repeat (100) begin
        static value_t count = '0;
        automatic value_t value = ++count;

        counts.put(count);
        hif.valid(value);
      end
      repeat (100) begin
        automatic value_t value, count;
        hif.ready(value);
        counts.get(count);

        if ($test$plusargs("verbose")) begin
          $display("%0dns: o_value -> %0h", $time, value);
        end
        if (value != count) begin
          $display("%0dns: o_value error %0h != %0h", $time, value, count);
          $finish;
        end
      end
    join

    $finish;
  end

endmodule
