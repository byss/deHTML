deHTML
======

Small and extremely fast and consuming much less RAM NSString category, which
allows efficient translation of HTML entities to Unicode. There is some demo
code in this repository as well as primitive benchmark. Below are results of
comparison with a well-known [MWFeedParser's HTML entities parser](https://github.com/mwaterfall/MWFeedParser/tree/master/Classes).

Benchmark
=========

Implementation | User time | System time | Peak RSS size (aka RAM consumption)
---------------|-----------|-------------|------------------------------------
Kirill Bystrov's (this) | 1.117 sec | 0.222 sec | 751444 kB
Michael Waterfall's | 20.138 sec | 0.604 sec | 1256740 kB

License
=======

This code is distributed under the terms of MIT License. Source code of 3rd party libraries (GTMNSString+HTML and MW's NSString+HTML) are available under the terms of Apache and MIT licenses, respectively.
