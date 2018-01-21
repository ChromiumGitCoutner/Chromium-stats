#!/bin/bash

#if [ -z "$1" ]
#    then
#        echo "No email domain."
#        echo "Usage : ./runChromiumGitAnalyzer.sh [email domain] (i.e. ./runChromiumGitAnalyzer.sh @lge.com, @igalia.com)"
#        exit 1
#fi

# Define pathes for this tool and Chromium source.
CHROMIUM_PATH=$HOME/chromium/Chromium/
OUTPUT_PATH=$HOME/github/igalia-chromium-stats/igalia-chromium-contribution-stats/

export IGALIA_EMAIL="@igalia.com"
export GYUYOUNG_LGE_EMAIL="gyuyoung.kim@lge.com"
export DAPE_LGE_EMAIL="jose.dapena@lge.com"

#while :
#do
    # Update Chromium source code.
    start_timestamp=$(date +"%T")
    timestamp=$start_timestamp
    echo "[$timestamp] Start updating  Chromium trunk, please wait..."
    cd $CHROMIUM_PATH
    git pull origin master:master
    git subtree add --prefix=v8-log https://chromium.googlesource.com/v8/v8.git master
    timestamp=$(date +"%T")
    echo "[$timestamp] Finish to update Chromium."

    # Start to analyze commit counts.
    now="$(date +'%Y-%m-%d')"
    timestamp=$(date +"%T")
    echo "[$timestamp] Starting checking foo$1 commits until $now, please wait..."
    git filter-branch -f --commit-filter '
        if echo "$GIT_AUTHOR_EMAIL" | grep -q "$IGALIA_EMAIL\|$GYUYOUNG_LGE_EMAIL\|$DAPE_LGE_EMAIL";
        then
            git commit-tree "$@";
        else
            skip_commit "$@";
        fi' HEAD

    timestamp=$(date +"%T")
    echo "[$timestamp] Finish to find LGE commits."

    git_stats generate -p $CHROMIUM_PATH -o $OUTPUT_PATH

    # Restore master branch
    git reset --hard refs/original/refs/heads/master
    git reset --hard HEAD~1

    # Upload the result to github.
#    cd $OUTPUT_PATH
#    git add .
#    git commit -m "Update the new result by bot"
#    git fetch origin master
#    git rebase origin/master
#    git push origin master:master
    timestamp=$(date +"%T")
    echo "[$timestamp] Finish to upload new result!"
    echo "- StartTime: $start_timestamp"
    echo "- EndTime: $timestamp"
#    sleep 8h
#done

skip_commit() {
    shift;
    while [ -n "$1" ];
    do
        shift;
        map "$1";
        shift;
    done;
}
