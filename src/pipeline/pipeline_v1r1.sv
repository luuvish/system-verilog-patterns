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

    File         : pipeline_v1r1.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : design patterns for pipeline v1r1 module

==============================================================================*/

module pipeline_v1r1 #(VALUE_BITS = 8, STATE_BITS = 8) (
  input  wire                    clock,
  input  wire                    reset_n,
  input  wire [VALUE_BITS - 1:0] i_value,
  input  wire                    i_valid,
  output reg                     o_ready,
  output reg  [VALUE_BITS - 1:0] o_value,
  output reg                     o_valid,
  input  wire                    i_ready
);

  reg  [STATE_BITS - 1:0] r_state;
  reg  [STATE_BITS - 1:0] n_state;
  wire [VALUE_BITS - 1:0] w_value;
  reg  [VALUE_BITS - 1:0] n_value;
  reg                     w_ready;

  reg  [VALUE_BITS - 1:0] r_value;
  reg                     r_valid;
  reg                     r_ready;
  wire                    s_valid;
  wire                    s_ready;
  wire                    m_valid;
  wire                    m_ready;

  assign w_value = r_valid ? r_value : i_value;
  assign w_valid = r_valid | s_valid;

//always_comb begin
//  stage(r_state, w_value, n_state, n_value, w_ready);
//end

  always_ff @(posedge clock, negedge reset_n) begin
    if (~reset_n) begin
      r_state <= '0;
    end
    else if (w_valid & m_ready) begin
      r_state <= n_state;
    end
  end

  assign s_valid =  i_valid & o_ready;
  assign s_ready = ~m_valid | i_ready;

  always_ff @(posedge clock, negedge reset_n) begin
    if (~reset_n) begin
      o_ready <= 1'b0;
    end
    else begin
      o_ready <= s_ready;
    end
  end

  always_ff @(posedge clock, negedge reset_n) begin
    if (~reset_n) begin
      r_value <= '0;
      r_valid <= 1'b0;
    end
    else if (o_ready | i_ready) begin
      if (s_valid & ~m_ready) begin
        r_value <= i_value;
      end
      r_valid <= s_valid & ~m_ready;
    end
  end

  assign m_valid =   r_valid | o_valid;
  assign m_ready = (~o_valid | i_ready) & w_ready;

  always_ff @(posedge clock, negedge reset_n) begin
    if (~reset_n) begin
      o_value <= '0;
      o_valid <= 1'b0;
    end
    else if (m_ready) begin
      if (r_valid | s_valid) begin
        o_value <= r_valid ? r_value : i_value;
      end
      o_valid <= r_valid | s_valid;
    end
  end

  task stage (
    input  logic [STATE_BITS - 1:0] i_state,
    input  logic [VALUE_BITS - 1:0] i_value,
    output logic [STATE_BITS - 1:0] o_state,
    output logic [VALUE_BITS - 1:0] o_value,
    output logic                    o_ready
  );
  endtask

endmodule
