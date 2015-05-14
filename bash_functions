# MISC

## DOCKER RELATED

buildimage(){
	docker build -t $1 .
}

removeimage(){
	docker rmi -f $1
}


## GIT RELATED
switchbranch(){
	if [ -z "$1" ]
	then
		git checkout "$(git branch | percol | awk '{print $1}')"
	else
		git checkout "$1"
	fi
}

# GIT
gitdifforigin(){
	CURRENT_BRANCH="$(git branch | grep \* | awk '{print $2}')"
	git diff "${CURRENT_BRANCH}" "origin/${CURRENT_BRANCH}"
}

gitdiffupstream(){
	git fetch -v upstream
	CURRENT_BRANCH="$(git branch | grep \* | awk '{print $2}')"
	git diff "${CURRENT_BRANCH}" "upstream/master" "$2"
}

gitstatorigin(){
	CURRENT_BRANCH="$(git branch | grep \* | awk '{print $2}')"
	git diff --name-only "${CURRENT_BRANCH}" "origin/${CURRENT_BRANCH}"
}

gittwdifforigin(){
	git fetch -v upstream
	FILE="$1"
	NEWFILE="$1.HEAD.$(date +%s)"
	git fetch -v &&  git show upstream/master:"./$FILE" > "./$NEWFILE"
	twdiff "./$FILE" "./$NEWFILE"
}

gittwdiffnext(){
	git fetch -v upstream
	FILE="$1"
	NEWFILE="$1.HEAD.$(date +%s)"
	git fetch -v &&  git show upstream/next:"./$FILE" > "./$NEWFILE"
	twdiff "./$FILE" "./$NEWFILE"
}


gitac(){
	ARGS="$@"
	FILES="${@:1:${#}-1}" # GET ALL ARGS BUT LAST
	LASTFILE="${FILES##* }"
	MESSAGE="${@: -1}"

	if [ "$LASTFILE" == "-m" ]; then
		FILES="${FILES% *}" # GET ALL FILES BUT LAST
	fi

	git add $FILES && git commit $FILES -m "$MESSAGE"
}

gitupdate(){
	git pull --rebase upstream $1
}

pullreq(){
	git fetch $1 pull/$2/head:$3
	git checkout $3
}

untracked(){
	git status . | grep -A10000 'Untracked files' | tail -n +4 | sed 's/^..//' | awk 'NR>1{print buf}{buf = $0}'
}

edituntracked(){
	vi $(untracked | percol)
}

## SHOW WHICH PROCESS IS LISTENING ON A SPECIFIC PORT
onport(){
	lsof -i ":$1"
}

whichreally(){
	BIN="$1";
	ls -alh "$(which ${BIN})"
}

members(){
	dscl . -list /Users | while read user;
		do 
			printf "$user "; 
			dsmemberutil checkmembership -U "$user" -G "$*"; 
		done | grep "is a member" | cut -d " " -f 1;
};

checkoutremote(){
	git fetch $1
	git checkout -b $1/$2 $1/$2
};

taketheirs(){
	git checkout --theirs "$1" && git add $1
};

takemine(){
	git checkout --ours "$1" && git add $1
};



## MONIT PROCESS
monitprocesses(){
	while true; do	
		clear
		echo "\033[4mMONIT PROCESSES\033[0m"
		ps aux | head -n 1
		ps aux | grep $1 | grep -v grep
		sleep 2
	done
	
}


# NODE FUNCTIONS
nodeprocesses(){
	while true; do	
		clear
		echo "\033[4mNODE PROCESSES\033[0m"
		ps aux | head -n 1
		ps aux | egrep '^.+[0-9]:[0-9]{2}\.[0-9]{2}\s(node|\/(\w|\/)+\/node).*$'
		sleep 2
	done
	
}

javaprocesses(){
	while true; do
		clear
		echo "\033[4mJAVA PROCESSES\033[0m"
		ps aux | head -n 1
		ps aux | grep java | grep -v grep
		sleep 2
	done
}

inspectprocess(){
	PID="$1"
	while true; do
		clear
		echo "\033[4m${PID} PROCESSES\033[0m"
		ps aux | head -n 1
		ps aux | grep $PID
		sleep 2
	done
}

# MEMCACHED

flushcache(){
	{ echo "flush_all"; sleep 1; } | telnet $@
	
}
v5flushcache(){
		flushcache localhost 11211
}

trimit(){
	echo "$1" | sed 's/ *$//' | sed 's/^ *//'
}

# Opens a new tab in the current Terminal window and optionally executes a command.
# When invoked via a function named 'newwin', opens a new Terminal *window* instead.
newtab() {

	# If this function was invoked directly by a function named 'newwin', we open a new *window* instead
	# of a new tab in the existing window.
	local funcName=$FUNCNAME
	local targetType='tab'
	local targetDesc='new tab in the active Terminal window'
	local makeTab=1
	case "${FUNCNAME[1]}" in
		newwin)
			makeTab=0
			funcName=${FUNCNAME[1]}
			targetType='window'
			targetDesc='new Terminal window'
			;;
	esac

	# Command-line help.
	if [[ "$1" == '--help' || "$1" == '-h' ]]; then
		cat <<EOF
Synopsis:
	$funcName [-g|-G] [command [param1 ...]]

Description:
	Opens a $targetDesc and optionally executes a command.

	The new $targetType will run a login shell (i.e., load the user's shell profile) and inherit
	the working folder from this shell (the active Terminal tab).
	IMPORTANT: In scripts, \`$funcName\` *statically* inherits the working folder from the
	*invoking Terminal tab* at the time of script *invocation*, even if you change the
	working folder *inside* the script before invoking \`$funcName\`.

	-g (back*g*round) causes Terminal not to activate, but within Terminal, the new tab/window
	  will become the active element.
	-G causes Terminal not to activate *and* the active element within Terminal not to change;
	  i.e., the previously active window and tab stay active.

	NOTE: With -g or -G specified, for technical reasons, Terminal will still activate *briefly* when
	you create a new tab (creating a new window is not affected).

	When a command is specified, its first token will become the new ${targetType}'s title.
	Quoted parameters are handled properly.

	To specify multiple commands, use 'eval' followed by a single, *double*-quoted string
	in which the commands are separated by ';' Do NOT use backslash-escaped double quotes inside
	this string; rather, use backslash-escaping as needed.
	Use 'exit' as the last command to automatically close the tab when the command
	terminates; precede it with 'read -s -n 1' to wait for a keystroke first.

	Alternatively, pass a script name or path; prefix with 'exec' to automatically
	close the $targetType when the script terminates.

Examples:
	$funcName ls -l "\$Home/Library/Application Support"
	$funcName eval "ls \\\$HOME/Library/Application\ Support; echo Press a key to exit.; read -s -n 1; exit"
	$funcName /path/to/someScript
	$funcName exec /path/to/someScript
EOF
		return 0
	fi

	# Option-parameters loop.
	inBackground=0
	while (( $# )); do
		case "$1" in
			-g)
				inBackground=1
				;;
			-G)
				inBackground=2
				;;
			--) # Explicit end-of-options marker.
				shift	# Move to next param and proceed with data-parameter analysis below.
				break
				;;
			-*) # An unrecognized switch.
				echo "$FUNCNAME: PARAMETER ERROR: Unrecognized option: '$1'. To force interpretation as non-option, precede with '--'. Use -h or --h for help." 1>&2 && return 2
				;;
			*)	# 1st argument reached; proceed with argument-parameter analysis below.
				break
				;;
		esac
		shift
	done

	# All remaining parameters, if any, make up the command to execute in the new tab/window.

	local CMD_PREFIX='tell application "Terminal" to do script'

		# Command for opening a new Terminal window (with a single, new tab).
	local CMD_NEWWIN=$CMD_PREFIX	# Curiously, simply executing 'do script' with no further arguments opens a new *window*.
		# Commands for opening a new tab in the current Terminal window.
		# Sadly, there is no direct way to open a new tab in an existing window, so we must activate Terminal first, then send a keyboard shortcut.
	local CMD_ACTIVATE='tell application "Terminal" to activate'
	local CMD_NEWTAB='tell application "System Events" to keystroke "t" using {command down}'
		# For use with -g: commands for saving and restoring the previous application
	local CMD_SAVE_ACTIVE_APPNAME='tell application "System Events" to set prevAppName to displayed name of first process whose frontmost is true'
	local CMD_REACTIVATE_PREV_APP='activate application prevAppName'
		# For use with -G: commands for saving and restoring the previous state within Terminal
	local CMD_SAVE_ACTIVE_WIN='tell application "Terminal" to set prevWin to front window'
	local CMD_REACTIVATE_PREV_WIN='set frontmost of prevWin to true'
	local CMD_SAVE_ACTIVE_TAB='tell application "Terminal" to set prevTab to (selected tab of front window)'
	local CMD_REACTIVATE_PREV_TAB='tell application "Terminal" to set selected of prevTab to true'

	if (( $# )); then # Command specified; open a new tab or window, then execute command.
			# Use the command's first token as the tab title.
		local tabTitle=$1
		case "$tabTitle" in
			exec|eval) # Use following token instead, if the 1st one is 'eval' or 'exec'.
				tabTitle=$(echo "$2" | awk '{ print $1 }') 
				;;
			cd) # Use last path component of following token instead, if the 1st one is 'cd'
				tabTitle=$(basename "$2")
				;;
		esac
		local CMD_SETTITLE="tell application \"Terminal\" to set custom title of front window to \"$tabTitle\""
			# The tricky part is to quote the command tokens properly when passing them to AppleScript:
			# Step 1: Quote all parameters (as needed) using printf '%q' - this will perform backslash-escaping.
		local quotedArgs=$(printf '%q ' "$@")
			# Step 2: Escape all backslashes again (by doubling them), because AppleScript expects that.
		local cmd="$CMD_PREFIX \"${quotedArgs//\\/\\\\}\""
			# Open new tab or window, execute command, and assign tab title.
			# '>/dev/null' suppresses AppleScript's output when it creates a new tab.
		if (( makeTab )); then
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
				else
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
				fi
			else
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" >/dev/null
			fi
		else # make *window*
			# Note: $CMD_NEWWIN is not needed, as $cmd implicitly creates a new window.
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$cmd" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
				else
					osascript -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
				fi
			else
					# Note: Even though we do not strictly need to activate Terminal first, we do it, as assigning the custom title to the 'front window' would otherwise sometimes target the wrong window.
				osascript -e "$CMD_ACTIVATE" -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
			fi
		fi		  
	else	# No command specified; simply open a new tab or window.
		if (( makeTab )); then
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
				else
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
				fi
			else
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" >/dev/null
			fi
		else # make *window*
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$CMD_NEWWIN" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
				else
					osascript -e "$CMD_NEWWIN" >/dev/null
				fi
			else
					# Note: Even though we do not strictly need to activate Terminal first, we do it so as to better visualize what is happening (the new window will appear stacked on top of an existing one).
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWWIN" >/dev/null
			fi
		fi
	fi

}

# Opens a new Terminal window and optionally executes a command.
newwin() {
	newtab "$@" # Simply pass through to 'newtab', which will examine the call stack to see how it was invoked.
}



# Opens a new tab in the current Terminal window and optionally executes a command.
# When invoked via a function named 'newwin', opens a new Terminal *window* instead.
newtab() {

	# If this function was invoked directly by a function named 'newwin', we open a new *window* instead
	# of a new tab in the existing window.
	local funcName=$FUNCNAME
	local targetType='tab'
	local targetDesc='new tab in the active Terminal window'
	local makeTab=1
	case "${FUNCNAME[1]}" in
		newwin)
			makeTab=0
			funcName=${FUNCNAME[1]}
			targetType='window'
			targetDesc='new Terminal window'
			;;
	esac

	# Command-line help.
	if [[ "$1" == '--help' || "$1" == '-h' ]]; then
		cat <<EOF
Synopsis:
	$funcName [-g|-G] [command [param1 ...]]

Description:
	Opens a $targetDesc and optionally executes a command.

	The new $targetType will run a login shell (i.e., load the user's shell profile) and inherit
	the working folder from this shell (the active Terminal tab).
	IMPORTANT: In scripts, \`$funcName\` *statically* inherits the working folder from the
	*invoking Terminal tab* at the time of script *invocation*, even if you change the
	working folder *inside* the script before invoking \`$funcName\`.

	-g (back*g*round) causes Terminal not to activate, but within Terminal, the new tab/window
	  will become the active element.
	-G causes Terminal not to activate *and* the active element within Terminal not to change;
	  i.e., the previously active window and tab stay active.

	NOTE: With -g or -G specified, for technical reasons, Terminal will still activate *briefly* when
	you create a new tab (creating a new window is not affected).

	When a command is specified, its first token will become the new ${targetType}'s title.
	Quoted parameters are handled properly.

	To specify multiple commands, use 'eval' followed by a single, *double*-quoted string
	in which the commands are separated by ';' Do NOT use backslash-escaped double quotes inside
	this string; rather, use backslash-escaping as needed.
	Use 'exit' as the last command to automatically close the tab when the command
	terminates; precede it with 'read -s -n 1' to wait for a keystroke first.

	Alternatively, pass a script name or path; prefix with 'exec' to automatically
	close the $targetType when the script terminates.

Examples:
	$funcName ls -l "\$Home/Library/Application Support"
	$funcName eval "ls \\\$HOME/Library/Application\ Support; echo Press a key to exit.; read -s -n 1; exit"
	$funcName /path/to/someScript
	$funcName exec /path/to/someScript
EOF
		return 0
	fi

	# Option-parameters loop.
	inBackground=0
	while (( $# )); do
		case "$1" in
			-g)
				inBackground=1
				;;
			-G)
				inBackground=2
				;;
			--) # Explicit end-of-options marker.
				shift	# Move to next param and proceed with data-parameter analysis below.
				break
				;;
			-*) # An unrecognized switch.
				echo "$FUNCNAME: PARAMETER ERROR: Unrecognized option: '$1'. To force interpretation as non-option, precede with '--'. Use -h or --h for help." 1>&2 && return 2
				;;
			*)	# 1st argument reached; proceed with argument-parameter analysis below.
				break
				;;
		esac
		shift
	done

	# All remaining parameters, if any, make up the command to execute in the new tab/window.

	local CMD_PREFIX='tell application "Terminal" to do script'

		# Command for opening a new Terminal window (with a single, new tab).
	local CMD_NEWWIN=$CMD_PREFIX	# Curiously, simply executing 'do script' with no further arguments opens a new *window*.
		# Commands for opening a new tab in the current Terminal window.
		# Sadly, there is no direct way to open a new tab in an existing window, so we must activate Terminal first, then send a keyboard shortcut.
	local CMD_ACTIVATE='tell application "Terminal" to activate'
	local CMD_NEWTAB='tell application "System Events" to keystroke "t" using {command down}'
		# For use with -g: commands for saving and restoring the previous application
	local CMD_SAVE_ACTIVE_APPNAME='tell application "System Events" to set prevAppName to displayed name of first process whose frontmost is true'
	local CMD_REACTIVATE_PREV_APP='activate application prevAppName'
		# For use with -G: commands for saving and restoring the previous state within Terminal
	local CMD_SAVE_ACTIVE_WIN='tell application "Terminal" to set prevWin to front window'
	local CMD_REACTIVATE_PREV_WIN='set frontmost of prevWin to true'
	local CMD_SAVE_ACTIVE_TAB='tell application "Terminal" to set prevTab to (selected tab of front window)'
	local CMD_REACTIVATE_PREV_TAB='tell application "Terminal" to set selected of prevTab to true'

	if (( $# )); then # Command specified; open a new tab or window, then execute command.
			# Use the command's first token as the tab title.
		local tabTitle=$1
		case "$tabTitle" in
			exec|eval) # Use following token instead, if the 1st one is 'eval' or 'exec'.
				tabTitle=$(echo "$2" | awk '{ print $1 }') 
				;;
			cd) # Use last path component of following token instead, if the 1st one is 'cd'
				tabTitle=$(basename "$2")
				;;
		esac
		local CMD_SETTITLE="tell application \"Terminal\" to set custom title of front window to \"$tabTitle\""
			# The tricky part is to quote the command tokens properly when passing them to AppleScript:
			# Step 1: Quote all parameters (as needed) using printf '%q' - this will perform backslash-escaping.
		local quotedArgs=$(printf '%q ' "$@")
			# Step 2: Escape all backslashes again (by doubling them), because AppleScript expects that.
		local cmd="$CMD_PREFIX \"${quotedArgs//\\/\\\\}\""
			# Open new tab or window, execute command, and assign tab title.
			# '>/dev/null' suppresses AppleScript's output when it creates a new tab.
		if (( makeTab )); then
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
				else
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
				fi
			else
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" >/dev/null
			fi
		else # make *window*
			# Note: $CMD_NEWWIN is not needed, as $cmd implicitly creates a new window.
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$cmd" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
				else
					osascript -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
				fi
			else
					# Note: Even though we do not strictly need to activate Terminal first, we do it, as assigning the custom title to the 'front window' would otherwise sometimes target the wrong window.
				osascript -e "$CMD_ACTIVATE" -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
			fi
		fi		  
	else	# No command specified; simply open a new tab or window.
		if (( makeTab )); then
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
				else
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
				fi
			else
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" >/dev/null
			fi
		else # make *window*
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$CMD_NEWWIN" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
				else
					osascript -e "$CMD_NEWWIN" >/dev/null
				fi
			else
					# Note: Even though we do not strictly need to activate Terminal first, we do it so as to better visualize what is happening (the new window will appear stacked on top of an existing one).
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWWIN" >/dev/null
			fi
		fi
	fi

}

# Opens a new Terminal window and optionally executes a command.
newwin() {
	newtab "$@" # Simply pass through to 'newtab', which will examine the call stack to see how it was invoked.
}



# Opens a new tab in the current Terminal window and optionally executes a command.
# When invoked via a function named 'newwin', opens a new Terminal *window* instead.
newtab() {

	# If this function was invoked directly by a function named 'newwin', we open a new *window* instead
	# of a new tab in the existing window.
	local funcName=$FUNCNAME
	local targetType='tab'
	local targetDesc='new tab in the active Terminal window'
	local makeTab=1
	case "${FUNCNAME[1]}" in
		newwin)
			makeTab=0
			funcName=${FUNCNAME[1]}
			targetType='window'
			targetDesc='new Terminal window'
			;;
	esac

	# Command-line help.
	if [[ "$1" == '--help' || "$1" == '-h' ]]; then
		cat <<EOF
Synopsis:
	$funcName [-g|-G] [command [param1 ...]]

Description:
	Opens a $targetDesc and optionally executes a command.

	The new $targetType will run a login shell (i.e., load the user's shell profile) and inherit
	the working folder from this shell (the active Terminal tab).
	IMPORTANT: In scripts, \`$funcName\` *statically* inherits the working folder from the
	*invoking Terminal tab* at the time of script *invocation*, even if you change the
	working folder *inside* the script before invoking \`$funcName\`.

	-g (back*g*round) causes Terminal not to activate, but within Terminal, the new tab/window
	  will become the active element.
	-G causes Terminal not to activate *and* the active element within Terminal not to change;
	  i.e., the previously active window and tab stay active.

	NOTE: With -g or -G specified, for technical reasons, Terminal will still activate *briefly* when
	you create a new tab (creating a new window is not affected).

	When a command is specified, its first token will become the new ${targetType}'s title.
	Quoted parameters are handled properly.

	To specify multiple commands, use 'eval' followed by a single, *double*-quoted string
	in which the commands are separated by ';' Do NOT use backslash-escaped double quotes inside
	this string; rather, use backslash-escaping as needed.
	Use 'exit' as the last command to automatically close the tab when the command
	terminates; precede it with 'read -s -n 1' to wait for a keystroke first.

	Alternatively, pass a script name or path; prefix with 'exec' to automatically
	close the $targetType when the script terminates.

Examples:
	$funcName ls -l "\$Home/Library/Application Support"
	$funcName eval "ls \\\$HOME/Library/Application\ Support; echo Press a key to exit.; read -s -n 1; exit"
	$funcName /path/to/someScript
	$funcName exec /path/to/someScript
EOF
		return 0
	fi

	# Option-parameters loop.
	inBackground=0
	while (( $# )); do
		case "$1" in
			-g)
				inBackground=1
				;;
			-G)
				inBackground=2
				;;
			--) # Explicit end-of-options marker.
				shift	# Move to next param and proceed with data-parameter analysis below.
				break
				;;
			-*) # An unrecognized switch.
				echo "$FUNCNAME: PARAMETER ERROR: Unrecognized option: '$1'. To force interpretation as non-option, precede with '--'. Use -h or --h for help." 1>&2 && return 2
				;;
			*)	# 1st argument reached; proceed with argument-parameter analysis below.
				break
				;;
		esac
		shift
	done

	# All remaining parameters, if any, make up the command to execute in the new tab/window.

	local CMD_PREFIX='tell application "Terminal" to do script'

		# Command for opening a new Terminal window (with a single, new tab).
	local CMD_NEWWIN=$CMD_PREFIX	# Curiously, simply executing 'do script' with no further arguments opens a new *window*.
		# Commands for opening a new tab in the current Terminal window.
		# Sadly, there is no direct way to open a new tab in an existing window, so we must activate Terminal first, then send a keyboard shortcut.
	local CMD_ACTIVATE='tell application "Terminal" to activate'
	local CMD_NEWTAB='tell application "System Events" to keystroke "t" using {command down}'
		# For use with -g: commands for saving and restoring the previous application
	local CMD_SAVE_ACTIVE_APPNAME='tell application "System Events" to set prevAppName to displayed name of first process whose frontmost is true'
	local CMD_REACTIVATE_PREV_APP='activate application prevAppName'
		# For use with -G: commands for saving and restoring the previous state within Terminal
	local CMD_SAVE_ACTIVE_WIN='tell application "Terminal" to set prevWin to front window'
	local CMD_REACTIVATE_PREV_WIN='set frontmost of prevWin to true'
	local CMD_SAVE_ACTIVE_TAB='tell application "Terminal" to set prevTab to (selected tab of front window)'
	local CMD_REACTIVATE_PREV_TAB='tell application "Terminal" to set selected of prevTab to true'

	if (( $# )); then # Command specified; open a new tab or window, then execute command.
			# Use the command's first token as the tab title.
		local tabTitle=$1
		case "$tabTitle" in
			exec|eval) # Use following token instead, if the 1st one is 'eval' or 'exec'.
				tabTitle=$(echo "$2" | awk '{ print $1 }') 
				;;
			cd) # Use last path component of following token instead, if the 1st one is 'cd'
				tabTitle=$(basename "$2")
				;;
		esac
		local CMD_SETTITLE="tell application \"Terminal\" to set custom title of front window to \"$tabTitle\""
			# The tricky part is to quote the command tokens properly when passing them to AppleScript:
			# Step 1: Quote all parameters (as needed) using printf '%q' - this will perform backslash-escaping.
		local quotedArgs=$(printf '%q ' "$@")
			# Step 2: Escape all backslashes again (by doubling them), because AppleScript expects that.
		local cmd="$CMD_PREFIX \"${quotedArgs//\\/\\\\}\""
			# Open new tab or window, execute command, and assign tab title.
			# '>/dev/null' suppresses AppleScript's output when it creates a new tab.
		if (( makeTab )); then
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
				else
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
				fi
			else
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" >/dev/null
			fi
		else # make *window*
			# Note: $CMD_NEWWIN is not needed, as $cmd implicitly creates a new window.
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$cmd" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
				else
					osascript -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
				fi
			else
					# Note: Even though we do not strictly need to activate Terminal first, we do it, as assigning the custom title to the 'front window' would otherwise sometimes target the wrong window.
				osascript -e "$CMD_ACTIVATE" -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
			fi
		fi		  
	else	# No command specified; simply open a new tab or window.
		if (( makeTab )); then
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
				else
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
				fi
			else
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" >/dev/null
			fi
		else # make *window*
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$CMD_NEWWIN" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
				else
					osascript -e "$CMD_NEWWIN" >/dev/null
				fi
			else
					# Note: Even though we do not strictly need to activate Terminal first, we do it so as to better visualize what is happening (the new window will appear stacked on top of an existing one).
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWWIN" >/dev/null
			fi
		fi
	fi

}

# Opens a new Terminal window and optionally executes a command.
newwin() {
	newtab "$@" # Simply pass through to 'newtab', which will examine the call stack to see how it was invoked.
}



# Opens a new tab in the current Terminal window and optionally executes a command.
# When invoked via a function named 'newwin', opens a new Terminal *window* instead.
newtab() {

	# If this function was invoked directly by a function named 'newwin', we open a new *window* instead
	# of a new tab in the existing window.
	local funcName=$FUNCNAME
	local targetType='tab'
	local targetDesc='new tab in the active Terminal window'
	local makeTab=1
	case "${FUNCNAME[1]}" in
		newwin)
			makeTab=0
			funcName=${FUNCNAME[1]}
			targetType='window'
			targetDesc='new Terminal window'
			;;
	esac

	# Command-line help.
	if [[ "$1" == '--help' || "$1" == '-h' ]]; then
		cat <<EOF
Synopsis:
	$funcName [-g|-G] [command [param1 ...]]

Description:
	Opens a $targetDesc and optionally executes a command.

	The new $targetType will run a login shell (i.e., load the user's shell profile) and inherit
	the working folder from this shell (the active Terminal tab).
	IMPORTANT: In scripts, \`$funcName\` *statically* inherits the working folder from the
	*invoking Terminal tab* at the time of script *invocation*, even if you change the
	working folder *inside* the script before invoking \`$funcName\`.

	-g (back*g*round) causes Terminal not to activate, but within Terminal, the new tab/window
	  will become the active element.
	-G causes Terminal not to activate *and* the active element within Terminal not to change;
	  i.e., the previously active window and tab stay active.

	NOTE: With -g or -G specified, for technical reasons, Terminal will still activate *briefly* when
	you create a new tab (creating a new window is not affected).

	When a command is specified, its first token will become the new ${targetType}'s title.
	Quoted parameters are handled properly.

	To specify multiple commands, use 'eval' followed by a single, *double*-quoted string
	in which the commands are separated by ';' Do NOT use backslash-escaped double quotes inside
	this string; rather, use backslash-escaping as needed.
	Use 'exit' as the last command to automatically close the tab when the command
	terminates; precede it with 'read -s -n 1' to wait for a keystroke first.

	Alternatively, pass a script name or path; prefix with 'exec' to automatically
	close the $targetType when the script terminates.

Examples:
	$funcName ls -l "\$Home/Library/Application Support"
	$funcName eval "ls \\\$HOME/Library/Application\ Support; echo Press a key to exit.; read -s -n 1; exit"
	$funcName /path/to/someScript
	$funcName exec /path/to/someScript
EOF
		return 0
	fi

	# Option-parameters loop.
	inBackground=0
	while (( $# )); do
		case "$1" in
			-g)
				inBackground=1
				;;
			-G)
				inBackground=2
				;;
			--) # Explicit end-of-options marker.
				shift	# Move to next param and proceed with data-parameter analysis below.
				break
				;;
			-*) # An unrecognized switch.
				echo "$FUNCNAME: PARAMETER ERROR: Unrecognized option: '$1'. To force interpretation as non-option, precede with '--'. Use -h or --h for help." 1>&2 && return 2
				;;
			*)	# 1st argument reached; proceed with argument-parameter analysis below.
				break
				;;
		esac
		shift
	done

	# All remaining parameters, if any, make up the command to execute in the new tab/window.

	local CMD_PREFIX='tell application "Terminal" to do script'

		# Command for opening a new Terminal window (with a single, new tab).
	local CMD_NEWWIN=$CMD_PREFIX	# Curiously, simply executing 'do script' with no further arguments opens a new *window*.
		# Commands for opening a new tab in the current Terminal window.
		# Sadly, there is no direct way to open a new tab in an existing window, so we must activate Terminal first, then send a keyboard shortcut.
	local CMD_ACTIVATE='tell application "Terminal" to activate'
	local CMD_NEWTAB='tell application "System Events" to keystroke "t" using {command down}'
		# For use with -g: commands for saving and restoring the previous application
	local CMD_SAVE_ACTIVE_APPNAME='tell application "System Events" to set prevAppName to displayed name of first process whose frontmost is true'
	local CMD_REACTIVATE_PREV_APP='activate application prevAppName'
		# For use with -G: commands for saving and restoring the previous state within Terminal
	local CMD_SAVE_ACTIVE_WIN='tell application "Terminal" to set prevWin to front window'
	local CMD_REACTIVATE_PREV_WIN='set frontmost of prevWin to true'
	local CMD_SAVE_ACTIVE_TAB='tell application "Terminal" to set prevTab to (selected tab of front window)'
	local CMD_REACTIVATE_PREV_TAB='tell application "Terminal" to set selected of prevTab to true'

	if (( $# )); then # Command specified; open a new tab or window, then execute command.
			# Use the command's first token as the tab title.
		local tabTitle=$1
		case "$tabTitle" in
			exec|eval) # Use following token instead, if the 1st one is 'eval' or 'exec'.
				tabTitle=$(echo "$2" | awk '{ print $1 }') 
				;;
			cd) # Use last path component of following token instead, if the 1st one is 'cd'
				tabTitle=$(basename "$2")
				;;
		esac
		local CMD_SETTITLE="tell application \"Terminal\" to set custom title of front window to \"$tabTitle\""
			# The tricky part is to quote the command tokens properly when passing them to AppleScript:
			# Step 1: Quote all parameters (as needed) using printf '%q' - this will perform backslash-escaping.
		local quotedArgs=$(printf '%q ' "$@")
			# Step 2: Escape all backslashes again (by doubling them), because AppleScript expects that.
		local cmd="$CMD_PREFIX \"${quotedArgs//\\/\\\\}\""
			# Open new tab or window, execute command, and assign tab title.
			# '>/dev/null' suppresses AppleScript's output when it creates a new tab.
		if (( makeTab )); then
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
				else
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
				fi
			else
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" >/dev/null
			fi
		else # make *window*
			# Note: $CMD_NEWWIN is not needed, as $cmd implicitly creates a new window.
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$cmd" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
				else
					osascript -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
				fi
			else
					# Note: Even though we do not strictly need to activate Terminal first, we do it, as assigning the custom title to the 'front window' would otherwise sometimes target the wrong window.
				osascript -e "$CMD_ACTIVATE" -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
			fi
		fi		  
	else	# No command specified; simply open a new tab or window.
		if (( makeTab )); then
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
				else
					osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
				fi
			else
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" >/dev/null
			fi
		else # make *window*
			if (( inBackground )); then
				# !! Sadly, because we must create a new tab by sending a keystroke to Terminal, we must briefly activate it, then reactivate the previously active application.
				if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
					osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$CMD_NEWWIN" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
				else
					osascript -e "$CMD_NEWWIN" >/dev/null
				fi
			else
					# Note: Even though we do not strictly need to activate Terminal first, we do it so as to better visualize what is happening (the new window will appear stacked on top of an existing one).
				osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWWIN" >/dev/null
			fi
		fi
	fi

}

# Opens a new Terminal window and optionally executes a command.
newwin() {
	newtab "$@" # Simply pass through to 'newtab', which will examine the call stack to see how it was invoked.
}



v6workspace(){
	workspace=(ua-b2c ua-cache ua-cms ua-common ua-mongo-models ua-runtime ua-designer ua-media)
	for package in ${workspace[@]}; do
		newtab eval "cd /git/${package}; sleep 2; echo -n -e '\033]0;${package}\007'; ~/workspace/scripts/update_repo.sh"
	done;
}

b2bworkspace(){
	workspace=(ua-b2b-schema ua-b2b-services ua-b2b)
	for package in ${workspace[@]}; do
		newtab eval "cd /git/${package}; sleep 2; echo -n -e '\033]0;${package}\007'; git checkout master && git pull upstream master"
	done;
}

createschema(){
	echo "create schema public authorization postgres" | psql b2b
}

resetschema(){
	echo "drop schema public cascade; create schema public authorization postgres" | psql b2b
}

b2bsetowner(){
	for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" b2b`; do
		psql -c "alter table $tbl owner to postgres" b2b
	done

	for tbl in `psql -qAt -c "select viewname from pg_views where schemaname = 'public';" b2b`; do
		psql -c "alter view $tbl owner to postgres" b2b
	done
}

updateb2bschema(){
	cd /git/ua-b2b-schema
	./migrate.sh
	cd -
}

#rebuildb2bschema(){
#	resetschema
#	cd /git/ua-b2b-schema/
#	./migrate.sh demo
#	cd -
#}

b2btestdata(){
	resetschema
	CURRENT_DIR="$(pwd)"
	cd /git/ua-b2b-schema
	./migrate.sh tables
	cd /git/ua-b2b-services/testingcommon/src/main/resources/
	./migrate-test.sh
	cd $CURRENT_DIR
}




function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

dropremotebranch(){
	if [[ "yes" == $(ask_yes_or_no "Are you sure you want to drop origin/$1") ]]; then
		git push origin :$1
	fi
}

uniqcapture(){
	FILE="$1"
	REGEX="$2"
	cat "$FILE" | perl -n -e echo "/$REGEX/ && print \$1" | sort -u
}


updateis(){
	echo $OLDPWD
	cd /git/ua-datacenter-utils
	git --git-dir=/git/ua-datacenter-utils/.git --work-tree=/git/ua-datacenter-utils pull origin master
	node /git/ua-datacenter-utils/alias.js > ~/ua_idc.sh
	source ~/ua_idc.sh
}

killscreens(){
	screen -ls | awk '{print $1}' | awk 'BEGIN { FS = "." } ; {print $1}' | tail -n +2 | sed '$d' | sed '$d' | while read line; do kill -15 $line; done;
}

killsbt(){
	ps aux | grep sbt | grep -v grep | awk '{ print $2 }' | while read line; do kill -15 $line; done;
}

grepkill(){
	ps aux | grep $1 | grep -v grep | awk '{print $2}' | while read line; do kill -9 $line; done
}

newscreen(){
	screen -S $1 -dm
}

tellscreen(){
	screen -S $1 -p 0 -X stuff "$2
	"
}

initializeb2bservices(){
	ENDPOINTS=(pim search identity cart)
	SERVICES_DIR=/git/ua-b2b-services

	cd $SERVICES_DIR

	for endpoint in ${ENDPOINTS[@]}; do
		newscreen ${endpoint}
		tellscreen ${endpoint} "sbt ${endpoint}/run"
	done;

}

gentags(){
	/usr/local/Cellar/ctags/5.8/bin/ctags --exclude=node_modules --exclude=build --exclude=bower_components -R
}

retag(){
	gitroot
	gentags
	cd -
}

startb2b(){

	B2B_DIR=/git/ua-b2b

	### CLEAN SLATE... TODO: Fixy this hackiness
	killscreens
	screen -wipe
	killsbt
	##########

	initialize_postgres.sh > /dev/null 2>&1 &
	initialize_elasticsearch.sh > /dev/null 2>&1 &
	read -p "Press [Enter] when elasticsearch and postgres are running..."
	initializeb2bservices
	read -p "Press [Enter] when B2B Services are running..."
	cd $B2B_DIR
	screen -S b2bnode -dm node server
	echo "Initialization steps finished..."
	######################################
}

es(){

	CMD="$(echo $1 | awk '{print tolower($0)}')"

	if [[ $CMD == "start" ]]; then
		startes
		exit
	fi

	if [[ $CMD == "stop" ]]; then
		stopes
		exit
	fi

	echo "Usage: es [ start | stop ]"
}

startes(){
	elasticsearch
}

stopes(){
	curl -XPOST 'http://localhost:9200/_cluster/nodes/_local/_shutdown'
}

shutdownescluster(){
	curl -XPOST 'http://localhost:9200/_shutdown'
}

runetl(){
	./git/ua-es-product-stream/etlcore -d uaproducts -c uaproducts,material_type,style_type
}

updateprojectnext(){
	project=$1
	newscreen "${project}"
	tellscreen "${project}" "cd /git/${project}; git pull upstream next && exit"
}

updateb2b(){
	PROJECTSNEXT=("ua-b2b-services" "ua-b2b" "ua-b2b-schema")

	for project in ${PROJECTSNEXT[@]}; do
		newscreen "${project}"
		tellscreen "${project}" "cd /git/${project}; git pull upstream next && exit"
	done;

	PROJECTS=("ua-cache" "ua-common" "ua-express-session" "ua-media-b2b" "ua-mongo-models" "ua-rest-b2b" "ua-runtime" "ua-es-product-stream")
	for project in ${PROJECTS[@]}; do
		newscreen "${project}"
		tellscreen "${project}" "cd /git/${project}; git pull upstream master && exit"
	done;
}

portopen(){
	nc $1 $2 < /dev/null
	SUCCESS=$?

	if [[ $SUCCESS -eq 0 ]]
	then
		echo "PORT ON REMOTE END IS OPEN"
	else
		echo "PORT ON REMOTE END IS CLOSED"
	fi

	exit $SUCCESS
}


