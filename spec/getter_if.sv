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

    File         : getter_if.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : bulk getter interface

==============================================================================*/

interface getter_if #(BITS = 8) (interface i);

  typedef logic [BITS - 1:0] value_t;

  logic [BITS - 1:0] value;
  logic              valid;
  logic              ready;

  assign value = i.master.value;
  assign valid = i.master.valid;
  assign i.master.ready = ready;

  clocking cb @(posedge i.clock);
    input  value, valid;
    output ready;
  endclocking

  task clear ();
    cb.ready <= 1'b0;
  endtask

  task ticks (input int tick);
    repeat (tick) @(cb);
  endtask

  task get (output value_t value);
    cb.ready <= 1'b1;
    @(cb);

    wait (cb.valid == 1'b1);
    value = cb.value;
    cb.ready <= 1'b0;
  endtask

endinterface
