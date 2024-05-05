#!/bin/bash

function get_current_vim_buffer() {
  echo $(vim --version | grep -oP '(?<=^Current\ buffer\:\ ).*')
}

function get_system_context() {
  local system_context=$(inxi -F)
  echo $system_context
  printf $system_context
}


function get_pacman_packages() {
    pacman -Q
}




