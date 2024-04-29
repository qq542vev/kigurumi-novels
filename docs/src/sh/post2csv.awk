#!/usr/bin/awk -f

# @cuktash awk-use cuktash/html/unescape *
# @cuktash awk-use cuktash/html/entity/html4
# @cuktash awk-use cuktash/csv/gen * csv_

BEGIN {
	timezone = "+09:00"
	split("", csv, " ")
}

match($0, /<dt><a name="[1-9][0-9]*">[1-9][0-9]* ?<\/a> 名前：<(font color="#008800"|a href="[^"]*mailto:[^"]*")><b> [^<]* ?<\/b>((<font color="#FF0000">（[0-9A-Za-z.\/]+）<\/font>| ◆[0-9A-Za-z.\/]+)<b> <\/b>)?<\/(font|a)> 投稿日： [0-9]{4}\/[0-9]{2}\/[0-9]{2}\((月|火|水|木|金|土|日)\) [0-9]{2}:[0-9]{2}(:[0-9]{2})?<br><dd>.* ?<br><br>$/) {
	comment = substr($0, RSTART, RLENGTH)
	position = index(comment, "<br><dd>")
	content = substr(comment, position + length("<br><dd>"))
	split(substr(comment, 1, position - 1), array, / ?<\/a> 名前：|<\/(font|a)> 投稿日： /)
	gsub(/ ?<br><br>$|<a [^>]*>|<\/a>/, "", content)
	gsub(/<br>/, "\r\n", content)
	gsub(/<b> | <\/b>/, "", array[2])

	csv[1, 1] = array[1]

	if(match(array[2], /<font color="#FF0000">（[0-9A-Za-z.\/]+）<\/font>/)) {
		csv[1, 2] = substr(array[2], 1, RSTART - 1)
		csv[1, 3] = substr(array[2], RSTART, RLENGTH)

		gsub("（|）", "", csv[1, 3])
	} else if(match(array[2], / ◆[0-9A-Za-z.\/]+/)) {
		csv[1, 2] = substr(array[2], 1, RSTART - 1)
		csv[1, 3] = substr(substr(array[2], RSTART, RLENGTH), length(" ◆") + 1)
	} else {
		csv[1, 2] = array[2]
		csv[1, 3] = ""
	}

	for(i = 1; i <= 3; i++) {
		gsub(/<[a-z]+[^>]*>|<\/[a-z]+>/, "", csv[1, i])
	}

	csv[1, 2] = unescape(csv[1, 2], CUKTASH_cuktash__html_entity_html4)

	gsub(/ /, "", array[3])
	gsub(/\((月|火|水|木|金|土|日)\)/, "T", array[3])
	gsub(/\//, "-", array[3])

	csv[1, 4] = array[3] timezone
	csv[1, 5] = unescape(content, CUKTASH_cuktash__html_entity_html4)

	printf("%s", csv_gen(csv, 1))
}

match($0, /<dt><a name="[1-9][0-9]*">[1-9][0-9]*<\/a> ：<(font color="#008800"|a href="[^"]*mailto:[^"]*")><b>[^<]*<\/b>( ◆[0-9A-Za-z.\/]+<b><\/b>)?<\/(font|a)>：[0-9]{4}\/[0-9]{2}\/[0-9]{2}\((月|火|水|木|金|土|日)\) [0-9]{2}:[0-9]{2}:[0-9]{2} <dd>.* <br><br>$/) {
	comment = substr($0, RSTART, RLENGTH)
	position = index(comment, "<dd>")
	content = substr(comment, position + 4)
	split(substr(comment, 1, position - 1), array, /<\/[a-z]+> ?：/)
	gsub(/^ | <br><br>$|<a [^>]*>|<\/a>/, "", content)
	gsub(/<br>/, "\r\n", content)

	csv[1, 1] = array[1]

	if(match(array[2], / ◆[0-9A-Za-z.\/]+/)) {
		csv[1, 2] = substr(array[2], 1, RSTART - 1)
		csv[1, 3] = substr(substr(array[2], RSTART, RLENGTH), length(" ◆") + 1)
	} else {
		csv[1, 2] = array[2]
		csv[1, 3] = ""
	}

	for(i = 1; i <= 3; i++) {
		gsub(/<[a-z]+[^>]*>|<\/[a-z]+>/, "", csv[1, i])
	}

	csv[1, 2] = unescape(csv[1, 2], CUKTASH_cuktash__html_entity_html4)

	gsub(/ /, "", array[3])
	gsub(/\((月|火|水|木|金|土|日)\)/, "T", array[3])
	gsub(/\//, "-", array[3])

	csv[1, 4] = array[3] timezone
	csv[1, 5] = unescape(content, CUKTASH_cuktash__html_entity_html4)

	printf("%s", csv_gen(csv, 1))
}

$0 ~ /^<dt><a name="[1-9][0-9]{0,3}">[1-9][0-9]{0,3}<\/a> ：<a href="[^"]*mailto:あぼーん"><b>あぼーん<\/b><\/a>：あぼーん <dd> あぼーん <br><br>$/ || $0 ~ /^<dt><a name="[1-9][0-9]{0,3}">[0-9][1-9]{0,3} ?<\/a> 名前：<a href="[^"]*mailto:あぼーん"><b> ?あぼーん ?<\/b><\/a> 投稿日： あぼーん<br><dd>あぼーん <br><br>$/ {
	match($0, /<a name="[1-9][0-9]{0,3}">/)

	number = substr($0, RSTART, RLENGTH)
	gsub(/[^0-9]/, "", number)

	csv[1, 1] = number
	csv[1, 2] = ""
	csv[1, 3] = ""
	csv[1, 4] = ""
	csv[1, 5] = ""

	printf("%s", csv_gen(csv, 1))
}
