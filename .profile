#============================================================
#
#  GITHUB ALIASES AND FUNCTIONS
#
#  Arguably, some functions defined here are quite big.
#  If you want to make this file smaller, these functions can
#+ be converted into scripts and removed from here.
#
#============================================================
function addkick() {
    echo "parameters: $@";
    echo "$@/styles";
    if [[ $1 != "" ]]
        pushd $PWD && mkdir styles && styles && git init && git remote add kickoff https://github.com/jobvite-github/Kickoff.git && git fetch kickoff && git checkout kickoff/master && rm -rf .git && popd
    then
        pushd $PWD && mkdir $@/styles && $@/styles && git init && git remote add kickoff https://github.com/jobvite-github/Kickoff.git && git fetch kickoff && git checkout kickoff/master && rm -rf .git && popd
    fi
}
function camp() {
    git add .
    if [[ $1 != "" ]]
    then
        git commit -m $1
    else
        # empty camp sets origin to origin/current_branch
        git push -u origin $(git symbolic-ref --short HEAD) $2
    fi
    git push $2
}
function cmp() {
    if [[ $1 != "" ]]
    then
        git commit -m $1
    else
        # empty camp sets origin to origin/current_branch
        git push -u origin $(git symbolic-ref --short HEAD) $2
    fi
    git push $2
}
function gwtm() {
    if [[ $1 != "" ]]
    then
        ~/Jobvite/CWS && git checkout starter_branch && git fetch && git pull && git worktree add ${1} && git checkout root && ${1}/ && mkdir _dev && git commit -am "Setting up $(git symbolic-ref --short HEAD) project in Git" && git push --set-upstream origin $(git symbolic-ref --short HEAD)
    else
        echo 'Gotta name that shit, bud.'
    fi
}
function gwtn() {
    if [[ $1 != "" ]] then
		git show-branch refs/remotes/origin/${1}
		if [[ $? == 0 ]] then
        	~/Jobvite/CWS && git checkout starter_branch && git fetch && git pull && git worktree add ${1} && git checkout root && ${1}/ && mkdir _dev && styles/ && npm i && .. && code .
		else
        	~/Jobvite/CWS && git checkout starter_branch && git fetch && git pull && git worktree add --track -B ${1} ./${1} origin/${1} && git checkout root && ${1}/ && mkdir _dev && styles/ && npm i && .. && git commit -am "Setting up $(git symbolic-ref --short HEAD) project in Git" && git push --set-upstream origin $(git symbolic-ref --short HEAD) && code .
		fi
    else
        echo 'Gotta name that shit, bud.'
    fi
}
function start() {
    if [[ $1 != "" ]]
    then
        $BRANCH/${@}/**/styles && npm i && gulp
    else
        if [ -d $BRANCH/styles/ ]
        then
            $BRANCH/styles/ && npm i && gulp
        elif [ -d $BRANCH/**/styles/ ]
        then
            $BRANCH/**/styles/ && npm i && gulp
        elif [ -d $BRANCH/style/ ]
        then
            $BRANCH/style/ && npm i && gulp
        elif [ -d $BRANCH/**/style/ ]
        then
            $BRANCH/**/style/ && npm i && gulp
        else
            echo 'No styles or style folder found in the parent directory'
        fi
    fi
}
function stats() {
    git log --stat --all --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-50}
}
#-------------------------------------------------------------
# GitHub Aliases
#-------------------------------------------------------------
alias add='git add'
alias back='git reset HEAD~1'
alias bkto='git reset --hard origin/$(git symbolic-ref --short HEAD)'
alias branch='git branch'
alias branches='git branch --list'
alias bset='git branch --set-upstream-to=origin/$(git symbolic-ref --short HEAD) $(git symbolic-ref --short HEAD)'
alias cam='git add . && git commit -m'
alias ch='git checkout'
alias chr='git checkout root'
alias chsb='git checkout starter_branch'
alias clone='git clone'
alias cm='git commit -m'
alias coressh='git config core.sshCommand "ssh -i ~/.ssh/${1} -F /dev/null"'
alias counts='git shortlog -sne'
alias dm='git diff --minimal'
alias fetch='git fetch'
alias fuck='reset --hard origin/$(git symbolic-ref --short HEAD)'
alias grs='git reset'
alias grsurl='git remote set-url origin'
alias grv='git remote -v'
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias gwtr='git worktree remove'
alias lga='git log --graph --all --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)"'
alias mg='git merge'
alias newb='git checkout -b'
alias peek='git log --graph $(git symbolic-ref --short HEAD) --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}'
alias peekall='git log --graph origin --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}'
alias poke='git push origin $(git symbolic-ref --short HEAD)'
alias pop='git stash pop'
alias pset='git push --set-upstream origin $(git symbolic-ref --short HEAD)'
alias ptag='git push origin --tags'
alias pull='git pull'
alias push='git push'
alias pushall='git push && git push origin --tags'
alias rb='git rebase'
alias ref='git reflog'
alias s='git status'
alias setit='git reset --hard origin/$(git symbolic-ref --short HEAD)'
alias shit='git checkout .'
alias shove='git push -f'
alias sta='git add . && git stash'
alias stash='git add . && git stash'
alias stashed='git stash show'
alias tag='git tag'
alias tagging='git tag -a $1 -m $2 && git push origin --tags'
alias tags='git tag -l'
alias tug='git pull'
alias whichup=whichupstream='git branch -vv'

#-------------------------------------------------------------
# NPM
#-------------------------------------------------------------
alias naf='npm audit fix'
alias ncui='ncu -u && npm install'
alias ncuif='ncu -u && npm install && npm audit fix'

#-------------------------------------------------------------
#
#  GREETING, MOTD, ETC. ...
#
#  Color definitions (taken from Color Bash Prompt HowTo).
#  Some colors might look different of some terminals.
#  For example, I see 'Bold Red' as 'orange' on my screen,
#  hence the 'Green' 'BRed' 'Red' sequence I often use in my prompt.
#
#-------------------------------------------------------------

# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset

ALERT=${BWhite}${On_Red} # Bold White on red background

#============================================================
#
#  ALIASES AND FUNCTIONS
#
#  Arguably, some functions defined here are quite big.
#  If you want to make this file smaller, these functions can
#+ be converted into scripts and removed from here.
#
#============================================================

#-------------------
# Personnal Aliases
#-------------------
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p' # -> Prevents accidentally clobbering files.
alias which='type -a'
alias ..='cd ..'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

#-------------------------------------------------------------
# The 'ls' family (this assumes you use a recent GNU ls).
#-------------------------------------------------------------
# Add colors for filetype and  human-readable sizes by default on 'ls':
# alias ls='ls -h --color'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first"
alias lm='ll |more'        #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...

#-------------------------------------------------------------
# Load / Edit .profile
#-------------------------------------------------------------
alias config='code ~/.profile && echo "$(tput setaf 255)$(tput setab 9)Editing ~/.profile"'
alias ebash='code ~/.profile && echo "$(tput setaf 255)$(tput setab 9)Editing ~/.profile"'
alias reload='source ~/.profile && echo "$(tput setaf 41).profile Reloaded"'
alias sbash='source ~/.profile && echo "$(tput setaf 41).profile Reloaded"'

# System Stuff
alias ding='print \\a'

# The 'ls' family
alias lsa='ls -a'
