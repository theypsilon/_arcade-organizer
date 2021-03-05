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

INIFILE=Path(sys.argv[0]).with_suffix('.ini').absolute()
ini_file_path = Path(INIFILE)

config = configparser.ConfigParser()
if ini_file_path.is_file():
    try:
        config.read(ini_file_path)
    except:
        with ini_file_path.open() as fp:
            config.read_file(itertools.chain(['[DEFAULT]'], fp), source=ini_file_path)

ini_args = config['DEFAULT']
MRADIR = ini_args.get('MRADIR', "/media/fat/_Arcade/").strip('"\'')
ORGDIR = ini_args.get('ORGDIR', "/media/fat/_Arcade/_Organized").strip('"\'')
SKIPALTS = bool(distutils.util.strtobool(ini_args.get('SKIPALTS', 'true').strip('"\'')))
INSTALL = bool(distutils.util.strtobool(ini_args.get('INSTALL', 'false').strip('"\'')))

###############################
ARCADE_ORGANIZER_VERSION = "1.0"
ARCADE_ORGANIZER_WORK_PATH = os.getenv('ARCADE_ORGANIZER_WORK_PATH', "/media/fat/Scripts/.cache/arcade-organizer")
ARCADE_ORGANIZER_NAMES_TXT = os.getenv('ARCADE_ORGANIZER_NAMES_TXT', "/media/fat/names.txt")
CACHED_DATA_ZIP = Path("%s/data.zip" % ARCADE_ORGANIZER_WORK_PATH)
ORGDIR_FOLDERS_FILE = Path("%s/orgdir-folders" % ARCADE_ORGANIZER_WORK_PATH)
SSL_SECURITY_OPTION = os.getenv('SSL_SECURITY_OPTION', '--insecure')
CURL_RETRY =  '--max-time 30 --show-error'
TMP_DATA_ZIP = "/tmp/data.zip"

#####Organized Directories#####
ORGDIR_1AE="%s/_1 A-E" % ORGDIR
ORGDIR_1FK="%s/_1 F-K" % ORGDIR
ORGDIR_1LQ="%s/_1 L-Q" % ORGDIR
ORGDIR_1RT="%s/_1 R-T" % ORGDIR
ORGDIR_1UZ="%s/_1 U-Z" % ORGDIR
ORGDIR_2Core="%s/_2 Core" % ORGDIR
ORGDIR_3Year="%s/_3 Year" % ORGDIR
ORGDIR_4Manufacturer="%s/_4 Manufacturer" % ORGDIR
ORGDIR_5Category="%s/_5 Category" % ORGDIR
ORGDIR_6Rotation="%s/_6 Rotation" % ORGDIR
ORGDIR_7Region="%s/_7 Region" % ORGDIR

ORGDIR_DIRECTORIES = [
   ORGDIR_1AE,
   ORGDIR_1FK,
   ORGDIR_1LQ,
   ORGDIR_1RT,
   ORGDIR_1UZ,
   ORGDIR_2Core,
   ORGDIR_3Year,
   ORGDIR_4Manufacturer,
   ORGDIR_5Category,
   ORGDIR_6Rotation,
   ORGDIR_7Region,
]

ROTATION_DIRECTORIES = {
      0: "Horizontal",
     90: "Vertical CW 90 Deg",
    180: "Horizontal 180 Deg",
    270: "Vertical CCW 90 Deg"
}

#####Build names.txt Dictionary#####

NAMES_TXT=dict()
arcade_organizer_names_txt = Path(ARCADE_ORGANIZER_NAMES_TXT)
if arcade_organizer_names_txt.is_file():
    with arcade_organizer_names_txt.open() as f:
        for line in f:
            if ":" not in line:
                continue
            splits = line.split(':', 1)
            NAMES_TXT[splits[0].upper()] = splits[1].strip()

def better_core_name(core_name):
    if core_name == "":
        return ""

    upper_core = core_name.upper()
    if upper_core in NAMES_TXT:
        return NAMES_TXT[upper_core]

    return core_name

#####Core name fix optimized#####
CORES_DIR = Path("%s/cores/" % MRADIR)
CORES_DICT = dict()
if CORES_DIR.is_dir():
    for core_path in CORES_DIR.iterdir():
        core_name = core_path.name.rsplit('_', 1)[0]
        CORES_DICT[core_name.upper()] = core_name

def fix_core(core_name):
    if core_name == "":
        return ""
    return CORES_DICT.get(core_name.upper().strip(".RBF"), core_name)

#####Extract MRA Info######
def header():
   print('%-44s' % "MRA", end='')
   print(' %-10s' % "Core", end='')
   print(' %-4s' % "Year", end='')
   print(' %-10s' % "Manufactu.", end='')
   print(' %-8s' % "Category", end='')
   print()
   print("################################################################################")

def between_chars(char, left, right):
    return char >= ord(left) and char <= ord(right)

def make_symlink(mra_path, basename_mra, directory):
    target = Path("%s/%s" % (directory, basename_mra))
    if target.is_file() or target.is_symlink():
        return
    try:
        target.parent.mkdir(parents=True, exist_ok=True)
    except:
        return
    os.symlink(str(mra_path.absolute()), str(target.absolute()))

def read_orgdir_file_folders():
    result = list()
    orgdir_folders_file = Path(ORGDIR_FOLDERS_FILE)
    if orgdir_folders_file.is_file():
        with orgdir_folders_file.open() as f:
            for line in f:
                directory = line.strip()
                path = Path(directory)
                if path.is_dir():
                    result.append(directory)
    return result

def read_rotations():
    if CACHED_DATA_ZIP.is_file():
        output = subprocess.run("unzip -p %s" % CACHED_DATA_ZIP, shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.PIPE)
        if output.returncode == 0:
            return json.loads(output.stdout.decode())

        print("Error while reading rotations from %s" % CACHED_DATA_ZIP)

    return {}

def search_rotation(setname, ao_db):
    mame_rotation = ao_db.get(setname, {}).get('rot')
    return ROTATION_DIRECTORIES.get(mame_rotation, '')

def is_alternative(mra_path):
    return any(p.name.lower() == '_alternatives' for p in mra_path.parents)

def organize_mra(mra_path, ao_db):
    tags = ['name', 'setname', 'rbf', 'year', 'manufacturer', 'category', 'region']
    fields = { i : '' for i in tags }

    try:
        context = ET.iterparse(str(mra_path), events=("start",))
        for event, elem in context:
            elem_tag = elem.tag.lower()
            if elem_tag in tags:
                tags.remove(elem_tag)
                elem_value = elem.text
                if isinstance(elem_value, str):
                    fields[elem_tag] = elem_value
                if len(tags) == 0:
                    break
    except:
        pass

    skipping_alt = SKIPALTS and is_alternative(mra_path)

    if skipping_alt and fields['region'] == '':
        return

    if 'rbf' not in fields:
        print("%s is ill-formed, please delete and download it again." % mra)
        return

    fields['rbf'] = fix_core(fields['rbf'])

    basename_mra = mra_path.name

    print('%-44s' % basename_mra[0:44], end='')
    print(' %-10s' % fields['rbf'][0:10], end='')
    print(' %-4s' % fields['year'][0:4], end='')
    print(' %-10s' % fields['manufacturer'][0:10], end='')
    print(' %-8s' % fields['category'].replace('/', '')[0:8], end='')
    print()

    fields['rbf'] = better_core_name(fields['rbf'])

    #####Create symlinks for Region#####
    if fields['region'] != '':
        make_symlink(mra_path, basename_mra, "%s/_%s/" % (ORGDIR_7Region, fields['region']))

    if skipping_alt:
        return

    #####Create symlinks for A-Z######
    first_letter_char = ord(basename_mra.upper()[0])
    if between_chars(first_letter_char, '0', '9') or between_chars(first_letter_char, 'A', 'E'):
        make_symlink(mra_path, basename_mra, ORGDIR_1AE)
    elif between_chars(first_letter_char, 'F', 'K'):
        make_symlink(mra_path, basename_mra, ORGDIR_1FK)
    elif between_chars(first_letter_char, 'L', 'Q'):
        make_symlink(mra_path, basename_mra, ORGDIR_1LQ)
    elif between_chars(first_letter_char, 'R', 'T'):
        make_symlink(mra_path, basename_mra, ORGDIR_1RT)
    elif between_chars(first_letter_char, 'U', 'Z'):
        make_symlink(mra_path, basename_mra, ORGDIR_1UZ)

    #####Create symlinks for Core#####
    if fields['rbf'] != '':
        make_symlink(mra_path, basename_mra, "%s/_%s/" % (ORGDIR_2Core, fields['rbf']))

    #####Create symlinks for Year#####
    if fields['year'] != '':
        make_symlink(mra_path, basename_mra, "%s/_%s/" % (ORGDIR_3Year, fields['year']))

    #####Create symlinks for Manufacturer#####
    if fields['manufacturer'] != '':
        make_symlink(mra_path, basename_mra, "%s/_%s/" % (ORGDIR_4Manufacturer, fields['manufacturer']))

    #####Create symlinks for Category#####
    if fields['category'] != '':
        make_symlink(mra_path, basename_mra, "%s/_%s/" % (ORGDIR_5Category, fields['category']))

    #####Create symlinks for Rotation#####
    if fields['setname'] != '' and CACHED_DATA_ZIP.is_file():
        rotation = search_rotation(fields['setname'], ao_db)
        if rotation != '':
            make_symlink(mra_path, basename_mra, "%s/_%s/" % (ORGDIR_6Rotation, rotation))


def is_date(date_text):
    try:
        datetime.datetime.strptime(date_text, '%Y-%m-%dT%H:%M:%SZ')
        return True
    except:
        return False

def are_files_different(file1, file2):
    with file1.open() as f1:
        with file2.open() as f2:
            diffs = list(difflib.unified_diff(f1.readlines(), f2.readlines()))
            return len(diffs) > 0

def are_files_md5_different(path1, path2):
    return hashlib.md5(path1.open('rb').read()).hexdigest() != hashlib.md5(path2.open('rb').read()).hexdigest()

def download_data_zip():
    print("Downloading rotations data.zip")

    zip_output = subprocess.run('curl %s %s -o %s https://raw.githubusercontent.com/MAME-GETTER/_arcade-organizer/master/rotations/data.zip' % (CURL_RETRY, SSL_SECURITY_OPTION, TMP_DATA_ZIP), shell=True, stderr=subprocess.DEVNULL)

    tmp_data_zip = Path(TMP_DATA_ZIP)
    if zip_output.returncode != 0 or not tmp_data_zip.is_file():
        print("Couldn't download rotations data.zip : Network Problem")
        print()
        return
    
    md5_output = subprocess.run('curl %s %s https://raw.githubusercontent.com/MAME-GETTER/_arcade-organizer/master/rotations/data.zip.md5' % (CURL_RETRY, SSL_SECURITY_OPTION), shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.PIPE)
    if md5_output.returncode != 0:
        print("Couldn't download rotations data.zip.md5 : Network Problem")
        print()
        tmp_data_zip.unlink()
        return

    md5hash = md5_output.stdout.splitlines()[0].decode()
    print("MD5 Hash: %s" % md5hash)
    print()
    if hashlib.md5(open(TMP_DATA_ZIP,'rb').read()).hexdigest() != md5hash:
        print("Corrupted rotations data.zip : Network Problem")
        print()
        tmp_data_zip.unlink()

def optimized_arcade_organizer():
    Path(ARCADE_ORGANIZER_WORK_PATH).mkdir(parents=True, exist_ok=True)

    print("Reading INI (%s):" % ini_file_path.name)

    INI_DATE = ''
    if ini_file_path.is_file():
        ctime = datetime.datetime.fromtimestamp(ini_file_path.stat().st_ctime)
        INI_DATE = ctime.strftime('%Y-%m-%dT%H:%M:%SZ')
        print("OK")
    else:
        print("Not found.")

    print()
    print('Arguments:')
    for key, value in calculate_ini_options().items():
        print("%s=%s" % (key, value))
    print()

    #########Auto Install##########
    INSTALL_PATH="/media/fat/Scripts/update_arcade-organizer.sh"
    if INSTALL and not Path(INSTALL_PATH).is_file():
        print("Installing update_arcade-organizer.sh at /media/fat/Scripts")
        output = subprocess.run('curl %s %s --location -o %s https://raw.githubusercontent.com/MAME-GETTER/_arcade-organizer/master/update_arcade-organizer.sh' % (CURL_RETRY, SSL_SECURITY_OPTION, INSTALL_PATH), shell=True)
        if output.returncode == 0:
            print("Installed.")
        else:
            print("Couldn't install it : Network Problem")
        time.sleep(10)
        print()

    # check for any previous rotation files in tmp folder
    tmp_data_zip = Path(TMP_DATA_ZIP)
    if tmp_data_zip.is_file():
        tmp_data_zip.unlink()

    download_data_zip()

    last_run_path = Path("%s/last_run" % ARCADE_ORGANIZER_WORK_PATH)

    LAST_INI_DATE = ''
    LAST_MRA_DATE = ''
    if last_run_path.is_file():
        with last_run_path.open() as f:
            content = f.readlines()
            content = [x.strip() for x in content]
            if len(content) > 1:
                LAST_INI_DATE = content[1]
            if len(content) > 2:
                LAST_MRA_DATE = content[2]

    FROM_SCRATCH = False

    if not Path(ORGDIR_1AE).is_dir() or \
       not Path(ORGDIR_1FK).is_dir() or \
       not Path(ORGDIR_1LQ).is_dir() or \
       not Path(ORGDIR_1RT).is_dir() or \
       not Path(ORGDIR_1UZ).is_dir() or \
       not is_date(LAST_MRA_DATE):
        FROM_SCRATCH = True
        print("Fresh run required.")
        print()

    cached_names = Path("%s/installed_names.txt" % ARCADE_ORGANIZER_WORK_PATH)
    real_names = Path(ARCADE_ORGANIZER_NAMES_TXT)
    if real_names.is_file() and (not cached_names.is_file() or are_files_different(real_names, cached_names)):
        FROM_SCRATCH = True
        print("The installed names.txt is new for the Arcade Organizer.")
        print()

    if INI_DATE != LAST_INI_DATE:
        FROM_SCRATCH = True
        if LAST_INI_DATE != '':
            print("INI file has been modified.")
            print()

    if tmp_data_zip.is_file():
        cached_data_zip = CACHED_DATA_ZIP
        if not cached_data_zip.is_file() or are_files_md5_different(tmp_data_zip, cached_data_zip):
            shutil.copy(str(tmp_data_zip), str(cached_data_zip))
            FROM_SCRATCH = True
            print("The rotations data.zip is new for the Arcade Organizer")
            print()
        else:
            print("No changes detected in rotations data.zip")
            print("Skipping rotations data.zip...")
            print()
        tmp_data_zip.unlink()

    find_args=""
    for directory in ORGDIR_DIRECTORIES:
        find_args = "%s -not -path \"%s\"/\*" % (find_args, directory)

    if not FROM_SCRATCH:
        find_args = "%s -newerct %s" % (find_args, LAST_MRA_DATE)

    orgdir_folders_file = ORGDIR_FOLDERS_FILE
    MRA_DATE = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    if FROM_SCRATCH:
        print("Performing a full build.")
        if orgdir_folders_file.is_file():
            for directory in read_orgdir_file_folders():
                remove_dir(directory)
            orgdir_folders_file.unlink()
        for directory in ORGDIR_DIRECTORIES:
            remove_dir(directory)

    if not FROM_SCRATCH:
        print("Performing an incremental build.")
        print("NOTE: Remove the Organized folders if you wish to start from scratch.")
        for directory in read_orgdir_file_folders():
            remove_broken_symlinks(directory)

    print()

    find_command = 'find %s -type f -name "*.mra" %s' % (MRADIR, find_args)
    updated_mras = subprocess.run(find_command, shell=True, stdout=subprocess.PIPE).stdout.splitlines()
    updated_mras = map(lambda byteline: Path(byteline.decode()), updated_mras)
    updated_mras = sorted(updated_mras, key=lambda mra: mra.name.lower())

    if len(updated_mras) == 0:
        print("No new MRAs detected")
        print()
        print("Skipping Arcade Organizer...")
        print()
        exit(0)
    
    print("Organizing %s MRAs." % len(updated_mras))
    print()

    ao_db = read_rotations()
    header()

    for mra in updated_mras:
        organize_mra(mra, ao_db)

    with orgdir_folders_file.open("a") as f:
        orgdir_lines = read_orgdir_file_folders()
        for directory in ORGDIR_DIRECTORIES:
            if Path(directory).is_dir():
                if not os.listdir(directory):
                    remove_dir(directory)
                elif directory not in orgdir_lines:
                    f.write(directory + "\n")

    org_rp = Path(os.path.realpath(ORGDIR))
    mra_rp = Path(os.path.realpath(MRADIR))

    org_cores = Path("%s/cores" % ORGDIR)
    mra_cores = Path("%s/cores" % MRADIR)
    if mra_rp not in org_rp.parents and not org_cores.is_dir() and mra_cores.is_dir():
        os.symlink(str(mra_cores.absolute()), str(org_cores.absolute()))
        with orgdir_folders_file.open("a") as f:
            f.write(str(org_cores) + "\n")

    with last_run_path.open("w") as f:
        f.write(ARCADE_ORGANIZER_VERSION + "\n")
        f.write(INI_DATE + "\n")
        f.write(MRA_DATE + "\n")
    
    if real_names.is_file():
        shutil.copy(str(real_names), str(cached_names))

    print("################################################################################")

def remove_dir(directory):
    path = Path(directory)
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(directory)
    elif path.is_symlink():
        path.unlink()
    else:
        return
    parent = str(path.parent)
    if not os.listdir(parent):
        shutil.rmtree(parent)

def remove_broken_symlinks(directory):
    output = subprocess.run('find "%s/" -xtype l -exec rm \{\} \;' % directory, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if output.returncode != 0:
        print("Couldn't clean broken symlinks at " + directory)

def calculate_orgdir_folders():
    dir_set=set()
    for directory in ORGDIR_DIRECTORIES:
        if Path(directory).is_dir():
            dir_set.add(directory)
    
    for directory in read_orgdir_file_folders():
        dir_set.add(directory)

    return sorted(dir_set)

def calculate_ini_options():
    return {
        'MRADIR' : MRADIR,
        'ORGDIR' : ORGDIR,
        'SKIPALTS' : "true" if SKIPALTS else "false",
        'INSTALL' : "true" if INSTALL else "false",
    }

if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == "--print-orgdir-folders":
        for directory in calculate_orgdir_folders():
            print(directory)

    elif len(sys.argv) == 2 and sys.argv[1] == "--print-ini-options":
        for key, value in calculate_ini_options().items():
            print("%s=%s" % (key, value))

    elif len(sys.argv) != 1:
        print("Invalid arguments.")
        print("Usage: %s --print-orgdir-folders" % sys.argv[0])
        print("       %s --print-ini-options" % sys.argv[0])
        print("       %s" % sys.argv[0])
        exit(1)

    else:
        optimized_arcade_organizer()