#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
================================================================================

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

    File         : pipeline_v1r0.sv
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : Script for unit test of fbc testbench

================================================================================
'''

import os
import subprocess
import sys

IRUN = 'irun'

NCFLAGS = ['-nocopyright', '-nolog']

ROOT_DIR = os.path.abspath(os.path.dirname(__file__))

SRC_DIR  = os.path.join(ROOT_DIR, 'src')
SPEC_DIR = os.path.join(ROOT_DIR, 'spec')
TEST_DIR = os.path.join(ROOT_DIR, 'test')

specs = {
  'options': {
    'irun': ['-access', 'r', '-timescale', '1ns/10ps'],
    'files': [os.path.join(SRC_DIR, 'handshake', 'handshake_if.sv')]
  },
  'tb_handshake_v0r0': [
    os.path.join(SRC_DIR, 'handshake', 'handshake_v0r0.sv'),
    os.path.join(SPEC_DIR, 'handshake', 'tb_handshake_v0r0.sv')
  ],
  'tb_handshake_v1r0': [
    os.path.join(SRC_DIR, 'handshake', 'handshake_v1r0.sv'),
    os.path.join(SPEC_DIR, 'handshake', 'tb_handshake_v1r0.sv')
  ],
  'tb_handshake_v1r1': [
    os.path.join(SRC_DIR, 'handshake', 'handshake_v1r1.sv'),
    os.path.join(SPEC_DIR, 'handshake', 'tb_handshake_v1r1.sv')
  ],
  'tb_pipeline_v0r0': [
    os.path.join(SRC_DIR, 'pipeline', 'pipeline_v0r0.sv'),
    os.path.join(SPEC_DIR, 'pipeline', 'tb_pipeline_v0r0.sv')
  ],
  'tb_pipeline_v1r0': [
    os.path.join(SRC_DIR, 'pipeline', 'pipeline_v1r0.sv'),
    os.path.join(SPEC_DIR, 'pipeline', 'tb_pipeline_v1r0.sv')
  ],
  'tb_pipeline_v1r1': [
    os.path.join(SRC_DIR, 'pipeline', 'pipeline_v1r1.sv'),
    os.path.join(SPEC_DIR, 'pipeline', 'tb_pipeline_v1r1.sv')
  ]
}


def main():
  if not os.path.exists(TEST_DIR):
    os.mkdir(TEST_DIR)
  os.chdir(TEST_DIR)

  arguments = ['+verbose', '+waveform']
  for key in specs.keys():
    if key is not 'options':
      irun(specs.get(key), arguments)


def irun(sets, args=[]):
  options = specs['options']['irun'] + specs['options']['files']
  subprocess.call([IRUN] + NCFLAGS + options + sets + args)


if __name__ == '__main__':
  sys.exit(main())
