#!/bin/bash
if [ ! -d "releases" ]; then
    git clone https://github.com/JarlPenguin/releases.git -b master
fi
cd releases
curl https://storage.googleapis.com/git-repo-downloads/repo > bin/repo
chmod a+x bin/*
export PATH="$(pwd)/bin:${PATH}"
export branch=$(git branch | grep \* | cut -d ' ' -f2)
git restore .
git fetch origin "${branch}"
git checkout FETCH_HEAD
git branch -D "${branch}"
git checkout -b "${branch}"
export BUILD_NUMBER=""
