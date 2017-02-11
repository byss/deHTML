//
// NSString+deHTML.h
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

#import "NSString+deHTML.h"

#import "dehtml.h"

@implementation NSString (deHTML)

- (NSString *) deHTML {
	size_t resultLen = 0;
	char *dehtml = kb_dehtml_utf8_string_with_length ([self UTF8String], &resultLen);
	NSString *result = [[NSString alloc] initWithBytesNoCopy:dehtml length:resultLen encoding:NSUTF8StringEncoding freeWhenDone:YES];
	
	if (!result) {
		// From NSString documentation:
		// If an error occurs during the creation of the string, then bytes is not freed
		// even if flag is YES. In this case, the caller is responsible for freeing the buffer.
		free (dehtml);
	}
	return result;
}

@end
