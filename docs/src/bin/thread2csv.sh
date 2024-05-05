#!/usr/bin/env sh

# @cuktash sh-use cuktash/sh/c_locale *

c_locale

nkf -x --ic=EUC-JP-MS --oc=UTF-8 -- "${@}" | awk -f "${0%/*}/thread2csv.awk" -
