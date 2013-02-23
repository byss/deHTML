deHTML
======

Small and extremely fast and consuming much less RAM NSString category, which
allows efficient translation of HTML entities to Unicode. There is some demo
code in this repository as well as primitive benchmark. Below are results of
comparison with a well-known [MWFeedParser's HTML entities parser](https://github.com/mwaterfall/MWFeedParser/tree/master/Classes).

Benchmark
=========

<table>
	<tr>
		<th>Implementation</th>
		<th>User time</th>
		<th>System time</th>
		<th>Peak RSS size (aka RAM consumption)</th>
	</tr>
	<tr>
		<td>Kirill Bystrov's (this)</td>
		<td>2.315 sec</td>
		<td>0.215 sec</td>
		<td>300132 kB</td>
	</tr>
	<tr>
		<td>Michael Waterfall's</td>
		<td>17.701 sec</td>
		<td>1.29 sec</td>
		<td>1198352 kB</td>
	</tr>
</table>

License
=======

This code is distributed under the terms of MIT License. Source code of 3rd party libraries (GTMNSString+HTML and MW's NSString+HTML) are available under the terms of Apache and MIT licenses, respectively.
