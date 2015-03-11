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

    File         : queue_if.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : design patterns for queue interface

==============================================================================*/

interface queue_if #(NUMS = 10, BITS = 8, VALID = 0, READY = 0) (
  input logic clock, reset_n
);

  localparam integer QIDX = $clog2(NUMS);

  logic [BITS - 1:0] q_queue [0:NUMS - 1];
  logic [QIDX - 1:0] q_m_idx;
  logic [QIDX - 1:0] q_s_idx;

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
    input  s_value, s_valid, s_ready,
    input  m_value, m_valid, m_ready
  );

  logic [QIDX - 1:0] q_m_inc;
  logic [QIDX - 1:0] q_s_inc;

  assign q_m_inc = wrap(q_m_idx + (m_valid & m_ready), '0, NUMS);
  assign q_s_inc = wrap(q_s_idx + (s_valid & s_ready), '0, NUMS);

  always_ff @(posedge clock, negedge reset_n) begin
    if (!reset_n) begin
      foreach (q_queue [i]) begin
        q_queue[i] <= '0;
      end
      q_s_idx <= '0;
      q_m_idx <= '0;
    end
    else begin
      if (s_valid & s_ready) begin
        q_queue[q_s_idx] <= s_value;
      end
      q_s_idx <= q_s_inc;
      q_m_idx <= q_m_inc;
    end
  end

  generate
    logic bypass;

    if (VALID == 0 && READY == 0) begin : v0r0
      assign bypass = s_valid & (q_m_idx == q_s_idx);

      assign s_ready = q_m_idx != q_s_idx + 1'b1;

      assign m_value = bypass ? s_value : q_queue[q_m_idx];
      assign m_valid = bypass | (q_m_idx != q_s_idx);
    end

    if (VALID == 1 && READY == 0) begin : v1r0
      assign bypass = s_valid & (q_m_inc == q_s_idx);

      assign s_ready = q_m_idx != q_s_idx + 1'b1;

      always_ff @(posedge clock, negedge reset_n) begin
        if (!reset_n) begin
          m_value <= '0;
          m_valid <= 1'b0;
        end
        else begin
          m_value <= bypass ? s_value : q_queue[q_m_inc];
          m_valid <= q_m_inc != q_s_inc;
        end
      end
    end

    if (VALID == 1 && READY == 1) begin : v1r1
      assign bypass = s_valid & (q_m_inc == q_s_idx);

      always_ff @(posedge clock, negedge reset_n) begin
        if (!reset_n) begin
          s_ready <= 1'b0;
          m_value <= '0;
          m_valid <= 1'b0;
        end
        else begin
          s_ready <= q_m_inc != q_s_inc + 1'b1;
          m_value <= bypass ? s_value : q_queue[q_m_inc];
          m_valid <= q_m_inc != q_s_inc;
        end
      end
    end

  endgenerate

  function automatic integer wrap (integer val, min, max);
    return val < max ? val : min;
  endfunction

endinterface
