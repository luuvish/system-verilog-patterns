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

    File         : drive_if.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : bulk driver interface

==============================================================================*/

interface driver_if #(BITS = 8) (interface io);

  typedef logic [BITS - 1:0] value_t;

  logic [BITS - 1:0] m_value;
  logic              m_valid;
  logic              m_ready;

  logic [BITS - 1:0] s_value;
  logic              s_valid;
  logic              s_ready;

  assign io.slave.value = m_value;
  assign io.slave.valid = m_valid;
  assign m_ready = io.slave.ready;

  assign s_value = io.master.value;
  assign s_valid = io.master.valid;
  assign io.master.ready = s_ready;

  clocking m_cb @(posedge io.clock);
    output m_value, m_valid;
    input  m_ready;
  endclocking

  clocking s_cb @(posedge io.clock);
    input  s_value, s_valid;
    output s_ready;
  endclocking

  task clear ();
    m_cb.m_value <= '0;
    m_cb.m_valid <= 1'b0;
    s_cb.s_ready <= 1'b0;
  endtask

  task ticks (input int tick);
    repeat (tick) @(m_cb);
  endtask

  task valid (input value_t value);
    m_cb.m_value <= value;
    m_cb.m_valid <= 1'b1;
    @(m_cb);

    wait (m_cb.m_ready == 1'b1);
    m_cb.m_value <= '0;
    m_cb.m_valid <= 1'b0;
  endtask

  task ready (output value_t value);
    s_cb.s_ready <= 1'b1;
    @(s_cb);

    wait (s_cb.s_valid == 1'b1);
    value = s_cb.s_value;
    s_cb.s_ready <= 1'b0;
  endtask

endinterface
