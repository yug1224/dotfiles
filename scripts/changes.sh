#!/bin/bash

usage_exit() {
  echo "\nUsage: $0 \033[;34m[Options]\033[0;39m\n" 1>&2
  echo "\033[;34mOptions:\033[0;39m
    -r (required) name of the Github repository
    -b name of the default branch  [master]
  " 1>&2
  exit 1
}

BRANCH_NAME="master"

while getopts b:r:h OPT
do
  case $OPT in
    "b" ) BRANCH_NAME="$OPTARG" ;;
    "r" ) REPOSITORY_NAME="$OPTARG" ;;
    "h" ) usage_exit ;;
    *   ) usage_exit ;;
  esac
done

if [ -z "$REPOSITORY_NAME" ] ; then
  echo "'-r' expects a value"
  usage_exit
else
  github-changes --host ghe.ca-tools.org -o GLASGOW -r $REPOSITORY_NAME -b $BRANCH_NAME -a --only-pulls --use-commit-body --path-prefix api/v3 -k e0d2f9d447028807608ec68849a1af796391ab20 -z Asia/Tokyo
fi
