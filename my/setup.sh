#!/bin/bash

timedatectl set-ntp true
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone

git config --global push.default simple

git_config_gmail(){
    git config user.name "$1"
    git config user.email "$1@gmail.com"
}
git_config_gmail fzinfz