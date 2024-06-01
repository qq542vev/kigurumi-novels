#!/usr/bin/awk -f


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
## ASCII制御文字を削除する。
##
## Parameters:
##
##   str_   - 文字列。
##   exclude_ 削除しないASCII制御文字。
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

### Function: CUKTASH_cuktash__xml_sanitize
##
## XMLで許可されないASCII制御文字を削除する。
##
## Parameters:
##
##   str_ - 対象の文字列。
##
## Returns:
##
##   XMLで使用可能な安全な文字列。

function CUKTASH_cuktash__xml_sanitize(str_) {
	return CUKTASH_cuktash__str_sanitize(str_, "\t\n\r\177")	
}
function sanitize(str_) { return CUKTASH_cuktash__xml_sanitize(str_); }

### Function: CUKTASH_cuktash__xml_gen_cdata
##
## XMLのCDATAセクションを生成する。
##
## Parameters:
##
##   content_ - 内容。
##
## Returns:
##
##   CDATAセクションの文字列。

function CUKTASH_cuktash__xml_gen_cdata(content_) {
	content = CUKTASH_cuktash__xml_sanitize(content_)

	gsub("]]>", "]]]]><![CDATA[>", content_)
	
	return "<![CDATA[" content_ "]]>"	
}

### Function: CUKTASH_cuktash__xml_escape
##
## XMLの特殊文字をエスケープする。
##
## Parameters:
##
##   str_  - エスケープする文字列。
##   type_ - エスケープの方法。
##
## Returns:
##
##   XMLエスケープされた文字列。

function CUKTASH_cuktash__xml_escape(str_, type_) {
	type_ = (type_ == "" && type_ == 0 ? 1 : 0)
	
	gsub(/&/, "\\&amp;", str_)
	gsub(/</, "\\&lt;", str_)

	if(type_ == "cdata") {
		gsub(/>/, "\\&gt;", str_)
		gsub(/'/, "\\&apos;", str_)
		gsub(/"/, "\\&quot;", str_)
		gsub(/\t/, "\\&#x9;", str_)
		gsub(/\n/, "\\&#xA;", str_)
		gsub(/\r/, "\\&#xD;", str_)
	} else if(type_ == "element") {
		gsub(/]]>/, "]]\\&gt;", str_)
	} else if(type_ == "attribute") {
		gsub(/'/, "\\&apos;", str_)
		gsub(/"/, "\\&quot;", str_)
	} else if(type_ == "single") {
		gsub(/'/, "\\&apos;", str_)
	} else if(type_ == "double") {
		gsub(/"/, "\\&quot;", str_)
	} else if(type_) {
		gsub(/>/, "\\&gt;", str_)
		gsub(/'/, "\\&apos;", str_)
		gsub(/"/, "\\&quot;", str_)
	}

	return str_	
}

### Function: CUKTASH_cuktash__xml_gen_elem
##
## XMLの要素を生成する。
##
## Parameters:
##
##   name_    - 要素名。
##   attr_    - 属性の文字列。
##   content_ - 要素の内容。
##   esc_     - 要素の内容についてのエスケープの種類。
##
## Returns:
##
##   要素の文字列。

function CUKTASH_cuktash__xml_gen_elem(name_, attr_, content_, esc_) {
	esc_ = (esc_ == "" && esc_ == 0 ? 1 : esc_)

	gsub(/^[\t\r\n ]+|[\t\r\n ]$/, "", attr_)

	if(content_ == "") {
		return "<" name_ (attr_ == "" ? "" : " " attr_) "/>"	
	}

	if(esc_ == "cdata") {
		content_ = CUKTASH_cuktash__xml_gen_cdata(content_)
	} else if(esc_ == "minimal") {
		content_ = CUKTASH_cuktash__xml_escape(CUKTASH_cuktash__xml_sanitize(content_), "element")
	} else if(esc_) {
		content_ = CUKTASH_cuktash__xml_escape(CUKTASH_cuktash__xml_sanitize(content_))
	}

	return "<" name_ (attr_ == "" ? "" : " " attr_) ">" content_ "</" name_ ">"	
}
function elem(name_, attr_, content_, esc_) { return CUKTASH_cuktash__xml_gen_elem(name_, attr_, content_, esc_); }

### Function: CUKTASH_cuktash__xml_gen_attr
##
## XMLの属性を生成する。
##
## Parameters:
##
##   name1_ - 属性名1。
##   val1_  - 属性値1。
##   esc1_  - 属性値1のエスケープの有無。
##   name2_ - 属性名2。
##   val2_  - 属性値2。
##   esc2_  - 属性値2のエスケープの有無。
##   name3_ - 属性名3。
##   val3_  - 属性値3。
##   esc3_  - 属性値3のエスケープの有無。
##   name4_ - 属性名4。
##   val4_  - 属性値4。
##   esc4_  - 属性値4のエスケープの有無。
##   name5_ - 属性名5。
##   val5_  - 属性値5。
##   esc5_  - 属性値5のエスケープの有無。
##   name6_ - 属性名6。
##   val6_  - 属性値6。
##   esc6_  - 属性値6のエスケープの有無。
##   name7_ - 属性名7。
##   val7_  - 属性値7。
##   esc7_  - 属性値7のエスケープの有無。
##   name8_ - 属性名8。
##   val8_  - 属性値8。
##   esc8_  - 属性値8のエスケープの有無。
##
## Returns:
##
##   属性文字列。

function CUKTASH_cuktash__xml_gen_attr(name1_, val1_, esc1_, name2_, val2_, esc2_, name3_, val3_, esc3_, name4_, val4_, esc4_, name5_, val5_, esc5_, name6_, val6_, esc6_, name7_, val7_, esc7_, name8_, val8_, esc8_,    ret_,attrs_,i_) {
	ret_ = ""
	split("", attrs_, " ")
	attrs_["name#1"] = name1_; attrs_["val#1"] = val1_; attrs_["esc#1"] = esc1_
	attrs_["name#2"] = name2_; attrs_["val#2"] = val2_; attrs_["esc#2"] = esc2_
	attrs_["name#3"] = name3_; attrs_["val#3"] = val3_; attrs_["esc#3"] = esc3_
	attrs_["name#4"] = name4_; attrs_["val#4"] = val4_; attrs_["esc#4"] = esc4_
	attrs_["name#5"] = name5_; attrs_["val#5"] = val5_; attrs_["esc#5"] = esc5_
	attrs_["name#6"] = name6_; attrs_["val#6"] = val6_; attrs_["esc#6"] = esc6_
	attrs_["name#7"] = name7_; attrs_["val#7"] = val7_; attrs_["esc#7"] = esc7_
	attrs_["name#8"] = name8_; attrs_["val#8"] = val8_; attrs_["esc#8"] = esc8_

	for(i_ = 1; i_ <= 8; i_++) {
		if(attrs_["name#" i_] == "") {
			break
		}

		attrs_["val#" i_] = CUKTASH_cuktash__xml_sanitize(attrs_["val#" i_])

		if(attrs_["esc#" i_] == "single") {
			ret_ = ret_ " " attrs_["name#" i_] "='" CUKTASH_cuktash__xml_escape(attrs_["val#" i_], "single") "'"
		} else if(attrs_["esc#" i_] ~ /^(cdata|double)$/) {
			ret_ = ret_ " " attrs_["name#" i_] "=\"" CUKTASH_cuktash__xml_escape(attrs_["val#" i_], attrs_["esc#" i_]) "\""
		} else if(attrs_["esc#" i_] || (attrs_["esc#" i_] == 0 && attrs_["esc#" i_] == "")) {
			ret_ = ret_ " " attrs_["name#" i_] "=\"" CUKTASH_cuktash__xml_escape(attrs_["val#" i_]) "\""
		} else {
			ret_ = ret_ " " attrs_["name#" i_] "=\"" attrs_["val#" i_] "\""
		}
	}
	
	return ret_
}
function attr(name1_, val1_, esc1_, name2_, val2_, esc2_, name3_, val3_, esc3_, name4_, val4_, esc4_, name5_, val5_, esc5_, name6_, val6_, esc6_, name7_, val7_, esc7_, name8_, val8_, esc8_) { return CUKTASH_cuktash__xml_gen_attr(name1_, val1_, esc1_, name2_, val2_, esc2_, name3_, val3_, esc3_, name4_, val4_, esc4_, name5_, val5_, esc5_, name6_, val6_, esc6_, name7_, val7_, esc7_, name8_, val8_, esc8_); }

BEGIN {
	csv_parse("<" ARGV[1], array)

	for(count = 1; (count, 1) in array; count++) {}
	count--

	board = elem("dcterms:title", "", ARGV[2])
	board = board elem("sioc:num_items", attr("rdf:datatype", "&xsd;nonNegativeInteger", 0), count)

	if(1 <= count) {
		board = board elem("dcterms:created", attr("rdf:datatype", "&dcterms;W3CDTF", 0), array[1, 4])
		board = board elem("sioc:last_item_date", attr("rdf:datatype", "&dcterms;W3CDTF", 0), array[count, 4])
	}

	printf("%s", elem("types:MessageBoard", attr("rdf:about", "&board;", 0), board, 0))

	for(i = 1; (i, 1) in array; i++) {
		number = array[i, 1]
		name = array[i, 2]
		trip = array[i, 3]
		date = array[i, 4]
		content = array[i, 5]

		post = elem("rdfs:label", attr("rdf:datatype", "&xsd;positiveInteger", 0), number)

		if(name != "" || trip != ""){
			creator = ""

			if(name != "") {
				creator = creator elem("foaf:nick", (name == "名無しさん@着ぐるみすと" ? attr("xml:lang", "ja") : attr("rdf:datatype", "&xsd;string", 0)), sanitize(name))
			}

			if(trip != "") {
				creator = creator elem("dcterms:identifier", attr("rdf:datatype", "&xsd;string", 0), trip)
			}

			post = post elem("dcterms:creator", attr("rdf:parseType", "Resource"), creator, 0)
		}

		if(date != "") {
			post = post elem("sioc:delivered_at", attr("rdf:datatype", "&dcterms;W3CDTF", 0), date)
			post = post elem("sioc:content", attr("xml:lang", "ja"), sanitize(content))

			refs = ""
			while(match(content, />>([1-9][0-9]?[0-9]?|1000)/)) {
				ref_number = substr(content, RSTART + 2, RLENGTH - 2)
				content = substr(content, RSTART + RLENGTH)

				if(!index(refs, "#" ref_number ",") && index(content, "-") != 1) {
					refs = refs "#" ref_number ","
					post = post elem("dcterms:relation", attr("rdf:resource", "&post;" ref_number, 0))
				}
			}

			post = post elem("schema:creativeWorkStatus", attr("xml:lang", "en"), "Published")
		} else {
			post = post elem("schema:creativeWorkStatus", attr("xml:lang", "en"), "Deleted")
		}

		post = post elem("sioc:has_container", attr("rdf:resource", "&board;", 0))

		printf("%s", elem("types:BoardPost", attr("rdf:about", "&post;" number, 0), post, 0))
	}
}
