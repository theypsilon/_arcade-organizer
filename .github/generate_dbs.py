#!/usr/bin/env python3
# Copyright (C) 2020, 2021 Andrew Moore "amoore2600", José Manuel Barroso Galindo "theypsilon"
# This file is part of the Arcade Organizer
#
# Arcade Organizer is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Arcade Organizer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License

import sys
import subprocess
from pathlib import Path
import configparser
from inspect import currentframe, getframeinfo
import itertools
import os
import io
import hashlib
import distutils.util
import datetime
import difflib
import shutil
import time
import json
import xml.etree.cElementTree as ET

def main():

    print('START!')

    subdirs_finder = SubdirsFinder('aod')
    for subdir in subdirs_finder.find_all_subdirs():
        print("\n%s:" % subdir)
        aod_finder = AodFinder(str(subdir))
        aod_reader = AodReader()

        for aod in aod_finder.find_all_aods():
            print(str(aod))
            aod_reader.read_aod(aod)

        json_filename = 'db/' + subdir.stem + '.json'
        zip_filename = json_filename + '.zip'
        save_data_to_compressed_json(aod_reader.data(), json_filename, zip_filename)
        run_succesfully('git add %s' % zip_filename)

    run_succesfully('git commit -m "BOT: Releasing new AOD databases."')
    if not run_conditional('git diff --exit-code master origin/master'):
        print("There are changes to commit.")
        print()

        run_succesfully('git push origin master')
    else:
        print("Nothing to be updated.")

    print('Done.')

class AodFinder:
    def __init__(self, dir):
        self._dir = dir

    def find_all_aods(self):
        return sorted(self._scan(self._dir), key=lambda aod: aod.name.lower())

    def _scan(self, directory):
        for entry in os.scandir(directory):
            if entry.is_dir(follow_symlinks=False):
                yield from self._scan(entry.path)
            elif entry.name.lower().endswith(".aod"):
                yield Path(entry.path)

class SubdirsFinder:
    def __init__(self, dir):
        self._dir = dir

    def find_all_subdirs(self):
        return sorted(self._scan(self._dir), key=lambda subdir: subdir.name.lower())

    def _scan(self, directory):
        for entry in os.scandir(directory):
            if entry.is_dir(follow_symlinks=False):
               yield Path(entry.path)

def read_aod_fields(aod_path, tags):
    fields = { i : '' for i in tags }

    try:
        context = ET.iterparse(str(aod_path), events=("start",))
        for event, elem in context:
            elem_tag = elem.tag.lower()
            if elem_tag in tags:
                tags.remove(elem_tag)
                elem_value = elem.text
                if isinstance(elem_value, str):
                    fields[elem_tag] = elem_value
                if len(tags) == 0:
                    break
    except Exception as e:
        print("Line %s || %s (%s)" % (lineno(), e, aod_path))

    return fields

class AodReader:
    def __init__(self):
        self._data = dict()

    def read_aod(self, aod):
        fields = read_aod_fields(aod, [
            'name',
            'setname',
            'rotation',
            'flip',
            'resolution',
            'region',
            'homebrew',
            'bootleg',
            'year',
            'category',
            'manufacturer'
        ])

        data = dict()
        set_if_not_empty(data, fields, 'name')
        set_if_not_empty(data, fields, 'rotation')
        set_if_not_empty(data, fields, 'flip')
        set_if_not_empty(data, fields, 'resolution')
        set_if_not_empty(data, fields, 'region')
        set_if_not_empty(data, fields, 'homebrew')
        set_if_not_empty(data, fields, 'bootleg')
        set_if_not_empty(data, fields, 'year')
        set_if_not_empty(data, fields, 'category')
        set_if_not_empty(data, fields, 'manufacturer')

        self._data[fields['setname']] = data

    def data(self):
        return self._data

def set_if_not_empty(data, fields, key):
    if fields[key] != '':
        data[key] = fields[key]

def save_data_to_compressed_json(db, json_name, zip_name):

    with open(json_name, 'w') as f:
        json.dump(db, f, sort_keys=True)

    run_succesfully('touch -a -m -t 202108231405 %s' % json_name)
    run_succesfully('zip -rq -D -X -9 -A --compression-method deflate %s %s' % (zip_name, json_name))

def run_conditional(command):
    result = subprocess.run(command, shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.PIPE)

    stdout = result.stdout.decode()
    if stdout.strip():
        print(stdout)
        
    return result.returncode == 0

def run_succesfully(command):
    result = subprocess.run(command, shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)

    stdout = result.stdout.decode()
    stderr = result.stderr.decode()
    if stdout.strip():
        print(stdout)
    
    if stderr.strip():
        print(stderr)

    if result.returncode != 0:
        raise Exception("subprocess.run Return Code was '%d'" % result.returncode)

if __name__ == '__main__':
    main()