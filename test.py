#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
================================================================================

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

    File         : test.py
    Author(s)    : luuvish (github.com/luuvish/system-verilog-patterns)
    Modifier     : luuvish (luuvish@gmail.com)
    Descriptions : Script for design patterns testbench

================================================================================
'''

import os
import subprocess
import sys

IRUN = 'irun'

NCFLAGS = ['-nocopyright', '-nolog']

ROOT_DIR = os.path.abspath(os.path.dirname(__file__))
SPEC_DIR = os.path.join(ROOT_DIR, 'spec')
TEST_DIR = os.path.join(ROOT_DIR, 'test')

tools = {
  'irun': {
    'options': ['-q', '-f', os.path.join(SPEC_DIR, 'tb_direct_test.f')],
    'files': [],
    'top': None
  }
}

specs = {
  'tb_handshake_direct_test': {
    'top': 'worklib.tb_handshake_direct_test:sv'
  },
  'tb_queue_direct_test': {
    'top': 'worklib.tb_queue_direct_test:sv'
  },
  'tb_pipeline_direct_test': {
    'top': 'worklib.tb_pipeline_direct_test:sv'
  }
}


def main():
  if not os.path.exists(TEST_DIR):
    os.mkdir(TEST_DIR)
  os.chdir(TEST_DIR)

  arguments = ['+verbose', '+waveform']
  for (k, v) in specs.iteritems():
    irun(v, arguments)


def irun(sets, args=[]):
  options = tools['irun']['options']
  files = tools['irun']['files']
  top = ['-top', sets['top']]
  subprocess.call([IRUN] + NCFLAGS + options + args + files + top)


if __name__ == '__main__':
  sys.exit(main())
