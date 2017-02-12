//
// dehtml.h
// deHTML
//
// Created by Kirill byss Bystrov on 23.02.13.
// Copyright (c) 2013 Kirill byss Bystrov. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#ifndef KB_DEHTML_H
#define KB_DEHTML_H 1

#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif
	
typedef uint16_t kb_unichar;
	
void kb_dehtml_utf16_string_with_length_noalloc (kb_unichar const *const input, size_t const input_length, kb_unichar *const result, size_t *const result_length);
	
static __inline__ __attribute__((always_inline)) kb_unichar *kb_dehtml_utf16_string_with_length (kb_unichar const *const input, size_t const input_length, size_t *const result_length) {
	if (input_length) {
		kb_unichar *result = malloc (input_length * sizeof (kb_unichar));
		kb_dehtml_utf16_string_with_length_noalloc (input, input_length, result, result_length);
		return result;
	} else {
		*result_length = 0;
		return NULL;
	}
}

void kb_dehtml_utf8_string_with_length_noalloc (char const *const input, char *const result, size_t *const result_length);
	
static __inline__ __attribute__((always_inline)) char *kb_dehtml_utf8_string_with_length (char const *const input, size_t *const result_length) {
	char *result = malloc (strlen (input) + 1);
	kb_dehtml_utf8_string_with_length_noalloc (input, result, result_length);
	return result;
}

static __inline__ __attribute__((always_inline)) char *kb_dehtml_utf8_string (char const *const input) {
	return kb_dehtml_utf8_string_with_length (input, NULL);
}
	
#ifdef __cplusplus
}
#endif

#endif // KB_DEHTML_H
