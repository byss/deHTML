#import <Foundation/Foundation.h>

#include <time.h>

#import "NSString+deHTML.h"
#import "3rdParty/NSString+HTML.h"

NSString *sourceString = @
	"&lt;tr&gt;"
	"&lt;td&gt;lt&lt;/td&gt;"
	"&lt;td&gt;&amp;lt;&lt;/td&gt;"
	"&lt;td&gt;U+003C (60)&lt;/td&gt;"
	"&lt;td&gt;HTML 2.0&lt;/td&gt;"
	"&lt;td&gt;HTMLspecial&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;&lt;a href=&quot;/wiki/Less-than_sign&quot; title=&quot;Less-than sign&quot;&gt;less-than sign&lt;/a&gt;&lt;/td&gt;"
	"&lt;/tr&gt;"
	"&lt;tr&gt;"
	"&lt;td&gt;gt&lt;/td&gt;"
	"&lt;td&gt;&amp;gt;&lt;/td&gt;"
	"&lt;td&gt;U+003E (62)&lt;/td&gt;"
	"&lt;td&gt;HTML 2.0&lt;/td&gt;"
	"&lt;td&gt;HTMLspecial&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;&lt;a href=&quot;/wiki/Greater-than_sign&quot; title=&quot;Greater-than sign&quot;&gt;greater-than sign&lt;/a&gt;&lt;/td&gt;"
	"&lt;/tr&gt;"
	"&lt;tr&gt;"
	"&lt;td&gt;nbsp&lt;/td&gt;"
	"&lt;td&gt;&lt;span style=&quot;background-color:blue;white-space:pre&quot;&gt;&amp;#160;&lt;/span&gt;&lt;/td&gt;"
	"&lt;td&gt;U+00A0 (160)&lt;/td&gt;"
	"&lt;td&gt;HTML 3.2&lt;/td&gt;"
	"&lt;td&gt;HTMLlat1&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;no-break space &lt;i&gt;(= &lt;a href=&quot;/wiki/Non-breaking_space&quot; title=&quot;Non-breaking space&quot;&gt;non-breaking space&lt;/a&gt;)&lt;/i&gt;&lt;sup id=&quot;cite_ref-spaces_4-0&quot; class=&quot;reference&quot;&gt;&lt;a href=&quot;#cite_note-spaces-4&quot;&gt;&lt;span&gt;[&lt;/span&gt;d&lt;span&gt;]&lt;/span&gt;&lt;/a&gt;&lt;/sup&gt;&lt;/td&gt;"
	"&lt;/tr&gt;"
	"&lt;tr&gt;"
	"&lt;td&gt;iexcl&lt;/td&gt;"
	"&lt;td&gt;&iexcl;&lt;/td&gt;"
	"&lt;td&gt;U+00A1 (161)&lt;/td&gt;"
	"&lt;td&gt;HTML 3.2&lt;/td&gt;"
	"&lt;td&gt;HTMLlat1&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;&lt;a href=&quot;/wiki/Inverted_question_and_exclamation_marks&quot; title=&quot;Inverted question and exclamation marks&quot;&gt;inverted exclamation mark&lt;/a&gt;&lt;/td&gt;"
	"&lt;/tr&gt;"
	"&lt;tr&gt;"
	"&lt;td&gt;cent&lt;/td&gt;"
	"&lt;td&gt;&cent;&lt;/td&gt;"
	"&lt;td&gt;U+00A2 (162)&lt;/td&gt;"
	"&lt;td&gt;HTML 3.2&lt;/td&gt;"
	"&lt;td&gt;HTMLlat1&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;&lt;a href=&quot;/wiki/Cent_(currency)&quot; title=&quot;Cent (currency)&quot;&gt;cent sign&lt;/a&gt;&lt;/td&gt;"
	"&lt;/tr&gt;"
	"&lt;tr&gt;"
	"&lt;td&gt;pound&lt;/td&gt;"
	"&lt;td&gt;&pound;&lt;/td&gt;"
	"&lt;td&gt;U+00A3 (163)&lt;/td&gt;"
	"&lt;td&gt;HTML 3.2&lt;/td&gt;"
	"&lt;td&gt;HTMLlat1&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;&lt;a href=&quot;/wiki/Pound_sign&quot; title=&quot;Pound sign&quot;&gt;pound sign&lt;/a&gt;&lt;/td&gt;"
	"&lt;/tr&gt;"
	"&lt;tr&gt;"
	"&lt;td&gt;curren&lt;/td&gt;"
	"&lt;td&gt;&curren;&lt;/td&gt;"
	"&lt;td&gt;U+00A4 (164)&lt;/td&gt;"
	"&lt;td&gt;HTML 3.2&lt;/td&gt;"
	"&lt;td&gt;HTMLlat1&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;&lt;a href=&quot;/wiki/Currency_(typography)&quot; title=&quot;Currency (typography)&quot;&gt;currency sign&lt;/a&gt;&lt;/td&gt;"
	"&lt;/tr&gt;"
	"&lt;tr&gt;"
	"&lt;td&gt;yen&lt;/td&gt;"
	"&lt;td&gt;&yen;&lt;/td&gt;"
	"&lt;td&gt;U+00A5 (165)&lt;/td&gt;"
	"&lt;td&gt;HTML 3.2&lt;/td&gt;"
	"&lt;td&gt;HTMLlat1&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;&lt;a href=&quot;/wiki/Japanese_yen&quot; title=&quot;Japanese yen&quot;&gt;yen sign&lt;/a&gt; &lt;i&gt;(= &lt;a href=&quot;/wiki/Chinese_yuan&quot; title=&quot;Chinese yuan&quot;&gt;yuan&lt;/a&gt; sign)&lt;/i&gt;&lt;/td&gt;"
	"&lt;/tr&gt;"
	"&lt;tr&gt;"
	"&lt;td&gt;brvbar&lt;/td&gt;"
	"&lt;td&gt;&brvbar;&lt;/td&gt;"
	"&lt;td&gt;U+00A6 (166)&lt;/td&gt;"
	"&lt;td&gt;HTML 3.2&lt;/td&gt;"
	"&lt;td&gt;HTMLlat1&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;broken bar &lt;i&gt;(= broken vertical bar)&lt;/i&gt;&lt;/td&gt;"
	"&lt;/tr&gt;"
	"&lt;tr&gt;"
	"&lt;td&gt;sect&lt;/td&gt;"
	"&lt;td&gt;&sect;&lt;/td&gt;"
	"&lt;td&gt;U+00A7 (167)&lt;/td&gt;"
	"&lt;td&gt;HTML 3.2&lt;/td&gt;"
	"&lt;td&gt;HTMLlat1&lt;/td&gt;"
	"&lt;td&gt;ISOnum&lt;/td&gt;"
	"&lt;td&gt;&lt;a href=&quot;/wiki/Section_sign&quot; title=&quot;Section sign&quot;&gt;section sign&lt;/a&gt;&lt;/td&gt;"
	"&lt;/tr&gt;";

#define REPEATS_COUNT (0x18000)
#define RU_FMT "%ld.%d sec"
#define RU_ARGS(_ru_st) (_ru_st).tv_sec, (_ru_st).tv_usec / 1000

int main (int argc, char const *argv []) {
	@autoreleasepool {
		for (NSUInteger i = 0; i < REPEATS_COUNT; i++) {
#if TEST_MW_TFM
			NSString *other = [sourceString stringByDecodingHTMLEntities];
#endif
#if TEST_KB_TFM
			NSString *other = [sourceString deHTML];
#endif
			other = nil;
		}

		char const *const authorName =
#if TEST_MW_TFM
			"Michael Waterfall's"
#endif
#if TEST_KB_TFM
			"Kirill Bystrov's (this)"
#endif
			"";

		struct rusage usage;
		if (getrusage (RUSAGE_SELF, &usage) < 0) {
			perror ("Cannot get system usage");
			return 0;
		}

		printf ("%s imlpementation resources usage:\n", authorName);

		printf ("  User time:     " RU_FMT "\n", RU_ARGS (usage.ru_utime));
		printf ("  System time:   " RU_FMT "\n", RU_ARGS (usage.ru_stime));
		printf ("  Peak RSS size: %ld kB\n",     usage.ru_maxrss / 1024);

		return 0;
	}
}
