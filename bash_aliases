# bash aliases
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
alias stashit="git stash save"
alias stashlist="git stash list"
alias applystash="git stash apply"
alias popstash="git stash pop"
alias remotes="git remote -v"
alias renamebranch="git branch -m"
alias newbranch="git checkout -b"
alias listremotes="git ls-remote --heads"
alias switchbranch="git checkout"
alias dropbranch="git branch -d"
alias newmaster="git checkout -b master upstream/master"
alias removebranch="dropbranch"
alias pullupstream="git pull --rebase upstream master"
alias gitroot='cd $(git rev-parse --show-cdup)'
alias tree="ls -R | grep ":" | sed -e 's/://' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"

# show open tcp sockets by portnumber
alias tcpports='lsof -i -n -P | grep TCP'

# memcached
alias memcachedstart='memcached -d -m 24 -p 11211'
alias memcachedstop='pkill -15 memcached'
alias memcachedrestart='memcachedstop && memcachedstart'


alias wrangle='open -a /Applications/TextWrangler.app'

alias tidy="tidy -config ~/tidy_config.txt"

alias speedtest="wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip"
alias beautify="js-beautify -t -r"

