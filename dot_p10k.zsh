# ~/.p10k.zsh — lean two-line Powerlevel10k config, vivid colours, system stats
# Line 1: [os] user@host  dir  git            status  time-taken  jobs  CPU  load  RAM  swap  disk  clock
# Line 2: ❯   (root: red user tag, red #)
# Needs a Nerd Font (MesloLGS NF / Meslo Nerd Font) in the terminal.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

# ---- Custom segment: CPU % since the previous prompt (reads /proc/stat) ----
function prompt_my_cpu() {
  [[ -r /proc/stat ]] || return
  local -a s=(${=${(M)${(f)"$(</proc/stat)"}:#cpu *}})
  local idle=$(( s[5] + s[6] )) total=0 i
  for i in ${s[2,-1]}; do (( total += i )); done
  if (( ${+_mycpu_pt} )); then
    local dt=$(( total - _mycpu_pt )) di=$(( idle - _mycpu_pi ))
    if (( dt > 0 )); then
      local pct=$(( 100 * (dt - di) / dt )) fg=108
      (( pct >= 50 )) && fg=179
      (( pct >= 80 )) && fg=167
      p10k segment -f $fg -i $'' -t "${(l:3:)pct}%%"
    fi
  fi
  typeset -g _mycpu_pt=$total _mycpu_pi=$idle
}

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # ---- Layout ----
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon context dir vcs
    newline
    prompt_char
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status command_execution_time background_jobs virtualenv anaconda
    my_cpu load ram swap disk_usage
    time
  )

  # ---- General style (lean: transparent, except user and dir tags) ----
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER// }'
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_{PREFIX,SUFFIX}=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=238
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=' '

  # ---- prompt_char ----
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=108
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=167
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=

  # ---- os_icon ----
  typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='%f${P9K_CONTENT}'
  typeset -g POWERLEVEL9K_OS_ICON_LEFT_RIGHT_WHITESPACE=' '
  typeset -g POWERLEVEL9K_DIR_LEFT_LEFT_WHITESPACE=' '

  # ---- context: blue-tinted tag for users, red-tinted for root ----
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO,REMOTE,REMOTE_SUDO}_BACKGROUND=23
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO,REMOTE,REMOTE_SUDO}_FOREGROUND=152
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=52
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=217
  typeset -g POWERLEVEL9K_CONTEXT_LEFT_{LEFT,RIGHT}_WHITESPACE=' '
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO,REMOTE,REMOTE_SUDO}_CONTENT_EXPANSION='%n%F{245}@%F{180}%m'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_CONTENT_EXPANSION='%F{210}%n%F{245}@%F{180}%m'
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO,REMOTE,REMOTE_SUDO,ROOT}_VISUAL_IDENTIFIER_EXPANSION=

  # ---- Root: red banner instead of OS icon, red '#' prompt char ----
  if (( EUID == 0 )); then
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=167
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='#'
  fi

  # ---- dir: soft green highlight ----
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=108
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=108
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=114
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false
    typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=60
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_BACKGROUND=52

  # ---- vcs (git) ----
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=$' '
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=108
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=179
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=110
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=167
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=244
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # ---- status ----
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=108
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=167
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=167
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=167

  # ---- command_execution_time (shown if ≥ 3 s) ----
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=144
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # ---- background_jobs ----
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=108

  # ---- virtualenv ----
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=73
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  # ---- anaconda (conda env name) ----
  typeset -g POWERLEVEL9K_ANACONDA_FOREGROUND=73

  # ---- Fixed-width stats, so the right column stays aligned ----
  typeset -g POWERLEVEL9K_{LOAD,RAM,SWAP,DISK_USAGE}_CONTENT_EXPANSION='${(l:5:)P9K_CONTENT}'

  # ---- load (1-min average, coloured relative to core count) ----
  typeset -g POWERLEVEL9K_LOAD_WHICH=1
  typeset -g POWERLEVEL9K_LOAD_NORMAL_FOREGROUND=109
  typeset -g POWERLEVEL9K_LOAD_WARNING_FOREGROUND=179
  typeset -g POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND=167

  # ---- ram / swap ----
  typeset -g POWERLEVEL9K_RAM_FOREGROUND=140
  typeset -g POWERLEVEL9K_SWAP_FOREGROUND=175

  # ---- disk_usage (current filesystem) ----
  typeset -g POWERLEVEL9K_DISK_USAGE_NORMAL_FOREGROUND=108
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_FOREGROUND=179
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_FOREGROUND=167
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=85
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL=95
  typeset -g POWERLEVEL9K_DISK_USAGE_ONLY_WARNING=false

  # ---- time ----
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=243
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # ---- Behaviour ----
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
