#!/bin/sh -e

usage() {
	echo 'usage: KEY=... SID=... SNIPPET=... update.sh <dir>'
}

if [ ! -d "$1" ]; then
	usage >&2
	exit 1
fi

if [ -z "$KEY" -o -z "$SID" -o -z "$SNIPPET" ]; then
	usage >&2
	exit 1
fi

htdocs="$1"

urlencode() {
	perl -p -e 's/([^[:print:]]|["%\\])/sprintf("%%%02X", ord($1))/seg'
}

vclstr() {
	echo -n '"'
	urlencode
	echo -n '"'
}

kv() {
	echo -n '  '
	echo -n "$1" | vclstr
	echo -n ': '
	cat | vclstr
	echo -n ',\n'
}

(
	echo 'table body {'
	find "$htdocs" -type f \
	| grep -v '^\.' \
	| cut -f2- -d/ \
	| while read -r path; do
		cat "$htdocs/$path" | kv "/$path"
	done
	echo '}'
	echo ''
) \
| curl -X PUT -s https://api.fastly.com/service/$SID/snippet/$SNIPPET \
	-H "Fastly-Key:$KEY" \
	-F 'content=@-'

