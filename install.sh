#!/bin/bash

USERNAME="sharboul"
SCRIPT_PATH="/root/.scripts/"

apt-get update -y
apt upgrade -y
apt-get install -y libpam-pwquality libpwquality-tools sudo
groupadd user42
usermod -a -G user42,sudo $USERNAME
mkdir -p $SCRIPT_PATH

cp monitoring.sh > $SCRIPT_PATH
cat login.defs > /etc/login.defs
cat common-password > /etc/pam.d/common-password
cat sshd_config > /etc/ssh/sshd_config
cat crontab > /etc/crontab
cat sudoers > /etc/sudoers

