#============================================================
#= Config Values
#= SET THESE VALUES TO ENSURE YOUR ALIASES WORK CORRECTLY
#============================================================

# Set your CWSPATH variable to your CWS folder's path.
CWSPATH=~/Jobvite/CWS/

#-------------------------------------------------------------
# Load / Edit .profile
#-------------------------------------------------------------
alias config='code ~/.profile && Alert $cWarning "Editing ~/.profile"'
alias reload='source ~/.profile && Alert $cSuccess ".profile Reloaded"'

#-------------------------------------------------------------
#  Global Variables
#	Variables for the current branch, and its path.
#-------------------------------------------------------------
BRANCH=$(git branch |grep \* | cut -d " " -f2)
BRANCHPATH=$CWSPATH/$BRANCH/
#-------------------------------------------------------------

#-------------------------------------------------------------
# Git
#-------------------------------------------------------------
function camp() {
    git add .
    cmp $@
}
function cmp() {
    pushing=true
    # Usage
    #= camp
    #= camp <commit_msg>
    #= camp -t <tag>
    #= camp -t <tag> <commit_msg>
    #= camp -t <tag> -m <msg>
    #= camp -t <tag> -m <msg> <commit_msg>
    #
    # You can specify a branch name by adding that branch name at
    #    the end of the function call. Example:
    #        camp <commit_msg> <branch_name>
    #-------------------------------------------------------------
    local branch=$(git branch |grep \* | cut -d " " -f2)

    # Flags
    m=false		#commit message flag
    t=false		#Includes tag
    tm=false	#tag message flag
    f=false		#forced flag
    # Messages / Tag
    tag=''	#tag
    tmg=''	#tag message
    msg=''	#commit message

    for (( i = 1; i <= $#; i += 1 )); do
        if [[ ${@[$i]} == '-t' ]] then # if tagged
            t=true
            i+=1
            tag=${@[$i]}
        elif [[ ${@[$i]} == '-m' ]] then # if tag and commit msg
            tm=true
            i+=1
            tmg=${@[$i]}
        elif [[ ${@[$i]} == '-f' ]] then # if force pushed
            f=true
        elif [[ ${@[$i]} != "" ]] then
            git show-ref --quiet refs/remotes/origin/${@[$i]}

            if [[ $? == 0 ]] then # if last parameter is specified branch
                branch=${@[$i]}
            else # if it isn't a flag or a branch, it must be a commit message
                m=true
                msg=${@[$i]}
            fi
        fi
    done

	if ( $t && ! $tm ) {
		tmg="Updating to ${tag}"
		tm=true
	}

    if ( ! $m )
	then
		if ( $tm )
		then
        	msg=$tmg;
		else
			echo $(Error "You have to have at least ONE thing to say about what you've done before you push")
			return
		fi
    fi

    # echo '------ tags -------'
    # echo 'm: ' $m
    # echo 't: ' $t
    # echo 'tm: ' $tm
    # echo 'f: ' $f
    # echo
    # echo '------ info -------'
    # echo 'tag: ' $tag
    # echo 'tmg: ' $tmg
    # echo 'msg: ' $msg
    # echo 'branch: ' $branch

	git commit -m $msg

	if ( $f ) then
		git push origin $branch -f
	else
		git push origin $branch
	fi

    if ( $t ) then
        git tag -a $tag -m $tmg
        git push origin --tags
    fi

	if [[ $pushing == true ]]; then
		trap 'echo $(Alert $cError "Something went wrong")' 1 2 3 6
	fi

	pushing=false
}
function gwtn() {
    if [[ $1 != "" ]]; then
        git show-ref --quiet refs/remotes/origin/${1}
        if [[ $? == 0 ]] then
            $CWSPATH && git checkout starter_branch && git fetch && git pull && git worktree add --track -B ${1} ./${1} origin/${1} && git checkout root && ${1}/ && mkdir _dev && styles/ && ncu -u && npm install && npm audit fix && .. && git push origin ${1} && code .
        else
            $CWSPATH && git checkout starter_branch && git fetch && git pull && git worktree add ${1} && git checkout root && ${1}/ && mkdir _dev && styles/ && ncu -u && npm install && npm audit fix && .. && git commit -am "Setting up $(git symbolic-ref --short HEAD) project in Git" && git push --set-upstream origin $(git symbolic-ref --short HEAD) && code .
        fi
    else
        echo $(Message "Add a worktree name ( e.x. gwtn myworktree )")
    fi
    return 1
}
function gwtm() {
    if [[ $1 != "" ]]; then
        git show-ref --quiet refs/remotes/origin/${1}
        if [[ $1 == 'starter_branch' ]]
        then
            $CWSPATH && git fetch && git pull && git worktree add --track -B ${1} ./${1} origin/${1} && git checkout root && ${1}/ && mkdir _dev && git push --set-upstream origin ${1}
        elif [[ $? == 0 ]] then
            $CWSPATH && git checkout starter_branch && git fetch && git pull && git worktree add --track -B ${1} ./${1} origin/${1} && git checkout root && ${1}/ && mkdir _dev && git push --set-upstream origin ${1}
        else
            $CWSPATH && git checkout starter_branch && git fetch && git pull && git worktree add ${1} && git checkout root && ${1}/ && mkdir _dev && git commit -am "Setting up $1" && git push --set-upstream origin ${1}
        fi
    else
        echo $(Message "Add a worktree name ( e.x. gwtm myworktree )")
    fi
}
function gwtr() {
    del=false
    local branch=$(git branch |grep \* | cut -d " " -f2)


    if [[ $1 == "-d" ]] then
        del=true
        if [[ $2 != "" ]] then
            branch=$2
        fi
    elif [[ $1 != "" ]]; then
        branch=$1
    elif [[ $branch == "root" ]] || [[ $branch == "starter_branch" ]] then
        echo $(Message "You can't use gwtr in root or starter_branch. Either specify a branch, or cd into that branch and run gwtr")
        return 1
    fi

    $CWSPATH/$branch

    if [[ $del == true ]] then
        git show-ref --quiet refs/remotes/origin/$branch

        if [[ $? == 0 ]] then # if last parameter is specified branch
            git push origin --delete $branch
        fi
    fi

    $CWSPATH
    git worktree remove $branch

    if [[ $del == true ]] then
        git branch -D $branch
    fi
}
function mpeek() {
    git log master.. --graph $(git symbolic-ref --short HEAD) --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}
}
function addkick() {
	if [[ $1 != '' ]]
	then
		if [ -d $@/styles/ ]; then
			echo $(Warning "Kickoff already exists at $@/styles")
			return
		else
			pushd $PWD && $@/ && git init && git remote add kickoff https://github.com/jobvite-github/Kickoff.git && git fetch kickoff && git checkout kickoff/master && rm -rf .git && popd
			return
		fi
	else
		if [ -d styles/ ]; then
			echo $(Warning "Kickoff already exists at /styles")
			return
		else
			pushd $PWD && sudo mkdir $@/styles && $@/styles && git init && git remote add kickoff https://github.com/jobvite-github/Kickoff.git && git fetch kickoff && git checkout kickoff/master && rm -rf .git && popd
			return
		fi
	fi
}
function new() {
    if [ -d desktop/ ] || mkdir desktop && touch desktop/.gitkeep
    if [ -d mobile/ ] || mkdir mobile && touch mobile/.gitkeep
    if [ -d images/ ] || mkdir images && touch images/.gitkeep
    if [ -d styles/ ] || addkick
}
function start() {
    run=true
    # Directory containing package.json
    dir=''

    if [ -f package.json ]
    then
        dir=$(dirname 'package.json')
    fi

    for (( i=1; i <= 3; i++ ))
    do
        for SDIR in `fn ${1=.} 'package.json' $i`
        do
            dir=$(dirname $SDIR)
        done
        [[ $dir != '' ]] && break
    done

    if [[ $dir != '' ]]
    then
        # Catch for exiting on ctrl+c for exit message and returning from packaged dir
        home=$PWD
        if [[ $run == true ]]; then
            trap 'echo && echo $(colorText $cMessage "...Kickoff Stopped") && $home' 1 2 3 6
        fi

        # cd to dir containing package.json
        $dir

        # Start message
        echo $(colorText $cSuccess 'Starting Kickoff in '"$(formatText 'bold' $dir)")
        echo
        echo $(formatText 'bold' "$(colorText $cMessage 'To stop, press Control-C')")

        # update npm, install package.json, npm audit fit, then gulp
        ncu -u && npm install && npm audit fix && gulp
    else
        echo $(formatText 'bold' "$(colorText $cWarning '! There is no Kickoff found in '$PWD/$1 '!')")
        echo '\ncd into the correct directory,\nuse command\n'
        echo $(formatText 'bold' "$(colorText $cMessage ' > addkick')")
        echo '\nto add a new Kickoff to your project,\nor specify in which folder, not including, your Kickoff exists by doing:\n'
        echo $(formatText 'bold' "$(colorText $cMessage ' > start path/to')")
        echo
        echo $(formatText 'bold' underline 'Hold up! Wait a minute. Make sure you read ^this^ before you move on.')
        echo
    fi

    run=false
}
function stats() {
    git log --stat --all --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-50}
}
# Tagging
function tagging() {
    if [[ $1 == "-D" ]] then
        git tag -d $2
        git push --delete origin $2
        return 1
    elif [[ $1 != "" ]]; then
        git tag -a $1 -m "Updating to ${1}"
        git push origin $1
        return 1
    else
        echo $(Message "Add a version ( e.x. tagging v1.0 )")
    fi
}
alias tag='git tag'
alias tags='git tag -l'
alias tug='git pull'
#End Tagging

alias add='git add'
# alias addkick='mkdir styles && ./styles && git init && git remote add kickoff https://github.com/jobvite-github/Kickoff.git && git fetch kickoff && git checkout kickoff/master && rm -rf .git'
alias back='git reset HEAD~1'
alias bset='git branch --set-upstream-to=origin/$(git symbolic-ref --short HEAD) $(git symbolic-ref --short HEAD)'
alias branch='git branch'
alias branches='git branch --list'
alias bkto='git reset --hard origin/$(git symbolic-ref --short HEAD)'
alias cam='git add . && git commit -m'
alias ch='git checkout'
alias chd='git checkout develop'
alias chma='git checkout master'
# function chpm() {
# 	#!/bin/bash
# 	# Reset Permissions Script
# 	# resetpermission

# 	FTPUSER=brettbyron

# 	echo -e 'Please enter the directory to go to:' $1
# 	if [[ $1 == "" ]]
# 	then
# 		read $(git symbolic-ref --short HEAD)
# 	else
# 		read DIR
# 	fi
# 	echo -e 'Please enter the folder to update permissions:' $2
# 	read FOLDER
# 	sftp $FTPUSER@sftp.jobvite.com:/uploads/$1 <<EOF
# 	chmod 777 -R $2

# }
alias chr='git checkout root'
alias chs='git checkout sandbox'
alias chsb='git checkout starter_branch'
alias clone='git clone'
alias cm='git commit -m'
alias coressh='git config core.sshCommand "ssh -i ~/.ssh/${1} -F /dev/null"'
alias counts='git shortlog -sne'
alias dm='git diff --minimal'
alias fetch='git fetch'
alias fuck='git reset --hard origin/$(git symbolic-ref --short HEAD)'
alias grs='git reset'
alias grsurl='git remote set-url origin'
alias grv='git remote -v'
alias gwt='git worktree'
alias gwts='git worktree add $1 $1'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias home='git reset origin/master'
alias lga='git log --graph --all --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)"'
alias mg='git merge'
alias newb='git checkout -b'
alias pages='git stash && git checkout gh-pages'
alias peek='git log --graph $(git symbolic-ref --short HEAD) --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}'
alias peekall='git log --graph origin --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}'
alias poke='git push origin $(git symbolic-ref --short HEAD)'
alias pop='git stash pop'
alias pud='git pull origin develop'
alias push='git push'
alias pushall='git push && git push origin --tags'
alias pset='git push --set-upstream origin $(git symbolic-ref --short HEAD)'
alias ptag='git push origin --tags'
alias rb='git rebase'
alias rbd='git rebase develop'
alias rbm='git rebase master'
alias ref='git reflog'
alias s='git status'
alias setit='git reset --hard origin/$(git symbolic-ref --short HEAD)'
alias shit='git checkout .'
alias shove='git push -f'
alias sta='git add . && git stash'
alias stash='git add . && git stash'
alias stashed='git stash show'
alias whichup=whichupstream='git branch -vv'

# SFTP / FileZilla
#-------------------------------------------------------------
function fz() {
    if [[ $1 != "" ]]; then
        echo $@
        echo $FZPWD | pbcopy && sftp $FZUSER@sftp.jobvite.com:/uploads/${1}
    else
        echo $FZPWD | pbcopy && sftp $FZUSER@sftp.jobvite.com:/uploads/$(git symbolic-ref --short HEAD)
    fi
}
alias fzu="echo $FZPWD | pbcopy && sftp $FZUSER@sftp.jobvite.com:/uploads/"
alias fzr="echo $FZPWD | pbcopy && sftp $FZUSER@sftp.jobvite.com:/uploads/$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')"

# NPM
#-------------------------------------------------------------
alias naf='npm audit fix'
alias ncui='ncu -u && npm install'
alias ncuif='ncu -u && npm install && npm audit fix'

# Heroku
#-------------------------------------------------------------
alias apps='heroku list'
alias hbkto='git reset --hard heroku/$(git symbolic-ref --short HEAD)'
alias hl='heroku logs --tail'
alias hp='git push heroku master'
alias hpt='git push heroku --tags'

# Build
#-------------------------------------------------------------
alias watch='build --deploy --watch'
alias deploy='build --deploy'
alias assets='build --deploy -task --assets'
alias djs='build --deploy -task --js'

# Zip Password
#-------------------------------------------------------------
alias zipit='zip -er $1.zip $2'

#-------------------------------------------------------------
#
#= tput Text Formatting
#
#-------------------------------------------------------------

#- Colors
Black='#000000'
White='#FFFFFF'
Red='#C8334D'
Orange='#FEA42F'
Yellow='#C7C748'
Green='#43CC63'
Teal='#8AFFC8'
Blue='#88D1FE'
Dark='#615340'

cSuccess=$Green
cWarning=$Orange
cError=$Red
cMessage=$Blue
cEnd=$(tput sgr0)

ALERTWIDTH=30 #Columns for alert width

#- Coloring Functions
function Alert() {
    color=$cWarning;
    space=''
    str=''
    if [[ $2 != "" ]]; then
        color=$1
        str=$2
    else
        str=$1
    fi

    for (( i = 1; i <= ($ALERTWIDTH-${#str}) / 2; i += 1 )); do
        space=$space"-"
    done

    str="$space $str $space"

    echo -e "$(Highlight $color $str)"
}
function Success() {
    echo -e $(formatText 'bold' "$(colorText $cSuccess $1)")
}
function Warning() {
    echo -e $(formatText 'bold' "$(colorText $cWarning $1)")
}
function Error() {
    echo -e $(formatText 'bold' "$(colorText $cError $1)")
}
function Message() {
    echo -e $(formatText 'bold' "$(colorText $cMessage $1)")
}
function Highlight() {
    # $1: highlight color <required>
    # $2: text content <required>
    echo -e $(formatText 'bold' "$(highlightText $1 $2)")
}

#- Formatting Functions
function formatText() {
    res=''
    for (( i = 1; i < $#; i += 1 )); do
        if [[ $@[$i] == 'normal' ]]; then
            res=$res"$(tput sgr0)"
        elif [[ $@[$i] == 'bold' ]]; then
            res=$res"$(tput bold)"
        elif [[ $@[$i] == 'underline' ]]; then
            res=$res"$(tput smul)"
        elif [[ $@[$i] == 'nounderline' ]]; then
            res=$res"$(tput rmul)"
        fi
    done

    res=$res$@[$#]

    endFormatting
}
function colorText() {
    # two required arguments, one optional argument for color
    # $1: text color <required>
    # $2: text content <required>

    res=''

    res=$res$(tput setaf $(fromHex $1))
    res=$res${@:2}

    endFormatting
}
function highlightText() {
    # $1: highlight color <required>
    # $2: text content <required>

    res=''

    res=$res$(tput setab $(fromHex $1))
    res=$res' '${@:2}' '

    endFormatting
}
function fromHex() {
    # fromHex: https://gist.github.com/mhulse/b11e568260fb8c3aa2a8
    hex=$1
    if [[ $hex == "#"* ]]; then
        isHex=true
        hex=$(echo $1 | awk '{print substr($0,2)}')
    fi
    r=$(printf '0x%0.2s' "$hex")
    g=$(printf '0x%0.2s' ${hex#??})
    b=$(printf '0x%0.2s' ${hex#????})
    rgb=$(((r<75?0:(r-35)/40)*6*6+(g<75?0:(g-35)/40)*6+(b<75?0:(b-35)/40)+16))

    echo -e ${rgb:0}
}
function endFormatting() {
    if [[ $(contains $@[$#] $cEnd) ]] || res=$res$cEnd

    echo -e $res
}

#-------------------------------------------------------------

#-------------------------------------------------------------
#
#  ALIASES AND FUNCTIONS
#
#  Arguably, some functions defined here are quite big.
#  If you want to make this file smaller, these functions can
#+ be converted into scripts and removed from here.
#
#-------------------------------------------------------------

#-------------------
# Personnal Aliases
#-------------------
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# -> Prevents accidentally clobbering files.
alias mkdir='mkdir -p'

alias h='history'
alias j='jobs -l'
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
# Spelling typos - highly personnal and keyboard-dependent :-)
#-------------------------------------------------------------

alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'

#-------------------------------------------------------------
# Find Helpers
#-------------------------------------------------------------
function fn() {
    if [[ $3 != "" ]]
    then
        find $1 -name "$2" -prune -maxdepth $3
    elif [[ $2 != "" ]]
    then
        find $1 -name "$2" -prune -maxdepth 1
    elif [[ $1 != "" ]]
    then
        find . -name "$1" -prune -maxdepth 1
    else
        echo 'Enter the name of the file you want to search and, optionally ( as the first argument ), where you want to search.'
    fi
}
function fnd() {
    if [[ $3 != "" ]]
    then
        find $1 -name "$2" -type d -prune -maxdepth $3
    elif [[ $2 != "" ]]
    then
        find $1 -name "$2" -type d -prune -maxdepth 1
    elif [[ $1 != "" ]]
    then
        find . -name "$1" -type d -prune -maxdepth 1
    else
        echo 'Enter the name of the file you want to search and, optionally ( as the first argument ), where you want to search.'
    fi
}
function contains() { case "$1" in *"$2"*) true ;; *) false ;; esac }
#-------------------------------------------------------------