#!/bin/bash
export my_dir=$(pwd)
cd ~
git clone https://github.com/akhilnarang/scripts --depth 1
cd scripts
. setup/android_build_env.sh
cd ..
rm -rf scripts
sudo apt purge openjdk-11* -y
sudo apt install openjdk-8-jdk -y
cd "$my_dir"
if [ ! -f /usr/bin/telegram ]; then
sudo install telegram /usr/bin
elif [ ! -f /usr/bin/github-release ]; then
sudo install github-release /usr/bin
fi
. clean.sh
