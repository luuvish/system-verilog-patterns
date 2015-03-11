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

    File         : pipeline.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : design patterns for pipeline module

==============================================================================*/

module pipeline #(NUMS = 10, BITS = 8) (
  interface i, o
);

  typedef logic [BITS - 1:0] value_t;

  typedef struct {
    logic [BITS - 1:0] value;
    logic              valid;
    logic              ready;
  } state_t;

  state_t stages [0:NUMS];

  assign stages[0].value = i.master.value;
  assign stages[0].valid = i.master.valid;
  assign i.master.ready = stages[0].ready;

  always_comb begin
    for (int i = NUMS; i >= 1; i--) begin
      stages[i - 1].ready = ~stages[i].valid | stages[i].ready;
    end
  end

  always_ff @(posedge i.clock, negedge i.reset_n) begin
    if (!i.reset_n) begin
      for (int i = 1; i <= NUMS; i++) begin
        stages[i].value <= '0;
        stages[i].valid <= 1'b0;
      end
    end
    else begin
      for (int i = 1; i <= NUMS; i++) begin
        if (stages[i - 1].ready) begin
          if (stages[i - 1].valid) begin
            stages[i].value <= stage(stages[i - 1].value);
          end
          stages[i].valid <= stages[i - 1].valid & stages[i - 1].ready;
        end
      end
    end
  end

  assign o.slave.value = stages[NUMS].value;
  assign o.slave.valid = stages[NUMS].valid;
  assign stages[NUMS].ready = o.slave.ready;

  function automatic value_t stage (input value_t value);
    return value;
  endfunction

endmodule
