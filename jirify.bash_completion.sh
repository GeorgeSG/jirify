#//bin/bash
# jirify tab-completion script for bash.

JIRIFY_FOLDER="${HOME}/.jirify"
ISSUE_KEYS_CACHE="${JIRIFY_FOLDER}/.cache"
CACHE_TTL=60

_jirify_write_issues_to_cache() {
  my_issue_keys="$(jira issues -k)"
  echo "$my_issue_keys" > "$ISSUE_KEYS_CACHE"
}

_jirify_maybe_reload_cache() {
  if [ -f $ISSUE_KEYS_CACHE ]; then
    time_elapsed=`expr $(date +%s) - $(stat -f %c $ISSUE_KEYS_CACHE)`

    if (( time_elapsed >= CACHE_TTL )); then
      _jirify_write_issues_to_cache
    fi
  else
    _jirify_write_issues_to_cache
  fi
}

_jirify_completions() {
  current="${COMP_WORDS[COMP_CWORD]}"
  previous="${COMP_WORDS[COMP_CWORD-1]}"

  top_level_commands="help issues projects setup sprint version"
  projects_commands="help list"
  setup_commands="help init bash_completion verbose"
  issues_commands="help assignee block close describe mine open review start status take todo transition transitions unassign unblock"

  _compgen_issue_keys() {
    _jirify_maybe_reload_cache
    my_issue_keys=$(<${ISSUE_KEYS_CACHE})
    COMPREPLY=($(compgen -W "${my_issue_keys}" -- ${current}))
  }

  _compgen_top_level() {
    COMPREPLY=($(compgen -W "${top_level_commands}" -- ${current}))
  }

  _compgen_projects() {
    COMPREPLY=($(compgen -W "${projects_commands}" -- ${current}))
  }

  _compgen_setup() {
    COMPREPLY=($(compgen -W "${setup_commands}" -- ${current}))
  }

  _compgen_issues() {
    COMPREPLY=($(compgen -W "${issues_commands}" -- ${current}))
  }

  if [ $COMP_CWORD == 1 ]
  then
    _compgen_top_level
    return 0
  fi

  if [ $COMP_CWORD == 2 ]
  then
    case "$previous" in
      "help")
        _compgen_top_level
        return 0
        ;;
      "projects")
        _compgen_projects
        return 0
        ;;
      "setup")
        _compgen_setup
        return 0
        ;;
      i|issues)
        _compgen_issues
        return 0
        ;;
    esac
  fi

  if [ $COMP_CWORD == 3 ]
  then
    action="${COMP_WORDS[COMP_CWORD-2]}"

    if [ "$previous" == "help" ]; then
      case "$action" in
        "projects")
          _compgen_projects
          return 0
          ;;
        "setup")
          _compgen_setup
          return 0
          ;;
        i|issues)
          _compgen_issues
          return 0
          ;;
      esac
    elif [ "$action" == "issues" ] || [ "$action" == "i" ]; then
      _compgen_issue_keys
      return 0
    fi
  fi
}

complete -F _jirify_completions jira
