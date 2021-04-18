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

    inifile = Path(original_script_path).with_suffix('.ini').absolute()
    ini_parser = configparser.ConfigParser()
    config["ini_file_path"] = Path(inifile)
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

    return config

def lineno():
    return getframeinfo(currentframe().f_back).lineno

class Printer:
    def __init__(self, config):
        self._config = config

    def __enter__(self):
        self._logfile = open(self._config['ARCADE_ORGANIZER_WORK_PATH'] + "/issues.log", "w")
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self._logfile.close()

    def print(self, *args, sep='', end='\n', file=sys.stdout, flush=False):
        print(*args, sep=sep, end=end, file=file, flush=flush)

    def log(self, *args, sep='', end='\n', flush=False):
        print(*args, sep=sep, end=end, file=self._logfile, flush=flush)

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
        orgdir_folders_file = Path(self._config['ORGDIR_FOLDERS_FILE'])
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
        return not Path(self._config['ORGDIR_1AE']).is_dir() or \
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
            'category',
            'region'
        ])

        skipping_alt = self._config['SKIPALTS'] and is_alternative(mra_path)

        if skipping_alt and fields['region'] == '':
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

        if skipping_alt:
            return

        #####Create symlinks for A-Z######
        first_letter_char = ord(basename_mra.upper()[0])
        if between_chars(first_letter_char, '0', '9') or between_chars(first_letter_char, 'A', 'E'):
            self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1AE'])
        elif between_chars(first_letter_char, 'F', 'K'):
            self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1FK'])
        elif between_chars(first_letter_char, 'L', 'Q'):
            self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1LQ'])
        elif between_chars(first_letter_char, 'R', 'T'):
            self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1RT'])
        elif between_chars(first_letter_char, 'U', 'Z'):
            self._infra.make_symlink(mra_path, basename_mra, self._config['ORGDIR_1UZ'])

        #####Create symlinks for Core#####
        if fields['rbf'] != '':
            self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_2Core'], fields['rbf']))

        #####Create symlinks for Year#####
        if fields['year'] != '':
            self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_3Year'], fields['year']))

        #####Create symlinks for Manufacturer#####
        if fields['manufacturer'] != '':
            self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_4Manufacturer'], fields['manufacturer']))

        #####Create symlinks for Category#####
        if fields['category'] != '':
            self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_5Category'], fields['category']))

        #####Create symlinks for Rotation#####
        if fields['setname'] != '' and self._config['CACHED_DATA_ZIP'].is_file():
            rotation = self.search_rotation(fields['setname'])
            if rotation != '':
                self._infra.make_symlink(mra_path, basename_mra, "%s/_%s/" % (self._config['ORGDIR_6Rotation'], rotation))

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

    def calculate_orgdir_folders(self):
        dir_set=set()
        for directory in ORGDIR_DIRECTORIES:
            if Path(directory).is_dir():
                dir_set.add(directory)
        
        for directory in self.read_orgdir_file_folders():
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