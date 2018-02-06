# Chromium-stats
This tool is to generate a result to track Igalia Chromium contribution

# Instruction
## Install git_stats tool
```sh
$ git clone https://github.com/ChromiumGitCoutner/igalia_git_stats.git
```

## Checkout Chromium
```sh
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$ export PATH="$PATH:/path/to/depot_tools"
$ mkdir ~/chromium && cd ~/chromium
$ fetch --nohooks chromium
```

## Download igalia-chromium-contribution-stats repo
```sh
$ git clone git@github.com:ChromiumGitCoutner/igalia-chromium-contribution-stats.git
```

## Modify ./script/runChromiumGitAnalyzer.sh
Register the chromium path in the file.

```sh
 CHROMIUM_PATH=/path/to/Chromium/src (i.e. $HOME/chromium-stats/chromium/Chromium/)
 OUTPUT_PATH=/path/to/igalia-chromium-contribution-stats  (i.e. $HOME/github/Igalia-Chromium-Stats/igalia-chromium-contribution-stats/
 GIT_STATS_PATH=/path/to/igalia_git_stats/bin/git_stats
 ```
 
## Replace ssh key files in .ssh for auto result update
 ```sh
$ mv id_rsa ~/.ssh
$ mv id_rsa.pub ~/.ssh
```
 
 ## Run
 There are 2 ways to run the tool automatically. One is to use the crontab. The other is to use ./script/boot.sh.
 
 If you want to use boot.sh, please replace user name in the boot.sh
 ```sh
 screen -d -m -t $user ./runChromiumGitAnalyzer.sh $user
 (i.e. screen -d -m -t gyuyoung ./runChromiumGitAnalyzer.sh gyuyoung)
 ```
 Or you just register ./script/runChromiumGitAnalyzer.sh to crontab with an execution time.
  

