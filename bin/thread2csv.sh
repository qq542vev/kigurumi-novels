#!/usr/bin/env sh


### Function: CUKTASH_cuktash__sh_var_append
##
## 
##
## Synopsis:
##
##   > CUKTASH_cuktash__sh_var_prepend variable string [separator]
##
## Operands:
##
##   variable  - 
##   string    - 
##   separator - 

CUKTASH_cuktash__sh_var_append() {
	eval "${1}=\"\${${1}-}\${${1}:+\"\${3-}\"}\${2}\""
}

### Function: CUKTASH_cuktash__sh_c_locale
##
## ロケールをC(POSIXロケール)に変更する。
##
## Synopsis:
##
##   > CUKTASH_cuktash__sh_c_locale [var] [locale_var]...
##
## Operands:
##
##   var - 変更前の値を代入する変数。
##   locale_var - ロケール変数。

CUKTASH_cuktash__sh_c_locale() {
	case "${#}" in
		'0') set -- '' 'LC_ALL';;
		'1') set -- "${1}" 'LC_ALL';;
	esac

	case "${1}" in
		'' | '^'* | *'$') ;;
		*) eval "${1}=''"
	esac

	while [ '2' -le "${#}" ]; do
		case "${1}" in
			'-')
				eval printf "%s='%s'" '"${2}"' "\"\${${2}-}\""
				case "${#}" in
					'2') printf '\n';;
					*) printf ' ';;
				esac
				;;
			'^'?*) eval "${1#^}${2}=\"\${${2}-}\"";;
			*?'$') eval "${2}${1%%$}=\"\${${2}-}\"";;
			?*) eval CUKTASH_cuktash__sh_var_append '"${1}"' "\"${2}=\${${2}-}\"" '" "';;
		esac

		export "${2}=C"

		eval "shift 2; set -- '${1}'" '"${@}"'
	done
}
if command -v -- 'CUKTASH_cuktash__sh_c_locale' >'/dev/null' 2>&1; then alias 'c_locale=CUKTASH_cuktash__sh_c_locale'; fi
case "${CUKTASH_cuktash__sh_c_locale+1}" in 1) readonly c_locale="${CUKTASH_cuktash__sh_c_locale}";; esac

c_locale

nkf -x --ic=EUC-JP-MS --oc=UTF-8 -- "${@}" | awk -f "${0%/*}/thread2csv.awk" -
