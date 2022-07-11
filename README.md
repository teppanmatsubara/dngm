# DNGM
This repository is for DNGM (danbugmi) service. DNGM is to format two separate paragraphs in two columns.

## Example

Input:
<pre>
I am using Google Workspace tools such as Mail, Calendar, or Spreadsheet in English mode because it seems more inclusive when you share your desktop over a video conference. Zoom is also in English.
||
メールやカレンダー、スプレッドシートなど Google のツールは英語モードで使ってます。ビデオ会議で画面共有する時に Inclusive かなと思って。Zoom も英語モードにしてます。
</pre>

Output:
<pre>
I am using Google Workspace tools		メールやカレンダー、スプレッドシー
such as Mail, Calendar, or Spreadsheet		トなど Google のツールは英語モー
in English mode because it seems		ドで使ってます。ビデオ会議で画面共
more inclusive when you share your		有する時に Inclusive かなと思って。
desktop over a video conference.		Zoom も英語モードにしてます。
Zoom is also in English.
</pre>
