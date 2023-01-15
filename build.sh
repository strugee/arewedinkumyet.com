#!/bin/sh

skill_summary() {
	# Each line here accomplishes roughly one transformation step
	cut -d, -f3 skill-list.csv \
	| tr '[:upper:]' '[:lower:]' \
	| sort | uniq -ic | sed 's/^[[:space:]]*//' \
	| sort -nr \
	| awk 1 ORS=', ' | sed 's/, $//'
}

skill_list() {
	# TODO why did I have to use cat instead of <
	cat skill-list.csv | while read line; do
		skill_name="$(echo $line | cut -d, -f1)"
		skill_id=$(echo $line | cut -d, -f2)
		skill_status="$(echo $line | cut -d, -f3)"
		status_link="$(echo $line | cut -d, -f4)"

		# The `<a href...` sed call removes <a>s if we don't have a link in the CSV
		# ^ was picked for STATUS_LINK because it is illegal in URLs.
		sed -E \
		 -e "s/SKILL_NAME/$skill_name/" \
		 -e "s/SKILL_ID/$skill_id/" \
		 -e "s/SKILL_STATUS/$skill_status/" \
		 -e "s^STATUS_LINK^$status_link^" \
		 -e 's;<a href="">(.*)</a>;\1;' \
		 skill-row.html.fragment
	done
}

mkdir -p dist/
rm -r dist/* 2>/dev/null || true
cp LICENSE CNAME *.css dist/
sed "s/SKILL_SUMMARY/$(skill_summary)/" head.html.fragment > dist/index.html
skill_list >> dist/index.html
cat foot.html.fragment >> dist/index.html
