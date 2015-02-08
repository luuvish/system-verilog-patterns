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

    File         : tb_handshake_inout.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : testbench for handshake inout module

==============================================================================*/

`timescale 1ns / 10ps

module tb_handshake_inout;

  localparam integer CLOCK_RERIOD = 10; // 100Mhz -> 10ns

  typedef bit [7:0] value_t;

  logic       clock;
  logic       reset_n;
  logic [7:0] i_value;
  logic       i_valid;
  logic       o_ready;
  logic [7:0] o_value;
  logic       o_valid;
  logic       i_ready;

  handshake_inout dut (.*);

  clocking cb @(posedge clock);
    output i_value, i_valid;
    input  o_ready;
    input  o_value, o_valid;
    output i_ready;
  endclocking

  task reset ();
    cb.i_value <= '0;
    cb.i_valid <= 1'b0;
    cb.i_ready <= 1'b0;

    reset_n = 1'b1;
    repeat (10) @(cb);
    reset_n = 1'b0;
    repeat (10) @(cb);
    reset_n = 1'b1;
  endtask

  task valid (input value_t value);
    repeat (random()) @(cb);

    cb.i_value <= value;
    cb.i_valid <= 1'b1;
    @(cb);

    wait (cb.o_ready == 1'b1);
    cb.i_value <= '0;
    cb.i_valid <= 1'b0;
  endtask

  task ready (output value_t value);
    repeat (random()) @(cb);

    cb.i_ready <= 1'b1;
    @(cb);

    wait (cb.o_valid == 1'b1);
    value = cb.o_value;
    cb.i_ready <= 1'b0;
  endtask

  initial begin
    clock = 1'b0;
    forever #(CLOCK_RERIOD / 2) clock = ~clock;
  end

  initial begin
    automatic mailbox #(value_t) counts = new;

    $shm_open("waveform");
    $shm_probe("arms");

    reset();

    fork
      repeat (100) begin
        static value_t count = '0;
        automatic value_t value = ++count;
        counts.put(count);
        valid(value);
      end
      repeat (100) begin
        automatic value_t value, count;
        ready(value);
        print(value);
        counts.get(count);
        if (value != count) begin
          $display("%0dns: o_value error %0h != %0h", $time, value, count);
          $finish;
        end
      end
    join

    $finish;
  end

  function automatic void print (input value_t value);
    $display("%0dns: o_value -> %0h", $time, value);
  endfunction

  function automatic int random ();
    return $urandom_range(0, 1) ? 0 : $urandom_range(1, 10);
  endfunction

endmodule
