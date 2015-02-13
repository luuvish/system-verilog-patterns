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

    File         : pipeline_output.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : design patterns for pipeline output module

==============================================================================*/

module pipeline_output (
  input  wire       clock,
  input  wire       reset_n,
  output reg  [7:0] o_value,
  output reg        o_valid,
  input  wire       i_ready
);

  reg        r_ticks;

  reg  [7:0] r_value;
  reg        r_valid;
  reg        r_ready;
  wire       s_valid;
  wire       s_ready;
  wire       m_valid;
  wire       m_ready;

  always_ff @(posedge clock, negedge reset_n) begin
    if (~reset_n) begin
      r_ticks <= 1'b0;
    end
    else begin
      r_ticks <= $urandom_range(0, 5) ? 1'b0 : 1'b1;
    end
  end

  assign s_valid =  r_valid & r_ready;
  assign s_ready = ~r_valid | r_ready;

  always_ff @(posedge clock, negedge reset_n) begin
    if (~reset_n) begin
      r_ready <= 1'b0;
    end
    else begin
      r_ready <= m_ready;
    end
  end

  always_ff @(posedge clock, negedge reset_n) begin
    if (~reset_n) begin
      r_value <= '0;
      r_valid <= 1'b0;
    end
    else if (s_ready & m_ready) begin
      if (r_ticks) begin
        r_value <= r_value + 1'b1;
      end
      r_valid <= r_ticks;
    end
  end

  assign m_ready = ~o_valid | i_ready;

  always_ff @(posedge clock, negedge reset_n) begin
    if (~reset_n) begin
      o_value <= '0;
      o_valid <= 1'b0;
    end
    else if (m_ready) begin
      if (s_valid) begin
        o_value <= r_value;
      end
      o_valid <= s_valid;
    end
  end

endmodule
