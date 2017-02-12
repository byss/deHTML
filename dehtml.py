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

def utf8Len (entity):
	return len (unichr (htmlentitydefs.name2codepoint [entity]).encode ('utf-8'))

def utf16Len (entity):
	return len (unichr (htmlentitydefs.name2codepoint [entity]).encode ('utf-16-le')) / 2

maxUTF8 = 0
maxUTF16 = 0
for e in htmlentitydefs.name2codepoint:
	src = len (e) + 2
	dst8 = utf8Len (e)
	if dst8 > maxUTF8:
		maxUTF8 = dst8
	dst16 = utf16Len (e)
	if dst16 > maxUTF16:
		maxUTF16 = dst16

	if (dst8 > src) or (dst16 > src):
		print 'Sorry, you proved my program wrong =('
		sys.exit (-1)
		
maxBytes8Length = 6 * maxUTF8 - 2
maxBytes16Length = 8 * maxUTF16 - 2

try:
	fout = open (OUTPUT, 'wt')
except:
	sys.stderr.write ('Cannot open ' + OUTPUT + '.')
	sys.exit (-2)

fout.write ('''\
#include "dehtml.h"

#include <stdbool.h>

#ifndef KB_DEHTML_UTF16

struct EncodedEntity {{
	char utf8 [{maxUTF8}];
	size_t utf8_size;
	unichar utf16 [{maxUTF16}];
	size_t utf16_size;
}};
'''.format (maxUTF8 = maxUTF8, maxUTF16 = maxUTF16))

entities = sorted (htmlentitydefs.name2codepoint.keys ())

fout.write ('''
static struct EncodedEntity const entities [] = {
''')

for entity in entities:
	value = unichr (htmlentitydefs.name2codepoint [entity])
	bytes8 = ", ".join (['0x' + hex (ord (byte)) [2:].rjust (2, '0') for byte in value.encode ('utf-8')])
	rawBytes16 = value.encode ('utf-16-le')
	unichars = map (lambda t: ord (t [0]) + ord (t [1]) * 0x100, zip (rawBytes16 [::2], rawBytes16 [1::2]))
	bytes16 = ", ".join (['0x' + hex (unichar) [2:].rjust (4, '0') for unichar in unichars])
	fout.write ('''\
	{{ .utf8 = {{{bytes8}}}, .utf8_size = {len8}, .utf16 = {{{bytes16}}}, .utf16_size = {len16} }}, // {entity}
'''.format (bytes8 = bytes8.ljust (maxBytes8Length), len8 = utf8Len (entity), bytes16 = bytes16.ljust (maxBytes16Length), len16 = utf16Len (entity), entity = entity))

fout.write ('''\
};

static __inline__ __attribute__((always_inline)) char *mempcpy_utf8 (char *const restrict dst, char const *const restrict src, size_t const n) {
	memcpy (dst, src, n);
	return (dst + n);
}

static __inline__ __attribute__((always_inline)) unichar *mempcpy_utf16 (unichar *const restrict dst, unichar const *const restrict src, size_t const n) {
	memcpy (dst, src, n * sizeof (unichar));
	return (dst + n);
}

void kb_dehtml_utf8_string_with_length_noalloc (char const *const input, char *const result, size_t *const result_length) {
#	ifdef kb_char
#		undef kb_char
#	endif
#	ifdef kb_zero_terminated
#		undef kb_zero_terminated
#	endif
#	ifdef kb_encoding
#		undef kb_encoding
#	endif
#	ifdef kb_size
#		undef kb_size
#	endif
#	ifdef mempcpy
#		undef mempcpy
#	endif

#	define kb_char char
#	define kb_zero_terminated 1
#	define kb_encoding utf8
#	define kb_size utf8_size
#	define mempcpy mempcpy_utf8
#else
void kb_dehtml_utf16_string_with_length_noalloc (unichar const *const input, size_t const length, unichar *const result, size_t *const result_length) {
#	ifdef kb_char
#		undef kb_char
#	endif
#	ifdef kb_zero_terminated
#		undef kb_zero_terminated
#	endif
#	ifdef kb_encoding
#		undef kb_encoding
#	endif
#	ifdef kb_size
#		undef kb_size
#	endif
#	ifdef mempcpy
#		undef mempcpy
#	endif

#	define kb_char unichar
#	define kb_zero_terminated 0
#	define kb_encoding utf16
#	define kb_size utf16_size
#	define mempcpy mempcpy_utf16
#endif

#if !kb_zero_terminated
	if (!length) {
		*result_length = 0;
		return;
	}
	kb_char const *const inputEnd = input + length;
#endif

	kb_char const *curr = input;
	kb_char const *lastCopied = input;
	kb_char *resultEnd = result;

	do {
#if !kb_zero_terminated
		if (curr == inputEnd) {
			resultEnd = mempcpy (resultEnd, lastCopied, curr - lastCopied);
			break;
		}
#endif
	
		switch (*curr) {
#if kb_zero_terminated
			case 0:
				resultEnd = mempcpy (resultEnd, lastCopied, curr - lastCopied);
				break;
#endif

			case '&': {
				++curr;
				size_t entity = 0;
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
{ts}	resultEnd = mempcpy (resultEnd, lastCopied, curr - lastCopied - 2);
{ts}	lastCopied = curr - 2;
{ts}}}
{ts}entity = {idx};
{ts}sourceLength = {i};
{ts}break;
'''.format (ts = tabs (i), i = i, entity = entity, idx = entities.index (ent)))
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
						kb_char const *numberEnd = curr;
						kb_char digit = *curr;

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
								resultEnd = mempcpy (resultEnd, lastCopied, curr - lastCopied - 2);
							}
							
#if KB_DEHTML_UTF16
							if (entityValue < 0x10000) {
								*resultEnd++ = entityValue;
							} else {
								entityValue = (entityValue >> 16) - 1;
								*resultEnd++ = ((entityValue & 0xffc00) >> 10) + 0xd800;
								*resultEnd++ = (entityValue & 0x1ff) + 0xdc00;
							}
#else
							if (entityValue < 0x80) {
								*resultEnd++ = entityValue;
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
#endif
							curr = lastCopied = numberEnd + 1;
						}
					} break;
				}
				if (entity) {
					resultEnd = mempcpy (resultEnd, lastCopied, curr - lastCopied - 1);
					resultEnd = mempcpy (resultEnd, entities [entity].kb_encoding, entities [entity].kb_size);
					lastCopied = (curr += sourceLength);
				}
				--curr;
			} break;
		}
#if kb_zero_terminated
	} while (*curr++);
	*resultEnd = 0;
#else
		curr++;
	} while (1);
#endif

	if (result_length) {
		*result_length = (resultEnd - result);
	}
}

#ifndef KB_DEHTML_UTF16
#	define KB_DEHTML_UTF16 1
#	include "dehtml.c"
#endif
''')

fout.close ()
