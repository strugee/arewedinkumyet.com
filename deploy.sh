#!/bin/sh

./build.sh
if ! test -d .deploy-cache/; then
	git clone --branch gh-pages $(git remote get-url origin) .deploy-cache
	cd .deploy-cache
else
	cd .deploy-cache
	git checkout gh-pages
	git fetch
	git reset --hard origin/gh-pages
fi

rm -rf *
cp ../dist/* .

git add .
git commit -m 'Deploy'
git push
