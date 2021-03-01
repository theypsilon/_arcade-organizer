#!/usr/bin/env bash
# Copyright (c) 2021 José Manuel Barroso Galindo <theypsilon@gmail.com>

set -euo pipefail

pushd rotations
./regenerate_mame-rotations.sh
popd

echo

git config --global user.email "theypsilon@gmail.com"
git config --global user.name "The CI/CD Bot"

ROTATIONS_FILES="rotations/mame-rotations.txt rotations/data.zip rotations/data.zip.md5"
git add ${ROTATIONS_FILES}

if ! git diff --staged --quiet --exit-code ; then
    git commit -m "BOT: ${ROTATIONS_FILES} updated."
    git push origin master
else
    echo "Nothing to be done."
fi
