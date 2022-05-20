#!/usr/bin/env bash

function _make_index() {
  local index_name=$1
  shift
  local -a value_array=("$@")
  local i
  # -A means associative array, -g means create a global variable:
  declare -g -A ${index_name}
  for i in "${!value_array[@]}"; do
    eval ${index_name}["${value_array[$i]}"]=$i
  done
}

_squarectl_completion() {
  COMPREPLY=()

  # Declare our list of commands
  local cur_word prev_word

  # Case 1: squarectl command
  local global_commands_list
  global_commands_list=(compose configs info kube secrets swarm completion)

  # Case 1: compose command
  local compose_commands_list
  compose_commands_list=(build clean config down ps setup top up exec start stop)

  # Case 2: configs command
  local configs_commands_list
  configs_commands_list=(create destroy)

  # Case 3: secrets command
  local secrets_commands_list
  secrets_commands_list=(create destroy)

  # Case 4: swarm command
  local swarm_commands_list
  swarm_commands_list=(build clean config deploy destroy push setup)

  # Case 5: kube command
  local kube_commands_list
  kube_commands_list=(build clean config convert deploy push setup)

  # Case 6: completion command
  local completion_commands_list
  completion_commands_list=(bash)

  # Case 7: info command
  local info_commands_list
  info_commands_list=(compose swarm kube)

  # Create indices
  _make_index compose_commands_index "${compose_commands_list[@]}"
  _make_index configs_commands_index "${configs_commands_list[@]}"
  _make_index secrets_commands_index "${secrets_commands_list[@]}"
  _make_index swarm_commands_index "${swarm_commands_list[@]}"
  _make_index kube_commands_index "${kube_commands_list[@]}"
  _make_index completion_commands_index "${completion_commands_list[@]}"
  _make_index info_commands_index "${info_commands_list[@]}"

  # COMP_WORDS is an array of words in the current command line.
  # COMP_CWORD is the index of the current word (the one the cursor is
  # in). So COMP_WORDS[COMP_CWORD] is the current word; we also record
  # the previous word here, although this specific script doesn't
  # use it yet.
  cur_word="${COMP_WORDS[COMP_CWORD]}"
  prev_word="${COMP_WORDS[COMP_CWORD-1]}"
  word_before="${COMP_WORDS[COMP_CWORD-2]}"

  case ${prev_word} in
    compose)
      if [ ${word_before} = "info" ]; then
        COMPREPLY=()
        return 0
      fi

      COMPREPLY=($(compgen -W "${compose_commands_list[*]}" -- "${cur_word}"))
      return 0
    ;;

    configs)
      COMPREPLY=($(compgen -W "${configs_commands_list[*]}" -- "${cur_word}"))
      return 0
    ;;

    secrets)
      COMPREPLY=($(compgen -W "${secrets_commands_list[*]}" -- "${cur_word}"))
      return 0
    ;;

    swarm)
      if [ ${word_before} = "info" ]; then
        COMPREPLY=()
        return 0
      fi

      COMPREPLY=($(compgen -W "${swarm_commands_list[*]}" -- "${cur_word}"))
      return 0
    ;;

    kube)
      if [ ${word_before} = "info" ]; then
        COMPREPLY=()
        return 0
      fi

      COMPREPLY=($(compgen -W "${kube_commands_list[*]}" -- "${cur_word}"))
      return 0
    ;;

    completion)
      COMPREPLY=($(compgen -W "${completion_commands_list[*]}" -- "${cur_word}"))
      return 0
    ;;

    info)
      COMPREPLY=($(compgen -W "${info_commands_list[*]}" -- "${cur_word}"))
      return 0
    ;;

    *)
      if [ "${compose_commands_index[${prev_word}]}" ] ||
        [ "${configs_commands_index[${prev_word}]}" ] ||
        [ "${secrets_commands_index[${prev_word}]}" ] ||
        [ "${swarm_commands_index[${prev_word}]}" ] ||
        [ "${kube_commands_index[${prev_word}]}" ] ||
        [ "${completion_commands_index[${prev_word}]}" ] ; then
        COMPREPLY=()
        return 0
      fi
    ;;
  esac

  COMPREPLY=($(compgen -W "${global_commands_list[*]}" -- "${cur_word}"))
  return 0
}

complete -F _squarectl_completion squarectl
