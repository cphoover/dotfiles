# bash aliases
alias d='cd $(ls -1 -d */ | head -n 1)' # go into first directory
alias cp="cp -iv"     # interactive, verbose
alias rm="rm -i"      # interactive
alias mv="mv -iv"     # interactive, verbose
alias grep="grep -i"  # ignore case
alias list='ls -lah'
alias rename='mv'
alias remove='rm -i'
alias rmdir='rm -rf'
alias copy='cp'
alias copydir='cp -r'
alias killit='kill -15'
alias killlivereload="onport 35729 | tail -n +2 | awk '{ print $2 }' | while read pid; do kill -9 $pid; done"
alias stashit="git stash save -u"
alias stashlist="git stash list"
alias applystash="git stash apply"
alias popstash="git stash pop"
alias remotes="git remote -v"
alias renamebranch="git branch -m"
alias newbranch="git checkout -b"
alias listremotes="git ls-remote --heads"
#alias switchbranch="git checkout"
alias whichbranch='git branch | grep "*"'
alias pushorigin="git push origin HEAD"
alias choosebranch="git checkout \$(git branch | percol)"
alias dropbranch="git branch -d"
alias newmaster="git checkout -b master upstream/master && git pull upstream master"
alias removebranch="dropbranch"
alias pullupstream="git pull --rebase upstream master"
alias showgitroot='git rev-parse --show-cdup'
alias gitroot='cd "$(git rev-parse --show-cdup)"'
alias gitunpick='git revert -n'
alias buildit="gitroot; gulp build; cd -;"
alias tree="ls -R | grep ":" | sed -e 's/://' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias pedit='vim $(echo "..\n$(find .)" | percol)'
alias ack='ack --ignore-file=match:tags --ignore-dir="target" --ignore-dir="node_modules" --ignore-dir="build" --ignore-dir="gen" --ignore-dir="bower_components"'
alias enternewest='cd $(ls -tr1 | tail -n 1)'
alias heapdump='kill -USR2 $(lsof -t -i ":3000")'
alias killitall='while read line; do sudo kill -9 $line; done;'
alias startpostgres='psql -D /usr/local/var/postgres'
alias b2b='startpostgres && elasticsearch'
alias killpostgres='kill -INT `head -1 /usr/local/var/postgres/postmaster.pid`'
alias sesh="screen -S"
alias rat="screen -r"
alias debugdisk="sudo fs_usage -f filesys"


# show open tcp sockets by portnumber
alias tcpports='lsof -i -n -P | grep TCP'

# memcached
alias memcachedstart='memcached -d -m 24 -p 11211'
alias memcachedstop='pkill -15 memcached'
alias memcachedrestart='memcachedstop && memcachedstart'

#v5
alias v5root='cd ${v5_root}'
alias v5pruners='cd ${v5_root}/runtime/pruners'
alias v5runtime='vi ${v5_root}/runtime/Base.cfc'
alias v5map='vi ${v5_root}/www/runtime.cfm'
alias v5deployments='cd ${v5_root}/deployments'
alias v5images='cd ${v5_root}/www/images'
alias v5shop='cd ${v5_root}/runtime/pruners/shop-page'
alias v5serviceapi='vi ${v5_root}/cfc/ServiceAPI.cfc'

alias v6prototypes='cd ~/workspace/sandbox/redesign-prototypes'
alias v6b2c='cd /git/ua-b2c'
alias b2c='v6b2c'
alias v6root='cd /git'
alias v6models="cd /git/ua-mongo-models"
alias v6frontend="b2c"

alias wfroot='cd ${wf_root}'

alias wrangle='open -a /Applications/TextWrangler.app'
alias tidy="tidy -config ~/tidy_config.txt"

alias speedtest="wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip"
alias beautify="js-beautify -t -r"
