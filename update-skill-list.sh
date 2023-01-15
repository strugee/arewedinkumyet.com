#!/bin/sh

set -eu

check_cmd() {
	if ! type $1 >/dev/null 2>&1; then
		echo $(basename $0): can\'t find $1, bailing out 2>&1
		exit 1
	fi
}

check_cmd jq
check_cmd sponge # From moreutils
check_cmd curl

curl https://market.mycroft.ai/api/skills/available | jq -r '.skills[] | .displayName + "," + .id + ",Unknown,"' > skill-list.csv.new
trap 'rm skill-list.csv.new' EXIT

cut -d, -f2 skill-list.csv.new | while read id; do
	if ! grep -q $id skill-list.csv; then
		grep $id skill-list.csv.new >> skill-list.csv
	fi
done

grep -v '^$' skill-list.csv | sort | sponge skill-list.csv
