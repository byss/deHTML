#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dehtml.h"

static char *tests [][2] = {
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
};

int main () {
	int failed = 0;
	for (int i = 0; i < sizeof (tests) / sizeof (tests [0]); i++) {
		char *source = tests [i][0];
		char *expected = tests [i][1];
		printf ("Testing: '%s' -> '%s': ", source, expected);
		char *result = kb_dehtml_utf8_string (source);
		if (strcmp (result, expected)) {
			printf ("failed (got '%s')\n", result);
			failed = 1;
		} else {
			puts ("OK");
		}
		free (result);
	}
	return failed;
}
