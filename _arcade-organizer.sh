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

def make_config():
    config = dict()
    config['PRINT_SYMLINKS'] = os.getenv('PRINT_SYMLINKS', 'false') == 'true'

    fake_data = os.getenv('FAKE_DATA')
    if fake_data is not None:
        config['FAKE_DATA'] = fake_data

    original_script_path = subprocess.run('ps | grep "^ *%s " | grep -o "[^ ]*$"' % os.getppid(), shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.PIPE).stdout.decode().strip()
    if original_script_path == '-bash':
        original_script_path = sys.argv[0]

    INIFILE=Path(original_script_path).with_suffix('.ini').absolute()
    ini_parser = configparser.ConfigParser()
    config["ini_file_path"] = Path(INIFILE)
    if config['ini_file_path'].is_file():
        try:
            ini_parser.read(config['ini_file_path'])
        except:
            with config['ini_file_path'].open() as fp:
                ini_parser.read_file(itertools.chain(['[DEFAULT]'], fp), source=config['ini_file_path'])

    ini_args = ini_parser['DEFAULT']
    config['MRADIR'] = ini_args.get('MRADIR', "/media/fat/_Arcade/").strip('"\'')
    config['ORGDIR'] = ini_args.get('ORGDIR', "/media/fat/_Arcade/_Organized").strip('"\'')
    config['SKIPALTS'] = bool(distutils.util.strtobool(ini_args.get('SKIPALTS', 'true').strip('"\'')))
    config['INSTALL'] = bool(distutils.util.strtobool(ini_args.get('INSTALL', 'false').strip('"\'')))
    config['VERBOSE'] = bool(distutils.util.strtobool(ini_args.get('VERBOSE', 'false').strip('"\'')))
    config['AZ_DIR'] = bool(distutils.util.strtobool(ini_args.get('AZ_DIR', 'true').strip('"\'')))
    config['CHRON_DIR'] = bool(distutils.util.strtobool(ini_args.get('CHRON_DIR', 'true').strip('"\'')))
    config['CHRON_SUB_DIR'] = bool(distutils.util.strtobool(ini_args.get('CHRON_SUB_DIR', 'true').strip('"\'')))
    config['BUTTONS_DIR'] = bool(distutils.util.strtobool(ini_args.get('BUTTONS_DIR', 'true').strip('"\'')))
    config['JOYSTICK_DIR'] = bool(distutils.util.strtobool(ini_args.get('JOYSTICK_DIR', 'true').strip('"\'')))
    config['PLAYERS_DIR'] = bool(distutils.util.strtobool(ini_args.get('PLAYERS_DIR', 'true').strip('"\'')))
    config['RESOLUTION_DIR'] = bool(distutils.util.strtobool(ini_args.get('RESOLUTION_DIR', 'true').strip('"\'')))
    config['ROTATION_DIR'] = bool(distutils.util.strtobool(ini_args.get('ROTATION_DIR', 'true').strip('"\'')))
    config['CORE_DIR'] = bool(distutils.util.strtobool(ini_args.get('CORE_DIR', 'true').strip('"\'')))
    config['MANUFACTURER_DIR'] = bool(distutils.util.strtobool(ini_args.get('MANUFACTURER_DIR', 'true').strip('"\'')))
    config['CATEGORY_DIR'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_DIR', 'true').strip('"\'')))
    config['SERIES_DIR'] = bool(distutils.util.strtobool(ini_args.get('SERIES_DIR', 'true').strip('"\'')))
    config['PLATFORM_DIR'] = bool(distutils.util.strtobool(ini_args.get('PLATFORM_DIR', 'true').strip('"\'')))
    config['SPECIAL_CONTROLS_DIR'] = bool(distutils.util.strtobool(ini_args.get('SPECIAL_CONTROLS_DIR', 'true').strip('"\'')))
    config['FLIP_DIR'] = bool(distutils.util.strtobool(ini_args.get('FLIP_DIR', 'true').strip('"\'')))
    config['REGION_DIR'] = bool(distutils.util.strtobool(ini_args.get('REGION_DIR', 'true').strip('"\'')))
    config['REGION_SUB_DIR'] = bool(distutils.util.strtobool(ini_args.get('REGION_SUB_DIR', 'true').strip('"\'')))
    config['BOOTLEG_DIR'] = bool(distutils.util.strtobool(ini_args.get('BOOTLEG_DIR', 'true').strip('"\'')))
    config['HOMEBREW_DIR'] = bool(distutils.util.strtobool(ini_args.get('HOMEBREW_DIR', 'true').strip('"\'')))
    config['ALTERNATIVE'] = bool(distutils.util.strtobool(ini_args.get('ALTERNATIVE', 'true').strip('"\'')))
    config['PLAYERS_1'] = bool(distutils.util.strtobool(ini_args.get('PLAYERS_1', 'true').strip('"\'')))
    config['PLAYERS_2_ALT'] = bool(distutils.util.strtobool(ini_args.get('PLAYERS_2_ALT', 'true').strip('"\'')))
    config['PLAYERS_2_SIM'] = bool(distutils.util.strtobool(ini_args.get('PLAYERS_2_SIM', 'true').strip('"\'')))
    config['PLAYERS_3'] = bool(distutils.util.strtobool(ini_args.get('PLAYERS_3', 'true').strip('"\'')))
    config['PLAYERS_4'] = bool(distutils.util.strtobool(ini_args.get('PLAYERS_4', 'true').strip('"\'')))
    config['PLAYERS_5'] = bool(distutils.util.strtobool(ini_args.get('PLAYERS_5', 'true').strip('"\'')))
    config['PLAYERS_6'] = bool(distutils.util.strtobool(ini_args.get('PLAYERS_6', 'true').strip('"\'')))
    config['BUTTONS_1'] = bool(distutils.util.strtobool(ini_args.get('BUTTONS_1', 'true').strip('"\'')))
    config['BUTTONS_2'] = bool(distutils.util.strtobool(ini_args.get('BUTTONS_2', 'true').strip('"\'')))
    config['BUTTONS_3'] = bool(distutils.util.strtobool(ini_args.get('BUTTONS_3', 'true').strip('"\'')))
    config['BUTTONS_4'] = bool(distutils.util.strtobool(ini_args.get('BUTTONS_4', 'true').strip('"\'')))
    config['BUTTONS_5'] = bool(distutils.util.strtobool(ini_args.get('BUTTONS_5', 'true').strip('"\'')))
    config['BUTTONS_6'] = bool(distutils.util.strtobool(ini_args.get('BUTTONS_6', 'true').strip('"\'')))
    config['JOYSTICK_2H'] = bool(distutils.util.strtobool(ini_args.get('JOYSTICK_2H', 'true').strip('"\'')))
    config['JOYSTICK_2V'] = bool(distutils.util.strtobool(ini_args.get('JOYSTICK_2V', 'true').strip('"\'')))
    config['JOYSTICK_4'] = bool(distutils.util.strtobool(ini_args.get('JOYSTICK_4', 'true').strip('"\'')))
    config['JOYSTICK_8'] = bool(distutils.util.strtobool(ini_args.get('JOYSTICK_8', 'true').strip('"\'')))
    config['SPINNER'] = bool(distutils.util.strtobool(ini_args.get('SPINNER', 'true').strip('"\'')))
    config['TRACKBALL'] = bool(distutils.util.strtobool(ini_args.get('TRACKBALL', 'true').strip('"\'')))
    config['TWIN_STICK'] = bool(distutils.util.strtobool(ini_args.get('TWIN_STICK', 'true').strip('"\'')))
    config['TANK_STICK'] = bool(distutils.util.strtobool(ini_args.get('TANK_STICK', 'true').strip('"\'')))
    config['POSITIONAL_STICK'] = bool(distutils.util.strtobool(ini_args.get('POSITIONAL_STICK', 'true').strip('"\'')))
    config['TILT_STICK'] = bool(distutils.util.strtobool(ini_args.get('TILT_STICK', 'true').strip('"\'')))
    config['RESOLUTION_15KHZ'] = bool(distutils.util.strtobool(ini_args.get('RESOLUTION_15KHZ', 'true').strip('"\'')))
    config['RESOLUTION_24KHZ'] = bool(distutils.util.strtobool(ini_args.get('RESOLUTION_24KHZ', 'true').strip('"\'')))
    config['RESOLUTION_31KHZ'] = bool(distutils.util.strtobool(ini_args.get('RESOLUTION_31KHZ', 'true').strip('"\'')))
    config['ROTATION_0'] = bool(distutils.util.strtobool(ini_args.get('ROTATION_0', 'true').strip('"\'')))
    config['ROTATION_90'] = bool(distutils.util.strtobool(ini_args.get('ROTATION_90', 'true').strip('"\'')))
    config['ROTATION_180'] = bool(distutils.util.strtobool(ini_args.get('ROTATION_180', 'true').strip('"\'')))
    config['ROTATION_270'] = bool(distutils.util.strtobool(ini_args.get('ROTATION_270', 'true').strip('"\'')))
    config['REGION_USA'] = bool(distutils.util.strtobool(ini_args.get('REGION_USA', 'true').strip('"\'')))
    config['REGION_JAPAN'] = bool(distutils.util.strtobool(ini_args.get('REGION_JAPAN', 'true').strip('"\'')))
    config['REGION_EUROPE'] = bool(distutils.util.strtobool(ini_args.get('REGION_EUROPE', 'true').strip('"\'')))
    config['REGION_WORLD'] = bool(distutils.util.strtobool(ini_args.get('REGION_WORLD', 'true').strip('"\'')))
    config['REGION_ASIA'] = bool(distutils.util.strtobool(ini_args.get('REGION_ASIA', 'true').strip('"\'')))
    config['REGION_BRAZIL'] = bool(distutils.util.strtobool(ini_args.get('REGION_BRAZIL', 'true').strip('"\'')))
    config['BOOTLEG'] = bool(distutils.util.strtobool(ini_args.get('BOOTLEG', 'true').strip('"\'')))
    config['HOMEBREW'] = bool(distutils.util.strtobool(ini_args.get('HOMEBREW', 'true').strip('"\'')))
    config['1970S'] = bool(distutils.util.strtobool(ini_args.get('1970S', 'true').strip('"\'')))
    config['1980S'] = bool(distutils.util.strtobool(ini_args.get('1980S', 'true').strip('"\'')))
    config['1990S'] = bool(distutils.util.strtobool(ini_args.get('1990S', 'true').strip('"\'')))
    config['2000S'] = bool(distutils.util.strtobool(ini_args.get('2000S', 'true').strip('"\'')))
    config['2010S'] = bool(distutils.util.strtobool(ini_args.get('2010S', 'true').strip('"\'')))
    config['2020S'] = bool(distutils.util.strtobool(ini_args.get('2020S', 'true').strip('"\'')))
    config['CATEGORY_ACTION'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_ACTION', 'true').strip('"\'')))
    config['CATEGORY_ARENA'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_ARENA', 'true').strip('"\'')))
    config['CATEGORY_BALL_PADDLE'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_BALL_PADDLE', 'true').strip('"\'')))
    config['CATEGORY_BEAT_EM_UP'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_BEAT_EM_UP', 'true').strip('"\'')))
    config['CATEGORY_FIGHTING'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_FIGHTING', 'true').strip('"\'')))
    config['CATEGORY_GAMBLING'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_GAMBLING', 'true').strip('"\'')))
    config['CATEGORY_GRID_MAZE'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_GRID_MAZE', 'true').strip('"\'')))
    config['CATEGORY_LANDER'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_LANDER', 'true').strip('"\'')))
    config['CATEGORY_MAHJONG'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_MAHJONG', 'true').strip('"\'')))
    config['CATEGORY_MIXED'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_MIXED', 'true').strip('"\'')))
    config['CATEGORY_PLATFORM'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_PLATFORM', 'true').strip('"\'')))
    config['CATEGORY_PLATFORM_CLIMB'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_PLATFORM_CLIMB', 'true').strip('"\'')))
    config['CATEGORY_PUZZLE'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_PUZZLE', 'true').strip('"\'')))
    config['CATEGORY_PUZZLE_PLATFORM'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_PUZZLE_PLATFORM', 'true').strip('"\'')))
    config['CATEGORY_QUIZ'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_QUIZ', 'true').strip('"\'')))
    config['CATEGORY_RUN_N_GUN_HOR'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_RUN_N_GUN_HOR', 'true').strip('"\'')))
    config['CATEGORY_RUN_N_GUN_VER'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_RUN_N_GUN_VER', 'true').strip('"\'')))
    config['CATEGORY_SHOOTER_GALLERY'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_SHOOTER_GALLERY', 'true').strip('"\'')))
    config['CATEGORY_SHOOTER_HOR'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_SHOOTER_HOR', 'true').strip('"\'')))
    config['CATEGORY_SHOOTER_ISO'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_SHOOTER_ISO', 'true').strip('"\'')))
    config['CATEGORY_SHOOTER_MULTI'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_SHOOTER_MULTI', 'true').strip('"\'')))
    config['CATEGORY_SHOOTER_TUBE'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_SHOOTER_TUBE', 'true').strip('"\'')))
    config['CATEGORY_SHOOTER_VER'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_SHOOTER_VER', 'true').strip('"\'')))
    config['CATEGORY_SPORTS'] = bool(distutils.util.strtobool(ini_args.get('CATEGORY_SPORTS', 'true').strip('"\'')))
    config['CLEAN_CATEGORY'] = bool(distutils.util.strtobool(ini_args.get('CLEAN_CATEGORY', 'true').strip('"\'')))

    ###############################
    config['ARCADE_ORGANIZER_VERSION'] = "1.0"
    config['ARCADE_ORGANIZER_WORK_PATH'] = os.getenv('ARCADE_ORGANIZER_WORK_PATH', "/media/fat/Scripts/.cache/arcade-organizer")
    config['ARCADE_ORGANIZER_NAMES_TXT'] = Path(os.getenv('ARCADE_ORGANIZER_NAMES_TXT', "/media/fat/names.txt"))
    config['CACHED_DATA_ZIP'] = Path("%s/data.zip" % config['ARCADE_ORGANIZER_WORK_PATH'])
    config['ORGDIR_FOLDERS_FILE'] = Path("%s/orgdir-folders" % config['ARCADE_ORGANIZER_WORK_PATH'])
    config['SSL_SECURITY_OPTION'] = os.getenv('SSL_SECURITY_OPTION', '--insecure')
    config['CURL_RETRY'] =  '--max-time 30 --show-error'
    config['TMP_DATA_ZIP'] = "/tmp/data.zip"

    #####Organized Directories#####
    config['ORGDIR_109'] = "%s/_1 0-9" % config['ORGDIR']
    config['ORGDIR_1AE'] = "%s/_1 A-E" % config['ORGDIR']
    config['ORGDIR_1FK'] = "%s/_1 F-K" % config['ORGDIR']
    config['ORGDIR_1LQ'] = "%s/_1 L-Q" % config['ORGDIR']
    config['ORGDIR_1RT'] = "%s/_1 R-T" % config['ORGDIR']
    config['ORGDIR_1UZ'] = "%s/_1 U-Z" % config['ORGDIR']
    config['ORGDIR_2Core'] = "%s/_2 Core" % config['ORGDIR']
    config['ORGDIR_3Year'] = "%s/_3 Year" % config['ORGDIR']
    config['ORGDIR_4Manufacturer'] = "%s/_4 Manufacturer" % config['ORGDIR']
    config['ORGDIR_5Category'] = "%s/_5 Category" % config['ORGDIR']
    config['ORGDIR_6Rotation'] = "%s/_6 Rotation" % config['ORGDIR']
    config['ORGDIR_7Region'] = "%s/_7 Region" % config['ORGDIR']

    config['ORGDIR_DIRECTORIES'] = [
        config['ORGDIR_109'],
        config['ORGDIR_1AE'],
        config['ORGDIR_1FK'],
        config['ORGDIR_1LQ'],
        config['ORGDIR_1RT'],
        config['ORGDIR_1UZ'],
        config['ORGDIR_2Core'],
        config['ORGDIR_3Year'],
        config['ORGDIR_4Manufacturer'],
        config['ORGDIR_5Category'],
        config['ORGDIR_6Rotation'],
        config['ORGDIR_7Region'],
    ]

    config['ROTATION_DIRECTORIES'] = {
        0: "Horizontal",
        90: "Vertical CW 90 Deg",
        180: "Horizontal 180 Deg",
        270: "Vertical CCW 90 Deg"
    }

    if True:
        return config

    # @TODO Activate PR #38
    #####Misteraddons Organized Directories#####
    config['ORGDIR_109'] = "%s/__0-9" % config['ORGDIR']
    config['ORGDIR_1AE'] = "%s/__A-E" % config['ORGDIR']
    config['ORGDIR_1FK'] = "%s/__F-K" % config['ORGDIR']
    config['ORGDIR_1LQ'] = "%s/__L-Q" % config['ORGDIR']
    config['ORGDIR_1RT'] = "%s/__R-T" % config['ORGDIR']
    config['ORGDIR_1UZ'] = "%s/__U-Z" % config['ORGDIR']
    config['ORGDIR_Core'] = "%s/_Core" % config['ORGDIR']
    config['ORGDIR_Chron'] = "%s/_Chronological" % config['ORGDIR']
    config['ORGDIR_Manufacturer'] = "%s/_Manufacturer" % config['ORGDIR']
    config['ORGDIR_Category'] = "%s/_Category" % config['ORGDIR']
    config['ORGDIR_Rotation'] = "%s/_Rotation" % config['ORGDIR']
    config['ORGDIR_Region'] = "%s/_Region" % config['ORGDIR']
    config['ORGDIR_Resolution'] = "%s/_Resolution" % config['ORGDIR']
    config['ORGDIR_Series'] = "%s/_Series" % config['ORGDIR']
    config['ORGDIR_Platform'] = "%s/_Platform" % config['ORGDIR']
    config['ORGDIR_Flip'] = "%s/_Flip" % config['ORGDIR']
    config['ORGDIR_Players'] = "%s/_Players" % config['ORGDIR']
    config['ORGDIR_Joystick'] = "%s/_Joystick" % config['ORGDIR']
    config['ORGDIR_NumButtons'] = "%s/_Buttons" % config['ORGDIR']
    config['ORGDIR_SpecialControls'] = "%s/_Special Controls" % config['ORGDIR']
    config['ORGDIR_Bootleg'] = "%s/_Bootleg" % config['ORGDIR']
    config['ORGDIR_Homebrew'] = "%s/_Homebrew" % config['ORGDIR']

    config['ORGDIR_DIRECTORIES'] = [
        config['ORGDIR_109'],
        config['ORGDIR_1AE'],
        config['ORGDIR_1FK'],
        config['ORGDIR_1LQ'],
        config['ORGDIR_1RT'],
        config['ORGDIR_1UZ'],
        config['ORGDIR_Core'],
        config['ORGDIR_Chron'],
        config['ORGDIR_Manufacturer'],
        config['ORGDIR_Category'],
        config['ORGDIR_Rotation'],
        config['ORGDIR_Rotation'],
        config['ORGDIR_Region'],
        config['ORGDIR_Resolution'],
        config['ORGDIR_Series'],
        config['ORGDIR_Platform'],
        config['ORGDIR_Flip'],
        config['ORGDIR_Players'],
        config['ORGDIR_Joystick'],
        config['ORGDIR_NumButtons'],
        config['ORGDIR_SpecialControls'],
        config['ORGDIR_Bootleg'],
        config['ORGDIR_Homebrew']
    ]

    config['ROTATION_DIRECTORIES'] = {
        0: "Horizontal",
        90: "Vertical (CW)",
        180: "Horizontal (180)",
        270: "Vertical (CCW)"
    }

    return config

def lineno():
    return getframeinfo(currentframe().f_back).lineno

class Printer:
    def __init__(self, config):
        self._config = config

    def __enter__(self):
        try:
            self._logfile = open(self._config['ARCADE_ORGANIZER_WORK_PATH'] + "/issues.log", "w")
        except:
            pass
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        try:
            self._logfile.close()
        except:
            pass

    def print(self, *args, sep='', end='\n', file=sys.stdout, flush=False):
        print(*args, sep=sep, end=end, file=file, flush=flush)

    def log(self, *args, sep='', end='\n', flush=False):
        try:
            print(*args, sep=sep, end=end, file=self._logfile, flush=flush)
        except:
            pass

def between_chars(char, left, right):
    return char >= ord(left) and char <= ord(right)

def is_alternative(mra_path):
    return any(p.name.lower() == '_alternatives' for p in mra_path.parents)

def datetime_from_ctime(entry):
    return datetime.datetime.utcfromtimestamp(entry.stat().st_ctime)

class MraFinderOld:
    def __init__(self, config, infra):
        self._config = config
        self._find_args = ''

    def not_in_directory(self, directory):
        self._find_args = "%s -not -path \"%s\"/\*" % (self._find_args, directory)

    def newer_than(self, date):
        self._find_args = "%s -newerct %s" % (self._find_args, date)

    def find_all_mras(self):
        find_command = 'find %s -type f -name "*.mra" %s' % (self._config['MRADIR'], self._find_args)
        updated_mras = subprocess.run(find_command, shell=True, stdout=subprocess.PIPE).stdout.splitlines()
        updated_mras = map(lambda byteline: Path(byteline.decode()), updated_mras)
        updated_mras = sorted(updated_mras, key=lambda mra: mra.name.lower())
        return updated_mras

class MraFinderNew:
    def __init__(self, config, infra):
        self._config = config
        self._infra = infra
        self._not_in_directory = []
        self._newer_than = None

    def not_in_directory(self, directory):
        self._not_in_directory.append(directory)

    def newer_than(self, date_text):
        self._newer_than = self._infra.text_to_date(date_text)

    def find_all_mras(self):
        return sorted(self._scan(self._config['MRADIR']), key=lambda mra: mra.name.lower())

    def _scan(self, directory):
        for entry in os.scandir(directory):
            if entry.is_dir(follow_symlinks=False) and entry.path not in self._not_in_directory:
                yield from self._scan(entry.path)
            elif entry.name.lower().endswith(".mra") \
            and (self._newer_than is None or datetime_from_ctime(entry) > self._newer_than):
                yield Path(entry.path)

class Infrastructure:
    def __init__(self, config, printer):
        self._config = config
        self._printer = printer
        self._init_private_variables()

    def _init_private_variables(self):
        self._last_run_path = Path("%s/last_run" % self._config['ARCADE_ORGANIZER_WORK_PATH'])
        self._cached_names_path = Path("%s/installed_names.txt" % self._config['ARCADE_ORGANIZER_WORK_PATH'])
        self._tmp_data_zip_path = Path(self._config['TMP_DATA_ZIP'])

    def make_symlink(self, mra_path, basename_mra, directory):
        target = Path("%s/%s" % (directory, basename_mra))
        if target.is_file() or target.is_symlink():
            return
        try:
            self.make_directory(target.parent)
        except Exception as e:
            self._printer.log("Line %s || %s (%s)" % (lineno(), e, mra_path))
            return
        src = str(mra_path.absolute())
        dst = str(target.absolute())
        if self._config['PRINT_SYMLINKS']:
            self._printer.print("make_symlink: src %s dst %s" % (src, dst))
        else:
            os.symlink(src, dst)

    def download_data_zip(self):
        self._printer.print("Downloading rotations data.zip")

        if 'FAKE_DATA' in self._config:
            src = self._config['FAKE_DATA']
            shutil.copyfile(src, self._config['TMP_DATA_ZIP'])
            with open(self._config['TMP_DATA_ZIP'], 'rb') as tmp_data_zip:
                self._printer.print("MD5 Hash: %s" % hashlib.md5(tmp_data_zip.read()).hexdigest())
                self._printer.print()
                return None

        zip_output = subprocess.run('curl %s %s -o %s https://raw.githubusercontent.com/MAME-GETTER/_arcade-organizer/master/rotations/data.zip' % (self._config['CURL_RETRY'], self._config['SSL_SECURITY_OPTION'], self._config['TMP_DATA_ZIP']), shell=True, stderr=subprocess.DEVNULL)

        if zip_output.returncode != 0 or not self._tmp_data_zip_path.is_file():
            self._printer.print("Couldn't download rotations data.zip : Network Problem")
            self._printer.print()
            return None

        md5_output = subprocess.run('curl %s %s https://raw.githubusercontent.com/MAME-GETTER/_arcade-organizer/master/rotations/data.zip.md5' % (self._config['CURL_RETRY'], self._config['SSL_SECURITY_OPTION']), shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.PIPE)
        if md5_output.returncode != 0:
            self._printer.print("Couldn't download rotations data.zip.md5 : Network Problem")
            self._printer.print()
            self._tmp_data_zip_path.unlink()
            return None

        md5hash = md5_output.stdout.splitlines()[0].decode()
        self._printer.print("MD5 Hash: %s" % md5hash)
        self._printer.print()
        with open(self._config['TMP_DATA_ZIP'], 'rb') as tmp_data_zip:
            if hashlib.md5(tmp_data_zip.read()).hexdigest() != md5hash:
                self._printer.print("Corrupted rotations data.zip : Network Problem")
                self._printer.print()
                self._tmp_data_zip_path.unlink()
                return None

        return self._tmp_data_zip_path

    def remove_orgdir_directories(self, orgdir_folders_file):
        if orgdir_folders_file.is_file():
            for directory in self.read_orgdir_file_folders():
                self._remove_dir(directory)
            orgdir_folders_file.unlink()
        for directory in self._config['ORGDIR_DIRECTORIES']:
            self._remove_dir(directory)

    def remove_all_broken_symlinks(self):
        for directory in self.read_orgdir_file_folders():
            self._remove_broken_symlinks(directory)

    def get_ini_date(self):
        ini_file_path = self._config['ini_file_path']
        self._printer.print("Reading INI (%s):" % ini_file_path.name)

        ini_date = ''
        if ini_file_path.is_file():
            ctime = datetime_from_ctime(self._config['ini_file_path'])
            ini_date = ctime.strftime('%Y-%m-%dT%H:%M:%SZ')
            self._printer.print("OK")
        else:
            self._printer.print("Not found.")

        return ini_date

    def get_now_date(self):
        return datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

    def read_last_run_file(self):
        last_ini_date = ''
        last_mra_date = ''
        if self._last_run_path.is_file():
            with self._last_run_path.open() as f:
                content = f.readlines()
                content = [x.strip() for x in content]
                if len(content) > 1:
                    last_ini_date = content[1]
                if len(content) > 2:
                    last_mra_date = content[2]

        return [last_ini_date, last_mra_date]

    def write_last_run_file(self, ini_date, mra_date):
        with self._last_run_path.open("w") as f:
            f.write(self._config['ARCADE_ORGANIZER_VERSION'] + "\n")
            f.write(ini_date + "\n")
            f.write(mra_date + "\n")

    def cache_names_file(self):
        if self._config['ARCADE_ORGANIZER_NAMES_TXT'].is_file():
            shutil.copy(str(self._config['ARCADE_ORGANIZER_NAMES_TXT']), str(self._cached_names_path))

    def handle_orgdir_outside_mra_folder(self):
        org_rp = Path(os.path.realpath(self._config['ORGDIR']))
        mra_rp = Path(os.path.realpath(self._config['MRADIR']))

        org_cores = Path("%s/cores" % self._config['ORGDIR'])
        mra_cores = Path("%s/cores" % self._config['MRADIR'])
        if mra_rp not in org_rp.parents and not org_cores.is_dir() and mra_cores.is_dir():
            os.symlink(str(mra_cores.absolute()), str(org_cores.absolute()))
            orgdir_folders_file = self._config['ORGDIR_FOLDERS_FILE']
            with orgdir_folders_file.open("a") as f:
                f.write(str(org_cores) + "\n")

    def write_orgdir_folders_file(self):
        orgdir_folders_file = self._config['ORGDIR_FOLDERS_FILE']

        with orgdir_folders_file.open("a") as f:
            orgdir_lines = self.read_orgdir_file_folders()
            for directory in self._config['ORGDIR_DIRECTORIES']:
                if Path(directory).is_dir():
                    if not os.listdir(directory):
                        self._remove_dir(directory)
                    elif directory not in orgdir_lines:
                        f.write(directory + "\n")

    def read_orgdir_file_folders(self):
        result = list()
        orgdir_folders_file = self._config['ORGDIR_FOLDERS_FILE']
        if orgdir_folders_file.is_file():
            with orgdir_folders_file.open() as f:
                for line in f:
                    directory = line.strip()
                    path = Path(directory)
                    if path.is_dir():
                        result.append(directory)
        return result

    def install_standalone_script_if_needed(self):
        self._config['INSTALL_PATH'] = "/media/fat/Scripts/update_arcade-organizer.sh"
        if self._config['INSTALL'] and not Path(self._config['INSTALL_PATH']).is_file():
            self._printer.print("Installing update_arcade-organizer.sh at /media/fat/Scripts")
            output = subprocess.run('curl %s %s --location -o %s https://raw.githubusercontent.com/MAME-GETTER/_arcade-organizer/master/update_arcade-organizer.sh' % (self._config['CURL_RETRY'], self._config['SSL_SECURITY_OPTION'], self._config['INSTALL_PATH']), shell=True)
            if output.returncode == 0:
                self._printer.print("Installed.")
            else:
                self._printer.print("Couldn't install it : Network Problem")
            time.sleep(10)
            self._printer.print()

    def remove_any_previous_rotation_files_in_tmp(self):
        if self._tmp_data_zip_path.is_file():
            self._tmp_data_zip_path.unlink()

    def get_cached_data_zip(self):
        return self._config['CACHED_DATA_ZIP']

    def are_files_different(self, left_file, right_file):
        return (not left_file.is_file() and right_file.is_file()) or \
                (not right_file.is_file() and left_file.is_file()) or \
                self._are_files_md5_different(left_file, right_file)

    def copy_file(self, from_file, to_file):
        shutil.copy(str(from_file), str(to_file))

    def remove_file(self, file_path):
        file_path.unlink()

    def check_if_orgdir_directories_are_missing(self):
        return not Path(self._config['ORGDIR_109']).is_dir() or \
            not Path(self._config['ORGDIR_1AE']).is_dir() or \
            not Path(self._config['ORGDIR_1FK']).is_dir() or \
            not Path(self._config['ORGDIR_1LQ']).is_dir() or \
            not Path(self._config['ORGDIR_1RT']).is_dir() or \
            not Path(self._config['ORGDIR_1UZ']).is_dir()

    def check_if_names_txt_is_new(self):
        return self._config['ARCADE_ORGANIZER_NAMES_TXT'].is_file() \
        and ( \
            not self._cached_names_path.is_file() \
            or self._are_files_different(self._config['ARCADE_ORGANIZER_NAMES_TXT'], self._cached_names_path) \
        )

    def read_mra_fields(self, mra_path, tags):
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
        except Exception as e:
            self._printer.log("Line %s || %s (%s)" % (lineno(), e, mra_path))

        return fields

    def read_rotations(self):
        if self._config['CACHED_DATA_ZIP'].is_file():
            output = subprocess.run("unzip -p %s" % self._config['CACHED_DATA_ZIP'], shell=True, stderr=subprocess.DEVNULL, stdout=subprocess.PIPE)
            if output.returncode == 0:
                return json.loads(output.stdout.decode())

            self._printer.print("Error while reading rotations from %s" % self._config['CACHED_DATA_ZIP'])

        return {}

    def text_is_date(self, date_text):
        if self.text_to_date(date_text) is None:
            return False
        else:
            return True

    def text_to_date(self, date_text):
        try:
            date = datetime.datetime.strptime(date_text, '%Y-%m-%dT%H:%M:%SZ')
            return date
        except Exception as e:
            self._printer.log("Line %s || %s (%s)" % (lineno(), e, date_text))
            return None

    def make_directory(self, directory_path):
        directory_path.mkdir(parents=True, exist_ok=True)

    def _are_files_different(self, file1, file2):
        with file1.open() as f1, file2.open() as f2:
            diffs = list(difflib.unified_diff(f1.readlines(), f2.readlines()))
            return len(diffs) > 0

    def _are_files_md5_different(self, path1, path2):
        with path1.open('rb') as path1_file, path2.open('rb') as path2_file:
            return hashlib.md5(path1_file.read()).hexdigest() != hashlib.md5(path2_file.read()).hexdigest()

    def _remove_dir(self, directory):
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

    def _remove_broken_symlinks(self, directory):
        output = subprocess.run('find "%s/" -xtype l -exec rm \{\} \;' % directory, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        if output.returncode != 0:
            self._printer.print("Couldn't clean broken symlinks at " + directory)
            self._printer.print(output.stderr.decode())


class ArcadeOrganizer:
    def __init__(self, config, infra, mra_finder, printer):
        self._config = config
        self._infra = infra
        self._mra_finder = mra_finder
        self._printer = printer
        self._init_cores_dict()
        self._init_names_txt_dict()
        self._cached_rotations = None

    def _init_cores_dict(self):
        cores_dir = Path("%s/cores/" % self._config['MRADIR'])
        self._cores_dict = dict()
        if cores_dir.is_dir():
            for core_path in cores_dir.iterdir():
                core_name = core_path.name.rsplit('_', 1)[0]
                self._cores_dict[core_name.upper()] = core_name

    def _init_names_txt_dict(self):
        self._names_txt_dict = dict()
        if self._config['ARCADE_ORGANIZER_NAMES_TXT'].is_file():
            with self._config['ARCADE_ORGANIZER_NAMES_TXT'].open() as f:
                for line in f:
                    if ":" not in line:
                        continue
                    splits = line.split(':', 1)
                    self._names_txt_dict[splits[0].upper()] = splits[1].strip()

    def organize_single_mra(self, mra_path):

        fields = self._infra.read_mra_fields(mra_path, [
            'name',
            'setname',
            'rbf',
            'year',
            'manufacturer',
            # @TODO Activate PR #38
            #'manufacturer2',
            #'manufacturer3',
            'category',
            #'category2',
            #'category3',
            'region',
            #'homebrew',
            #'bootleg',
            #'platform',
            #'alternative',
            #'series',
            #'parent',
            #'resolution',
            #'rotation',
            #'flip',
            #'players',
            #'joystick',
            #'special_controls',
            #'buttons',
            #'num_buttons'
        ])

        category_list = [
            "Action",
            "Arena",
            "Ball and Paddle",
            "Beat \'em Up",
            "Fighting",
            "Gambling",
            "Grid / Maze",
            "Lander",
            "Mixed",
            "Platform",
            "Platform - Climb",
            "Puzzle",
            "Puzzle - Platform",
            "Quiz",
            "Racing",
            "Run \'n\' Gun - Horizontal",
            "Run \'n\' Gun - Vertical",
            "Shooter - Gallery",
            "Shooter - Horizontal",
            "Shooter - Isometric",
            "Shooter - Multidirectional",
            "Shooter - Tube",
            "Shooter - Vertical",
            "Sports"
        ]

        # @TODO Activate PR #38
        if False and self._config['CLEAN_CATEGORY']:
            if fields['category'] not in category_list:
                if fields['category'] == "Adventure / Knights" or fields['category'] == "Adventure/Knights":
                    fields['category'] = "Platform"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Arcade / Knights category changed to %s" % (fields['setname'], fields['category']))
                if fields['category'] == "Adventure / Western":
                    fields['category'] = "Run \'n\' Gun - Vertical"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Adventure / Western category changed to %s" % (fields['setname'], fields['category']))
                if fields['category'] == "Arcade Quiz":
                    fields['category'] = "Quiz"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Arcade Quiz category changed to %s" % (fields['setname'], fields['category']))
                if fields['category'] == "Army / Airforce":
                    fields['category'] = "Shooter - Vertical"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Army / Airforce category changed to %s" % (fields['setname'], fields['category']))
                if fields['category'] == "Army / Fighter":
                    fields['category'] = "Platform"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Army / Fighter category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Beat em up":
                    fields['category'] = "Beat \'em Up"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Beat em up category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Beat\'em up":
                    fields['category'] = "Beat \'em Up"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Beat\'em up category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Fighter":
                    fields['category'] = "Fighting"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Fighter category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Fighter / Asian" or fields['category'] == "Fighter / Hero" or fields['category'] == "Fighter / Warriors":
                    fields['category'] = "Beat \'em Up"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Fighter * category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Hack & Slash":
                    fields['category'] = "Platform"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Hack & Slash category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Hack \'n Slash":
                    fields['category'] = "Platform"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Hack \'n Slash category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Horizontal scrolling shooter":
                    fields['category'] = "Shooter - Horizontal"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Horizontal scrolling shooter category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Isometric Shoot\'em up":
                    fields['category'] = "Shooter - Isometric"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Isometric Shoot\'em up category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Multigame":
                    fields['category'] = "Mixed"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Multigame category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "MultiGame":
                    fields['category'] = "Sports"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: MultiGame category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Platformer":
                    fields['category'] = "Platform"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Platformer category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Run \'n Gun":
                    fields['category'] = "Run \'n\' Gun - Vertical"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Run \'n Gun category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Run n Gun":
                    fields['category'] = "Run \'n\' Gun - Horizontal"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Run n Gun category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Scrolling Shooter":
                    fields['category'] = "Shooter - Horizontal"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Scrolling Shooter category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Shoot \'em up":
                    if fields['setname'] == "sidearms" or fields['setname'] == "unsquad":
                        fields['category'] = "Shooter - Horizontal"
                    elif fields['setname'] == "varth":
                        fields['category'] = "Shooter - Vertical"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Shoot \'em up category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Shoot\'em Up" or fields['category'] == "Shoot&apos;em up" or fields['category'] == "Shoot\'em up":
                    if fields['setname'] == "ecofghtr" or fields['setname'] == "unsquad" or fields['setname'] == "fantzone" or fields['setname'] == "progear":
                        fields['category'] = "Shooter - Horizontal"
                    elif fields['setname'] == "19xx" or fields['setname'] == "1944" or fields['setname'] == "dimahoo" or fields['setname'] == "gigawing" or fields['setname'] == "mmatrix" or fields['setname'] == "afighter":
                        fields['category'] = "Shooter - Vertical"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Shoot\'em up category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Shooter":
                    if fields['setname'] == "sectionz" or fields['setname'] == "cawing":
                        fields['category'] = "Shooter - Horizontal"
                    elif fields['setname'] == "19xx" or fields['setname'] == "dfeveron" or fields['setname'] == "ddonpach" or fields['setname'] == "espradej" or fields['setname'] == "esprade" or fields['setname'] == "lwings" or fields['setname'] == "srumbler":
                        fields['category'] = "Shooter - Vertical"
                    elif fields['setname'] == "ganbare":
                        fields['category'] = "Shooter - Gallery"
                    elif fields['setname'] == "tricktrp":
                        fields['category'] = "Run \'n\' Gun - Horizontal"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Shooter category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Shooter / Walking":
                    fields['category'] = "Run \'n\' Gun - Vertical"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Shooter / Walking category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Space":
                    fields['category'] = "Shooter - Tube"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Space category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Space / Asteroids":
                    fields['category'] = "Shooter - Multidirectional"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Space / Asteroids category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Space / Force":
                    fields['category'] = "Shooter - Vertical"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Space / Force category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Space / Moon":
                    fields['category'] = "Lander"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Space / Moon category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Space / Shooter":
                    if fields['setname'] == "gyrussb" or fields['setname'] == "venus":
                        fields['category'] = "Shooter - Tube"
                    if fields['setname'] == "pleiads" or fields['setname'] == "pleiadce":
                        fields['category'] = "Shooter - Vertical"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Space / Shooter category changed to %s" % (fields['setname'], fields['category']))
                elif fields['category'] == "Wrestling" or fields['category'] == "Wrestling / Fighting"or fields['category'] == "Wrestling/Fighting":
                    fields['category'] = "Sports"
                    if self._config['VERBOSE']:
                        self._printer.print("----%s: Wrestling * category changed to %s" % (fields['setname'], fields['category']))

        skipping_alt = self._config['SKIPALTS'] and is_alternative(mra_path)

        # @TODO Activate PR #38
        if skipping_alt and fields['region'] == '':
            return
    
        # @TODO Activate PR #38
        if False and 'region' in fields:
            if (fields['region'] == "USA" or fields['region'] == "US") and not self._config['REGION_USA']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Region USA ****"))
                return
            elif fields['region'] == "Japan" and not self._config['REGION_JAPAN']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Region Japan ****"))
                return
            elif fields['region'] == "World" and not self._config['REGION_WORLD']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Region World ****"))
                return
            elif fields['region'] == "Europe" and not self._config['REGION_EUROPE']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Region Europe ****"))
                return
            elif fields['region'] == "Asia" and not self._config['REGION_ASIA']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Region Asia ****"))
                return
            elif fields['region'] == "Brazil" and not self._config['REGION_BRAZIL']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Region Brazil ****"))
                return
        
        # @TODO Activate PR #38
        if False and 'homebrew' in fields:
            if fields['homebrew'] == "yes" and not self._config['HOMEBREW']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Homebrew ****"))
                return

        # @TODO Activate PR #38
        if False and 'bootleg' in fields:
            if fields['bootleg'] == "yes" and not self._config['BOOTLEG']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Bootleg ****"))
                return

        # @TODO Activate PR #38
        if False and 'alternative' in fields:
            if fields['alternative'] != '' and not self._config['ALTERNATIVE']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Alternative ****"))
                return

        # @TODO Activate PR #38
        if False and 'resolution' in fields:
            if fields['resolution'] == "15kHz" and not self._config['RESOLUTION_15KHZ']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 15kHz ****"))
                return
            elif fields['resolution'] == "24kHz" and not self._config['RESOLUTION_24KHZ']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 24kHz ****"))
                return
            elif fields['resolution'] == "31kHz" and not self._config['RESOLUTION_31KHZ']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 31kHz ****"))
                return

        # @TODO Activate PR #38
        if False and 'rotation' in fields:
            if fields['rotation'] == "horizontal":
                if not self._config['ROTATION_0']:
                    self._printer.print("%s: %s" % (basename_mra, "**** Skipping Rotation 0 ****"))
                    return
                elif not self._config['ROTATION_180'] and fields['flip'] != "yes":
                    self._printer.print("%s: %s" % (basename_mra, "**** Skipping Rotation 180 + flip ****"))
                    return
            elif fields['rotation'] == "horizontal (flip)":
                if not self._config['ROTATION_180']:
                    self._printer.print("%s: %s" % (basename_mra, "**** Skipping Rotation 180 ****"))
                    return
                elif not self._config['ROTATION_0'] and fields['flip'] != "yes":
                    self._printer.print("%s: %s" % (basename_mra, "**** Skipping Rotation 0 + flip ****"))
                    return
            elif fields['rotation'] == "vertical (cw)":
                if not self._config['ROTATION_90']:
                    self._printer.print("%s: %s" % (basename_mra, "**** Skipping Rotation 90 ****"))
                    return
                elif not self._config['ROTATION_270'] and fields['flip'] != "yes":
                    self._printer.print("%s: %s" % (basename_mra, "**** Skipping Rotation 270 + flip ****"))
                    return
            elif fields['rotation'] == "vertical (ccw)":
                if not self._config['ROTATION_270']:
                    self._printer.print("%s: %s" % (basename_mra, "**** Skipping Rotation 270 ****"))
                    return
                elif not self._config['ROTATION_90'] and fields['flip'] != "yes":
                    self._printer.print("%s: %s" % (basename_mra, "**** Skipping Rotation 90 + flip ****"))
                    return

        # @TODO Activate PR #38
        if False and 'players' in fields:
            if fields['players'] == "1" and not self._config['PLAYERS_1']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 1 Player ****"))
                return
            elif fields['players'] == "2 (alternating)" and not self._config['PLAYERS_2_ALT']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 2 Players (Alternating) ****"))
                return
            elif fields['players'] == "2 (simultaneous)" and not self._config['PLAYERS_2_SIM']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 2 Players (Simultaneous) ****"))
                return
            elif fields['players'] == "3" and not self._config['PLAYERS_3']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 3 Players ****"))
                return
            elif fields['players'] == "4" and not self._config['PLAYERS_4']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 4 Players ****"))
                return
            elif fields['players'] == "5" and not self._config['PLAYERS_5']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 5 Players ****"))
                return
            elif fields['players'] == "6" and not self._config['PLAYERS_6']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 6 Players ****"))
                return

        # @TODO Activate PR #38
        if False and 'joystick' in fields:
            if fields['joystick'] == "2-way horizontal" and not self._config['JOYSTICK_2H']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 2-way Horizontal Joystick ****"))
                return
            elif fields['joystick'] == "2-way vertical" and not self._config['JOYSTICK_2V']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 2-way Vertical Joystick ****"))
                return
            elif fields['joystick'] == "4-way" and not self._config['JOYSTICK_4']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 4-way Joystick ****"))
                return
            elif fields['joystick'] == "8-way" and not self._config['JOYSTICK_8']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 8-way Joystick ****"))
                return

        # @TODO Activate PR #38
        if False and 'special_controls' in fields:
            if fields['special_controls'] == "trackball" and not self._config['TRACKBALL']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Trackball ****"))
                return
            elif fields['special_controls'] == "spinner" and not self._config['SPINNER']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Spinner ****"))
                return
            elif fields['special_controls'] == "twin stick" and not self._config['TWIN_STICK']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Twin Stick ****"))
                return
            elif fields['special_controls'] == "tank stick" and not self._config['TANK_STICK']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Tank Stick ****"))
                return
            elif fields['special_controls'] == "positional stick" and not self._config['POSITIONAL_STICK']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Positional Stick ****"))
                return
            elif fields['special_controls'] == "tilt stick" and not self._config['TILT_STICK']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping Tilt Stick ****"))
                return
        
        # @TODO Activate PR #38
        if False and 'num_buttons' in fields:
            if fields['num_buttons'] == "1" and not self._config['BUTTONS_1']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 1 Button ****"))
                return
            elif fields['num_buttons'] == "2" and not self._config['BUTTONS_2']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 2 Buttons ****"))
                return
            elif fields['num_buttons'] == "3" and not self._config['BUTTONS_3']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 3 Buttons ****"))
                return
            elif fields['num_buttons'] == "4" and not self._config['BUTTONS_4']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 4 Buttons ****"))
                return
            elif fields['num_buttons'] == "5" and not self._config['BUTTONS_5']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 5 Buttons ****"))
                return
            elif fields['num_buttons'] == "6" and not self._config['BUTTONS_6']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 6 Buttons ****"))
                return

        # @TODO Activate PR #38
        if False and 'year' in fields:
            if fields['year'] < "1980" and not self._config['1970S']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 1970s ****"))
                return
            elif fields['year'] < "1990" and not self._config['1980S']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 1980s ****"))
                return
            elif fields['year'] < "2000" and not self._config['1990S']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 1990s ****"))
                return
            elif fields['year'] < "2010" and not self._config['2000S']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 2000s ****"))
                return
            elif fields['year'] < "2020" and not self._config['2010S']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 2010s ****"))
                return
            elif fields['year'] < "2030" and not self._config['2020S']:
                self._printer.print("%s: %s" % (basename_mra, "**** Skipping 2020s ****"))
                return

        if 'rbf' not in fields:
            self._printer.print("%s is ill-formed, please delete and download it again." % mra)
            return

        fields['rbf'] = self.fix_core(fields['rbf'])

        basename_mra = mra_path.name

        self._printer.print('%-44s' % basename_mra[0:44], end='')
        self._printer.print(' %-10s' % fields['rbf'][0:10], end='')
        self._printer.print(' %-4s' % fields['year'][0:4], end='')
        self._printer.print(' %-10s' % fields['manufacturer'][0:10], end='')
        self._printer.print(' %-8s' % fields['category'].replace('/', '')[0:8], end='')
        self._printer.print()

        fields['rbf'] = self.better_core_name(fields['rbf'])

        #####Create symlinks for Region#####
        if fields['region'] != '':
            self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_7Region'], fields['region']))

        # @TODO Activate PR #38
        if False and self._config['REGION_DIR']:
            if 'region' in fields and fields['region'] != '':
                if fields['region'] == "US":
                    if self._config['VERBOSE']:
                        self._printer.print("**** US Region detected - please update MRA Region to USA ****")
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Region'], "USA"))
                else:    
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Region'], fields['region']))
                if self._config['REGION_SUB_DIR']:
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Core", fields['rbf']))
                    if fields['manufacturer'] != '':
                        self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Manufacturer", fields['manufacturer']))
                    if fields['manufacturer2'] != '':
                        self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Manufacturer", fields['manufacturer']))
                    if fields['manufacturer3'] != '':
                        self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Manufacturer", fields['manufacturer']))
                    if fields['platform'] != '':
                        self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Platform", fields['platform']))
                if self._config['CHRON_SUB_DIR']:
                    if fields['region'] == "US":
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Region'], "USA", "Chronological"))
                    else:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Chronological"))
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Core", fields['rbf'], "Chronological"))
                        if fields['manufacturer'] != '':
                            self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Manufacturer", fields['manufacturer'], "Chronological"))
                        if fields['manufacturer2'] != '':
                            self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Manufacturer", fields['manufacturer'], "Chronological"))
                        if fields['manufacturer3'] != '':
                            self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Manufacturer", fields['manufacturer'], "Chronological"))
                        if fields['platform'] != '':
                            self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/_%s/_%s/" % (self._config['ORGDIR_Region'], fields['region'], "Platform", fields['platform'], "Chronological"))
            elif self._config['VERBOSE']:
                self._printer.print("----%s: %s" % (basename_mra, "missing <region>"))

        if skipping_alt:
            return

        # @TODO Activate PR #38
        #####Create symlinks for A-Z######
        if True or self._config['AZ_DIR']:
            first_letter_char = ord(basename_mra.upper()[0])
            if between_chars(first_letter_char, '0', '9'):
                self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_109'])
            elif between_chars(first_letter_char, 'A', 'E'):
                self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1AE'])
            elif between_chars(first_letter_char, 'F', 'K'):
                self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1FK'])
            elif between_chars(first_letter_char, 'L', 'Q'):
                self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1LQ'])
            elif between_chars(first_letter_char, 'R', 'T'):
                self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1RT'])
            elif between_chars(first_letter_char, 'U', 'Z'):
                self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1UZ'])

        # @TODO Activate PR #38
        #####Create symlinks for Core#####
        if True or self._config['CORE_DIR']:
            if fields['rbf'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_2Core'], fields['rbf']))

                # @TODO Activate PR #38
                # Create chronological links inside core folder
                if False and self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Core'], fields['rbf'], "Chronological"))

        #####Create symlinks for Chronological#####
        if fields['year'] != '':
            self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_3Year'], fields['year']))

        # @TODO Activate PR #38
        if False and self._config['CHRON_DIR']:
            if fields['year'] != '':
                if fields['year'] < "1980":
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Chron'], "1970s"))
                    # Create chronological links inside decades folders
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Chron'], "1970s", "Chronological"))
                elif fields['year'] < "1990":
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Chron'], "1980s"))
                    # Create chronological links inside decades folders
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Chron'], "1980s", "Chronological"))
                elif fields['year'] < "2000":
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Chron'], "1990s"))
                    # Create chronological links inside decades folders
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Chron'], "1990s", "Chronological"))
                elif fields['year'] < "2010":
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Chron'], "2000s"))
                    # Create chronological links inside decades folders
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Chron'], "2000s", "Chronological"))
                elif fields['year'] < "2020":
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Chron'], "2010s"))
                    # Create chronological links inside decades folders
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Chron'], "2010s", "Chronological"))
                elif fields['year'] < "2030":
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Chron'], "2020s"))
                    # Create chronological links inside decades folders
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Chron'], "2020s", "Chronological"))
                # Create chronological links inside chronological folder
                self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/" % self._config['ORGDIR_Chron'])
            elif self._config['VERBOSE']:
                self._printer.print("----%s: %s" % (basename_mra, "missing <year>"))

        #####Create symlinks for Manufacturer#####
        if fields['manufacturer'] != '':
            self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_4Manufacturer'], fields['manufacturer']))

        # @TODO Activate PR #38
        if False and self._config['MANUFACTURER_DIR']:
            if fields['manufacturer'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Manufacturer'], fields['manufacturer']))
                # Create chronological links inside manufacturer
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Manufacturer'], fields['manufacturer'], "Chronological"))
            elif self._config['VERBOSE']:
                self._printer.print("%s: %s" % (basename_mra, "missing <manufacturer>"))
            if fields['manufacturer2'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Manufacturer'], fields['manufacturer2']))
                # Create chronological links inside manufacturer
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Manufacturer'], fields['manufacturer2'], "Chronological"))
            if fields['manufacturer3'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Manufacturer'], fields['manufacturer3']))
                # Create chronological links inside manufacturer
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Manufacturer'], fields['manufacturer3'], "Chronological"))
            

        #####Create symlinks for Category#####
        if fields['category'] != '':
            self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_5Category'], fields['category']))

        # @TODO Activate PR #38
        if False and self._config['CATEGORY_DIR']:
            if fields['category'] != '':
                if fields['category'] not in category_list and self._config['VERBOSE']:
                    self._printer.print("----%s: %s" % (basename_mra, "non-standard <category>"))
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Category'], fields['category']))
                # Create chronological links inside category
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Category'], fields['category'], "Chronological"))
            elif self._config['VERBOSE']:
                self._printer.print("----%s: %s" % (basename_mra, "missing <category>"))

        #####Create symlinks for Rotation#####
        if fields['setname'] != '' and self._config['CACHED_DATA_ZIP'].is_file():
            rotation = self.search_rotation(fields['setname'])
            if rotation != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_6Rotation'], rotation))

        # @TODO Activate PR #38
        #####Create symlinks for Rotation (MRA)#####
        if False and self._config['ROTATION_DIR']:
            if 'rotation' in fields:
                if fields['rotation'] == 'horizontal':
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Rotation'], "Horizontal"))
                    # Create chronological links inside rotation folder
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Rotation'], fields['rotation'], "Chronological"))
                elif fields['rotation'] == 'vertical (cw)' and fields['flip'] == 'no':
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Rotation'], "Vertical (CW)"))
                    # Create chronological links inside rotation folder
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Rotation'], fields['rotation'], "Chronological"))
                elif fields['rotation'] == 'vertical (ccw)' and fields['flip'] == 'no':
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Rotation'], "Vertical (CCW)"))
                    # Create chronological links inside rotation folder
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Rotation'], fields['rotation'], "Chronological"))
                elif fields['rotation'] == ('vertical (cw)' or 'vertical (ccw)') and fields['flip'] == 'yes':
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Rotation'], "Vertical (Either)"))
                    # Create chronological links inside rotation folder
                    if self._config['CHRON_SUB_DIR']:
                        self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Rotation'], "vertical (either)", "Chronological"))
            elif fields['setname'] != '' and self._config['CACHED_DATA_ZIP'].is_file():
                self._printer.print("%s: %s" % (basename_mra, "missing <rotation>"))
                rotation = self.search_rotation(fields['setname'])
                if rotation != '':
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Rotation'], rotation))

        #####Create symlinks for Resolution#####
        if self._config['RESOLUTION_DIR']:
            if 'resolution' in fields and fields['resolution'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Resolution'], fields['resolution']))
                # Create chronological links inside resolution folder
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Resolution'], fields['resolution'], "Chronological"))
            elif self._config['VERBOSE']:
                self._printer.print("----%s: %s" % (basename_mra, "missing <resolution>"))

        #####Create symlinks for Series #####
        if self._config['SERIES_DIR']:
            if 'series' in fields and fields['series'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Series'], fields['series']))
                # Create chronological links inside series folder
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Series'], fields['series'], "Chronological"))

        #####Create symlinks for Platform #####
        if self._config['PLATFORM_DIR']:
            if 'platform' in fields and fields['platform'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Platform'], fields['platform']))
                # Create chronological links inside platform folder
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Platform'], fields['platform'], "Chronological"))

        #####Create symlinks for Flip #####
        if self._config['FLIP_DIR']:
            if 'flip' in fields and fields['flip'] != '':
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Flip'], fields['flip']))

        #####Create symlinks for Players #####
        if self._config['PLAYERS_DIR']:
            if 'players' in fields and fields['players'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Players'], fields['players']))
                # Create chronological links inside players folder
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Players'], fields['players'], "Chronological"))
            elif self._config['VERBOSE']:
                self._printer.print("----%s: %s" % (basename_mra, "missing <players>"))

        #####Create symlinks for Joystick #####
        if self._config['JOYSTICK_DIR']:
            if 'joystick' in fields and fields['joystick'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_Joystick'], fields['joystick']))
                # Create chronological links inside joystick folder
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_Joystick'], fields['joystick'], "Chronological"))
            elif self._config['VERBOSE']:
                self._printer.print("----%s: %s" % (basename_mra, "missing <joystick>"))

        #####Create symlinks for Buttons #####
        if self._config['BUTTONS_DIR']:
            if 'num_buttons' in fields and fields['num_buttons'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_NumButtons'], fields['num_buttons']))
                # Create chronological links inside buttons folder
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_NumButtons'], fields['num_buttons'], "Chronological"))      
            elif self._config['VERBOSE']:
                ####self._printer.print(fields['buttons'])
                self._printer.print("----%s: %s" % (basename_mra, "missing <buttons>"))

        #####Create symlinks for Special Controls #####
        if self._config['SPECIAL_CONTROLS_DIR']:
            if 'special_controls' in fields and fields['special_controls'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_SpecialControls'], fields['special_controls']))
                # Create chronological links inside controls folder
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_SpecialControls'], fields['special_controls'], "Chronological"))
            if 'special_controls_2' in fields and fields['special_controls_2'] != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_SpecialControls'], fields['special_controls_2']))
                # Create chronological links inside controls folder
                if self._config['CHRON_SUB_DIR']:
                    self._infra.make_symlink(mra_path, "%s-%s" % (fields['year'], basename_mra), "%s/_%s/_%s/" % (self._config['ORGDIR_SpecialControls'], fields['special_controls_2'], "Chronological"))

        #####Create symlinks for Bootleg #####
        if self._config['BOOTLEG_DIR']:
            if 'bootleg' in fields and fields['bootleg'] == 'yes':
                self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_Bootleg'])

        #####Create symlinks for Homebrew #####
        if self._config['HOMEBREW_DIR']:
            if 'homebrew' in fields and fields['homebrew'] == 'yes':
                self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_Homebrew'])

    def fix_core(self, core_name):
        if core_name == "":
            return ""
        return self._cores_dict.get(core_name.upper().strip(".RBF"), core_name)

    def better_core_name(self, core_name):
        if core_name == "":
            return ""

        upper_core = core_name.upper()
        if upper_core in self._names_txt_dict:
            return self._names_txt_dict[upper_core]

        return core_name

    def search_rotation(self, setname):
        mame_rotation = self.rotations_dict.get(setname, {}).get('rot')
        return self._config['ROTATION_DIRECTORIES'].get(mame_rotation, '')

    def calculate_ini_options(self):
        return {
            'MRADIR' : self._config['MRADIR'],
            'ORGDIR' : self._config['ORGDIR'],
            'SKIPALTS' : "true" if self._config['SKIPALTS'] else "false",
            'INSTALL' : "true" if self._config['INSTALL'] else "false",
        }

        # @TODO Activate PR #38
        return {
            'MRADIR' : self._config['MRADIR'],
            'ORGDIR' : self._config['ORGDIR'],
            'SKIPALTS' : "true" if self._config['SKIPALTS'] else "false",
            'INSTALL' : "true" if self._config['INSTALL'] else "false",
            'AZ_DIR' : "true" if self._config['AZ_DIR'] else "false",
            'ALTERNATIVE' : "true" if self._config['ALTERNATIVE'] else "false",
            'CHRON_DIR' : "true" if self._config['CHRON_DIR'] else "false",
            'CHRON_SUB_DIR' : "true" if self._config['CHRON_SUB_DIR'] else "false",
            'PLAYERS_1' : "true" if self._config['PLAYERS_1'] else "false",
            'PLAYERS_2_ALT' : "true" if self._config['PLAYERS_2_ALT'] else "false",
            'PLAYERS_2_SIM' : "true" if self._config['PLAYERS_2_SIM'] else "false",
            'PLAYERS_3' : "true" if self._config['PLAYERS_3'] else "false",
            'PLAYERS_4' : "true" if self._config['PLAYERS_4'] else "false",
            'PLAYERS_5' : "true" if self._config['PLAYERS_5'] else "false",
            'PLAYERS_6' : "true" if self._config['PLAYERS_6'] else "false",
            'BUTTONS_1' : "true" if self._config['BUTTONS_1'] else "false",
            'BUTTONS_2' : "true" if self._config['BUTTONS_2'] else "false",
            'BUTTONS_3' : "true" if self._config['BUTTONS_3'] else "false",
            'BUTTONS_4' : "true" if self._config['BUTTONS_4'] else "false",
            'BUTTONS_5' : "true" if self._config['BUTTONS_5'] else "false",
            'BUTTONS_6' : "true" if self._config['BUTTONS_6'] else "false",
            'BUTTONS_DIR' : "true" if self._config['BUTTONS_DIR'] else "false",
            'JOYSTICK_2H' : "true" if self._config['JOYSTICK_2H'] else "false",
            'JOYSTICK_2V' : "true" if self._config['JOYSTICK_2V'] else "false",
            'JOYSTICK_4' : "true" if self._config['JOYSTICK_4'] else "false",
            'JOYSTICK_8' : "true" if self._config['JOYSTICK_8'] else "false",
            'SPINNER' : "true" if self._config['SPINNER'] else "false",
            'TRACKBALL' : "true" if self._config['TRACKBALL'] else "false",
            'POSITIONAL_STICK' : "true" if self._config['POSITIONAL_STICK'] else "false",
            'TILT_STICK' : "true" if self._config['TILT_STICK'] else "false",
            'TWIN_STICK' : "true" if self._config['TWIN_STICK'] else "false",
            'TANK_STICK' : "true" if self._config['TANK_STICK'] else "false",
            'JOYSTICK_DIR' : "true" if self._config['JOYSTICK_DIR'] else "false",
            'RESOLUTION_DIR' : "true" if self._config['ROTATION_DIR'] else "false",
            'RESOLUTION_15KHZ' : "true" if self._config['RESOLUTION_15KHZ'] else "false",
            'RESOLUTION_24KHZ' : "true" if self._config['RESOLUTION_24KHZ'] else "false",
            'RESOLUTION_31KHZ' : "true" if self._config['RESOLUTION_31KHZ'] else "false",
            'ROTATION_DIR' : "true" if self._config['ROTATION_DIR'] else "false",
            'ROTATION_0' : "true" if self._config['ROTATION_0'] else "false",
            'ROTATION_90' : "true" if self._config['ROTATION_90'] else "false",
            'ROTATION_180' : "true" if self._config['ROTATION_180'] else "false",
            'ROTATION_270' : "true" if self._config['ROTATION_270'] else "false",
            'SERIES_DIR' : "true" if self._config['SERIES_DIR'] else "false",
            'FLIP_DIR' : "true" if self._config['FLIP_DIR'] else "false",
            'SPECIAL_CONTROLS_DIR' : "true" if self._config['SPECIAL_CONTROLS_DIR'] else "false",
            'REGION_DIR' : "true" if self._config['REGION_DIR'] else "false",
            'REGION_SUB_DIR' : "true" if self._config['REGION_SUB_DIR'] else "false",
            'REGION_USA' : "true" if self._config['REGION_USA'] else "false",
            'REGION_JAPAN' : "true" if self._config['REGION_JAPAN'] else "false",
            'REGION_EUROPE' : "true" if self._config['REGION_EUROPE'] else "false",
            'REGION_WORLD' : "true" if self._config['REGION_WORLD'] else "false",
            'REGION_ASIA' : "true" if self._config['REGION_ASIA'] else "false",
            'REGION_BRAZIL' : "true" if self._config['REGION_BRAZIL'] else "false",
            'BOOTLEG' : "true" if self._config['BOOTLEG'] else "false",
            'BOOTLEG_DIR' : "true" if self._config['BOOTLEG_DIR'] else "false",
            'HOMEBREW' : "true" if self._config['HOMEBREW'] else "false",
            'HOMEBREW_DIR' : "true" if self._config['HOMEBREW_DIR'] else "false",
            '1970S' : "true" if self._config['1970S'] else "false",
            '1980S' : "true" if self._config['1980S'] else "false",
            '1990S' : "true" if self._config['1990S'] else "false",
            '2000S' : "true" if self._config['2000S'] else "false",
            '2010S' : "true" if self._config['2010S'] else "false",
            '2020S' : "true" if self._config['2020S'] else "false",
            'CATEGORY_ACTION' : "true" if self._config['CATEGORY_ACTION'] else "false",
            'CATEGORY_ARENA' : "true" if self._config['CATEGORY_ARENA'] else "false",
            'CATEGORY_BALL_PADDLE' : "true" if self._config['CATEGORY_BALL_PADDLE'] else "false",
            'CATEGORY_BEAT_EM_UP' : "true" if self._config['CATEGORY_BEAT_EM_UP'] else "false",
            'CATEGORY_FIGHTING' : "true" if self._config['CATEGORY_FIGHTING'] else "false",
            'CATEGORY_GAMBLING' : "true" if self._config['CATEGORY_GAMBLING'] else "false",
            'CATEGORY_GRID_MAZE' : "true" if self._config['CATEGORY_GRID_MAZE'] else "false",
            'CATEGORY_LANDER' : "true" if self._config['CATEGORY_LANDER'] else "false",
            'CATEGORY_MAHJONG' : "true" if self._config['CATEGORY_MAHJONG'] else "false",
            'CATEGORY_MIXED' : "true" if self._config['CATEGORY_MIXED'] else "false",
            'CATEGORY_PLATFORM' : "true" if self._config['CATEGORY_PLATFORM'] else "false",
            'CATEGORY_PUZZLE' : "true" if self._config['CATEGORY_PUZZLE'] else "false",
            'CATEGORY_PUZZLE_PLATFORM' : "true" if self._config['CATEGORY_PUZZLE_PLATFORM'] else "false",
            'CATEGORY_QUIZ' : "true" if self._config['CATEGORY_QUIZ'] else "false",
            'CATEGORY_RUN_N_GUN_HOR' : "true" if self._config['CATEGORY_RUN_N_GUN_HOR'] else "false",
            'CATEGORY_RUN_N_GUN_VER' : "true" if self._config['CATEGORY_RUN_N_GUN_VER'] else "false",
            'CATEGORY_SHOOTER_GALLERY' : "true" if self._config['CATEGORY_SHOOTER_GALLERY'] else "false",
            'CATEGORY_SHOOTER_HOR' : "true" if self._config['CATEGORY_SHOOTER_ISO'] else "false",
            'CATEGORY_SHOOTER_ISO' : "true" if self._config['CATEGORY_SHOOTER_MULTI'] else "false",
            'CATEGORY_SHOOTER_MULTI' : "true" if self._config['CATEGORY_SHOOTER_TUBE'] else "false",
            'CATEGORY_SHOOTER_VER' : "true" if self._config['CATEGORY_SHOOTER_VER'] else "false",
            'CATEGORY_SPORTS' : "true" if self._config['CATEGORY_SPORTS'] else "true"
        }

    def calculate_orgdir_folders(self):
        dir_set=set()
        for directory in self._config['ORGDIR_DIRECTORIES']:
            if Path(directory).is_dir():
                dir_set.add(directory)

        for directory in self._infra.read_orgdir_file_folders():
            dir_set.add(directory)

        return sorted(dir_set)

    @property
    def rotations_dict(self):
        if self._cached_rotations is None:
            self._cached_rotations = self._infra.read_rotations()
        return self._cached_rotations

    def organize_all_mras(self):
        self._infra.make_directory(Path(self._config['ARCADE_ORGANIZER_WORK_PATH']))

        ini_date = self._infra.get_ini_date()

        self._printer.print()
        self._printer.print('Arguments:')
        for key, value in sorted(self.calculate_ini_options().items()):
            self._printer.print("%s=%s" % (key, value))
        self._printer.print()

        self._infra.install_standalone_script_if_needed()

        self._infra.remove_any_previous_rotation_files_in_tmp()

        tmp_data_file = self._infra.download_data_zip()

        last_ini_date, last_mra_date = self._infra.read_last_run_file()

        from_scatch = False

        if self._infra.check_if_orgdir_directories_are_missing():
            from_scatch = True
            self._printer.print("Some ORGDIR directories are missing.")
            self._printer.print()

        if not self._infra.text_is_date(last_mra_date):
            from_scatch = True
            self._printer.print("Last run file not found.")
            self._printer.print()

        if self._infra.check_if_names_txt_is_new():
            from_scatch = True
            self._printer.print("The installed names.txt is new.")
            self._printer.print()

        if ini_date != last_ini_date:
            from_scatch = True
            if last_ini_date != '':
                self._printer.print("INI file has been modified.")
                self._printer.print()

        if tmp_data_file is not None:
            cached_data_file = self._infra.get_cached_data_zip()
            if self._infra.are_files_different(tmp_data_file, cached_data_file):
                self._infra.copy_file(tmp_data_file, cached_data_file)
                from_scatch = True
                self._printer.print("The rotations data.zip is new.")
                self._printer.print()
            self._infra.remove_file(tmp_data_file)

        for directory in self._config['ORGDIR_DIRECTORIES']:
            self._mra_finder.not_in_directory(directory)

        if not from_scatch:
            self._mra_finder.newer_than(last_mra_date)

        orgdir_folders_file = self._config['ORGDIR_FOLDERS_FILE']
        mra_date = self._infra.get_now_date()
        if from_scatch:
            self._printer.print("Performing a full build.")
            self._infra.remove_orgdir_directories(orgdir_folders_file)
        else:
            self._printer.print("Performing an incremental build.")
            self._printer.print("NOTE: Remove the Organized folders if you wish to start from scratch.")
            self._infra.remove_all_broken_symlinks()

        self._printer.print()

        updated_mras = self._mra_finder.find_all_mras()

        if len(updated_mras) == 0:
            self._printer.print("No new MRAs detected")
            self._printer.print()
            self._printer.print("Skipping Arcade Organizer...")
            self._printer.print()
            return

        self._printer.print("Organizing %s MRAs." % len(updated_mras))
        self._printer.print()
        self._printer.print('%-44s' % "MRA", end='')
        self._printer.print(' %-10s' % "Core", end='')
        self._printer.print(' %-4s' % "Year", end='')
        self._printer.print(' %-10s' % "Manufactu.", end='')
        self._printer.print(' %-8s' % "Category", end='')
        self._printer.print()
        self._printer.print("################################################################################")

        for mra in updated_mras:
            self.organize_single_mra(mra)

        self._infra.write_orgdir_folders_file()

        self._infra.handle_orgdir_outside_mra_folder()

        self._infra.write_last_run_file(ini_date, mra_date)
        
        self._infra.cache_names_file()

        self._printer.print("################################################################################")

def run():
    config = make_config()
    with Printer(config) as printer:
        infra = Infrastructure(config, printer)
        mra_finder = MraFinderNew(config, infra)
        ao = ArcadeOrganizer(config, infra, mra_finder, printer)

        if len(sys.argv) == 2 and sys.argv[1] == "--print-orgdir-folders":
            for directory in ao.calculate_orgdir_folders():
                printer.print(directory)

        elif len(sys.argv) == 2 and sys.argv[1] == "--print-ini-options":
            for key, value in sorted(ao.calculate_ini_options().items()):
                printer.print("%s=%s" % (key, value))

        elif len(sys.argv) != 1:
            printer.print("Invalid arguments.")
            printer.print("Usage: %s --print-orgdir-folders" % sys.argv[0])
            printer.print("       %s --print-ini-options" % sys.argv[0])
            printer.print("       %s" % sys.argv[0])
            exit(1)

        else:
            ao.organize_all_mras()


if __name__ == '__main__':
    run()
