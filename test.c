#include <errno.h>
#include <stdio.h>
#include <iconv.h>
#include <stdlib.h>
#include <string.h>

#include "dehtml.h"

static char const *tests_utf8 [][2] = {
	{"", ""},
	{"a", "a"},
	{"very very long string", "very very long string"},
	{"&gt;", ">"},
	{"a&gt;", "a>"},
	{"&gt", "&gt"},
	{"&&gt;gt", "&>gt"},
	{"&&ads", "&&ads"},
	{"&diams;", "♦"},
	{"&#32;", " "},
	{"&#x20;", " "},
	{"&#x2a0c;", "⨌"},
	{"&#10764;", "⨌"},
	{"&#x1234567890;", "&#x1234567890;"},
	{"&#12345678901112;", "&#12345678901112;"},
	{"A &spades; & to demonstrate; an &invalid; sequence; &Some text; &spades &#8364;", "A ♠ & to demonstrate; an &invalid; sequence; &Some text; &spades €"},
	{"&#x10000;", "𐀀"},
	{"Extended Unicode: &#x10000;", "Extended Unicode: 𐀀"},
};

struct utf16_string {
	kb_unichar *chars;
	size_t length;
	size_t allocated;
};

void utf16_string_init (struct utf16_string *const string, char const *const utf8_source);
int utf16_string_equals (struct utf16_string const *const lhs, struct utf16_string const *const rhs);
char *utf16_string_get_utf8 (struct utf16_string const *const string);
void utf16_string_deinit (struct utf16_string *const string);

int main () {
	int failed = 0;
	for (int i = 0; i < sizeof (tests_utf8) / sizeof (tests_utf8 [0]); i++) {
		char const *source_utf8 = tests_utf8 [i][0];
		char const *expected_utf8 = tests_utf8 [i][1];
		printf("-- '%s' -> '%s' --\n", source_utf8, expected_utf8);
		
		fputs ("Testing UTF-8: ", stdout);
		char *result_utf8 = kb_dehtml_utf8_string (source_utf8);
		if (strcmp (result_utf8, expected_utf8)) {
			printf ("failed (got '%s')\n", result_utf8);
			failed = 1;
		} else {
			puts ("OK");
		}
		free (result_utf8);
		
		fputs ("       UTF-16: ", stdout);
		struct utf16_string source_utf16;
		utf16_string_init (&source_utf16, source_utf8);
		struct utf16_string expected_utf16;
		utf16_string_init (&expected_utf16, expected_utf8);
		
		struct utf16_string result_utf16 = {0};
		result_utf16.chars = kb_dehtml_utf16_string_with_length (source_utf16.chars, source_utf16.length, &result_utf16.length);
		if (utf16_string_equals (&expected_utf16, &result_utf16)) {
			puts ("OK");
		} else {
			char *result_utf8 = utf16_string_get_utf8 (&result_utf16);
			printf ("failed (got %s)\n", result_utf8);
			failed = 1;
			free (result_utf8);
		}
		
		utf16_string_deinit (&source_utf16);
		utf16_string_deinit (&expected_utf16);
		utf16_string_deinit (&result_utf16);
	}
	return failed;
}

union _endianness {
	uint16_t value16;
	uint8_t value8;
};
union _endianness const endianness = { .value16 = 0x0100 };
static char const *const utf16_encodings [] = {
	"utf-16le",
	"utf-16be",
};

void utf16_string_init (struct utf16_string *const string, char const *const utf8_source) {
	size_t utf8_source_size = strlen (utf8_source);
	if (!utf8_source_size) {
		string->chars = NULL;
		string->length = 0;
		string->allocated = 0;
		return;
	}
	
	iconv_t utf8_utf16_cd = iconv_open (utf16_encodings [endianness.value8], "utf-8");
	
	char *utf8_source_copy = strdup (utf8_source);
	char *utf8_source_end = utf8_source_copy;
	
	string->allocated = utf8_source_size * sizeof (kb_unichar);
	string->chars = malloc (string->allocated);
	char *result_end = (char *) string->chars;
	size_t result_size = string->allocated;
	while (utf8_source_size) {
		size_t iconv_res = iconv (utf8_utf16_cd, &utf8_source_end, &utf8_source_size, &result_end, &result_size);
		if (iconv_res == ((size_t) -1)) {
			printf ("iconv failed: %d", errno);
			abort ();
		}
	}
	string->length = ((kb_unichar *) result_end) - string->chars;
	
	free (utf8_source_copy);
	iconv_close (utf8_utf16_cd);
}

int utf16_string_equals (struct utf16_string const *const lhs, struct utf16_string const *const rhs) {
	if (lhs->length != rhs->length) {
		return 0;
	}
	
	return !memcmp (lhs->chars, rhs->chars, lhs->length * sizeof (kb_unichar));
}

char *utf16_string_get_utf8 (struct utf16_string const *const string) {
	iconv_t utf16_utf18_cd = iconv_open ("utf-8", utf16_encodings [endianness.value8]);
	
	char *string_end = (char *) string->chars;
	size_t string_size = string->length * sizeof (kb_unichar);
	size_t result_size = string_size * 3 / 2 + 1;
	char *result = malloc (result_size);
	char *result_end = result;
	while (string_size) {
		size_t iconv_res = iconv (utf16_utf18_cd, &string_end, &string_size, &result_end, &result_size);
		if (iconv_res == ((size_t) -1)) {
			printf ("iconv failed: %d", errno);
			abort ();
		}
	}
	
	*result_end = 0;
	iconv_close (utf16_utf18_cd);
	return result;
}

void utf16_string_deinit (struct utf16_string *const string) {
	if (string->chars) {
		free (string->chars);
		string->chars = NULL;
	}
	string->length = 0;
	string->allocated = 0;
}
