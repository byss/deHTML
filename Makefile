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

CC=clang -c -Wall
LD=clang
PY=python

CFLAGS=-std=c99 -Os
OBJCFLAGS=-framework Foundation $(CFLAGS)
OBJCLFLAGS=-framework Foundation

all: dehtml.o

prepare: dehtml.c

dehtml.o: dehtml.h dehtml.c
	$(CC) $(CFLAGS) -o dehtml.o dehtml.c

dehtml.c: dehtml.py
	$(PY) dehtml.py

test: test-binary objc-test-binary-kb objc-test-binary-mw
	./test-binary
	./objc-test-binary-kb
	./objc-test-binary-mw

test-binary: dehtml.o test.o
	$(LD) -o test-binary dehtml.o test.o

test.o: test.c
	$(CC) $(CFLAGS) -o test.o test.c

objc-test-binary: dehtml.o NSString+deHTML.o objc-test.o 3rdParty/GTMNSString+HTML.o 3rdParty/NSString+HTML.o
	$(LD) $(OBJCLFLAGS) -o objc-test-binary dehtml.o NSString+deHTML.o objc-test.o 3rdParty/GTMNSString+HTML.o 3rdParty/NSString+HTML.o

objc-test-binary-mw: dehtml.o NSString+deHTML.o objc-test-mw.o 3rdParty/GTMNSString+HTML.o 3rdParty/NSString+HTML.o
	$(LD) $(OBJCLFLAGS) -o objc-test-binary-mw dehtml.o NSString+deHTML.o objc-test-mw.o 3rdParty/GTMNSString+HTML.o 3rdParty/NSString+HTML.o

objc-test-binary-kb: dehtml.o NSString+deHTML.o objc-test-kb.o 3rdParty/GTMNSString+HTML.o 3rdParty/NSString+HTML.o
	$(LD) $(OBJCLFLAGS) -o objc-test-binary-kb dehtml.o NSString+deHTML.o objc-test-kb.o 3rdParty/GTMNSString+HTML.o 3rdParty/NSString+HTML.o

NSString+deHTML.o: NSString+deHTML.m NSString+deHTML.h
	$(CC) $(OBJCFLAGS) -o NSString+deHTML.o NSString+deHTML.m

objc-test-kb.o: test.m
	$(CC) $(OBJCFLAGS) -DOBJC_TEST_USES_KB_HTML=1 -o objc-test-kb.o test.m

objc-test-mw.o: test.m
	$(CC) $(OBJCFLAGS) -DOBJC_TEST_USES_MW_HTML=1 -o objc-test-mw.o test.m

3rdParty/GTMNSString+HTML.o: 3rdParty/GTMNSString+HTML.m
	$(CC) $(OBJCFLAGS) -o 3rdParty/GTMNSString+HTML.o 3rdParty/GTMNSString+HTML.m

3rdParty/NSString+HTML.o: 3rdParty/NSString+HTML.m
	$(CC) $(OBJCFLAGS) -o 3rdParty/NSString+HTML.o 3rdParty/NSString+HTML.m

clean:
	rm -f *.o 3rdParty/*.o dehtml.c test-binary objc-test-binary-*
