#!/usr/bin/env sh



### Function: CUKTASH_cuktash__str_replace
##
## 
##
## Synopsis:
##
##   > CUKTASH_cuktash__str_replace variable string from [to] [count]
##
## Operands:
##
##   variable - 
##   string   - 
##   from     - 
##   to       - 
##   count    - 

CUKTASH_cuktash__str_replace() {
	if [ '0' -lt "${5:-1}" ]; then
		set -- "${1}" "${2}" "${3}" "${4-}" "${5:--1}" ''

		until [ "${2}" = "${2#*"${3}"}" ] || [ "${5}" -eq '0' ]; do
			set -- "${1}" "${2#*"${3}"}" "${3}" "${4}" "$((${5} - 1))" "${6}${2%%"${3}"*}${4}"
		done

		eval "${1}=\${6}\${2}"
	else
		set -- "${1}" "${2}" "${3}" "${4}" "${5}" ''

		until [ "${2}" = "${2%"${3}"*}" ] || [ "${5}" -eq '0' ]; do
			set -- "${1}" "${2%"${3}"*}" "${3}" "${4}" "$((${5} + 1))" "${4}${2##*"${3}"}${6}"
		done

		eval "${1}=\${2}\${6}"
	fi
}
if command -v -- 'CUKTASH_cuktash__str_replace' >'/dev/null' 2>&1; then alias 'str_replace=CUKTASH_cuktash__str_replace'; fi
case "${CUKTASH_cuktash__str_replace+1}" in 1) readonly str_replace="${CUKTASH_cuktash__str_replace}";; esac

awkScript=$(
	cat <<-'__EOF__'

### Function: CUKTASH_cuktash__sh_escape
##
## 文字列を Shell で安全なものに変換する。
##
## Parameters:
##
##   str_ - 変換を行う文字列。
##
## Returns:
##
##   変換された文字列。

function CUKTASH_cuktash__sh_escape(str_) {
	gsub(/\047+/, "\047\"&\"\047", str_)

	return "\047" str_ "\047"
}

### Function: CUKTASH_cuktash__str_csplit
##
## 
##
## Parameters:
##
##   str_   - 
##   array_ - 
##   count_ - 
##
## Returns:
##
##   

function CUKTASH_cuktash__str_csplit(str_, array_, count_,    len_,n_,sep_) {
	len_ = length(str_)
	n_ = split("", array_, " ")

	if(str_ == "") {
		return n_
	}
	
	if(count_ == "") {
		do {
			sep_ = sep_ "\037"
		} while(index(str_, sep_))

		gsub(/./, sep_ "&", str_)

		return split(substr(str_, length(sep_) + 1), array_, sep_)
	}

	if(0 <= count_) {
		count_ = (count_ < (len_ - 1) ? count_ : (len_ - 1))

		for(; count_ != 0; count_--) {
			array_[++n_] = substr(str_, 1, 1)
			str_ = substr(str_, 2)
		}

		array_[++n_] = str_
	} else {
		count_ = ((count_ * -1) < len_ ? (count_ * -1) : (len_ - 1))

		for(n_++; n_ <= count_; n_++) {
			array_[n_] = substr(str_, 1, 1)
			str_ = substr(str_, 2)
		}

		array_[n_] = str_
	}

	return n_
}

### Function: CUKTASH_cuktash__getline_split
##
## 入力から次のレコードを読み取り、各フィールドに分割する。
##
## Parameters:
##
##   expr_  - 入力を表した式。
##            空文字列の場合、現在のファイルから読み取る。
##            "<" から始まる場合、以後の文字列からファイルを開いて読み取る。
##            "!" から始まる場合、以後の文字列からコマンドを実行し、出力を読み取る。
##            "|" から始まる場合、以後の文字列から読み取る。
##   array_ - フィールドを代入する配列。
##   fs_    - フィールドの区切り文字。
##            未指定の場合、FS を使用する。
##            空文字列の場合、文字ごとに分割する。
##   close_ - 次のレコードが読み取れない場合、入力を閉じる。
##
## Returns:
##
##   入力に対しての getline の返り値。

function CUKTASH_cuktash__getline_split(expr_, array_, fs_, close_,    input_,recode_,status_,n_) {
	fs_ = (fs_ == 0 && fs_ == "" ? FS : fs_)

	if(expr_ == "") {
		status_ = getline recode_
	} else if(index(expr_, "<") == 1) {
		input_ = substr(expr_, 2)
		status_ = (getline recode_ < input_)
	} else if(index(expr_, "!") == 1) {
		input_ = substr(expr_, 2)
		status_ = (input_ | getline recode_)
	} else if(index(expr_, "|") == 1) {
		input_ = "printf \047%s\047 " CUKTASH_cuktash__sh_escape(substr(expr_, 2))
		status_ = (input_ | getline recode_)
	} else {
		return -2
	}

	if(0 < status_) {
		if(fs_ == "") {
			n_ = CUKTASH_cuktash__str_csplit(recode_, array_)
		} else {
			n_ = split(recode_, array_, fs_)
		}

		array_[0] = recode_
	} else {
		n_ = split("", array_, " ")

		if(close_ && expr_ != "") {
			close(input_)
		}
	}

	array_["#"] = n_

	return status_
}

### Function: CUKTASH_cuktash__regex_escape
##
## 
##
## Parameters:
##
##   str_ - 
##
## Returns:
##
##

function CUKTASH_cuktash__regex_escape(str_) {
	gsub(/[\\.*+?{}^$|()\[\]]/, "\\\\&", str_)

	return str_
}

### Function: CUKTASH_cuktash__csv_parse
##
## CSV ファイルを AWK 配列に変換する。
##
## Parameters:
##
##   expr_  - 
##   arrar_ - 
##   sep_   - 
##
## Returns:
##
##    1 - 正常に終了。
##    0 - 入力が CSV ではない。
##   <0 - getline に関するエラー。

function CUKTASH_cuktash__csv_parse(expr_, array_, sep_,    RS_,RSTART_,RLENGTH_,recode_,row_,col_,field_,lastcomma_,status_) {
	split("", array_, " ")
	sep_ = (sep_ == "" ? "," : CUKTASH_cuktash__regex_escape(sep_))
	RS_ = RS
	RS = "\n"
	RSTART_ = RSTART
	RLENGTH_ = RLENGTH
	row_ = 1

	while((status_ = CUKTASH_cuktash__getline_split(expr_, recode_, "\034", 1)) == 1) {
		col_ = 0

		while(recode_[0] != "") {
			if(match(recode_[0], "^(\"([^\"]|\"\")*\"|[^" sep_ "\"]*)(" sep_ "|\r?$)")) {
				array_[row_, ++col_] = ""
			} else if(match(recode_[0], /^["]/)) {
				array_[row_, ++col_] = substr(recode_[0], 2)

				while(1) {
					if((status_ = CUKTASH_cuktash__getline_split(expr_, recode_, "\034", 1)) != 1) {
						RS = RS_
						RSTART = RSTART_
						RLENGTH = RLENGTH_

						return status_
					}

					if(match(recode_[0], "^([^\"]|\"\")*\"(" sep_ "|\r?$)")) {
						break
					}

					gsub(/""/, "\"", recode_[0])

					array_[row_, col_] = array_[row_, col_] "\n" recode_[0]
				}

				array_[row_, col_] = array_[row_, col_] "\n"
			} else {
				RS = RS_
				RSTART = RSTART_
				RLENGTH = RLENGTH_

				return 0
			}

			field_ = substr(recode_[0], RSTART, RLENGTH)
			recode_[0] = substr(recode_[0], RSTART + RLENGTH)
			lastcomma_ = sub(sep_ "$", "", field_) > 0
			sub(/\r$/, "", field_)
			gsub(/^"|"$/, "", field_) && gsub(/""/, "\"", field_)
			array_[row_, col_] = array_[row_, col_] field_
		}

		if(lastcomma_) {
			array_[++col_] = ""
		}

		row_++
	}

	RS = RS_
	RSTART = RSTART_
	RLENGTH = RLENGTH_

	if(status_ < 0) {
		return status_
	}

	return 1
}
function csv_parse(expr_, array_, sep_) { return CUKTASH_cuktash__csv_parse(expr_, array_, sep_); }

### Function: CUKTASH_cuktash__str_sanitize
##
## 文字列内の制御文字を削除する。
##
## Parameters:
##
##   str_   - 文字列。
##   exclude_ 削除しない制御文字。
##
## Returns:
##
##   制御文字が削除された文字列。

function CUKTASH_cuktash__str_sanitize(str_, exclude_,    cc_) {
	cc_ = "\001|\002|\003|\004|\005|\006|\007|\010|\011|\012|\013|\014|\015|\016|\017|\020|\021|\022|\023|\024|\025|\026|\027|\030|\031|\032|\033|\034|\035|\036|\037|\177"

	gsub(".", "|&", exclude_);
	gsub(substr(exclude_, 2), "", cc_);
	gsub(cc_, "", str_)

	return str_
}
function str_sanitize(str_, exclude_) { return CUKTASH_cuktash__str_sanitize(str_, exclude_); }

### Function: CUKTASH_cuktash__xml_escape
##
## 
##
## Parameters:
##
##   str_   - 
##   quote_ - 
##
## Returns:
##
##   

function CUKTASH_cuktash__xml_escape(str_, quote_) {
	quote_ = (quote_ == "" ? 1 : 0)
	
	gsub(/&/, "\\&amp;", str_)

	if(quote_) {
		gsub(/'/, "\\&apos;", str_)
		gsub(/"/, "\\&quot;", str_)
	}

	gsub(/</, "\\&lt;", str_)
	gsub(/>/, "\\&gt;", str_)

	return str_	
}

### Function: CUKTASH_cuktash__xml_sanitize
##
## XML で許可されない ASCII 制御文字を削除する。
##
## Parameters:
##
##   str_ - 対象の文字列。
##
## Returns:
##
##   XML で使用可能な安全な文字列。

function CUKTASH_cuktash__xml_sanitize(str_) {
	return CUKTASH_cuktash__str_sanitize(str_, "\t\n\r\177")	
}

### Function: CUKTASH_cuktash__xml_gen_element
##
## 
##
## Parameters:
##
##   name_    - 
##   att_     - 
##   content_ - 
##   escape_  - 
##
## Returns:
##
##   

function CUKTASH_cuktash__xml_gen_element(name_, att_, content_, escape_) {
	escape_ = (escape_ == "" && escape_ == 0 ? 1 : escape_)

	gsub(/^[\t\r\n ]+|[\t\r\n ]$/, "", att_)

	if(content_ == "") {
		return "<" name_ (att_ == "" ? "" : " " att_) "/>"	
	}

	if(escape_ == 1 || (escape_ == 2 && index(content_, "]]>"))) {
		content_ = CUKTASH_cuktash__xml_escape(CUKTASH_cuktash__xml_sanitize(content_), 0)
	} else if(escape_ == 2) {
		content_ = "<![CDATA[" CUKTASH_cuktash__xml_sanitize(econtent_) "]]>"
	}

	return "<" name_ (att_ == "" ? "" : " " att_) ">" content_ "</" name_ ">"	
}
function element(name_, att_, content_, escape_) { return CUKTASH_cuktash__xml_gen_element(name_, att_, content_, escape_); }

	BEGIN {
		csv_parse("<" ARGV[1], array)

		for(count = 1; (count, 1) in array; count++) {}
		count--

		board = element("dcterms:title", "", ARGV[2])
		board = board element("sioc:num_items", "rdf:datatype=\"&xsd;nonNegativeInteger\"", count)

		if(1 <= count) {
			board = board element("dcterms:created", "rdf:datatype=\"&dcterms;W3CDTF\"", array[1, 4])
			board = board element("sioc:last_item_date", "rdf:datatype=\"&dcterms;W3CDTF\"", array[count, 4])
		}

		printf("%s", element("types:MessageBoard", "rdf:about=\"&board;\"", board, 0))

		for(i = 1; (i, 1) in array; i++) {
			number = array[i, 1]
			name = array[i, 2]
			trip = array[i, 3]
			date = array[i, 4]
			content = array[i, 5]

			post = element("rdfs:label", "rdf:datatype=\"&xsd;positiveInteger\"", number)

			if(name != "" || trip != ""){
				creator = ""

				if(name != "") {
					creator = creator element("foaf:nick", (name == "名無しさん@着ぐるみすと" ? "xml:lang=\"ja\"" : "rdf:datatype=\"&xsd;string\""), str_sanitize(name))
				}

				if(trip != "") {
					creator = creator element("dcterms:identifier", "rdf:datatype=\"&xsd;string\"", trip)
				}

				post = post element("dcterms:creator", "rdf:parseType=\"Resource\"", creator, 0)
			}

			if(date != "") {
				post = post element("sioc:delivered_at", "rdf:datatype=\"&dcterms;W3CDTF\"", date)
				post = post element("sioc:content", "xml:lang=\"ja\"", str_sanitize(content, "\t\n"))

				refs = ""
				while(match(content, />>([1-9][0-9]?[0-9]?|1000)/)) {
					ref_number = substr(content, RSTART + 2, RLENGTH - 2)
					content = substr(content, RSTART + RLENGTH)

					if(!index(refs, "#" ref_number ",") && index(content, "-") != 1) {
						refs = refs "#" ref_number ","
						post = post element("dcterms:relation", "rdf:resource=\"&post;" ref_number "\"")
					}
				}

				post = post element("schema:creativeWorkStatus", "xml:lang=\"en\"", "Published")
			} else {
				post = post element("schema:creativeWorkStatus", "xml:lang=\"en\"", "Deleted")
			}

			post = post element("sioc:has_container", "rdf:resource=\"&board;\"")

			printf("%s", element("types:BoardPost", "rdf:about=\"&post;" number "\"", post, 0))
		}
	}
	__EOF__
)
template=$(
	cat <<-__EOF__
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE rdf:RDF [
		<!ENTITY dcterms "http://purl.org/dc/terms/">
		<!ENTITY xsd "http://www.w3.org/2001/XML_Schema#">
		<!ENTITY board "${3}">
		<!ENTITY post "&board;${4}">
	]>
	<rdf:RDF
		xmlns:dcterms="http://purl.org/dc/terms/"
		xmlns:foaf="http://xmlns.com/foaf/0.1/"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
		xmlns:schema="https://schema.org/"
		xmlns:sioc="http://rdfs.org/sioc/ns#"
		xmlns:types="http://rdfs.org/sioc/types#"
	>
		<foaf:Document rdf:about="">
			<dcterms:modified rdf:datatype="&dcterms;W3CDTF">$(date +%Y-%m-%dT%H:%M:%S+09:00)</dcterms:modified>
			<foaf:primaryTopic rdf:nodeID="&board;"/>
		</foaf:Document>

		<!-- !CONTENT! -->
	</rdf:RDF>
	__EOF__
)

str_replace 'x' "${template}" '<!-- !CONTENT! -->' "$(awk -- "${awkScript}" "${1}" "${2}")"
printf '%s' "${x}" | xmlstarlet fo -t -
