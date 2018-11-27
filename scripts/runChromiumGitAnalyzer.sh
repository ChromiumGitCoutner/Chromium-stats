#!/bin/bash -x

# environment #######################################################

[ -z ${CHROMIUM_PATH} ] && CHROMIUM_PATH=${HOME}/chromium-stats/chromium/Chromium/
[ -z ${IGALIA_CHROMIUM_CONTRIB_STATS_OUTPUT} ] && IGALIA_CHROMIUM_CONTRIB_STATS_OUTPUT=${HOME}/github/Igalia-Chromium-Stats/igalia-cr-stats
[ -z ${GIT_STATS_PATH} ] && GIT_STATS_PATH=${HOME}/github/Igalia-Chromium-Stats/igalia_git_stats/bin/git_stats
[ -z ${IGALIA_CHROMIUM_CONTRIB_STATS_DAEMON} ] && IGALIA_CHROMIUM_CONTRIB_STATS_DAEMON=1
[ -z ${IGALIA_CHROMIUM_CONTRIB_STATS_PIDFILE} ] && PIDFILE=${HOME}/igalia-chromium-contribution-stats.pid
[ -z ${IGALIA_CHROMIUM_CONTRIB_STATS_PUSH} ] && IGALIA_CHROMIUM_CONTRIB_STATS_PUSH=1
[ -z ${IGALIA_CHROMIUM_CONTRIB_STATS_WHITELIST} ] && IGALIA_CHROMIUM_CONTRIB_STATS_WHITELIST=(
    @igalia.com
    gyuyoung.kim@lge.com
    gyuyoung.kim@samsung.com
    je_julie.kim@samsung.com
    jose.dapena@lge.com
    maksim.sisov@intel.com
    tonikitoo@webkit.org
    mrobinson@webkit.org
    xan@webkit.org
    alex@webkit.org
    fred.wang@free.fr
    simon.hong81@gmail.com
    simonhong@chromium.org
    rob.buis@samsung.com
    rwlbuiswgmail.com
    mario@webkit.org
    mario@endlessm.com
    mario.prada@samsung.com
    dehrenberg@chromium.org
    littledan@chromium.org
    henrique.ferreiro@gmail.com
)


# functions #########################################################
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }


function git_reset {
    git reset --hard origin
    git clean -f
    git reflog expire --all --expire-unreachable=0
    # git repack -A -d
    git prune
    git gc --auto
}


function pidfile { 
    if [ -f ${IGALIA_CHROMIUM_CONTRIB_STATS_PIDFILE} ]
    then
        PID=$(cat ${IGALIA_CHROMIUM_CONTRIB_STATS_PIDFILE})
        ps -p ${PID} > /dev/stderr
        if [ $? -eq 0 ]
        then
            echo "Process already running"
            exit 1
        else
            ## Process not found assume not running
            echo $$ > ${IGALIA_CHROMIUM_CONTRIB_STATS_PIDFILE}
            if [ $? -ne 0 ]
            then
                echo "Could not create PID file"
                exit 1
            fi
        fi
    else
        echo $$ > ${IGALIA_CHROMIUM_CONTRIB_STATS_PIDFILE}
        if [ $? -ne 0 ]
        then
            echo "Could not create PID file"
            exit 1
        fi
    fi
}


function quit {
    rm ${IGALIA_CHROMIUM_CONTRIB_STATS_PIDFILE}
    exit 0
}


# main ##############################################################

pidfile > /dev/stderr
export WHITELIST=$(join_by '\|' "${IGALIA_CHROMIUM_CONTRIB_STATS_WHITELIST[@]}")

while :
do
    # Update Chromium source code.
    start_timestamp=$(date +"%T")

    logger -is "Start updating  Chromium trunk, please wait ..." 2>&1
    cd ${CHROMIUM_PATH}
    git_reset > /dev/stderr
    git pull origin master:master > /dev/stderr
    git submodule foreach --recursive git reset --hard
    git submodule foreach --recursive git clean -fd
    git submodule init
    git submodule sync --recursive
    git submodule update --init --recursive
    git subtree add --prefix=pdfium-log https://pdfium.googlesource.com/pdfium master > /dev/stderr
    git add pdfium-log
    git commit -m "add pdfium-log"
    git subtree add --prefix=v8-log https://chromium.googlesource.com/v8/v8.git master > /dev/stderr
    git add v8-log
    git commit -m "add v8-log"
    logger -is "Finish to update Chromium." 2>&1

    # Start to analyze commit counts.
    cp ../mailmap  ./.mailmap
    now="$(date +'%Y-%m-%d')"
    logger -is "Checking Igalia commits until ${now}, please wait..." 2>&1
    git filter-branch -f --commit-filter '
	if echo "$GIT_AUTHOR_EMAIL" | grep -q "${WHITELIST}";
        then
            git commit-tree "$@";
        else
            skip_commit "$@";
        fi' HEAD > /dev/stderr

    logger -is "Finish to find Igalia commits." 2>&1
    ${GIT_STATS_PATH} generate -p ${CHROMIUM_PATH} -o ${IGALIA_CHROMIUM_CONTRIB_STATS_OUTPUT} > /dev/stderr

    # Upload the result to github.
    if [ "${IGALIA_CHROMIUM_CONTRIB_STATS_PUSH}" -eq "1" ]
    then
        cd ${IGALIA_CHROMIUM_CONTRIB_STATS_OUTPUT}
        git add . > /dev/stderr
        git commit -m "Update the new result by bot" > /dev/stderr
        git fetch origin master > /dev/stderr
        git rebase origin/master > /dev/stderr
        git push origin master:master > /dev/stderr
    fi

    end_timestamp="$(date +'%T')"
    logger -is "Finish to upload new result" 2>&1
    logger -is "StartTime: ${start_timestamp}" 2>&1
    logger -is "EndTime: ${end_timestamp}" 2>&1

    [ ${IGALIA_CHROMIUM_CONTRIB_STATS_DAEMON} -eq "0" ] && quit
done

quit
