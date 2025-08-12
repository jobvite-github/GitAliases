#== Config Values
#
# !!IMPORTANT!!
# Set these values to ensure your aliases work correctly
#
#============================================================

# Code editor command (default VSCode)
EDITOR_CMD=code

# FZ Stuff
#-------------------------------------------------------------
SFTP_PKEY=''       # FileZilla Public Key
SFTP_HOST=''   # FileZilla Host
SFTP_USER=''              # FileZilla Username
SFTP_PSWD=''        # FileZilla Password

#== End Config Values
#============================================================

###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!
#  WARNING: ALL CONTENT FROM HERE TO EOF WILL UPDATE WITH "checkForGitAliasesUpdate" COMMAND   #
###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!###!!!

# Git Aliases Version
GA_VERSION='v2.2.5'
GA_AUTOUPDATE=1

function whichGitAliasesVersion() {
    printf '%s\n|-------------------|\n' "GitAliases Versions" "LOCAL: $GA_VERSION" "REMOTE: $(remoteGitAliasesVersion)"
}
function remoteGitAliasesVersion() {
    local GA_REMOTE_PROFILE='https://raw.githubusercontent.com/jobvite-github/GitAliases/main/.profile'
    local GA_VERSION_REMOTE=$(curl -s "$GA_REMOTE_PROFILE" | grep -Eo "GA_VERSION='v[0-9]+\.?[0-9]+\.[0-9]+'" | sed -E "s/GA_VERSION='(v[0-9]+\.[0-9]+\.[0-9]+)'/\1/")
    echo $GA_VERSION_REMOTE
}
function checkForGitAliasesUpdate() {
    local GA_VERSION_LOCAL=$GA_VERSION
    local GA_VERSION_REMOTE=$(remoteGitAliasesVersion)

    if [ -n "$GA_VERSION_REMOTE" ] && [ -n "$GA_VERSION_LOCAL" ]; then
        if [[ "$(printf '%s\n' "$GA_VERSION_LOCAL" "$GA_VERSION_REMOTE" | sort -V | head -n 1)" == "$GA_VERSION_LOCAL" && "$GA_VERSION_REMOTE" != "$GA_VERSION_LOCAL" ]]; then
            if promptYesNo "$(Warning "Your GitAliases .profile file is older than the GitAliases repo. Do you want to update from $GA_VERSION_LOCAL to $GA_VERSION_REMOTE?")"; then
                # Check for valid config variables locally
                remote_version_line_number=$(curl -s "$GA_REMOTE_PROFILE" | grep -n "GA_VERSION_LOCAL='" | head -n 1 | cut -d: -f1)
                local_version_line_number=$(grep -n "GA_VERSION_LOCAL='" "$HOME/.profile" | head -n 1 | cut -d: -f1)

                remote_content=$(
                    echo "$(awk '/^###!!!.*(###|!!!)$/{exit}1' "$HOME/.profile")"
                    echo
                    echo "$(curl -s "$GA_REMOTE_PROFILE" | awk '/^###!!!.*(###|!!!)$/{found=1} found')"
                )

                # Combine the parts and overwrite the local profile
                {
                    printf "%s" "$remote_content" > "$HOME/.profile"
                } > "$HOME/.profile"

                GitSuccess "GitAliases update complete." && reload
            fi
        fi
    fi
}

# Load / Edit / Update .profile
#-------------------------------------------------------------
alias config='$EDITOR_CMD ~/.profile && GitInProgress "Editing ~/.profile. Run the \`reload\` function, or open a new session, when you finish to use your changes"'
alias reload='source ~/.profile &>/dev/null && GitSuccess ".profile Reloaded" && if [[ "$GA_AUTOUPDATE" -eq 1 ]]; then; checkForGitAliasesUpdate; fi'

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
function contains() { 
    case "$1" in
        *"$2"*) true ;;
        *) false ;; 
    esac
}
function renameCurrentDirectory() {
    local new_dir_name="$1"

    # Check if the new directory name is valid
    if [[ ! "$new_dir_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        Error "Invalid directory name. Please use only alphanumeric characters, hyphens, and underscores."
        return 1
    fi

    # Rename the current directory
    local current_dir=$(pwd)
    local parent_dir=$(dirname "$current_dir")
    local new_dir_path="$parent_dir/$new_dir_name"

    if ! mv "$current_dir" "$new_dir_path"; then
        Error "Failed to rename the directory."
        return 1
    fi

    # Change to the renamed directory
    cd "$new_dir_path"
}
#------------------------------------------------------------

#============================================================
# Text Formatting (tput)
#============================================================

#- Colors
declare -A colors=(
    [Black]='#000000'
    [Gray]='#D0CFD0'
    [DarkGray]='#202020'
    [White]='#FFFFFF'
    [Red]='#C8334D'
    [Orange]='#FEA42F'
    [Yellow]='#C7C748'
    [Green]='#43CC63'
    [Teal]='#8AFFC8'
    [Blue]='#88D1FE'
    [DarkBlue]='#4DACFF'
    [Dark]='#615340'
)
Black=${colors[Black]}
Gray=${colors[Gray]}
DarkGray=${colors[DarkGray]}
White=${colors[White]}
Red=${colors[Red]}
Orange=${colors[Orange]}
Yellow=${colors[Yellow]}
Green=${colors[Green]}
Teal=${colors[Teal]}
Blue=${colors[Blue]}
DarkBlue=${colors[DarkBlue]}
Dark=${colors[Dark]}

cSuccess=${colors[Green]}
cWarning=${colors[Orange]}
cError=${colors[Red]}
cCaution=${colors[Yellow]}
cMessage=${colors[Blue]}

function hexToColor() {
    local hex_value=$1
    
    # Validate hex value
    if [[ ! $hex_value =~ ^#[0-9a-fA-F]+$ ]]; then
        echo "Invalid hex value: $hex_value"
        return 1
    fi

    # Remove '#' from hex value
    hex_value=${hex_value#"#"}

    r=$(printf '0x%0.2s' "$hex_value")
    g=$(printf '0x%0.2s' ${hex_value#??})
    b=$(printf '0x%0.2s' ${hex_value#????})
    rgb=$(((r<75?0:(r-35)/40)*6*6+(g<75?0:(g-35)/40)*6+(b<75?0:(b-35)/40)+16))

    echo $rgb
}
function hexToTput() {
    local hex_value=$1

    # Validate hex value
    if [[ ! $hex_value =~ ^#?[0-9a-fA-F]+$ ]]; then
        echo "Invalid hex value: $hex_value"
        return 1
    fi

    # Remove '#' from hex value
    hex_value=${hex_value#"#"}

    # Convert hex to decimal
    local decimal_value=$((16#$hex_value))

    # Map decimal value to tput color value
    local tput_color=$((decimal_value % 8 + 30))

    echo $tput_color
}
function formatText() {
    local -A formatMap=(
        [normal]=$(tput sgr0)
        [bold]=$(tput bold)
        [underline]=$(tput smul)
        [nounderline]=$(tput rmul)
    )
    local str=''
    for arg in "$@"; do
        if [[ ${formatMap[$arg]} ]]; then
            str+="${formatMap[$arg]}"
        fi
    done
    str+="${@: -1}"
    
    echo -e $str$(tput sgr0)
}
function adjustToTerminalWidth() {
    local string="$1"
    local terminal_width=$(tput cols)

    if [[ ${#string} -gt $terminal_width ]]; then
        local truncated_string="${string:0:$((terminal_width - 3))}..."
        echo "$truncated_string"
    elif [[ ${#string} -lt $terminal_width ]]; then
        local padding_length=$((terminal_width - ${#string}))
        local padding=$(printf '%*s' "$padding_length" '')
        echo "${string}${padding}"
    else
        echo "$string"
    fi
}
function colorText() {
    local color=${1:-$Yellow}
    local output="${2:-""}"

    output="$(tput setaf $(hexToColor $color))$output"
    
    echo -e $output$(tput sgr0)
}
function Color() {
    # Usage: Color  [ -m Message <required> ] [ -c Color <required> ]
    #               [ -n normal <optional> ] [ -b bold <optional> ] [ -u underline <optional> ] [ -f limit to terminal window width <optional> ]
    local STR COLOR NORMAL BOLD UNDERLINE FULLWIDTH=false OUTPUT
    while getopts 'm:c:nbuf' flag
    do
        case $flag in
            m) STR=$OPTARG;;
            c) COLOR=$OPTARG;;
            n) NORMAL='normal';;
            b) BOLD='bold';;
            u) UNDERLINE='underline';;
            f) FULLWIDTH=true;;
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

    if $FULLWIDTH; then
        local output_length=${#STR}
        local terminal_width=$(tput cols)

        # Adjust the output based on terminal width
        OUTPUT=$(adjustToTerminalWidth "$STR")
    else
        OUTPUT=$STR
    fi

    echo -e $(formatText $NORMAL $BOLD $UNDERLINE "$(colorText ${COLOR:-$Blue} $OUTPUT)")
}
function Highlight() {
    local highlightColor=${1:-$Yellow}
    local output="${2:-""}"
    local textColor="$3"

    if [[ $3 != "" ]]; then
        echo -e "$(tput setab $(hexToColor $highlightColor))$(colorText $textColor $output)$(tput sgr0)"
    else
        echo -e "$(tput setab $(hexToColor $highlightColor))$output$(tput sgr0)"
    fi
}
function HighlightLine() {
    local highlightColor=${1:-$Yellow}
    local output="$(adjustToTerminalWidth "$2")"
    local textColor="$3"

    Highlight $highlightColor "$output" $textColor
}
#- Formatting Functions
function Alert() {
    local txt_color=${1:-$Black}
    local color=${2:-$cWarning}
    local str=${3:-''}

    echo -e $(HighlightLine $color "$(Color $txt_color "$str")")
}

#============================================================
#= Prompts
#============================================================
# Function to prompt for yes/no input
function promptYesNo() {
    local msg="${1:-Do you want to proceed?}"
    local response
    echo -n "$msg (y/n): "
    read response
    echo
    case $response in
        [Yy] ) return 0;;
        [Nn] ) return 1;;
        * ) return 2;;
    esac
}
# End Prompts
#============================================================

#- Coloring Functions
function Success() {
    echo -e $(Color -c $cSuccess -m ${1:-'Success'} -b)
}
function GitSuccess() {    
    local msg=" ${1:-"$(git show -s --format='%h - %s')"} "
    local icon=" $(echo -e ${2:-'✔'}) "
    local output="$msg"
    local output_length=$((${#icon} + ${#output}))
    local terminal_width=$(tput cols)
    local str=

    str="$(Highlight $DarkGray "$(Color $cSuccess "$icon")")$(Color $cSuccess "$output")"

    DisplayFormattedString
}
function GitInProgress() {
    local msg=" ${1:-'In progress'} "
    local icon=" $(echo -e ${2:-'↻'}) "
    local output="$msg"
    local output_length=$((${#icon} + ${#output}))
    local terminal_width=$(tput cols)

    str="$(Highlight $DarkGray "$(Color $cMessage "$icon")")$(Color $Blue "$output")"

    DisplayFormattedString
}
function GitFailure() {
    local msg=" ${1:-'Error: Something went wrong'} "
    local icon=" $(echo -e ${2:-'✖'}) "
    local output="$msg"
    local output_length=$((${#icon} + ${#output}))
    local terminal_width=$(tput cols)

    str="$(Highlight $cError "$icon")$(Color $cWarning "$output")"

    DisplayFormattedString
}
function Warning() {
    echo -e $(Color $cWarning ${1:-'Warning'})
}
function Error() {
    echo -e $(Color $cError ${1:-'Error'})
}
function Caution() {
    echo -e $(Color $cCaution ${1:-'Caution'})
}
function Message() {
    echo -e $(Color $cMessage ${1:-'Message'})
}
function DisplayFormattedString() {
    tput sgr0
    echo ${1:-$str}
    tput cnorm
}

# End Text Formatting
#============================================================

#============================================================
#
#= Animations
#
#============================================================
#!/bin/bash
# Shows a spinner while another command is running. Randomly picks one of 12 spinner styles.
# @args command to run (with any parameters) while showing a spinner.
#       E.g. ‹spinner sleep 10›

function shutdown() {
    tput cnorm
}
function loadingAnimation() {
    local pid=${1:-$!} # Process Id of the previous running command
    local msg=${2:-"Please hold"} # Message to display
    local spinIndex=${3:-$(($RANDOM % 15))}
    local output=
    local spin='-\|/' # Default spin characters
    local charwidth=1 # Default char width

    # Get the width of the terminal window
    width=$(tput cols)

    # Calculate the padding needed to fill the whole width
    padding=$((width - ${#msg}))

    # ---------------
    #  --  Debug --
    # ---------------
    # echo "pid: $pid"
    # echo "msg: $msg"
    # echo "spin: $spin"
    # echo "charwidth: $charwidth"

    echo -n $(tput civis) # cursor invisible

    case $spinIndex in
    0)
        spin='⠁⠂⠄⡀⢀⠠⠐⠈'
        # charwidth=3
        ;;
    1)
        spin='-\|/'
        # charwidth=1
        ;;
    2)
        spin="▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
        # charwidth=3
        ;;
    3)
        spin="▉▊▋▌▍▎▏▎▍▌▋▊▉"
        # charwidth=3
        ;;
    4)
        spin='←↖↑↗→↘↓↙'
        # charwidth=3
        ;;
    5)
        spin='▖▘▝▗'
        # charwidth=3
        ;;
    6)
        spin='┤┘┴└├┌┬┐'
        # charwidth=3
        ;;
    7)
        spin='◢◣◤◥'
        # charwidth=3
        ;;
    8)
        spin='◰◳◲◱'
        # charwidth=3
        ;;
    9)
        spin='◴◷◶◵'
        # charwidth=3
        ;;
    10)
        spin='◐◓◑◒'
        # charwidth=3
        ;;
    11)
        spin='⣾⣽⣻⢿⡿⣟⣯⣷'
        # charwidth=3
        ;;
    12)
        spin='.  .. ...'
        # charwidth=3
        ;;
    13)
        spin="🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕡🕖🕢🕗🕣🕘🕤🕙🕥🕚🕦"
        # charwidth=4
        ;;
    14)
        spin="🌑🌒🌓🌔🌕🌖🌗🌘"
        # charwidth=4
        ;;
    esac

    local i=0
    while kill -0 $pid &>/dev/null; do
        i=$(((i + charwidth) % ${#spin}))

        if [[ $msg != "" ]]; then
            output="$(tput bold)$(tput setaf $(hexToColor ${3=$Yellow})) ${spin:$i:$charwidth} $msg ${spin:$i:$charwidth}"
        else
            output="$(tput bold)$(tput setaf $(hexToColor ${3=$Yellow})) Please wait  Loading ${spin:$i:$charwidth}"
        fi

        # Calculate available width of the terminal
        terminal_width=$(tput cols)
        output_length=${#output}

        # Adjust the output based on terminal width
        if (( output_length < terminal_width )); then
            padding=$(( terminal_width - output_length ))
            output+="$(printf "%*s" "$padding" " ")"
        elif (( output_length > terminal_width )); then
            output="${output:0:$terminal_width-3}..."
        fi

        echo -en "$output $(tput sgr0)[$1D"
        sleep .1
    done

    echo -n "$(tput cnorm)"
}
function animationTest() {
    MSG=${1-'Testing with a medium length message for 2 seconds.'}
    
    (
        (
            if sleep 2 &>/dev/null; then
                Success "animationTest over with success"
                exit
            else
                Warning "animationTest over with failure"
                echo $(sleep 2)
                exit 1
            fi
        ) &

        loadingAnimation $! $MSG
    )
}
function gitAnimationTest() {
    MSG=${1-'Testing gitAnimationTest() with a medium length message for 2 seconds.'}
    
    (
        ( 
            if sleep 2 &>/dev/null; then
                GitSuccess "gitAnimationTest over with success"
                exit
            else
                GitFailure "gitAnimationTest over with failure"
                echo $(sleep 2)
                exit 1
            fi
        ) &
        echo
        loadingAnimation $! 'Testing gitAnimationTest() with a medium length message for 2 seconds.'
    )

    echo "do stuff"

    (
        ( 
            if sleep 2 &>/dev/null; then
                GitSuccess "2nd gitAnimationTest over with success"
                exit
            else
                GitFailure "2nd gitAnimationTest over with failure"
                echo $(sleep 2)
                exit 1
            fi
        ) &
        loadingAnimation $! "2nd testing gitAnimationTest() with a longer message than the last one by quite a bit for 2 seconds. Now I fill this space with text to lengthen the message. Isn't this just the most interesting stuff?"
    )
}
# End Animations
#============================================================

#============================================================
#= Aliases / Functions
#============================================================

# Git
#-------------------------------------------------------------

# References
function getNearestGitRepo() {
    local hierarchyLimit=${1:-5}
    local currentDir=$(pwd)
    gitRepo=""

    # Check if the current directory itself contains a .git file or folder
    if [ -d "$currentDir/.git" ]; then
        gitRepo="$currentDir"
    else
        # Traverse up the directory hierarchy
        local count=0
        while [ "$currentDir" != "/" ] && [ $count -lt $hierarchyLimit ]; do
            currentDir=$(dirname "$currentDir")
            if [ -d "$currentDir/.git" ]; then
                gitRepo="$currentDir"
                break
            fi
            ((count++))
        done
    fi

    # Find the nearest directory with a .git folder
    if [ -n "$gitRepo" ]; then
        echo "$gitRepo"
        return 0
    else
        Error "No .git directory found within the hierarchy limit. Be sure you are in a branch or repo"
        return 1
    fi
}
function getNearestGitDirectory() {
    echo "$(git rev-parse --show-toplevel)"
}
function getCurrentBranchName() {
    local nearestDir=$(getNearestGitDirectory)
    if [[ $(getNearestGitRepo) == $(getNearestGitDirectory) ]]; then
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [ -n "$branch" ]; then
            # GitSuccess "Current branch: $branch"
            echo $branch
        else
            GitFailure "Detached HEAD state, not on a branch. Checkout to the desired branch first."
            return 1
        fi
    else
        # GitSuccess "Current basename nearestDir: $(basename "$nearestDir")"
        echo "$(basename "$nearestDir")"
    fi

}
function gitRefCheck() {
    # Set repo and branch/worktree paths
    gitPath=$(git rev-parse --absolute-git-dir)
    gitWorktreePath=$(dirname $gitPath)
    gitRepo=$(getNearestGitRepo)
    gitDir=$(getNearestGitDirectory)
    gitRef=$(getCurrentBranchName)

    echo "gitPath: $gitPath"
    echo "gitWorktreePath: $gitWorktreePath"
    echo "gitRepo: $gitRepo"
    echo "gitDir: $gitDir"
    echo "gitRef: $gitRef"
}
function getCurrentWorktreeName() {
    local dir=''
    gitRefCheck &>/dev/null
    if [[ $gitDir == $gitRepo ]]; then
        dir=$(getCurrentBranchName)
    else
        dir=$(getNearestGitDirectory)
    fi
    echo $(basename $dir)
}
function goToGitRepo() {
    gitRefCheck &>/dev/null

    cd $gitRepo &>/dev/null
    popd -n &>/dev/null
}
function goToGitDir() {
    gitRefCheck &>/dev/null
    if [[ $(git rev-parse --show-cdup) ]]; then
        cd $(git rev-parse --show-cdup) &>/dev/null
    elif [[ $(getNearestGitDirectory) != $(getNearestGitRepo) ]]; then
        cd $(getNearestGitDirectory) &>/dev/null
    fi
    popd -n &>/dev/null
}
function checkGitDivergence() {
    if [ -z "$(git symbolic-ref HEAD 2>/dev/null)" ]; then
        GitFailure "The branch '$gitRef' has diverged from the origin."
        
        if promptYesNo "$(Message "Do you want to pull the changes before continuing?")"; then
            (
                (
                    if ! git add . &>/dev/null; then
                        GitFailure "Unable to add any changes"
                        echo $(git add .)
                        exit 1
                    else
                        GitSuccess "Added untracked changes"
                        exit
                    fi
                ) & loadingAnimation $! "Adding untracked changes"

                wait $!
            )
            
            (
                (
                    if ! git stash &>/dev/null; then
                        GitFailure "Unable to stash changes"
                        echo $(git stash)
                        exit 1
                    else
                        GitSuccess "Stashed changes"
                        exit
                    fi
                ) & loadingAnimation $! "Stashing changes"

                wait $!
            )
            
            (
                (
                    if ! ( git fetch origin $gitRef && git pull origin $gitRef ) &>/dev/null; then
                        GitFailure "Unable to update branch"
                        echo $( git fetch origin $gitRef && git pull origin $gitRef )
                        exit 1
                    else
                        GitSuccess "Branch updated"
                        exit
                    fi
                ) & loadingAnimation $! "Updating branch"

                wait $!
            )

            (
                (
                    if ! ( git checkout stash -- . ) &>/dev/null; then
                        GitFailure "Unable to pop last stash"
                        echo $( git checkout stash -- . )
                        exit 1
                    else
                        GitSuccess "Stashed changes popped"
                        exit
                    fi
                ) & loadingAnimation $! "Popping stashed changes"

                wait $!
            )
        fi
    else
        return 0
    fi
}
function worktreeExists() {
    gitRefCheck &>/dev/null
    if [ -z "$gitPath" ]; then
        # GitFailure "Worktree reference '$gitRef' does not exist at $gitPath."
        return 1
    else
        # GitSuccess "Worktree reference '$gitRef' exists at $gitPath."
        return 0
    fi
}
function worktreeCheck() {
    gitRefCheck &>/dev/null
    
    if worktreeExists $gitRef; then
        GitSuccess "Worktree $gitRef exists"
    else
        GitFailure "Worktree $gitRef does not exist"
    fi
}
function updateWorktreePrompt() {
    gitRefCheck &>/dev/null

    GitFailure "Error: Worktree and branch names do not match."
    Color $cWarning "Git Branch Reference:"
    echo "$gitRef"
    Color $cWarning "Local Worktree Directory:"
    echo "$gitDir"
    echo

    echo "Which would you like to update?"
    echo "$(Message '1')) Git Branch Reference"
    echo "$(Message '2')) Local Worktree Directory"
    echo "$(Message '3')) None"
    echo "$(Message '*')) Cancel"
    echo -n ": "

    local response
    read response
    case $response in
        1)
            if worktreeExists; then
                echo "Worktree exists. Setting reference"
                echo "gitdir: $gitPath/.git/worktrees/$gitDir" > .git
                return 0
            else
                Error "Worktree not yet created. Use gwtn to create a new worktree"
                return 1
            fi
            ;;
        2)
            echo "Renaming directory to $gitRef"
            renameCurrentDirectory "$gitRef"
            cd "$gitRepo/$gitRef" &>/dev/null
            return 0
            ;;
        3) 
            echo
            Caution "To remove these errors, be sure to have your Worktree Directory named the same as your Git Branch. To avoid this in the future, use gwtn when creating a new worktree"
            echo
            Error "Worktree and Git branch still do not match"
            return 0
            ;;
        *) 
            echo
            Message "Cancelled"
            return 1
            ;;
    esac

    gitRef=""
    gitPath=""
    gitRepo=""
    gitDir=""
}
function checkValidWorktree() {
    gitRefCheck &>/dev/null

    if worktreeExists; then
        return true
    fi

    if updateWorktreePrompt; then
        return true
    else
        return false
    fi
}
function validateWorktree() {
    if [[ $? == 0 ]]; then
        if ! worktreeExists; then
            if promptYesNo "$(Warning "Do you want to continue anyway?")"; then
                return 0
            fi
        fi
    fi

    return 1
}
function convertDirectoryToWorktree() {
    local cur_git_path=${1:-"$(getNearestGitRepo)"}
    local cur_dir_name=${2:-"$(basename $PWD)"}

    if worktreeExists; then
        echo "gitdir: $1/.git/worktrees/$2" > .git
        GitSuccess "Converted $2 to worktree"
    else
        GitFailure "Unable to convert to worktree: worktree does not exist."
    fi
}
function cmp() {
    gitPush $@
}
# function camp() {
#     if ! checkValidWorktree; then
#         validateWorktree
#     fi


#     if checkGitDivergence; then
#         git add . &>/dev/null
#         gitPush $@
#     fi
# }
function camp() {
    local add_all=true
    local add_args=()
    local pass_args=()

    # Parse arguments for -a flag and collect add arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a)
                add_all=false
                shift
                # Collect all arguments after -a until another flag or end
                while [[ $# -gt 0 && "$1" != -* ]]; do
                    add_args+=("$1")
                    shift
                done
                # If no files were added after -a, show error and exit
                if [[ ${#add_args[@]} -eq 0 ]]; then
                    GitFailure "Error: No files included after -a tag. Include filenames after the -a tag or don't use the tag to add all files."
                    return 1
                fi
                ;;
            *)
                pass_args+=("$1")
                shift
                ;;
        esac
    done

    if ! checkValidWorktree; then
        validateWorktree
    fi

    if checkGitDivergence; then
        if $add_all; then
            git add -A &>/dev/null
        else
            git add "${add_args[@]}" &>/dev/null
        fi
        gitPush "${pass_args[@]}"
    fi
}
function gitPush() {
    # Usage
    #= gitPush
    #= gitPush "my commit message"
    #= gitPush -t <tag>
    #= gitPush -t <tag> "my commit message"
    #= gitPush -t <tag> -m <msg>
    #= gitPush -t <tag> -m <msg> "my commit message"
    #
    # You can specify a branch name by adding that branch name at
    #    the end of the fn call. Example:
    #        gitPush "my commit message" <branch_name>
    #-------------------------------------------------------------
    local branch="$(getCurrentWorktreeName)"

    # Flags
    m=false		#commit message flag
    t=false		#Includes tag
    tm=false	#tag message flag
    f=false		#forced flag
    debug=false #debug flag
    # Messages / Tag
    tag=''	#tag
    tmg=''	#tag message
    msg=''	#commit message

    for (( i = 1; i <= $#; i += 1 )); do
        if [[ ${@[$i]} == '-h' ]] || [[ ${@[$i]} == '--help' ]]; then # if help
            echo "gitPush - Push changes to a Git repository"
            echo ""
            echo "Usage:"
            echo "gitPush"
            echo "gitPush \"my commit message\""
            echo "gitPush -t v1.2.3"
            echo "gitPush -t v1.2.3 \"my commit message\""
            echo "gitPush -t v1.2.3 -m \"my tag message\""
            echo "gitPush -t v1.2.3 -m \"my tag message\" \"my commit message\""
            echo ""
            echo "Options:"
            echo "-h, --help               show brief help"
            echo "-t, --tag <tag>          includes a tag"
            echo "-m, --tag-msg <msg>      specifies a tag message"
            echo "-f, --force              force push changes"
            echo "-c, --current            show current git refs"
            echo "--debug                  log information of current call"
            echo ""
            echo "Note:"
            echo "If no commit message is provided and no tag message is specified when using the -t flag, this will prompt you to include a message with your commit."
            echo ""
            if [[ ${@[$i+1]} == '-c' || ${@[$i+1]} == '--current' ]]; then
                echo "Current Git References"
                echo "----------------------"
                gitRefCheck
                echo "gitPush params"
                echo "----------------------"
                echo "branch: $branch"
                echo "m: $m"
                echo "t: $t"
                echo "tm: $tm"
                echo "f: $f"
                echo "tag: $tag"
                echo "tmg: $tmg"
                echo "msg: $msg"
            fi
            return
        elif [[ ${@[$i]} == '--debug' ]]; then # debug
            debug=true
        elif [[ ${@[$i]} == '-t' || ${@[$i]} == '--tag' ]]; then # if tagged
            t=true
            i+=1
            tag=${@[$i]}
        elif [[ ${@[$i]} == '-m' || ${@[$i]} == '--tag-msg' ]]; then # if tag and commit msg
            tm=true
            i+=1
            tmg=${@[$i]}
        elif [[ ${@[$i]} == '-f' || ${@[$i]} == '--force' ]]; then # if force pushed
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
            if ( ! $debug )
            then
                echo
                Error "Please include a message with your camp"
                Color -c $DarkGray -m '> camp "Your custom message"'
                echo
                return
            fi
        fi
    fi

    if ( $debug ); then
        #============================================================
        #= Debug
        #============================================================
        echo '------------------'
        echo '----- debug ------'
        echo '------------------'
        gitRefCheck
        echo "branch: $branch"
        echo '------ tags ------'
        echo 'm: ' $m
        echo 't: ' $t
        echo 'tm: ' $tm
        echo 'f: ' $f
        echo
        echo '------ info ------'
        echo "tag: $tag"
        echo "tmg: $tmg"
        echo "msg: $msg"
        echo '----- status -----'
        echo 'git status: '
        git status
    else
        goToGitDir

        (
            (
                if git commit -m "$msg" &>/dev/null; then
                    GitSuccess "$(git show -s --format='%s')"
                    exit
                else
                    echo "$(git commit -m "$msg")"
                    exit 1
                fi
            ) &
            loadingAnimation $! "Committing changes"

            wait $!
        )

        if [[ $? != 0 ]]; then
            GitFailure "Error: Failed to commit changes."
            return 1
        fi

        (
            (
                if ( $f ); then
                    if git push origin "$branch" -f &>/dev/null; then
                        GitSuccess "Commits pushed for branch: $branch"
                        exit
                    else
                        GitFailure "Error: Failed to push changes to origin/$branch."
                        echo $(git push origin "$branch" -f)
                        exit 1
                    fi
                else
                    if git push origin "$branch" &>/dev/null; then
                        GitSuccess "Commits pushed for branch: $branch"
                        exit
                    else
                        GitFailure "Error: Failed to push changes to origin/$branch."
                        echo $(git push origin "$branch")
                        exit 1
                    fi
                fi
            ) &
            loadingAnimation $! "Pushing changes"

            wait $!
        )

        if [[ $? != 0 ]]; then
            GitFailure "Error: Failed to commit changes."
            return 1
        fi

        (
            (
                if ( $t ); then
                    if git tag -a "$tag" -m "$tmg" &>/dev/null; then
                        GitSuccess "Success: Tag $tag created."
                        exit
                    else
                        GitFailure "Error: Failed to create tag $tag."
                        echo $(git tag -a "$tag" -m "$tmg")
                        exit 1
                    fi

                    if git push origin --tags &>/dev/null; then
                        GitSuccess "Success: Tags pushed to origin."
                        exit
                    else
                        GitFailure "Error: Failed to push tags to origin."
                        echo $(git push origin --tags)
                        exit 1
                    fi
                fi
            ) &
            loadingAnimation $! "Pushing tags"

            wait $!
        )

        if [[ $? != 0 ]]; then
            GitFailure "Error: Failed to commit changes."
            return 1
        fi
    fi
}
function gitPull() {
    # Usage
    #= gitPull
    #
    # You can specify a branch name by adding that branch name at
    #    the end of the fn call. Example:
    #        gitPull <branch_name>
    #-------------------------------------------------------------
    local branch="${1:-$(getCurrentWorktreeName)}"

    (
        (
            if git fetch origin $branch &>/dev/null && git pull origin $branch &>/dev/null; then
                GitSuccess "Branch up to date."
                exit
            else
                GitFailure "Error: Failed to pull."
                echo $(git fetch origin $branch && git pull origin $branch)
                exit 1
            fi
        ) &
        loadingAnimation $! "Updating branch: $branch"
    )
}

function gwtn() {
    local SKIP_INSTALL=false
    local NO_OPEN=false
    local DETACH=false
    local existingBranch=false
    local branch=""

    # Function to check if a flag is present
    function hasFlag() {
        for var in "$@"; do
            if [[ $var == "$1" ]]; then
                return 0
            fi
        done
        return 1
    }

    # Process the flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s | --skip-install | --skip)
                SKIP_INSTALL=true
                ;;
            -no | --noopen)
                NO_OPEN=true
                ;;
            -m | --make)
                SKIP_INSTALL=true
                NO_OPEN=true
                ;;
            -d | --detach)
                DETACH=true
                ;;
            -h | --help)
                echo "gwtn (Git Worktree New) - Creates a new JV project worktree"
                echo " "
                echo "gwtn [branch] [options]"
                echo " "
                echo "options:"
                echo "-h, --help                            show brief help"
                echo "-s, --skip-install=SKIP_INSTALL       specify an action to use"
                echo "-no, --noopen=NO_OPEN                 specify to open in editor"
                echo "-m, --make=MAKE                       equivalent to calling gwtn -s -no"
                echo "--detach=DETACH                       makes worktree, but no push to origin"
                if hasFlag "-c" "$@"; then
                    echo "Parameters"
                    echo "----------------------"
                    echo "SKIP_INSTALL: $SKIP_INSTALL"
                    echo "NO_OPEN: $NO_OPEN"
                    echo "DETACH: $DETACH"
                    echo "existingBranch: $existingBranch"
                    echo "branch location: $(getNearestGitRepo)/$branch"
                    echo "branch: $branch"
                fi
                return
                ;;
            --log)
                echo "gwtn parameters"
                echo "----------------------"
                echo "SKIP_INSTALL: $SKIP_INSTALL"
                echo "NO_OPEN: $NO_OPEN"
                echo "DETACH: $DETACH"
                echo "existingBranch: $existingBranch"
                echo "branch location: $(getNearestGitRepo)/$branch"
                echo "branch name: $branch"
                ;;
            *)
                if [[ -z $branch ]]; then
                    branch=$1
                fi
                ;;
        esac
        shift
    done

    if [[ $branch != "" ]]; then
        goToGitRepo

        if [ -d $(getNearestGitRepo)/"starter_branch" ]; then
            Error "starter_branch is in your worktrees. Remove the starter_branch worktree and try again."
            return
        fi

        if [ -d $(getNearestGitRepo)/$branch ]; then
            Caution "$(getNearestGitRepo)/$branch is already in your worktrees. Moving there now..."
            cd $(getNearestGitRepo)/$branch &>/dev/null
            return
        fi

        trap 'echo && echo $(Alert $cWarning "Stopped creating worktree \"$branch\". Check on what has been created so far") && shutdown && trap - 1 2 3 6 && return' 1 2 3 6

        if ([[ $branch != 'starter_branch' ]]); then
            if git switch starter_branch &>/dev/null; then
                gitPull
            else
                GitFailure "The was an issue when checking out into starter_branch"
                git switch starter_branch
                return
            fi
        fi

        (
            (
                if git show-ref --quiet refs/remotes/origin/"$branch"; then
                    existingBranch=true
                    git fetch origin $branch &>/dev/null
                    if git worktree add --track -B $branch ./$branch origin/$branch &>/dev/null; then
                        GitSuccess "Worktree added: $branch"
                        git switch root &>/dev/null
                        cd "$branch/" &>/dev/null
                        mkdir _dev &>/dev/null
                        exit
                    else
                        GitFailure "Unable to create worktree"
                        git switch root &>/dev/null
                        echo $(git worktree add --track -B $branch ./$branch origin/$branch)
                        exit 1
                    fi
                else
                    existingBranch=false
                    if git worktree add $branch &>/dev/null; then
                        GitSuccess "Worktree added: $branch"
                        git switch root &>/dev/null
                        cd "$branch/" &>/dev/null
                        mkdir _dev &>/dev/null
                        exit
                    else
                        GitFailure "Unable to create worktree"
                        git switch root &>/dev/null
                        echo $(git worktree add $branch)
                        exit 1
                    fi
                fi
            ) &
            
            loadingAnimation $! "Setting up worktree \"$branch\""
        )

        cd $(getNearestGitRepo)/$branch &>/dev/null

        if ! $SKIP_INSTALL; then
            start -i || { GitFailure "Unable to install npm"; return; }
        fi

        if ! $DETACH; then
            (
                (
                    if $existingBranch; then
                        if git commit -am "Setting up $(getNearestGitDirectory) project in Git" &>/dev/null && git push --set-upstream origin $(getNearestGitDirectory) &>/dev/null; then
                            GitSuccess "Branch created: $branch"
                            exit
                        else
                            GitFailure "Unable to create branch: $branch"
                            echo $(git commit -am "Setting up $(getNearestGitDirectory) project in Git")
                            echo $(git push --set-upstream origin $(getNearestGitDirectory))
                            exit 1
                        fi
                    else
                        if git push origin $branch &>/dev/null; then
                            GitSuccess "Branch linked to repo: $branch"
                            exit
                        else
                            GitFailure "Unable to create branch: $branch"
                            echo $(git push origin $branch)
                            exit 1
                        fi
                    fi
                ) &
                loadingAnimation $! "Setting up in GitHub"
            )
        fi

        if ! $NO_OPEN; then
            (
                (
                    if $EDITOR_CMD .; then
                        exit
                    else
                        GitFailure "Error: Failed to open in your editor."
                        echo $($EDITOR_CMD .)
                        exit 1
                    fi
                ) &
                loadingAnimation $! "Opening in your editor"
            )
        else
            popd &>/dev/null
        fi
    else
        Error "Need a worktree name ( e.x. gwtn myworktree )"
        return
    fi

    goToGitRepo &>/dev/null
}
function gwtr() {
    local ref=${1:-$(getCurrentWorktreeName)}
    trap 'echo && echo $(Alert $cWarning "Stopped removing worktree \"$ref\". Check on what has been deleted") && shutdown && trap - 1 2 3 6 && return' 1 2 3 6

    if ! worktreeExists; then
        GitFailure "Invalid worktree: $ref"
        return
    fi

    if [[ $ref != "root" ]]; then
        goToGitDir &>/dev/null
        git restore . &>/dev/null

        (
            (
                if git worktree remove $ref &>/dev/null; then
                    GitSuccess "$ref has been removed."
                    exit
                else
                    GitFailure "$ref was not removed."
                    echo "$(git worktree remove $ref)"
                    exit 1
                fi
            ) &
            loadingAnimation $! "Removing worktree \"$ref\""
        )
    else
        Error "You can't use gwtr without a parameter in root or starter_branch. Either specify a branch, or cd into that branch and run gwtr"
        return
    fi

    goToGitRepo &>/dev/null
}
# Git worktree rename (current name (optional), target name)
#   renames folder and git branch
function gwtrn() {
    # Set current worktree and target worktree names
    if [[ $2 != "" ]]; then
        local current="$1"
        local target="$2"
    elif [[ $1 != "" ]]; then
        local current="$(getCurrentWorktreeName)"
        local target="$1"
    fi

    (
        (
            # Move branch
            if git branch -m "$current" "$target"; then
                GitSuccess "\"$target\" created"
            else
                GitFailure "Unable to create $target"
                echo $(git branch -m "$current" "$target")
                exit 1
            fi
        ) &
        loadingAnimation $! "Moving worktree \"$current\" to \"$target\""
    )
    (
        (
            # push new branch
            if git push origin -u "$target"; then
                GitSuccess "\"$target\" pushed"
            else
                GitFailure "Unable to push $target"
                echo $(git push origin -u "$target")
                exit 1
            fi
        ) &
        loadingAnimation $! "Pushing worktree \"$target\""
    )

    # Prompt removal of old branch
    if promptYesNo "$(Message "Do you want to remove the $current branch?")"; then
        if git push origin --delete "$current"; then
            GitSuccess "\"$current\" deleted"
        else
            GitFailure "Unable to delete $current"
            exit 1
        fi
    fi

    if ! goToGitRepo; then
        GitFailure "Unable to go to repo"
        
    fi

    (
        (
            # Rename folder and move to it
            if git worktree move $current $target; then
                GitSuccess "Moved worktree \"$current\" to \"$target\""
            else
                GitFailure "Unable to move worktree \"$current\" to \"$target\""
                echo $(git worktree move $current $target)
                exit 1
            fi
        ) &
        loadingAnimation $! "Renaming worktree \"$current\" to \"$target\""
    )

    goToGitRepo &>/dev/null

    if ! cd $target; then
        GitFailure "Unable to change to directory: $target"
    fi

    (
        (
            # Remove worktree reference
            if rm -rf $gitPath; then
                GitSuccess "Removed reference: $gitPath"
            else
                GitSuccess "Unable to remove reference: $gitPath"
                echo $(rm -rf $gitPath)
                exit 1
            fi
        ) &
        loadingAnimation $! "Removing worktree reference for $current"
    )
}
function gwtd() {
    local branch=${1:-$(getCurrentWorktreeName)}

    if ! worktreeExists; then
        GitFailure "Invalid worktree: $branch"
        return
    fi

    if [[ $branch == "" ]] && [[ $branch == "root" ]] || [[ $branch == "starter_branch" ]]; then
        Message "You can't use gwtr without a parameter in root or starter_branch. Either specify a branch, or cd into that branch and run gwtr"
        return
    fi
    
    if promptYesNo "$(Warning "Are you sure you want to delete branch: \"$branch\"")"; then
        goToGitDir &>/dev/null
        git restore . &>/dev/null
        goToGitRepo &>/dev/null

        (
            (
                if git worktree remove $branch &>/dev/null; then
                    GitSuccess "Worktree \"$branch\" removed"
                    exit
                else
                    GitFailure "Unable to remove worktree: $branch"
                    echo $(git worktree remove $branch)
                    exit 1
                fi
            ) &
            loadingAnimation $! "Removing worktree \"$branch\""
        )

        (
            (
                if git branch -D $branch &>/dev/null && git push --no-verify origin --delete $branch &>/dev/null; then
                    GitSuccess "Branch \"$branch\" has been deleted."
                    exit
                else
                    GitFailure "Unable to delete branch: $branch"
                    echo "git branch -D $branch: $(git branch -D $branch)"
                    echo "git push --no-verify origin --delete $branch: $(git push --no-verify origin --delete $branch)"
                    exit 1
                fi
            ) &
            loadingAnimation $! "Deleting branch \"$branch\""
        )

        goToGitRepo &>/dev/null
    else
        Message "Canceling delete"
    fi
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
    local dir=''

    # Find directory containing package.json
    if [ -f package.json ]; then
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

    echo $dir
}
function start() {
    # Usage: Start  [ stylesFolderName <default:styles> <optional> ] [ -i Install Only <optional> ]

    local dir=''
    
    local SKIP_INSTALL=false
    local INSTALL_ONLY=false

    while [ $# -gt 0 ]; do
        case $1 in
            -i | --install-only) INSTALL_ONLY=true ;;
            -s | --skip-install | --skip) SKIP_INSTALL=true ;;
            -d | --dir) dir=$2;;
            *) dir=$1 ;;
        esac
        shift
    done

    local searchDir=${dir:-$(getNearestGitDirectory)}

    if ! $INSTALL_ONLY; then
        dir=$(findPackageJSON $searchDir)
    else
        dir=$(findPackageJSON $@)
    fi

    # Catch for exiting on ctrl+c for exit message and returning from packaged dir
    trap 'echo && GitFailure "Build canceled" && goToGitDir &>/dev/null && return' 1 2 3 6

    if [[ $dir != '' ]]; then
        # cd to dir containing package.json
        cd $dir &>/dev/null

        if ! $SKIP_INSTALL; then
            (
                (
                    # Catch for exiting on ctrl+c for exit message and returning from packaged dir
                    trap 'exit 1' 1 2 3 6
                    
                    if npm install &>/dev/null; then
                        GitSuccess "Kickoff installed"
                        exit
                    else
                        GitFailure "Kickoff not able to be installed"
                        echo $(npm install)
                        exit 1
                    fi
                ) &
                loadingAnimation $! "Installing NPM and stuff in $dir. This may take up to a few minutes."
            )
        else
            echo
        fi

        if ! $INSTALL_ONLY; then
            # Start gulp
            Success "Starting Kickoff in $dir"
            Message 'To stop, press Control-C'

            gulp
        fi
    fi

    cd $searchDir &>/dev/null
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

    trap 'echo && GitFailure "Stopped adding styles" && goToGitDir &>/dev/null && return' 1 2 3 6

    (
        (
            (
                git init &>/dev/null
                git remote add kickoff git@github.com:jobvite-github/Kickoff.git &>/dev/null
                git fetch kickoff &>/dev/null
                git checkout kickoff/master &>/dev/null
                rm -rf .git &>/dev/null
            ) && (
                GitSuccess "Kickoff added"
                exit
            ) || (
                GitFailure "Failed to add Kickoff"
                echo $(git init)
                echo $(git remote add kickoff git@github.com:jobvite-github/Kickoff.git)
                echo $(git fetch kickoff)
                echo $(git checkout kickoff/master)
                echo $(rm -rf .git)
                exit 1
            )
        ) &
        loadingAnimation $! "Adding Kickoff"
    )

    #find new Kickoff folder
    dir=$(findPackageJSON $@)
    (
        (
            # Catch for exiting on ctrl+c for exit message
            trap 'exit 1' 1 2 3 6

            if npm install &>/dev/null; then
                GitSuccess "Kickoff added to $dir"
                exit
            else
                GitFailure "Failed install Kickoff"
                echo $(npm install)
                exit 1
            fi
        ) &
        loadingAnimation $! "Installing Kickoff"
    )
}
function repairWorktrees() {
    gitRefCheck &>/dev/null

    goToGitRepo &>/dev/null

    local repairNeeded=false

    (
        (
            git for-each-ref --shell --format="ref=%(refname:short)" refs/heads | \
            while read entry
            do
                eval "$entry"
                if [ -d $PWD$ref ]; then
                    if [ ! -d $PWD.git/worktrees/$ref ]; then
                        repairNeeded=true

                        # Create worktree ref
                        mkdir $PWD.git/worktrees/$ref
                        -
                        $PWD.git/worktrees/$ref

                        if [ ! -f COMMIT_EDITMSG ]; then
                            # Create COMMIT_EDITMSG
                            touch COMMIT_EDITMSG
                        fi
                        if [ ! -f FETCH_HEAD ]; then
                            # Create FETCH_HEAD
                            touch FETCH_HEAD
                        fi
                        echo '../..' > commondir
                        echo "$PWD$ref/.git" > gitdir
                        echo "ref: refs/heads/$ref" > HEAD
                        echo $(git log -n 1 --pretty=format:"%H") > ORIG_HEAD

                        -
                        $PWD$ref
                        echo "gitdir: $PWD.git/worktrees/$ref" > .git
                        git reset --quiet
                    fi
                fi
            done
        ) &
        loadingAnimation $! "Repairing worktrees"
    )

    Alert $cSuccess "Worktrees repaired."

    goToGitRepo &>/dev/null
}
function repairWorktree() {
    local branch=$(getCurrentWorktreeName)

    goToGitDir &>/dev/null

    local ref=''
    local repairNeeded=false

    if [[ $2 != '' ]]; then
        ref=${2:-$(getNearestGitDirectory)}
    else
        ref=${1:-$(getNearestGitDirectory)}
        Warning 'No worktree referenced' 
        read REPLY"?$(Color -m 'What worktree do you want to repair? (enter nothing to skip)' -ub): "

        case $REPLY in
            *)
                goToGitRepo &>/dev/null
                echo

                if [ -d $PWD$ref ]; then
                    (
                        (
                            if [ ! -d $PWD.git/worktrees/$ref ]; then
                                repairNeeded=true

                                # Create worktree ref
                                mkdir $PWD.git/worktrees/$ref
                            fi

                            #============================================================
                            #= Debug
                            #============================================================
                            # echo 'PWD ~> '$PWD
                            # echo 'ref ~> '$ref
                            # echo 'repairNeeded ~> '$repairNeeded
                            #============================================================

                            $PWD.git/worktrees/$ref

                            if [ ! -f COMMIT_EDITMSG ]; then
                                # Create COMMIT_EDITMSG
                                touch COMMIT_EDITMSG
                            fi
                            if [ ! -f FETCH_HEAD ]; then
                                # Create FETCH_HEAD
                                touch FETCH_HEAD
                            fi
                            echo '../..' > commondir
                            echo "$PWD$ref/.git" > gitdir
                            echo "ref: refs/heads/$ref" > HEAD
                            echo $(git log -n 1 --pretty=format:"%H") > ORIG_HEAD

                            -
                            $PWD$ref
                            echo "gitdir: $PWD.git/worktrees/$ref" > .git
                            git reset --quiet
                        ) &
                        loadingAnimation $! "Repairing worktrees"
                    )
                else
                    Alert "Sorry, $whoami. I can't find the worktree $PWD$ref."
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

    goToGitRepo &>/dev/null
}

alias add='git add'
alias back='git reset HEAD~1'
alias bset='git branch --set-upstream-to=origin/$(getCurrentWorktreeName) $(getCurrentWorktreeName)'
alias branch='git branch'
alias branches='git branch --list'
alias bkto='git reset --hard origin/$(getCurrentWorktreeName)'
alias cam='git add . && git commit -m'
alias ch='git checkout'
alias chd='git checkout develop'
alias chma='git checkout master'
alias chr='git switch root'
alias chs='git checkout sandbox'
alias chsb='git switch starter_branch'
alias clone='git clone'
alias cm='git commit -m'
alias coressh='git config core.sshCommand "ssh -i ~/.ssh/${1} -F /dev/null"'
alias counts='git shortlog -sne'
alias dm='git diff --minimal'
alias fetch='git fetch'
alias fuck='git reset --hard origin/$(getCurrentWorktreeName)'
alias grs='git reset'
alias grsurl='git remote set-url origin'
alias grv='git remote -v'
alias gwt='git worktree'
alias gwtm='gwtn --make $1'
alias gwts='git worktree add $1 $1'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias home='git reset origin/master'
alias lga='git log --graph --all --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)"'
alias mg='git merge'
alias mpeek='git log master.. --graph $(getCurrentWorktreeName) --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}'
alias newb='git checkout -b'
alias pages='git stash && git checkout gh-pages'
alias peek='git fetch && git log --graph origin/$(getCurrentWorktreeName) --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20} --'
alias peekall='git log --graph origin --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}'
alias poke='git push origin $(getCurrentWorktreeName)'
alias pop='git stash pop'
alias pud='git pull origin develop'
alias push='git push'
alias pushall='git push && git push origin --tags'
alias pull='git pull'
alias pset='git push --set-upstream origin $(getCurrentWorktreeName)'
alias ptag='git push origin --tags'
alias rb='git rebase'
alias rbd='git rebase develop'
alias rbm='git rebase master'
alias ref='git reflog'
alias s='git status'
alias setit='git reset --hard origin/$(getCurrentWorktreeName)'
alias shit='git restore .'
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
    local branch=${1:-$(getCurrentWorktreeName)}

    # Reset Permissions Script
    Message 'Please enter the folder to update permissions:'
    read FOLDER
    Message "Updating permissions of $branch/$FOLDER"
    colorText $cSuccess "Your FZ password is copied, paste it now"
    echo "chmod 777 $FOLDER" | fz >/dev/null
}
function fz() {
    local branch=${1:-$(getCurrentWorktreeName)}

    if [[ $1 != "" ]]; then
        echo $@
        echo $SFTP_PSWD | pbcopy && sftp $SFTP_USER@$SFTP_HOST:/uploads/$1
    else
        echo $SFTP_PSWD | pbcopy && sftp $SFTP_USER@$SFTP_HOST:/uploads/$branch
    fi
}
function fzImages() {
    (
        (
            (
                fz $@ << EOF
                chmod 777 images
                chmod 777 images/*
                bye
EOF
            ) &>/dev/null
        ) &
        loadingAnimation $! "Updating images permissions to 777"
    )
}
function getdev() {
    local branch=${1:-$(getCurrentWorktreeName)}

    goToGitDir

    if [ ! -d _dev ] && mkdir _dev

    cd _dev/

    Message "Connecting to FileZilla and downloading the dev folder for $branch"
    echo "When prompted for your password, you can type in your password OR, if you have your \$SFTP_USER and \$SFTP_PSWD set in your aliases global variables, just paste as I've just copied that for you." 
    echo

echo $SFTP_PSWD | pbcopy && sftp -r $SFTP_USER@$SFTP_HOST:/uploads/$branch << EOF
get -r dev
EOF

    goToGitDir
    echo


    if [ -d _dev/dev ] && Success " √ Downloaded /uploads/$branch/dev to $branch/_dev/dev"

}

alias fzu="echo $SFTP_PSWD | pbcopy | sftp $SFTP_USER@$SFTP_HOST:/uploads/"
alias fzr="echo $SFTP_PSWD | pbcopy | sftp $SFTP_USER@$SFTP_HOST:/uploads/$(getCurrentWorktreeName)"

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
alias hbkto='git reset --hard heroku/$(getCurrentWorktreeName)'
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

#-------------------------------------------------------------
#
#  Other aliases and functions
#
#  Arguably, some functions defined here are quite big.
#  If you want to make this file smaller, these functions can
#+ be converted into scripts and removed from here.
#
#-------------------------------------------------------------
