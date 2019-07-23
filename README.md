# ROM BUILDER
#
This repo is exclusively for [drone ci](https://cloud.drone.io/) to build ROM without hassle.

## Pre-requisites

**1.** Account on [drone ci](https://cloud.drone.io/).

**2.** Github token with write access to your repos.

**3.** Telegram chat id.

**4.** Telegram bot token.

**5.** A GitHub repo on your ___main account___ where your builds will be uploaded.


## How to Setup

**1.** Fork my repo

**2.** Make required changes. All the variables that needs to be changed is present in config.sh


___Required Changes:___
 
  `GITHUB_USER`: You username on github.

  `GITHUB_EMAIL`: Public github email.

  `device`: Device codename.

  `ROM`: ROM name.

  `manifest_url`: Manifest url of that specific ROM.

  `rom_vendor_name`: This represent the vendor name used by different ROMs. e.g: aosp for , lineage for LineageOS, etc

  `release_repo`: The repo on your main account where the builds will be automatically uploaded as releases.
    

___Optional Changes:___
 
 `KBUILD_BUILD_USER`: Change the username in kernel string.

 `KBUILD_BUILD_HOST`: Change the hostname in kernel string.

 `timezone`: Changes timezone.


**4.** Generate your google-git-cookies ( this step is optional, but do it if your sync fails because of bandwidth errors ).

Visit [this url](https://accounts.google.com/o/oauth2/auth?response_type=code&access_type=offline&approval_prompt=force&client_id=413937457453.apps.googleusercontent.com&scope=https://www.googleapis.com/auth/gerritcodereview&redirect_uri=https://www.googlesource.com/new-password&state=android) and login.

Copy the lines from the box and paste them somewhere.

Make a repo on your account, repo name must be `google-git-cookies`and ___it must be private___.

Create a file `setup_cookies.sh` in that repo.

Paste the string that you copied before in `setup_cookies.sh`

Commit the changes and push them.

**5.** If you want to clone some repos, or do something in ROM folder, add those commands in clone.sh, make sure you don't fuck it up.

**6.** Open [drone ci](https://cloud.drone.io/).

Tap on repository name which you forked from this repo.

Tap on Activate Repository.

Go to settings showing adjacent to Activity feed.

Scroll down adn you will find secrets section.

You need to make three secrets:

`GITHUB_TOKEN` `TELEGRAM_CHAT` `TELEGRAM_TOKEN`

Done

**7.** Now just force push the last commit you pushed to the repo. It will trigger a build.

Now you can go to a activity feed and restart if you wanna build again.

Basically, you can either manually trigger the build or a commit will trigger it.
#
# Happy Buildbotting

## Sane pull requests / suggestions / issues reports are always welcome
