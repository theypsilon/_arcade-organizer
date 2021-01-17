#!/usr/bin/env bash
# Copyright (c) 2021 José Manuel Barroso Galindo <theypsilon@gmail.com>

set -euo pipefail

pushd rotations
./regenerate_mame-rotations.sh
popd

echo

git config --global user.email "theypsilon@gmail.com"
git config --global user.name "The CI/CD Bot"

ROTATIONS_FILE="rotations/mame-rotations.txt"
git add "${ROTATIONS_FILE}"

if ! git diff --staged --quiet --exit-code ; then
    git commit -m "BOT: ${ROTATIONS_FILE} updated."
    git push origin master
else
    echo "Nothing to be done."
fi
