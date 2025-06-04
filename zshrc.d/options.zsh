# options.zsh
# Additional Zsh options not in main zshrc

# Directory navigation
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # Push directories onto stack  
setopt PUSHD_MINUS          # Exchange + and - in pushd
setopt PUSHD_SILENT         # Don't print directory stack
setopt PUSHD_TO_HOME        # pushd with no args goes home
setopt CDABLE_VARS          # cd to named directories
DIRSTACKSIZE=10             # Directory stack size

# Globbing and pattern matching
setopt EXTENDED_GLOB        # Enhanced glob patterns
setopt GLOB_DOTS            # Include dotfiles in globbing
unsetopt NOMATCH            # Allow [ or ] without errors
setopt NULL_GLOB            # Delete pattern when no match found

# History improvements
setopt HIST_REDUCE_BLANKS   # Remove extra blanks from history
setopt HIST_FIND_NO_DUPS    # Don't show duplicates in search
setopt HIST_IGNORE_SPACE    # Don't save lines starting with space

# Job control
setopt LONG_LIST_JOBS       # Display PID when suspending processes
setopt NOTIFY               # Report status of background jobs immediately
setopt NO_BG_NICE           # Don't nice background tasks
setopt NO_CHECK_JOBS        # Don't warn about background jobs when exiting
setopt NO_HUP               # Don't kill jobs on shell exit

# Other useful options
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'
setopt MAIL_WARNING         # Warn if mail file has been accessed