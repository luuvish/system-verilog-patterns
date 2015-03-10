#===============================================================================
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Luuvish
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#===============================================================================
#
#   File         : tb_direct_test.f
#   Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
#   Modifier     : luuvish (luuvish@gmail.com)
#   Descriptions : listfile for design patterns testbench without UVM
#
#===============================================================================

-nclibdirname ../test
-reflib ../test/worklib

-sv
-work worklib

-incdir ../src/
../src/handshake_if.sv
../src/queue_if.sv
-incdir ../spec/
../spec/driver_if.sv
../spec/tb_handshake_direct_test.sv
../spec/tb_queue_direct_test.sv

-access +r
-timescale 1ns/10ps
-nospecify
