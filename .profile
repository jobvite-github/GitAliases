#============================================================
#= Config Values
#
# !!IMPORTANT!!
# Set these values to ensure your aliases work correctly
#
#============================================================
TLPATH='' # Set your TLPATH variable to your Talemetry folder's path.
JVPATH=~/Jobvite/CWS/ # Set your JVPATH variable to your Jobvite CWS folder's path.

# FZ Stuff
#-------------------------------------------------------------
FZUSER=''    # FileZilla Username
FZPWD=''    # FileZilla Password

# End Config
#============================================================

# Load / Edit / Update .profile
#-------------------------------------------------------------
alias config='code ~/.profile && echo $(Alert $cWarning "Editing ~/.profile ")'
alias reload='source ~/.profile && echo $(Alert $cSuccess ".profile Reloaded ")'
function updateAliases() {
    read res"?$(Color -m 'This will overwrite your .profile. Are you sure you want to continue? [y/n]'$cEnd -ub): "
    case $res in
        [yY])
            (
                (
                    curl -s https://raw.githubusercontent.com/brettwbyron/GitAliases/main/.profile > ~/.profile && reload
                ) &
                loadingAnimation $! "Updating .profile"
            )
        ;;
        *)
            return
        ;;
    esac
}

#============================================================
#= Global Variables
#============================================================
ENV=''
ENVTYPE=''
function findEnv() {
    dir=${1-$PWD}
    step=${2-0}
    if [[ $3 != '' ]]; then
        dir=$1$2
        step=$3
    fi
    result="${dir%"${dir##*[!/]}"}" # extglob-free multi-trailing-/ trim
    result="${result##*/}"                  # remove everything before the last /
    result=${result:-/}
    result=`echo "$result" | tr 'A-Z' 'a-z'`

    if [[ $result == 'jobvite' || $result == 'cws' ]]; then
        ENV=$JVPATH
        ENVTYPE='jv'
    elif [[ $result == "talemetry" ]]; then
        ENV=$TLPATH
        ENVTYPE='tl'
    elif [ $step -ge 0 ] && [[ $step > 5 ]]; then
        ENV=$PWD/
    else
        ((step++))
        findEnv $(dirname $dir) $step
        return
    fi

    step=0
}

#============================================================
#= Aliases / Functions
#============================================================

# Git
#-------------------------------------------------------------
function camp() {
    git add .
    gitPush $@
}
function cmp() {
    gitPush $@
}
function gitPush() {
    # Usage
    #= gitPush
    #= gitPush <commit_msg>
    #= gitPush -t <tag>
    #= gitPush -t <tag> <commit_msg>
    #= gitPush -t <tag> -m <msg>
    #= gitPush -t <tag> -m <msg> <commit_msg>
    #
    # You can specify a branch name by adding that branch name at
    #    the end of the function call. Example:
    #        gitPush <commit_msg> <branch_name>
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
        if [[ ${@[$i]} == '-t' ]]; then # if tagged
            t=true
            i+=1
            tag=${@[$i]}
        elif [[ ${@[$i]} == '-m' ]]; then # if tag and commit msg
            tm=true
            i+=1
            tmg=${@[$i]}
        elif [[ ${@[$i]} == '-f' ]]; then # if force pushed
            f=true
        elif [[ ${@[$i]} != "" ]]; then
            git show-ref --quiet refs/remotes/origin/${@[$i]}

            if [[ $? == 0 ]]; then # if last parameter is specified branch
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
            msg=$tmg
        else
            Error "You have to have at least ONE thing to say about what you've done before you push"
            return
        fi
    fi

    #============================================================
    #= Debug
    #============================================================
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

    findEnv
    if [[ $ENVTYPE == "jv" ]] || [[ $ENVTYPE == "tl" ]]; then
        cd $ENV$(git branch |grep \* | cut -d " " -f2)
    fi

    (
        (
            (
                git commit -m $msg &>/dev/null

                if ( $f ) then
                    git push origin $branch -f &>/dev/null
                else
                    git push origin $branch &>/dev/null
                fi

                if ( $t ) then
                    git tag -a $tag -m $tmg &>/dev/null
                    git push origin --tags &>/dev/null
                fi

            )
        ) &
        loadingAnimation $! "Pushing to origin/$branch"
    )
    # $(Color $txt_color "$(HighlightLine $color $str)")
    str=" $(git show -s --format='%h - %s') $cEnd"
    # chk=" √ $cEnd"
    chk=" $(echo -e '\U0001F44D') $cEnd"

    echo && echo $(Color -b -c $cSuccess -m "$(Highlight $DarkGray $chk)")$(Color -c $Black -m "$(Highlight $Blue $str)") && echo
}
function gitPull() {
    # Usage
    #= gitPull
    #
    # You can specify a branch name by adding that branch name at
    #    the end of the function call. Example:
    #        gitPull <branch_name>
    #-------------------------------------------------------------
    local branch=$(git branch |grep \* | cut -d " " -f2)

    (
        (
            git fetch origin $branch &>/dev/null
            git pull origin $branch &>/dev/null
        ) &
        loadingAnimation $! "Updating branch \"$branch\""
    )
}

function gwtn() {
    branch=$1

    if [[ $branch != "" ]]; then

        [ -d $ENV$branch ] && return

        findEnv
        if [[ $ENVTYPE == "jv" ]] || [[ $ENVTYPE == "tl" ]]; then
            cd $ENV &>/dev/null
        fi

        trap 'echo && echo $(Alert $cWarning "Stopped creating worktree \"$branch\"\nCheck on what has been created so far") && shutdown && trap - 1 2 3 6 && return' 1 2 3 6

        (
            (
                [[ $branch != 'starter_branch' ]] && git checkout starter_branch  &>/dev/null

                git fetch  &>/dev/null
                git pull  &>/dev/null

                git show-ref --quiet refs/remotes/origin/$branch
                if [[ $? == 0 ]]; then
                    git worktree add --track -B $branch ./$branch origin/$branch  &>/dev/null
                else
                    git worktree add $branch  &>/dev/null
                fi

                git checkout root  &>/dev/null

                cd $branch/

                mkdir _dev
            ) &
            loadingAnimation $! "Setting up worktree \"$branch\""
        )

        start -i $branch

        cd $ENV$branch &>/dev/null

        (
            (
                if [[ $? == 0 ]]; then
                    git push origin $branch &>/dev/null
                else
                    git commit -am "Setting up $(git symbolic-ref --short HEAD) project in Git"  &>/dev/null
                    git push --set-upstream origin $(git symbolic-ref --short HEAD)  &>/dev/null
                fi
            ) &
            loadingAnimation $! "Setting up in GitHub"
        )

        Alert $cSuccess "\"$branch\" created!\nOpening in VSCode"

        code .
    else
        Error "Need a worktree name ( e.x. gwtn myworktree )"
        return
    fi

    cd $ENV &>/dev/null
}
function gwtm() {
    branch=$1

    findEnv
    if [[ $ENVTYPE == "jv" ]] || [[ $ENVTYPE == "tl" ]]; then
        cd $ENV
    fi
    if [[ $branch != "" ]]; then

        [ -d $ENV$branch ] && return

        trap 'echo && echo $(Alert $cWarning "Stopped creating worktree \"$branch\"\nCheck on what has been created so far") && shutdown && trap - 1 2 3 6 && return' 1 2 3 6

        (
            (
                [[ $branch != 'starter_branch' ]] && git checkout starter_branch  &>/dev/null

                git fetch  &>/dev/null
                git pull  &>/dev/null

                if [ `git rev-parse --verify origin/$branch 2>/dev/null` ]; then
                    Alert $cMessage "\"$branch\" already exists"
                    git worktree add --track -B $branch ./$branch origin/$branch  &>/dev/null
                    Alert $cSuccess "\"$branch\" added!"
                else
                    git worktree add $branch  &>/dev/null
                fi

                git checkout root  &>/dev/null
                cd $branch/ &>/dev/null

                mkdir _dev
            ) &
            loadingAnimation $! "Setting up worktree \"$branch\""
        )

        cd $ENV$branch &>/dev/null

        (
            (
                if [ `git rev-parse --verify origin/$branch 2>/dev/null` ]; then
                else
                    git push origin $branch 2>/dev/null
                    Alert $cSuccess "\"$branch\" created!"
                fi
            ) &
            loadingAnimation $! "Setting up in GitHub"
        )
    else
        Error "Need a worktree name ( e.x. gwtn myworktree )"
        return
    fi

    - &>/dev/null
}
function gwtr() {
    trap 'echo && echo $(Alert $cWarning "Stopped removing worktree \"$branch\"\nCheck on what has been deleted") && shutdown && trap - 1 2 3 6 && return' 1 2 3 6

    local branch=${1:-$(git symbolic-ref --short HEAD)}
    local prune=${2:-false}

    if [[ $branch == "root" ]] || [[ $branch == "starter_branch" ]]; then
        Message "You can't use gwtr without a parameter in root or starter_branch. Either specify a branch, or cd into that branch and run gwtr"
        return
    fi

    cd $ENV$branch &>/dev/null
    git checkout . &>/dev/null

    findEnv
    if [[ $ENVTYPE == "jv" ]] || [[ $ENVTYPE == "tl" ]]; then
        cd $ENV/ &>/dev/null
    fi

    (
        (
            git worktree remove $branch &>/dev/null
        ) &
        loadingAnimation $! "Removing worktree \"$branch\""
    )

    Success "$branch has been removed."


    if ${prune}; then
        (
            (
                git worktree prune
            ) &
            loadingAnimation $! "Pruning..."
        )
    fi
}
function gwtd() {
    local branch

    if [[ $1 != "" ]]; then
        branch=$1
    elif [[ $1 == "" ]]; then
        branch=$(git symbolic-ref --short HEAD)
    fi

    if [[ $branch == "root" ]] || [[ $branch == "starter_branch" ]]; then
        Message "You can't use gwtr without a parameter in root or starter_branch. Either specify a branch, or cd into that branch and run gwtr"
        return
    fi

    cd $ENV$branch &>/dev/null
    git checkout . &>/dev/null

    findEnv
    if [[ $ENVTYPE == "jv" ]] || [[ $ENVTYPE == "tl" ]]; then
        cd $ENV/ &>/dev/null
    fi

    (
        (
            git worktree remove $branch &>/dev/null
        ) &
        loadingAnimation $! "Removing worktree \"$branch\""
    )

    (
        (
            git branch -D $branch &>/dev/null
            git push origin --delete $branch 2>/dev/null
        ) &
        loadingAnimation $! "Deleting branch \"$branch\""
    )

    Success "Branch \"$branch\" has been deleted."
}
function tagging() {
    if [[ $1 == "" ]]; then
        Message "Add a version ( e.x. tagging v1.0 )"
        return
    else
        if [[ $1 == "-D" ]]; then
            git tag -d $2
            git push --delete origin $2
        else
            git tag -a $1 -m "Updating to ${1}"
            git push origin $1
        fi
    fi
}
function findPackageJSON() {
    # Find directory containing package.json
    if [ -f package.json ]
    then
        dir=$(dirname 'package.json')
        return
    fi

    for (( i=1; i <= 3; i++ ))
    do
        for SDIR in `fn ${1=.} 'package.json' $i`
        do
            dir=$(dirname $SDIR)
        done
        [[ $dir != '' ]] && break
    done
}
function start() {
    # Usage: Start  [ stylesFolderName <default:styles> <optional> ] [ -i Install Only <optional> ]
    local INSTALL_ONLY=false
    if [[ $1 == '-i' ]]; then
        INSTALL_ONLY=true
    fi

    local dir=''
    # starting directory for redirect when finished
    pushd $PWD 1>/dev/null

    if [[ $INSTALL_ONLY ]]; then
        findPackageJSON ${2:$(git symbolic-ref --short HEAD)}
        echo $(findPackageJSON ${2:$(git symbolic-ref --short HEAD)})
    else
        findPackageJSON $@
        echo $(findPackageJSON $@)
    fi

    if [[ $dir != '' ]]
    then
        # Catch for exiting on ctrl+c for exit message and returning from packaged dir
        trap 'echo && echo $(colorText $cMessage "...Kickoff Stopped") && shutdown && popd 1>/dev/null && trap - 1 2 3 6 && return' 1 2 3 6

        # cd to dir containing package.json
        cd $dir &>/dev/null

        (
            (
                npm install &>/dev/null
            ) &
            loadingAnimation $! "Installing NPM and stuff in $dir. This may take up to a few minutes."
        )

        if ! $INSTALL_ONLY; then
            # Start gulp
            Success "Starting Kickoff in $dir"
            Message 'To stop, press Control-C\n'

            gulp
        else
            Success " √ Kickoff installed"
            echo
            - &>/dev/null
        fi
    else
        Warning "! There is no Kickoff found in $PWD/$1 !"
        echo '\ncd into the correct directory,\nuse command\n'
        Message ' > addStyles'
        echo '\nto add a new Kickoff to your project,\nor specify in which folder, not including, your Kickoff exists by doing:\n'
        Message ' > start path/to'
        echo $(formatText 'bold' underline '\nHold up! Wait a minute. Make sure you read ^this^ before you move on.\n')
    fi

    - &>/dev/null
}


#============================================================
#= Setup Functions
#============================================================
function new() {
    if [ -d _dev/ ] || mkdir _dev
    if [ -d desktop/ ] || mkdir desktop && touch desktop/.gitkeep
    if [ -d mobile/ ] || mkdir mobile && touch mobile/.gitkeep
    if [ -d images/ ] || mkdir images && touch images/.gitkeep
    if [ -d script/ ] || mkdir script && touch script/.gitkeep
    if [ -d styles/ ] || addStyles
}
function newTL() {
    if [ -d _dev/ ] || mkdir _dev
    if [ -d images/ ] || mkdir images && touch images/.gitkeep
    if [ -d layouts/ ] || mkdir layouts && touch layouts/.gitkeep
    if [ -d script/ ] || mkdir script && touch script/.gitkeep
    if [ -d templates/ ] || mkdir templates && touch templates/.gitkeep
    if [ -d styles/ ] || addStyles
}
function addStyles() {
    pushd $PWD 1>/dev/null

    if [[ $1 != '' ]]
    then
        if [ -d $@/styles/ ]; then
            Warning "Kickoff already exists at $@/styles"
            return
        else
            Message "Adding Kickoff to $@"
            $@
        fi
    else
        if [ -d styles/ ]; then
            Warning "Kickoff already exists at /styles"
            return
        else
            Message "Adding Kickoff to /styles"
            mkdir styles
            styles
        fi
    fi

    trap 'echo && echo $(Alert $cWarning "Stopped Adding Kickoff") && shutdown && popd 1>/dev/null && trap - 1 2 3 6 && return' 1 2 3 6

    (
        (
            git init &> /dev/null
            git remote add kickoff git@github.com:jobvite-github/Kickoff.git &> /dev/null
            git fetch kickoff &> /dev/null
            git checkout kickoff/master &> /dev/null
            rm -rf .git
        ) &
        loadingAnimation $! "Adding Kickoff"
    )

    popd 1>/dev/null

    #find new Kickoff folder
    dir=''
    findPackageJSON $@
    (
        npm install &>/dev/null
    ) &
    loadingAnimation $! "Installing Kickoff"

    Success "Kickoff added to $dir"

    trap - 1 2 3 6
}

function mvCWS() {
    if [ ! -d ~/Employ/ ]; then
        mkdir ~/Employ
    fi

    if [ -d ~/Documents/CWS/.git ]; then
        mv ~/Documents/CWS ~/Employ/Jobvite/
    elif [ -d ~/Documents/Jobvite/CWS/.git ]; then
        mv ~/Documents/Jobvite/CWS ~/Employ/Jobvite/
    elif [ -d ~/Jobvite/CWS/.git ]; then
        mv ~/Jobvite/CWS ~/Employ/Jobvite/
    fi
}
function repairWorktrees() {
    findEnv
    if [[ $ENVTYPE == "jv" ]] || [[ $ENVTYPE == "tl" ]]; then
        $ENV$branch
    else
        Error "No environment found"

        read "Do you want to continue? (y/n) " REPLY

        case $REPLY in
            [yY][eE][sS]|[yY])
                echo
                continue
            ;;
            [nN][oO]|[nN]|''|*)
                echo
                Message "Bye"
                return
            ;;
        esac
    fi

    local repairNeeded=false

    (
        (
            git for-each-ref --shell --format="ref=%(refname:short)" refs/heads | \
            while read entry
            do
                eval "$entry"
                if [ -d $ENV$ref ]; then
                    if [ ! -d $ENV.git/worktrees/$ref ]; then
                        repairNeeded=true

                        # Create worktree ref
                        mkdir $ENV.git/worktrees/$ref
                        -
                        $ENV.git/worktrees/$ref

                        if [ ! -f COMMIT_EDITMSG ]; then
                            # Create COMMIT_EDITMSG
                            touch COMMIT_EDITMSG
                        fi
                        if [ ! -f FETCH_HEAD ]; then
                            # Create FETCH_HEAD
                            touch FETCH_HEAD
                        fi
                        echo '../..' > commondir
                        echo "$ENV$ref/.git" > gitdir
                        echo "ref: refs/heads/$ref" > HEAD
                        echo $(git log -n 1 --pretty=format:"%H") > ORIG_HEAD

                        -
                        $ENV$ref
                        echo "gitdir: $ENV.git/worktrees/$ref" > .git
                        git reset --quiet
                    fi
                fi
            done
        ) &
        loadingAnimation $! "Repairing worktrees"
    )

    Alert $cSuccess "Worktrees repaired."

    -
}

function repairWorktree() {
    local branch=$(git branch |grep \* | cut -d " " -f2)

    findEnv
    if [[ $ENVTYPE == "jv" ]] || [[ $ENVTYPE == "tl" ]]; then
        $ENV$branch
    else
        Error "No environment found"

        read "Do you want to continue? (y/n) " REPLY

        case $REPLY in
            [yY][eE][sS]|[yY])
                echo
                continue
            ;;
            [nN][oO]|[nN]|''|*)
                echo
                Message "Bye"
                return
            ;;
        esac
    fi

    local ref=''
    local repairNeeded=false

    if [[ $2 != '' ]]; then
        ref=${2:-$(git symbolic-ref --short HEAD)}
    else
        ref=${1:-$(git symbolic-ref --short HEAD)}
        Warning 'No worktree referenced' $cEnd
        read REPLY"?$(Color -m 'What worktree do you want to repair? (enter nothing to skip)'$cEnd -ub): "

        case $REPLY in
            *)
                echo

                if [ -d $ENV$ref ]; then
                    (
                        (
                            if [ ! -d $ENV.git/worktrees/$ref ]; then
                                repairNeeded=true

                                # Create worktree ref
                                mkdir $ENV.git/worktrees/$ref
                            fi

                            #============================================================
                            #= Debug
                            #============================================================
                            # echo 'ENV ~> '$ENV
                            # echo 'ref ~> '$ref
                            # echo 'repairNeeded ~> '$repairNeeded
                            #============================================================

                            $ENV.git/worktrees/$ref

                            if [ ! -f COMMIT_EDITMSG ]; then
                                # Create COMMIT_EDITMSG
                                touch COMMIT_EDITMSG
                            fi
                            if [ ! -f FETCH_HEAD ]; then
                                # Create FETCH_HEAD
                                touch FETCH_HEAD
                            fi
                            echo '../..' > commondir
                            echo "$ENV$ref/.git" > gitdir
                            echo "ref: refs/heads/$ref" > HEAD
                            echo $(git log -n 1 --pretty=format:"%H") > ORIG_HEAD

                            -
                            $ENV$ref
                            echo "gitdir: $ENV.git/worktrees/$ref" > .git
                            git reset --quiet
                        ) &
                        loadingAnimation $! "Repairing worktrees"
                    )
                else
                    Alert "Sorry, $whoami. I can't find the worktree $ENV$ref."
                    return 1
                fi

                Alert $cSuccess "$ref repaired."
            ;;
            '')
                echo
                Message 'Bye!'
            ;;
        esac

    fi

    -
}

alias add='git add'
# alias addStyles='mkdir styles && ./styles && git init && git remote add kickoff https://github.com/jobvite-github/Kickoff.git && git fetch kickoff && git checkout kickoff/master && rm -rf .git'
alias back='git reset HEAD~1'
alias bset='git branch --set-upstream-to=origin/$(git symbolic-ref --short HEAD) $(git symbolic-ref --short HEAD)'
alias branch='git branch'
alias branches='git branch --list'
alias bkto='git reset --hard origin/$(git symbolic-ref --short HEAD)'
alias cam='git add . && git commit -m'
alias ch='git checkout'
alias chd='git checkout develop'
alias chma='git checkout master'
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
alias mpeek='git log master.. --graph $(git symbolic-ref --short HEAD) --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}'
alias newb='git checkout -b'
alias pages='git stash && git checkout gh-pages'
alias peek='git fetch && git log --graph $(git symbolic-ref --short HEAD) --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20} --'
alias peekall='git log --graph origin --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}'
alias poke='git push origin $(git symbolic-ref --short HEAD)'
alias pop='git stash pop'
alias pud='git pull origin develop'
alias push='git push'
alias pushall='git push && git push origin --tags'
alias pull='git pull'
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
alias stats='git log --stat --all --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-50}'
alias tag='git tag'
alias tags='git tag -l'
alias tug='gitPull'
alias whichup=whichupstream='git branch -vv'

#-------------------------------------------------------------
# SFTP / FileZilla
#-------------------------------------------------------------
function chpm() {
    local branch=$(git branch |grep \* | cut -d " " -f2)

    # Reset Permissions Script
    Message 'Please enter the folder to update permissions:'
    read FOLDER
    Message "Updating permissions of $branch/$FOLDER"
    colorText $cSuccess "Your FZ password is copied, paste it now"
    echo "chmod 777 $FOLDER" | fz >/dev/null
}
function fz() {
    local branch=$(git branch |grep \* | cut -d " " -f2)

    if [[ $1 != "" ]]; then
        echo $@
        echo $FZPWD | pbcopy && sftp $FZUSER@sftp.jobvite.com:/uploads/$1
    else
        echo $FZPWD | pbcopy && sftp $FZUSER@sftp.jobvite.com:/uploads/$branch
    fi
}
function getdev() {
    if [ -d _dev/dev ] || mkdir -p _dev/dev
    (
        echo $FZPWD | pbcopy && sftp -r $FZUSER@sftp.jobvite.com:/uploads/$(git symbolic-ref --short HEAD)/dev
        get -r dev/
    )

}
alias fzu="echo $FZPWD | pbcopy | sftp $FZUSER@sftp.jobvite.com:/uploads/"
alias fzr="echo $FZPWD | pbcopy | sftp $FZUSER@sftp.jobvite.com:/uploads/$(git symbolic-ref --short HEAD)"

#-------------------------------------------------------------
# NPM
#-------------------------------------------------------------
alias naf='npm audit fix'
alias ncui='ncu -u && npm install'
alias ncuif='ncu -u && npm install && npm audit fix'

#-------------------------------------------------------------
# Heroku
#-------------------------------------------------------------
alias apps='heroku list'
alias hbkto='git reset --hard heroku/$(git symbolic-ref --short HEAD)'
alias hl='heroku logs --tail'
alias hp='git push heroku master'
alias hpt='git push heroku --tags'

#-------------------------------------------------------------
# Build
#-------------------------------------------------------------
alias watch='build --deploy --watch'
alias deploy='build --deploy'
alias assets='build --deploy -task --assets'
alias djs='build --deploy -task --js'

#-------------------------------------------------------------
# Zip Password
#-------------------------------------------------------------
alias zipit='zip -er $1.zip $2'

# End Aliases / Functions
#============================================================


#============================================================
# tput Text Formatting
#============================================================

#- Colors
Black='#000000'
Gray='#D0CFD0'
DarkGray='#202020'
White='#FFFFFF'
Red='#C8334D'
Orange='#FEA42F'
Yellow='#C7C748'
Green='#43CC63'
Teal='#8AFFC8'
Blue='#88D1FE'
DarkBlue='#4DACFF'
Dark='#615340'

cSuccess=$Green
cWarning=$Orange
cError=$Red
cMessage=$Blue
cEnd=$(tput sgr0)

ALERTWIDTH=

#Set columns for alert width
function setAlertWidth() {
    if [ $(tput cols) -ge 150 ]; then
        ALERTWIDTH=150
    else
        ALERTWIDTH=$(tput cols)
    fi
}

#- Coloring Functions
function Success() {
    echo -e $(Color -c $cSuccess -m $1 -b)
}
function Warning() {
    echo -e $(Color -c $cWarning -m $1 -b)
}
function Error() {
    echo -e $(Color -c $cError -m $1 -b)
}
function Message() {
    echo -e $(Color -c $cMessage -m $1)
}
function Color() {
    # Usage: Color  [ -m Message <required> ] [ -c Color <required> ]
    #               [ -n normal <optional> ] [ -b bold <optional> ] [ -u underline <optional> ]
    local STR COLOR NORMAL BOLD UNDERLINE
    while getopts 'm:c:nbu' flag
    do
        case $flag in
            m) STR=$OPTARG;;
            c) COLOR=$OPTARG;;
            n) NORMAL='normal';;
            b) BOLD='bold';;
            u) UNDERLINE='underline';;
        esac
    done

    if [ $OPTIND -eq 1 ]; then
        if [[ $2 != '' ]]; then
            COLOR=$1
            STR=$2
        else
            STR=$1
        fi
    fi
    shift $((OPTIND-1))

    echo -e $(formatText $NORMAL $BOLD $UNDERLINE "$(colorText ${COLOR:-$Blue} $STR)")
}
function Highlight() {
    # $1: highlight color <required>
    # $2: text content <required>
    # $3: spacing character <optional>
    res=''
    echo -e "$(tput setab $(fromHex $1))$res$2$cEnd"
}

#- Formatting Functions
function Alert() {
    txt_color=$Black;
    color=$cWarning;
    space=''
    str=''

    setParams $@

    echo -e $(Color $txt_color "$(HighlightLine $color $str)")
}
function Prompt() {
    REPLY=''
    color=$Teal;
    str=''

    setParams $@

    read $str REPLY

    return $REPLY
}
function PromptYN() {
    local str=$1
    confirm=$2
    deny=$3

    read $str REPLY

    case $REPLY in [yY][eE][sS]|[yY]|[jJ]|'')

        echo
        echo 'Okay. Will do!'
        $confirm
        return true
        ;;
        *)
        echo
        echo 'Okay. I will pass on that for now.'
        $deny
        return false
        ;;
    esac
}
function setParams() {
    if [[ $3 != "" ]]; then
        txt_color=$1
        color=$2
        str=$3
    elif [[ $2 != "" ]]; then
        color=$1
        str=$2
    else
        str=$1
    fi
}
function setString() {
    setAlertWidth

    space=''
    delimeter=${1:-' '}

    if [[ $delimeter == " " ]]; then
        for (( i = 1; i <= ($ALERTWIDTH-${#str}-1); i += 1 )); do
            space=$space$delimeter
        done
        str="$str$space"
    else
        for (( i = 1; i <= ($ALERTWIDTH-${#str}-1) / 2; i += 1 )); do
            space=$space$delimeter
        done
        str="$space$str$space "
    fi
}
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
function HighlightLine() {
    # $1: highlight color <required>
    # $2: text content <required>
    color=${1-null}

    res=''

    if [[ color ]]; then
        str=$2
        setString ${3-'-'}
        res=$res
    else
        str=$1
        setString ${2-'-'}
        res=$res
    fi
    res="$(tput setab $(fromHex $1))$res $str"

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
    # if [[ $(contains $@[$#] $cEnd) ]] || res=$res$cEnd

    echo -e $res
}

# End tput Text Formatting
#============================================================

#-------------------------------------------------------------
#
#  Other aliases and functions
#
#  Arguably, some functions defined here are quite big.
#  If you want to make this file smaller, these functions can
#+ be converted into scripts and removed from here.
#
#-------------------------------------------------------------

#-------------------
# Helper Functions
#-------------------

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
    if [[ $3 != "" ]]; then
        find $1 -name "$2" -prune -maxdepth $3
    elif [[ $2 != "" ]]; then
        find $1 -name "$2" -prune -maxdepth 1
    elif [[ $1 != "" ]]; then
        find . -name "$1" -prune -maxdepth 1
    else
        Message 'Enter the name of the file you want to search and, optionally ( as the first argument ), where you want to search.'
    fi
}
function fnd() {
    if [[ $3 != "" ]]; then
        find $1 -name "$2" -type d -prune -maxdepth $3
    elif [[ $2 != "" ]]; then
        find $1 -name "$2" -type d -prune -maxdepth 1
    elif [[ $1 != "" ]]; then
        find . -name "$1" -type d -prune -maxdepth 1
    else
        Message 'Enter the name of the file you want to search and, optionally ( as the first argument ), where you want to search.'
    fi
}
function contains() { case "$1" in *"$2"*) true ;; *) false ;; esac }
#-------------------------------------------------------------

#============================================================
#
#= Animations
#
#============================================================


function patience() {
    local ID=${1-$!}
    MSG=${2-'Please be patient. Doing a lot of work over here...'}
    loadingAnimation $ID $MSG
}

function animationTest() {
    MSG=${1-'Fuck off, I am testing some shit here. 漣'}

    (
        ( sleep 2 ) &

        patience $! $MSG
    )

    (
        ( sleep 2 ) &

        patience $! "I'm sorry. I love you."
    )
}

#!/bin/bash
# Shows a spinner while another command is running. Randomly picks one of 12 spinner styles.
# @args command to run (with any parameters) while showing a spinner.
#       E.g. ‹spinner sleep 10›

function shutdown() {
    tput cnorm
}

function loadingAnimation() {
    # make sure we use non-unicode character type locale
    # (that way it works for any locale as long as the font supports the characters)
    local LC_CTYPE=C

    local pid=$1 # Process Id of the previous running command

    case $(($RANDOM % 15)) in
    0)
        local spin='⠁⠂⠄⡀⢀⠠⠐⠈'
        local charwidth=3
        ;;
    1)
        local spin='-\|/'
        local charwidth=1
        ;;
    2)
        local spin="▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
        local charwidth=3
        ;;
    3)
        local spin="▉▊▋▌▍▎▏▎▍▌▋▊▉"
        local charwidth=3
        ;;
    4)
        local spin='←↖↑↗→↘↓↙'
        local charwidth=3
        ;;
    5)
        local spin='▖▘▝▗'
        local charwidth=3
        ;;
    6)
        local spin='┤┘┴└├┌┬┐'
        local charwidth=3
        ;;
    7)
        local spin='◢◣◤◥'
        local charwidth=3
        ;;
    8)
        local spin='◰◳◲◱'
        local charwidth=3
        ;;
    9)
        local spin='◴◷◶◵'
        local charwidth=3
        ;;
    10)
        local spin='◐◓◑◒'
        local charwidth=3
        ;;
    11)
        local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
        local charwidth=3
        ;;
    12)
        local spin='.  .. ...'
        local charwidth=3
        ;;
    13)
        local spin="🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕡🕖🕢🕗🕣🕘🕤🕙🕥🕚🕦"
        local charwidth=4
        ;;
    14)
        local spin="🌑🌒🌓🌔🌕🌖🌗🌘"
        local charwidth=4
        ;;
    esac

    local i=0
    str=$2
    tput civis # cursor invisible
    while kill -0 $pid &>/dev/null; do
        local i=$(((i + $charwidth) % ${#spin}))

        if [[ $str != "" ]]; then
            echo -en "$(tput bold)$(tput setaf $(fromHex ${3=$Yellow})) $(rev<<<${spin:$i:$charwidth}) $str ${spin:$i:$charwidth} $(tput sgr0) \r"
        else
            echo -en "$(tput bold)$(tput setaf $(fromHex ${3=$Yellow})) Please wait  Loading ${spin:$i:$charwidth} $(tput sgr0) \r"
        fi

        echo -en "\033[$1D\r"
        sleep .16
    done

    wait $pid # capture exit code

    echo "$(tput cnorm)"

    return $?
}

#============================================================
