#!/bin/bash

# this code was provided by sixcooler

# preparation of this script:
# cd ..
# mkdir yacy_rc1
# cd yacy_rc1
# git init
# git remote add origin git://gitorious.org/yacy/rc1.git
# git pull origin master
# cd ../git2feed

# finally call this script (from here) with
# git2feed.sh ../yacy_rc1 .

cd $1
git pull origin master
cd -

gitDir=$1/.git
outDir=$2
declare -i counter
counter=9000
now=`date -R`

feed="<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
  <rss version=\"2.0\">
  <channel>
  <title>YaCy commit-feed</title>
  <description>Git commits to YaCy</description>
  <link>http://www.yacy.net/</link>
  <lastBuildDate>$now</lastBuildDate>
  <pubDate>$now</pubDate>"
feedEnd="</channel></rss>"

if [ ! -d "$gitDir" ] || [ ! -d "$outDir" ]
then
	echo usage: $0 git-directory output-directory
	exit 1
fi

for commit in $( git --git-dir=$gitDir log --pretty=format:%H ); do
	outFile="$outDir/$commit.txt"
	title=`git --git-dir=$gitDir show -s --pretty=format:"%h from %aN" $commit`
	description=`git --git-dir=$gitDir show -s --pretty=format:"%s" $commit`
	author=`git --git-dir=$gitDir show -s --pretty=format:"%aN, %aE" $commit`
	pubDate=`git --git-dir=$gitDir show -s --pretty=format:"%aD" $commit`
	feed+="<item>
		<title>$title</title>
		<description>$description</description>
		<link>$commit.txt</link>
		<author>$author</author>
		<guid>$commit</guid>
		<pubDate>$pubDate</pubDate>
		</item>"
	if [ ! -f "$outFile" ]
	then
		git --git-dir=$gitDir show $commit >"$outFile"
	fi
	let counter-=1
	if [ $counter -lt 1 ]
	then
		feed+="$feedEnd"
		echo $feed >"$outDir/shortlog.xml"
		exit 0
	fi
done
