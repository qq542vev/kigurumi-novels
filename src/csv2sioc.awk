#!/usr/bin/awk -f

# @cuktash use-block begin
# @cuktash awk-use cuktash/csv/parse * csv_
# @cuktash awk-use cuktash/xml/sanitize *
# @cuktash awk-use cuktash/xml/gen/elem *
# @cuktash awk-use cuktash/xml/gen/attr *
# @cuktash use-block end

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
