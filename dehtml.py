#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# dehtml.py
# deHTML
#
# Created by Kirill byss Bystrov on 23.02.13.
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

import sys
import htmlentitydefs

OUTPUT = 'dehtml.c'

##################################################################################################################################################

def tabs (i):
	return '\t' * (i * 2 + 4)

def utfLen (entity):
	return len (unichr (htmlentitydefs.name2codepoint [entity]).encode ('utf-8'))

maxUTF = 0
for e in htmlentitydefs.name2codepoint:
	src = len (e) + 2
	dst = utfLen (e)
	if dst > maxUTF:
		maxUTF = dst

	if dst >= src:
		print 'Sorry, you proved my program wrong =('
		sys.exit (-1)
maxBytesLength = 6 * maxUTF - 2

try:
	fout = open (OUTPUT, 'wt')
except:
	sys.stderr.write ('Cannot open ' + OUTPUT + '.')
	sys.exit (-2)

fout.write ('''\
#include "dehtml.h"

#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
''')

entities = sorted (htmlentitydefs.name2codepoint.keys ())

fout.write ('''
static char entities [][{maxUTF}] = {{
'''.format (maxUTF = maxUTF))
for entity in entities:
	bytes = ", ".join (['0x' + hex (ord (byte)) [2:].rjust (2, '0') for byte in unichr (htmlentitydefs.name2codepoint [entity]).encode ('utf-8')])
	fout.write ('''\
	{{{bytes}}}, // {entity}
'''.format (bytes = bytes.ljust (maxBytesLength), entity = entity))
fout.write ('''\
};

char *kb_dehtml_utf8_string (char const *const input) {
	size_t length = strlen (input);
	char const *curr = input;
	char const *lastCopied = input;

	char *result = malloc ((length + 1) * sizeof (char));
	char *resultEnd = result;

	do {
		switch (*curr) {
			case 0:
				resultEnd = stpncpy (resultEnd, lastCopied, curr - lastCopied);
				break;

			case '&': {
				++curr;
				size_t entity = 0;
				size_t entityLength = 0;
				size_t sourceLength = 0;

				switch (curr [0]) {
''')

common = ''
nesting = 0
for ent in entities:
	entity = ent + ';'
	newNesting = 0
	for i in xrange (len (common)):
		if entity [:i] == common [:i]:
			newNesting = i

	if newNesting > nesting:
		for i in xrange (nesting, newNesting):
			fout.write ('''\
{ts}case '{c}':
'''.format (ts = tabs (i), i = i, c = common [i]))
	else:
		for i in xrange (nesting - 1, newNesting, -1):
			fout.write ('''\
{ts}	default:
{ts}		curr += {i};
{ts}}}
{ts}break;
'''.format (ts = tabs (i), i = i))

	nesting = newNesting

	for i in xrange (nesting, len (entity)):
		if i != nesting:
			fout.write ('''\
{ts}switch (curr [{i}]) {{
'''.format (ts = tabs (i), i = i))
		fout.write ('''\
{ts}	case '{c}':
'''.format (ts = tabs (i), i = i, c = entity [i]))

	i = len (entity)
	fout.write ('''\
{ts}// "&{entity}"
{ts}if (lastCopied < curr - 2) {{
{ts}	resultEnd = stpncpy (resultEnd, lastCopied, curr - lastCopied - 2);
{ts}	lastCopied = curr - 2;
{ts}}}
{ts}entity = {idx};
{ts}entityLength = {length};
{ts}sourceLength = {i};
{ts}break;
'''.format (ts = tabs (i), i = i, entity = entity, idx = entities.index (ent), length = utfLen (ent)))

	nesting = len (entity)
	common = entity

for i in xrange (nesting - 1, 0, -1):
	fout.write ('''\
{ts}	default:
{ts}		curr += {i};
{ts}}}
{ts}break;
'''.format (ts = tabs (i), i = i))

fout.write ('''\
					case '#': {
						++curr;

						bool parsingHex = false;
						bool entityValid = false;
						long entityValue = 0;
						char const *numberEnd = curr;
						char digit = *curr;

						if ((digit == 'x') || (digit == 'X')) {
							numberEnd = ++curr;
							parsingHex = true;
						}

						while ((digit = *numberEnd)) {
							if (numberEnd - curr > (parsingHex ? 8 : 10)) {
								break;
							}

							if (digit == ';') {
								entityValid = true;
								break;
							}

							if (parsingHex) {
								entityValue <<= 4;
							} else {
								entityValue *= 10;
							}
							if (('0' <= digit) && (digit <= '9')) {
								entityValue += (digit - '0');
							} else if (parsingHex && ('a' <= digit) && (digit <= 'f')) {
								entityValue += (digit - 'a' + 10);
							} else if (parsingHex && ('A' <= digit) && (digit <= 'F')) {
								entityValue += (digit - 'A' + 10);
							} else {
								break;
							}
							numberEnd++;
						}

						if (entityValid) {
							if (parsingHex) {
								--curr;
							}
							if (lastCopied < curr - 2) {
								resultEnd = stpncpy (resultEnd, lastCopied, curr - lastCopied - 2);
							}
							if (entityValue < 0x80) {
								*resultEnd++ = entityValue & 0x7f;
							} else {
								if (entityValue < 0x800) {
									*resultEnd++ = 0xc0 | ((entityValue & 0x7c0) >> 6);
								} else {
									if (entityValue < 0x10000) {
										*resultEnd++ = 0xe0 | ((entityValue & 0xf000) >> 12);
									} else {
										if (entityValue < 0x200000) {
											*resultEnd++ = 0xf0 | ((entityValue & 0x1c0000) >> 18);
										} else {
											if (entityValue < 0x4000000) {
												*resultEnd++ = 0xf8 | ((entityValue & 0x3000000) >> 24);
											} else {
												if (entityValue < 0x80000000) {
													*resultEnd++ = 0xfc | ((entityValue & 0x40000000) >> 30);
													*resultEnd++ = 0x80 | ((entityValue & 0x3f000000) >> 24);
												}
												*resultEnd++ = 0x80 | ((entityValue & 0xfc0000) >> 18);
											}
										}
										*resultEnd++ = 0x80 | ((entityValue & 0x3f000) >> 12);
									}
									*resultEnd++ = 0x80 | ((entityValue & 0xfc0) >> 6);
								}
								*resultEnd++ = 0x80 |  (entityValue & 0x3f);
							}
							*resultEnd = 0;
							curr = lastCopied = numberEnd + 1;
						}
					} break;
				}
				if (entityLength) {
					resultEnd = stpncpy (resultEnd, lastCopied, curr - lastCopied - 1);
					resultEnd = stpncpy (resultEnd, entities [entity], entityLength);
					lastCopied = (curr += sourceLength);
				}
				--curr;
			} break;
		}
	} while (*curr++);

	*resultEnd = 0;
	return result;
}
''')

fout.close ()
