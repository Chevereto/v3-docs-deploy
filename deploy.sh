# !/usr/bin/env sh

set -e

if [ -f "./config.sh" ]; then
    . ./config.sh
else
    . ./config-dist.sh
fi

if [ -d "docs" ]; then
    cd docs
    if [ "$(git config --get remote.origin.url)" != "$GIT_DOCS" ]; then
        echo "Docs repo changed!"
        rm -rf -- "$(pwd -P)" && cd ..
        git clone $GIT_DOCS
    else
        git reset --hard
        git pull
        cd -
    fi
else
    git clone $GIT_DOCS
fi

echo 'Copy .vuepress/ contents to docs/.vuepress/'
cp -rf .vuepress/. docs/.vuepress/

echo 'PHP: Build nav & sidebar'
php build.php

echo 'yarn: Build VuePress'
yarn && yarn build

cd docs/.vuepress/dist

if [ -z "$CNAME" ]; then
    echo 'CNAME: None'
else
    echo 'CNAME: created at docs/.vuepress/dist'
    echo $CNAME >CNAME
fi

git init
git add -A
git commit -m 'deploy'
git push -f $GIT_HOSTING master

cd -
