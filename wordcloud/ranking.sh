#!/bin/bash

cat text.txt | mecab | ruby -e 'while gets; puts $_.split(" ")[0] if /名詞/ end' | sort |uniq -c | sort -r | ruby -e 'while gets; puts $_.split(" ")[0,2].join(",") end' >ranking.csv
