#!/bin/bash

# Define pathes for this tool and Chromium source.
GIT_COUNTER_PATH=$HOME/github/Chromium-stats
CHROMIUM_PATH=$HOME/chromium-stats/chromium
GIT_INSPECTOR_PATH=$HOME/github/gitinspector
INDEX_ORG_PATH=$HOME/chromium-stats/log
 START_DATE="2017-01-01"
export PATH=$GIT_INSPECTOR_PATH:$PATH

while :
do
    # Update Chromium source code.
    timestamp=$(date +"%T")
    echo "[$timestamp] Start updating  Chromium trunk, please wait..."
    cd $CHROMIUM_PATH
    git pull origin master:master
    git gc --auto
    timestamp=$(date +"%T")
    echo "[$timestamp] Finish to update Chromium."

    # Start to analyze LGE commit counts.
    now="$(date +'%Y-%m-%d')"
    timestamp=$(date +"%T")
    echo "[$timestamp] Starting checking foo@igalia.com and some foo@lge.com commits from $START_DATE to $now, please wait..."
    gitinspector.py --format=html --file-types=** --hard=false --since="$START_DATE" --until="$now" -T -x "email:^(?!([a-zA-Z0-9._-]+@igalia.com|gyuyoung.kim@lge.com|jose.dapena@lge.com))" $CHROMIUM_PATH > $INDEX_ORG_PATH/index-org.html
    cp $INDEX_ORG_PATH/index-org.html $GIT_COUNTER_PATH/index.html

    # Upload the result to github.
    cd $GIT_COUNTER_PATH
    git add index.html
    git commit -m "Update index.html by bot"
    git fetch origin master
    git rebase origin/master
    git push origin master:master
    timestamp=$(date +"%T")
    echo "[$timestamp] Finish to upload new index.html!"
    timestamp=$(date +"%T")
done
