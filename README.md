# Chromium-stats
This tool is to generate a result to track Igalia Chromium contribution

# Instruction
## Install git_stats tool
```sh
cd ${WORKDIR}
git clone https://github.com/ChromiumGitCoutner/igalia_git_stats.git
```

Install the ruby dependencies needed for `igalia_git_stats`:

```
apt install bundler
apt install zlib1g-dev
cd ${WORKDIR}/igalia_git_stats
bundle install
```

## Checkout Chromium

```sh
$ cd ${WORKDIR}
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$ export PATH="$PATH:/path/to/depot_tools"
$ mkdir ~/chromium && cd ~/chromium
$ fetch --nohooks chromium
```

## Download igalia-chromium-contribution-stats repo
```sh
$ cd ${WORKDIR}
$ git clone git@github.com:ChromiumGitCoutner/igalia-chromium-contribution-stats.git
```

## Modify ./script/runChromiumGitAnalyzer.sh

You don't need edit the `runChromiumGitAnalyzer.sh` script anymore.
All the sensitive variables can be redefined with `export` bash definitions.


```sh
# ... runChromiumGitAnalyzer.sh 
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
)
```

## Settinng igalia-chromium-contribution-stats as a cronjob

(`WORKDIR="/var/www")

* Create the script which setup the enviroment
  ```
cat << EOF > /usr/bin/update-igalia-chromium-contribution-stats
export IGALIA_CHROMIUM_CONTRIB_STATS_PIDFILE=/var/www/igalia-chromium-contribution-stats/pid
export IGALIA_CHROMIUM_CONTRIB_STATS_PUSH=0
export IGALIA_CHROMIUM_CONTRIB_STATS_DAEMON=0
export IGALIA_CHROMIUM_CONTRIB_STATS_OUTPUT=/var/www/igalia-chromium-contribution-stats/out
export CHROMIUM_PATH=/var/www/chromium/src
export GIT_STATS_PATH=/var/www/igalia_git_stats/bin/git_stats
/var/www/igalia-chromium-contribution-stats/scripts/runChromiumGitAnalyzer.sh
EOF
chmod +x /usr/bin/update-igalia-chromium-contribution-stats
  ```

* Configuring the crontask (every days at 1:05)
  ```
cat << EOF > /etc/cron.d/update-igalia-chromium-contribution-stats
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

5 1 * * * root /usr/bin/update-igalia-chromium-contribution-stats  2>/dev/null
EOF
  ```

Note that `runChromiumGitAnalyzer` controls if there is any other instance 
running in the system before start (`IGALIA_CHROMIUM_CONTRIB_STATS_PIDFILE`)


`IGALIA_CHROMIUM_CONTRIB_STATS_PUSH` controls if we want commit and push
the new stats into the `igalia-chromium-contribution-stats` repository.
Set to `0` if you don't wish that. In oppsite, you must ensure that
`IGALIA_CHROMIUM_CONTRIB_STATS_OUTPUT` is set to the
`igalia-chromium-contribution-stats` Git repository path

## Settinng igalia-chromium-contribution-stats as a daemon

(`WORKDIR="/var/www")

The enviroment is quite similar to the cronjob approaching. You only need
set the `runChromiumGitAnalyzer.sh` as a daemon (`IGALIA_CHROMIUM_CONTRIB_STATS_DAEMON=1`):

  ```
cat << EOF > /usr/bin/update-igalia-chromium-contribution-stats
export IGALIA_CHROMIUM_CONTRIB_STATS_PIDFILE=/var/www/igalia-chromium-contribution-stats/pid
export IGALIA_CHROMIUM_CONTRIB_STATS_PUSH=0
export IGALIA_CHROMIUM_CONTRIB_STATS_DAEMON=1
export IGALIA_CHROMIUM_CONTRIB_STATS_OUTPUT=/var/www/igalia-chromium-contribution-stats/out
export CHROMIUM_PATH=/var/www/chromium/src
export GIT_STATS_PATH=/var/www/igalia_git_stats/bin/git_stats
/var/www/igalia-chromium-contribution-stats/scripts/runChromiumGitAnalyzer.sh
EOF
chmod +x /usr/bin/update-igalia-chromium-contribution-stats
  ```

* Run it with screen:

 ```sh
 screen -d -m -t ${user} /usr/bin/update-igalia-chromium-contribution-stats 
 (i.e. screen -d -m -t gyuyoung /usr/bin/update-igalia-chromium-contribution-stats )
 ```

`IGALIA_CHROMIUM_CONTRIB_STATS_PUSH` controls if we want commit and push
the new stats into the `igalia-chromium-contribution-stats` repository.
Set to `0` if you don't wish that. In oppsite, you must ensure that
`IGALIA_CHROMIUM_CONTRIB_STATS_OUTPUT` is set to the
`igalia-chromium-contribution-stats` Git repository path

 
## Replace ssh key files in .ssh for auto result update
 ```sh
$ mv id_rsa ~/.ssh
$ mv id_rsa.pub ~/.ssh
```
