#
# Makefile
# deHTML
#
# Created by Kirill byss Bystrov on 06.02.13.
# Copyright (c) 2013 Kirill byss Bystrov. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# This Makefile is not masterpiece but it works.

CFLAGS = -c -Wall -std=c99 -Os
OBJCLDFLAGS = -framework Foundation

CC = clang $(CFLAGS)
LD = clang
MERGEOBJS = ld -r
PY = python

ALL_BENCHMARKS = KB MW
ALL_TESTS = basic $(ALL_BENCHMARKS:%=benchmark-%)

all: dehtml.o

prepare: dehtml.c

dehtml.o: dehtml.c dehtml.h
	$(CC) $(CFLAGS) -o $@ $<

dehtml.c: dehtml.py
	$(PY) $<

test: $(ALL_TESTS:%=test-binary-%)
	$(foreach testBinary,$^,./$(testBinary);)


test-binary-basic: dehtml.o test.o
	$(LD) -liconv -o $@ $^

test.o: test.c
	$(CC) -o $@ $^


test-binary-benchmark-%: test-objc_%.o test-objc-deps_%.o
	$(LD) $(OBJCLDFLAGS) -o $@ $^

test-objc_%.o: test.m
	$(CC) -fobjc-arc -DTEST_$*_TFM=1 -o $@ $^

test-objc-deps_KB.o: dehtml.o NSString+deHTML.o
	$(MERGEOBJS) -o $@ $^

test-objc-deps_MW.o: 3rdParty/GTMNSString+HTML.o 3rdParty/NSString+HTML.o
	$(MERGEOBJS) -o $@ $^


NSString+deHTML.o: NSString+deHTML.m NSString+deHTML.h
	$(CC) -fobjc-arc -o $@ $<

3rdParty/%.o: 3rdParty/%.m
	$(CC) -o $@ $<

clean:
	rm -f *.o 3rdParty/*.o dehtml.c test-binary-*
