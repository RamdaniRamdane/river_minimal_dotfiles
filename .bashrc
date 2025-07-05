# ==============================================================================
#                        ~/.bashrc - Improved & Organized
# ==============================================================================

# ------------------------------------------------------------------------------
# [1] Environment Variables
# ------------------------------------------------------------------------------
# Set preferred applications and language.
# NOTE: fr_FR.UTF-8 is used. The duplicate LANG=C.UTF-8 was removed for consistency.
export EDITOR='nvim'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/utils/eww/target/release:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export NVM_DIR="$HOME/.nvm"

# ------------------------------------------------------------------------------
# [2] Aliases & Shell Customizations
# ------------------------------------------------------------------------------

# --- `ls` with Nerd Font Icons using `lsd` ---
# This replaces the old `ls` alias and the long LS_COLORS export.
alias ls='lsd --color=always --icon=always'
alias ll='lsd -l --header' # Long format with headers
alias la='lsd -a'          # Show all files (including dotfiles)
alias llt='lsd -l --tree'  # Long format in a tree view

# --- General Aliases (Your custom aliases are preserved here) ---
alias grep='grep --color=auto'
alias vi='nvim'
alias vimtutor='nvim -c Tutor'
alias pacman='sudo pacman'
alias cat='bat' # Assumes 'bat' is installed, a great 'cat' replacement
alias ping='ping -c 4 1.1.1.1'
alias fsociety="sudo systemd-nspawn -D /opt/tools-container"
alias config="/usr/bin/git --git-dir=$HOME/river_minimal_dotfiles --work-tree=$HOME"

# ------------------------------------------------------------------------------
# [3] Application Initializations
# (Load nvm, pyenv, cargo, etc. at the end)
# ------------------------------------------------------------------------------
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Load nvm bash_completion
. "$HOME/.cargo/env"                                               # Load Rust/Cargo env
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# ==============================================================================
# [4] Advanced Powerline Prompt
# (Replaces the old static PS1 export)
# ==============================================================================

# --- Helper functions for prompt segments ---
prompt_git() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then printf " %s" " ${branch}"; fi
}

prompt_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then printf " %s" "🐍 ${VIRTUAL_ENV##*/}"; fi
}

prompt_path() {
    printf " %s" " \w" # \w is efficient and shows ~ for home
}

# --- Main prompt building function ---
prompt_command() {
    local last_status=$?
    local is_root=false && [[ "$(id -u)" -eq 0 ]] && is_root=true

    # Define Color Schemes
    local BGC_CWD BGC_GIT BGC_VENV BGC_TIME FGC_PRIMARY FGC_SECONDARY FGC_ACCENT
    if $is_root; then
        # ROOT THEME: Red/Orange for high alert
        BGC_CWD='\e[48;5;88m'
        BGC_GIT='\e[48;5;166m'
        BGC_VENV='\e[48;5;172m'
        BGC_TIME='\e[48;5;236m'
        FGC_PRIMARY='\e[38;5;255m'
        FGC_SECONDARY='\e[38;5;226m'
        FGC_ACCENT='\e[38;5;196m' # Red for prompt character
    else
        # REGULAR USER THEME: Blue/Green/Gray
        BGC_CWD='\e[48;5;24m'
        BGC_GIT='\e[48;5;22m'
        BGC_VENV='\e[48;5;30m'
        BGC_TIME='\e[48;5;236m'
        FGC_PRIMARY='\e[38;5;255m'
        FGC_SECONDARY='\e[38;5;244m'
        FGC_ACCENT='\e[38;5;46m' # Green for prompt character
    fi

    local SEP_RIGHT=""
    local SEP_LEFT=""

    # Build Line 1
    local prompt_line_1=""
    local current_bgc=${BGC_TIME}

    # TIME segment
    prompt_line_1+="\[${BGC_TIME}${FGC_SECONDARY}\]  \t"

    # Helper to add a new segment
    # Helper to add a new segment
    add_segment() {
        local segment_content=$1
        local segment_bgc=$2
        if [[ -n "$segment_content" ]]; then
            # The 'm' after the first parameter expansion has been removed.
            prompt_line_1+=" \[\e[38;5;${current_bgc#*5;}${segment_bgc}\]${SEP_RIGHT}\[\e[38;5;${FGC_PRIMARY#*5;}\]${segment_content}"
            current_bgc=${segment_bgc}
        fi
    }

    add_segment "$(prompt_path)" "${BGC_CWD}"
    add_segment "$(prompt_venv)" "${BGC_VENV}"
    add_segment "$(prompt_git)" "${BGC_GIT}"

    # Closing separator
    prompt_line_1+=" \[\e[38;5;${current_bgc#*5;}m\e[0m\]${SEP_RIGHT}\[ \e[0m\]"

    # Build Line 2
    local status_icon="\[\e[38;5;46m\]✔"                      # Green checkmark
    [ $last_status -ne 0 ] && status_icon="\[\e[38;5;196m\]✖" # Red X

    local prompt_char="$" && $is_root && prompt_char="#"
    local prompt_line_2="${status_icon} \[$FGC_ACCENT\]›\[\e[0m\] ${prompt_char} "

    # Assemble Final PS1
    PS1="\n${prompt_line_1}\n${prompt_line_2}"
}

# Set the prompt command
PROMPT_COMMAND=prompt_command
