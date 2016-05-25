#!/bin/sh

echo 'start : brew update'
brew update
echo 'end   : brew update'
echo

echo 'start : brew upgrade'
brew upgrade
echo 'end   : brew upgrade'
echo

echo 'start : apm update'
apm update -c false
echo 'end   : apm update'
echo

echo 'start : brew cleanup -s'
brew cleanup -s
echo 'end   : brew cleanup -s'
echo

echo 'start : npm cache clean'
npm cache clean
echo 'end : npm cache clean'
echo
