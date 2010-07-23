# -*- encoding: UTF-8 -*-
#
# (The MIT License)
# 
# Copyright (c) 2001-2006 Ryan Davis, Eric Hodel, Zen Spider Software
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'test/unit/assertions'

# Extra assertions for Test::Unit

module Test::Unit::Assertions

  # Captures $stdout and $stderr to StringIO objects and returns them.
  # Restores $stdout and $stderr when done.
  #
  # Usage:
  #   def test_puts
  #     out, err = capture do
  #       puts 'hi'
  #       STDERR.puts 'bye!'
  #     end
  #     assert_equal "hi\n", out.string
  #     assert_equal "bye!\n", err.string
  #   end
  #
  def capture
    require 'stringio'
    orig_stdout = $stdout.dup
    orig_stderr = $stderr.dup
    captured_stdout = StringIO.new
    captured_stderr = StringIO.new
    $stdout = captured_stdout
    $stderr = captured_stderr
    yield
    captured_stdout.rewind
    captured_stderr.rewind
    return captured_stdout.string, captured_stderr.string
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end

end