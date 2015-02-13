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

    File         : handshake_if.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : handshake interface

==============================================================================*/

interface handshake_if #(VALUE_BITS = 8, MAX_DELAY = 10) (
  input logic clock, reset_n
);

  typedef logic [VALUE_BITS - 1:0] value_t;

  logic [VALUE_BITS - 1:0] i_value;
  logic                    i_valid;
  logic                    o_ready;
  logic [VALUE_BITS - 1:0] o_value;
  logic                    o_valid;
  logic                    i_ready;

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
  endtask

  task ticks (input int tick);
    repeat (tick) @(cb);
  endtask

  task valid (input value_t value);
    ticks(random());

    cb.i_value <= value;
    cb.i_valid <= 1'b1;
    @(cb);

    wait (cb.o_ready == 1'b1);
    cb.i_value <= '0;
    cb.i_valid <= 1'b0;
  endtask

  task ready (output value_t value);
    ticks(random());

    cb.i_ready <= 1'b1;
    @(cb);

    wait (cb.o_valid == 1'b1);
    value = cb.o_value;
    cb.i_ready <= 1'b0;
  endtask

  function automatic int random ();
    int zero_delay = MAX_DELAY == 0 || $urandom_range(0, 1);
    return zero_delay ? 0 : $urandom_range(1, MAX_DELAY);
  endfunction

endinterface
