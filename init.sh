#!/bin/bash
export my_dir=$(pwd)
cd ~
echo "Downloading dependencies..."
git clone https://github.com/akhilnarang/scripts --depth 1
cd scripts
echo "Installing dependencies..."
source setup/android_build_env.sh
cd ..
rm -rf scripts
sudo apt purge openjdk-11* -y
sudo apt install openjdk-8-jdk -y
cd "${my_dir}"
if [ ! -f /usr/bin/telegram ]; then
    sudo install bin/telegram /usr/bin
elif [ ! -f /usr/bin/github-release ]; then
    sudo install bin/github-release /usr/bin
fi
echo "Starting build process..."
source clean.sh
