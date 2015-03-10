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

    File         : handshake_if.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : design patterns for handshake interface

==============================================================================*/

interface handshake_if #(BITS = 8, VALID = 0, READY = 0) (
  input logic clock, reset_n
);

  logic [BITS - 1:0] m_value;
  logic              m_valid;
  logic              m_ready;

  logic [BITS - 1:0] s_value;
  logic              s_valid;
  logic              s_ready;

  modport master (
    output .value(m_value),
    output .valid(m_valid),
    input  .ready(m_ready)
  );

  modport slave (
    input  .value(s_value),
    input  .valid(s_valid),
    output .ready(s_ready)
  );

  modport probe (
    input  m_value, m_valid, m_ready,
    input  s_value, s_valid, s_ready
  );

  generate

    if (VALID == 0 && READY == 0) begin : v0r0
      assign s_ready = m_ready;

      assign m_value = s_valid ? s_value : '0;
      assign m_valid = s_valid & m_ready;
    end

    if (VALID == 1 && READY == 0) begin : v1r0
      assign s_ready = ~m_valid | m_ready;

      always_ff @(posedge clock, negedge reset_n) begin
        if (!reset_n) begin
          m_value <= '0;
          m_valid <= 1'b0;
        end
        else if (s_ready) begin
          if (s_valid) begin
            m_value <= s_value;
          end
          m_valid <= s_valid;
        end
      end
    end

    if (VALID == 1 && READY == 1) begin : v1r1
      struct {
        logic [BITS - 1:0] value;
        logic              valid;
        logic              ready;
      } t, q, r, l;

      assign t.value =  s_value;
      assign t.valid =  s_valid & s_ready;
      assign t.ready = ~r.ready | m_ready;

      always_ff @(posedge clock, negedge reset_n) begin
        if (!reset_n) begin
          s_ready <= 1'b0;
        end
        else begin
          s_ready <= t.ready;
        end
      end

      assign q.value = t.value;
      assign q.valid = t.valid & ~l.ready;
      assign q.ready = s_ready |  m_ready;

      always_ff @(posedge clock, negedge reset_n) begin
        if (!reset_n) begin
          r.value <= '0;
          r.valid <= 1'b0;
        end
        else if (q.ready) begin
          if (q.valid) begin
            r.value <= q.value;
          end
          r.valid <= q.valid;
        end
      end

      assign r.ready = r.valid | m_valid;

      assign l.value =  r.valid ? r.value : t.value;
      assign l.valid =  r.valid | t.valid;
      assign l.ready = ~m_valid | m_ready;

      always_ff @(posedge clock, negedge reset_n) begin
        if (!reset_n) begin
          m_value <= '0;
          m_valid <= 1'b0;
        end
        else if (l.ready) begin
          if (l.valid) begin
            m_value <= l.value;
          end
          m_valid <= l.valid;
        end
      end
    end

  endgenerate

endinterface
