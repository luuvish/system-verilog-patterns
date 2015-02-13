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

    File         : handshake_v0r0.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : design patterns for handshake v0r0 module

==============================================================================*/

module handshake_v0r0 #(VALUE_BITS = 8) (
  input  wire                    clock,
  input  wire                    reset_n,
  input  wire [VALUE_BITS - 1:0] i_value,
  input  wire                    i_valid,
  output wire                    o_ready,
  output wire [VALUE_BITS - 1:0] o_value,
  output wire                    o_valid,
  input  wire                    i_ready
);

  assign o_ready = i_ready;

  assign o_value = o_valid ? i_value : '0;
  assign o_valid = i_valid & o_ready;

endmodule
