#== Config Values
#
# !!IMPORTANT!!
# Set these values to ensure your aliases work correctly
#
#============================================================
JVPATH=~/Employ/Jobvite/ # Set your JVPATH variable to your Jobvite folder's path. MUST END WITH /
TLPATH=~/Employ/Talemetry/ # Set your TLPATH variable to your Talemetry folder's path. MUST END WITH /

# FZ Stuff
#-------------------------------------------------------------
FZPKEY=''       # FileZilla Public Key
FZHOST=''       # FileZilla Host
FZUSER=''       # FileZilla Username
FZPWD=''        # FileZilla Password

#== End Config Values
#
# Set these values to ensure your aliases work correctly
#============================================================

# Load / Edit / Update .profile
#-------------------------------------------------------------
alias config='code ~/.profile && Highlight $cWarning " Editing ~/.profile $(tput cnorm)"'
alias reload='source ~/.profile && Highlight $cSuccess " .profile Reloaded $(tput cnorm)"'

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
function goToCurrentBranch() {
	local branch=$(git branch |grep \* | cut -d " " -f2)

	findEnv
	cd $ENV$branch
}

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
	local color=${1:=$Yellow}
	local output="${2:=""}"

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
	local color=${1:=$Yellow}
	local output="${2:=""}"

	echo -e "$(tput setab $(hexToColor $color))$output$(tput sgr0)"
}
function HighlightLine() {
	local str=
	local color=

	if [[ $# -eq 1 ]]; then
		str="$1"
	elif [[ $# -eq 2 ]]; then
		color="$1"
		str="$2"
	fi

	str=" ${str:=""} "
	color=${color:=$Yellow}

	Highlight $color "$(adjustToTerminalWidth "$str")"
}
#- Formatting Functions
function Alert() {
	local txt_color=${1:-$Black}
	local color=${2:-$cWarning}
	local str=${3:-''}

	echo -e $(Color $txt_color "$(HighlightLine "$str" $color)")
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
	echo -e $(Color -c $cSuccess -m ${1:='Success'} -b)
}
function GitSuccess() {    
	local msg=" ${1:="$(git show -s --format='%h - %s')"} "
	local icon=" $(echo -e ${2:='\U0002714'}) "
	local output="$msg"
	local output_length=$((${#icon} + ${#output}))
	local terminal_width=$(tput cols)
	local str=

	# Adjust the output based on terminal width
	if (( output_length < terminal_width )); then
		output+="$(printf "%*s" $((terminal_width - output_length)) " ")"
	# elif (( output_length > terminal_width )); then
	#     output="${output:0:$terminal_width-3}..."
	fi

	str="$(Highlight $DarkGray "$(Color $cSuccess "$icon")")$(Color $Blue "$output")"

	echo "$(tput sgr0)"
	echo $(adjustToTerminalWidth "$str")
	echo
}
function GitFailure() {
	local msg=" ${1:='Error: Something went wrong'} "
	local icon=" $(echo -e ${2:='\U0002716'}) "
	local output="$msg"
	local output_length=$((${#icon} + ${#output}))
	local terminal_width=$(tput cols)

	# Adjust the output based on terminal width
	if (( output_length < terminal_width )); then
		output+="$(printf "%*s" $((terminal_width - output_length)) " ")"
	# elif (( output_length > terminal_width )); then
	#     output="${output:0:$terminal_width-3}..."
	fi

	str="$(Highlight $cError "$icon")$(Color $cWarning "$output")"

	echo "$(tput sgr0)"
	echo $(adjustToTerminalWidth "$str")
	echo
}
function Warning() {
	echo -e $(Color $cWarning ${1:='Warning'})
}
function Error() {
	echo -e $(Color $cError ${1:='Error'})
}
function Caution() {
	echo -e $(Color $cCaution ${1:='Caution'})
}
function Message() {
	echo -e $(Color $cMessage ${1:='Message'})
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
	local pid=${1:=$!} # Process Id of the previous running command
	local msg=${2:="Please hold"} # Message to display
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
		local i=$(((i + $charwidth) % ${#spin}))

		if [[ $msg != "" ]]; then
			output="$(tput bold)$(tput setaf $(hexToColor ${3=$Yellow})) $(rev <<< "${spin:$i:$charwidth}") $msg ${spin:$i:$charwidth}"
		else
			output="$(tput bold)$(tput setaf $(hexToColor ${3=$Yellow})) Please wait  Loading ${spin:$i:$charwidth}"
		fi

		# Calculate available width of the terminal
		local terminal_width=$(tput cols)
		local output_length=${#output}

		# Adjust the output based on terminal width
		if (( output_length < terminal_width )); then
			local padding=$(( terminal_width - output_length ))
			output+="$(printf "%*s" "$padding" " ")"
		elif (( output_length > terminal_width )); then
			output="${output:0:$terminal_width-3}..."
		fi

		echo -en "$output $(tput sgr0)\033[$1D"
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
		loadingAnimation $! 'Testing gitAnimationTest() with a medium length message for 2 seconds.'
	)

	echo ""
	echo "do stuff"
	echo ""

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

	# Move to the nearest directory with a .git file/folder
	if [ -n "$gitRepo" ]; then
		echo "$gitRepo"
		return 0
	else
		Error "No .git directory found within the hierarchy limit. Be sure you are in a branch or repo"
		return 1
	fi
}
function getNearestGitDirectory() {
	local hierarchyLimit=${1:-5}
	local currentDir=$(pwd)
	gitDir=""

	# Check if the current directory itself contains a .git file or folder
	if [ -f "$currentDir/.git" ] || [ -d "$currentDir/.git" ]; then
		gitDir="$currentDir"
	else
		# Traverse up the directory hierarchy
		local count=0
		while [ "$currentDir" != "/" ] && [ $hierarchyLimit -gt 0 ]; do
			currentDir=$(dirname "$currentDir")
			if [ -f "$currentDir/.git" ] || [ -d "$currentDir/.git" ]; then
				gitDir="$currentDir"
				break
			fi
			hierarchyLimit=$((hierarchyLimit - 1))
		done
	fi

	# Move to the nearest directory with a .git file/folder
	if [ -n "$gitDir" ]; then
		echo "$gitDir"
		return 0
	else
		echo "$(getNearestGitRepo)"
	fi
}
function goToGitRepo() {
	gitRepo=$(getNearestGitRepo)

	cd $gitRepo &>/dev/null
}
function goToGitDir() {
	gitDir=$(getNearestGitDirectory)

	cd $gitDir &>/dev/null
}
function gitRefCheck() {	
	# Read the line from the .git file
	read -r line < "$(getNearestGitDirectory)/.git"
	
	# Extract path values
	gitRef=$(basename "$line")
	gitPath=$(dirname "$line")
	gitRepo=$(getNearestGitRepo)
	gitDir=$(basename "$(getNearestGitDirectory)")
}


function checkGitDivergence() {
	local branch_name=$(git symbolic-ref --short HEAD)
	local remote_branch="origin/$branch_name"

	local local_commit=$(git rev-parse HEAD)
	local remote_commit=$(git rev-parse "$remote_branch")
	local base_commit=$(git merge-base HEAD "$remote_branch")

	if [[ $local_commit == $remote_commit ]]; then
		return 0
	else
		GitFailure "The branch '$branch_name' has diverged from the origin."
		
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
					if ! ( git fetch origin $branch_name && git pull origin $branch_name ) &>/dev/null; then
						GitFailure "Unable to update branch"
						echo $( git fetch origin $branch_name && git pull origin $branch_name )
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
	fi
}
function worktreeCheck() {
	local repo=${1:-"$gitRepo"}
	local ref=${2:-"$gitRef"}

	if [ -d "$1/.git/worktrees/$2" ]; then
		return 1
	fi
	
	return 0
}
function worktreeExists() {
	gitRefCheck
	
	worktreeCheck
}
function gitBranchExists() {
	local branch_name="${1:-$(git branch |grep \* | cut -d " " -f2)}"
	git rev-parse --quiet --verify "$branch_name" >/dev/null
}
function isValidWorktree() {
	# If worktree reference exists in repo
	if worktreeExists; then
		# If .git reference matches folder name
		if [[ $gitRef == $gitDir ]]; then
			return 0
		fi
	fi

	return 1
}
function updateWorktreePrompt() {
	gitRefCheck

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
			Caution "To remove these errors, be sure to have your Worktree Directory named the same as your Git Branch. To avoid this in the future, use the gwtn function when creating a new worktree"
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
	gitRefCheck

	if isValidWorktree; then
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
		if ! isValidWorktree; then
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

	if worktreeCheck $1 $2; then
		echo "gitdir: $1/.git/worktrees/$2" > .git
		GitSuccess "Converted $2 to worktree"
	else
		GitFailure "Unable to convert to worktree: worktree does not exist."
	fi
}
function cmp() {
	if ! checkValidWorktree; then
		validateWorktree
	fi

	if checkGitDivergence; then
		gitPush $@
	fi
}
function camp() {
	if ! checkValidWorktree; then
		validateWorktree
	fi

	git add . &>/dev/null

	if checkGitDivergence; then
		gitPush $@
	fi
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
			echo
			Error "Please include a message with your camp"
			Color -c $DarkGray -m '> camp "Your custom message"'
			echo
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
	local MAKE=false
	local DETACH=false
	local existingBranch=false
	local branch=""

	while [[ $# -gt 0 ]]; do
		case $1 in
			-h | --help)
				echo "gwtn (Git Worktree New) - Creates a new JV project worktree"
				echo " "
				echo "gwtn [branch] [options]"
				echo " "
				echo "options:"
				echo "-h, --help                            show brief help"
				echo "-s, --skip-install=SKIP_INSTALL       specify an action to use"
				echo "-no, --noopen=NO_OPEN                 specify to open in VSCode"
				echo "-m, --make=MAKE                       equivalent to calling gwtn -s -no"
				echo "--detach=DETACH                       makes worktree, but no push to origin"
				return
				;;
			-s | --skip-install | --skip)
				SKIP_INSTALL=true
				shift
				;;
			-no | --noopen)
				NO_OPEN=true
				shift
				;;
			-m | --make)
				MAKE=true
				shift
				;;
			--detach)
				DETACH=true
				shift
				;;
			*)
				branch=$1
				shift
				;;
		esac
	done

	if [[ $branch != "" ]]; then
		findEnv
		if [[ $ENVTYPE == "jv" ]] || [[ $ENVTYPE == "tl" ]]; then
			cd $ENV &>/dev/null
		fi

		if [ -d $ENV"starter_branch" ]; then
			Error "starter_branch is in your worktrees. Remove the starter_branch worktree and try again."
			return
		fi

		if [ -d $ENV$branch ]; then
			Caution "$ENV$branch is already in your worktrees. Moving there now..."
			cd $ENV$branch &>/dev/null
			return
		fi

		trap 'echo && echo $(Alert $cWarning "Stopped creating worktree \"$branch\"\nCheck on what has been created so far") && shutdown && trap - 1 2 3 6 && return' 1 2 3 6

		if ([[ $branch != 'starter_branch' ]] && git checkout starter_branch &>/dev/null); then
			gitPull
		fi

		(
			(
				if git show-ref --quiet refs/remotes/origin/"$branch"; then
					existingBranch=true
					git fetch origin $branch &>/dev/null
					if git worktree add --track -B $branch ./$branch origin/$branch &>/dev/null; then
						GitSuccess "Worktree added: $branch"
						git checkout root &>/dev/null
						cd "$branch/" &>/dev/null
						mkdir _dev &>/dev/null
						exit
					else
						GitFailure "Unable to create worktree"
						git checkout root &>/dev/null
						echo $(git worktree add --track -B $branch ./$branch origin/$branch)
						exit 1
					fi
				else
					existingBranch=false
					if git worktree add $branch &>/dev/null; then
						GitSuccess "Worktree added: $branch"
						git checkout root &>/dev/null
						cd "$branch/" &>/dev/null
						mkdir _dev &>/dev/null
						exit
					else
						GitFailure "Unable to create worktree"
						git checkout root &>/dev/null
						echo $(git worktree add $branch)
						exit 1
					fi
				fi
			) &
			
			loadingAnimation $! "Setting up worktree \"$branch\""
		)

		cd $ENV$branch &>/dev/null

		if ! $SKIP_INSTALL && ! $MAKE; then
			start -i || { GitFailure "Unable to install npm"; return; }
		fi

		if ! $DETACH && ! $MAKE; then
			(
				(
					if $existingBranch; then
						if git commit -am "Setting up $(git symbolic-ref --short HEAD) project in Git" &>/dev/null && git push --set-upstream origin $(git symbolic-ref --short HEAD) &>/dev/null; then
							GitSuccess "Branch created: $branch"
							exit
						else
							GitFailure "Unable to create branch: $branch"
							echo $(git commit -am "Setting up $(git symbolic-ref --short HEAD) project in Git")
							echo $(git push --set-upstream origin $(git symbolic-ref --short HEAD))
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

		if ! $NO_OPEN && ! $MAKE; then
			(
				(
					if code .; then
						exit
					else
						GitFailure "Error: Failed to open in VSCode."
						echo $(code .)
						exit 1
					fi
				) &
				loadingAnimation $! "Opening in VSCode"
			)
		fi
	else
		Error "Need a worktree name ( e.x. gwtn myworktree )"
		return
	fi
}
function gwtr() {
	trap 'echo && echo $(Alert $cWarning "Stopped removing worktree \"$branch\"\nCheck on what has been deleted") && shutdown && trap - 1 2 3 6 && return' 1 2 3 6

	local branch=${1:=$(git symbolic-ref --short HEAD)}

	if [[ $branch != "root" ]] || [[ $branch != "starter_branch" ]]; then

		if ! [ -d $ENV$branch ]; then
			Alert "There is no existing $ENV$branch directory."
			return
		fi

		findEnv
		if [[ $ENVTYPE == "jv" ]] || [[ $ENVTYPE == "tl" ]]; then
			cd $ENV &>/dev/null
		fi

		cd $ENV$branch &>/dev/null
		git checkout . &>/dev/null

		(
			(
				if git worktree remove $branch &>/dev/null; then
					GitSuccess "$branch has been removed."
					exit
				else
					GitFailure "$branch was not removed."
					echo "$(git worktree remove $branch)"
					exit 1
				fi
			) &
			loadingAnimation $! "Removing worktree \"$branch\""
		)
	else
		Error "You can't use gwtr without a parameter in root or starter_branch. Either specify a branch, or cd into that branch and run gwtr"
		return
	fi

	cd - &>/dev/null
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

	cd - &>/dev/null
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

	# starting directory for redirect when finished
	pushd $PWD 1>/dev/null

	if ! $INSTALL_ONLY; then
		findPackageJSON ${2:$(git symbolic-ref --short HEAD)}
		echo $(findPackageJSON ${2:$(git symbolic-ref --short HEAD)})
	else
		findPackageJSON $@
		echo $(findPackageJSON $@)
	fi

	# if [[ $dir != '' ]]
	if [ -d $dir ]; then
		# Catch for exiting on ctrl+c for exit message and returning from packaged dir
		trap 'echo && echo $(colorText $cMessage "...Kickoff Stopped") && shutdown && popd 1>/dev/null && trap - 1 2 3 6 && return' 1 2 3 6

		# cd to dir containing package.json
		cd $dir &>/dev/null

		if ! $SKIP_INSTALL; then
			(
				(
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
			Message 'To stop, press Control-C\n'

			gulp
		fi
	else
		Warning "There is no Kickoff found in $dir"
		echo 'Try installing npm with start -i'
		echo '  $: start -i'
		echo 'or specify a path after start'
		echo '  $: start path/to/'
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

	popd 1>/dev/null

	#find new Kickoff folder
	dir=''
	findPackageJSON $@
	(
		(
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

	trap - 1 2 3 6
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
		Warning 'No worktree referenced' 
		read REPLY"?$(Color -m 'What worktree do you want to repair? (enter nothing to skip)' -ub): "

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
alias gwtm='gwtn --make $1'
alias gwts='git worktree add $1 $1'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias home='git reset origin/master'
alias lga='git log --graph --all --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)"'
alias mg='git merge'
alias mpeek='git log master.. --graph $(git symbolic-ref --short HEAD) --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20}'
alias newb='git checkout -b'
alias pages='git stash && git checkout gh-pages'
alias peek='git fetch && git log --graph origin/$(git symbolic-ref --short HEAD) --pretty=format:"%C(red bold)%h%Creset -%C(auto)%d%Creset %s%Creset - %C(green bold)%an %C(green dim)(%cr)" ${1-\-20} --'
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
		echo $FZPWD | pbcopy && sftp $FZUSER@$FZHOST:/uploads/$1
	else
		echo $FZPWD | pbcopy && sftp $FZUSER@$FZHOST:/uploads/$branch
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
	local branch=$(git branch |grep \* | cut -d " " -f2)

	goToCurrentBranch

	if [ ! -d _dev ] && mkdir _dev

	cd _dev/

	Message "Connecting to FileZilla and downloading the dev folder for $branch"
	echo "When prompted for your password, you can type in your password OR, if you have your \$FZUSER and \$FZPWD set in your aliases global variables, just paste as I've just copied that for you." 
	echo

echo $FZPWD | pbcopy && sftp -r $FZUSER@sftp.jobvite.com:/uploads/$branch << EOF
get -r dev
EOF

	goToCurrentBranch
	echo


	if [ -d _dev/dev ] && Success " √ Downloaded /uploads/$branch/dev to $branch/_dev/dev"

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