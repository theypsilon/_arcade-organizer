#!/bin/bash
#USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY NEUTER EVERYTHING.
#A /media/fat/Scripts/update_arcade-organizer.ini file may be used to set custom location for your MRA files (Scans recursivly) and Organized files.
#Add the following line to the ini file to set a directory for MRA files: MRADIR=/top/path/to/mra/files
#Add the following line to the ini file to set a directory for Organized files: ORGDIR=/path/to/_Organized 
###############################################################################
#set -x
set -euo pipefail
######VARS#####

INIFILE="$(pwd)/update_arcade-organizer.ini"
MRADIR="/media/fat/_Arcade/"
ORGDIR="/media/fat/_Arcade/_Organized"
SKIPALTS="true"
INSTALL="false"
#####INI FILES VARS######

INIFILE_FIXED=$(mktemp)
if [ -f "${INIFILE}" ] ; then
	dos2unix < "${INIFILE}" 2> /dev/null > ${INIFILE_FIXED} || true
fi

if [ `grep -c "ORGDIR=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      ORGDIR=`grep "ORGDIR" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^ *"//' -e 's/" *$//'`
fi 2>/dev/null


if [ `grep -c "MRADIR=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      MRADIR=`grep "MRADIR=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^ *"//' -e 's/" *$//'`
fi 2>/dev/null

 
if [ `grep -c "SKIPALTS=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      SKIPALTS=`grep "SKIPALTS=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^ *"//' -e 's/" *$//'`
fi 2>/dev/null

if [ `grep -c "INSTALL=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      INSTALL=`grep "INSTALL=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^ *"//' -e 's/" *$//'`
fi 2>/dev/null
 
rm ${INIFILE_FIXED}

###############################
ARCADE_ORGANIZER_VERSION="1.0"
WORK_PATH="/media/fat/Scripts/.cache/arcade-organizer"
ORGDIR_FOLDERS_FILE="${WORK_PATH}/orgdir-folders"
SSL_SECURITY_OPTION="${SSL_SECURITY_OPTION:---insecure}"
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5 --show-error"
TMP_ROTATIONS="/tmp/mame-rotations.txt"
#########Auto Install##########
if [[ "${INSTALL^^}" == "TRUE" ]] && [ ! -e "/media/fat/Scripts/update_arcade-organizer.sh" ]
   then
      echo "Downloading update_arcade-organizer.sh to /media/fat/Scripts"
      echo ""
      curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location -o "/media/fat/Scripts/update_arcade-organizer.sh" https://raw.githubusercontent.com/MAME-GETTER/_arcade-organizer/master/update_arcade-organizer.sh || true
      echo
fi

# check for any previous rotation files in tmp folder
if [ -e "${TMP_ROTATIONS}" ] ; then
   rm "${TMP_ROTATIONS}"
fi
echo "Downloading ${TMP_ROTATIONS}"
echo ""
set +e
curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --fail --location -o "${TMP_ROTATIONS}" "https://raw.githubusercontent.com/MAME-GETTER/_arcade-organizer/master/rotations/mame-rotations.txt"
RET_CURL=$?
set -e
if [ ${RET_CURL} -ne 0 ] ; then
   echo "Couldn't download ${TMP_ROTATIONS} : Network Problem"
   # allow rest script to carry on
   # and use non-existence of mame-rotations.txt to prevent rotation subfolder creation
fi

#####Organized Directories#####
ORGDIR_1AE="$ORGDIR/_1 A-E"
ORGDIR_1FK="$ORGDIR/_1 F-K"
ORGDIR_1LQ="$ORGDIR/_1 L-Q"
ORGDIR_1RT="$ORGDIR/_1 R-T"
ORGDIR_1UZ="$ORGDIR/_1 U-Z"
ORGDIR_2Core="${ORGDIR}/_2 Core"
ORGDIR_3Year="${ORGDIR}/_3 Year"
ORGDIR_4Manufacturer="${ORGDIR}/_4 Manufacturer"
ORGDIR_5Category="${ORGDIR}/_5 Category"
ORGDIR_6Rotation="${ORGDIR}/_6 Rotation"

ORGDIR_DIRECTORIES=( \
   "${ORGDIR_1AE}" \
   "${ORGDIR_1FK}" \
   "${ORGDIR_1LQ}" \
   "${ORGDIR_1RT}" \
   "${ORGDIR_1UZ}" \
   "${ORGDIR_2Core}" \
   "${ORGDIR_3Year}" \
   "${ORGDIR_4Manufacturer}" \
   "${ORGDIR_5Category}" \
   "${ORGDIR_6Rotation}" \
)
create_organized_directories() {
   for dir in "${ORGDIR_DIRECTORIES[@]}" ; do
      mkdir -p "${dir}"
   done
}
#####Build names.txt Dictionary#####

declare -A NAMES_TXT
if [ -f /media/fat/names.txt ]
   then
      IFS=$'\n'
      for LINE in $(grep ':' /media/fat/names.txt)
      do
         if [[ $LINE =~ ^[[:space:]]*([a-zA-Z0-9\_-]+)[[:space:]]*:[[:space:]]*([[:graph:]]+([[:space:]]+[[:graph:]]+)*)[[:space:]]*$ ]]
            then
               NAMES_TXT[${BASH_REMATCH[1]^^}]="${BASH_REMATCH[2]}"
         fi
      done
      unset IFS
fi

BETTER_CORE_NAME_RET=
better_core_name() {
   BETTER_CORE_NAME_RET="${1}"
   if [[ "${BETTER_CORE_NAME_RET}" == "" ]] ; then
      return
   fi
   local CORE_NAME="${NAMES_TXT[${BETTER_CORE_NAME_RET^^}]:-}"
   if [[ "${CORE_NAME}" != "" ]]
      then
         BETTER_CORE_NAME_RET="${CORE_NAME}"
   fi
}

#####Core name fix optimized#####

declare -A CORE_NAMES_CACHE
FIX_CORE_RET=
fix_core() {
   FIX_CORE_RET="${1}"
   local CORE_CACHE_KEY="${FIX_CORE_RET^^}"
   if [[ "${CORE_CACHE_KEY}" == "" ]] ; then
      return
   fi
   local CORE_CACHE_VALUE="${CORE_NAMES_CACHE[${CORE_CACHE_KEY}]:-}"
   if [[ "${CORE_CACHE_VALUE}" != "" ]] ; then
      FIX_CORE_RET="${CORE_CACHE_VALUE}"
   elif [[ "${CORE_CACHE_VALUE}" != "#" ]] ; then
      local CORE_FIND=
      local CORE_FIND=$(find ${MRADIR}/cores/ -type f -iname ${FIX_CORE_RET}_*.rbf | xargs basename -- 2> /dev/null)
      if [[ "${CORE_FIND}" != "" ]] && [ ${#CORE_FIND} -ge 14 ]
         then
            FIX_CORE_RET="$(echo $CORE_FIND | sed 's/_\([0-9]\{8\}[a-z]\?\).rbf$//g')"
            CORE_NAMES_CACHE[${CORE_CACHE_KEY}]="${FIX_CORE_RET}"
      else
         CORE_NAMES_CACHE[${CORE_CACHE_KEY}]="#"
      fi
   fi
}

#####Extract MRA Info######

header() {
   printf '%-44s' "MRA"
   printf ' %-10s' "Core"
   printf ' %-4s' "Year"
   printf ' %-10s' "Manufactu."
   printf ' %-8s' "Category"
   echo
   echo "################################################################################"
}

organize_mra() {
   local MRA="${1}"

   set +e
   local MRB="`echo $MRA | sed 's/.*\///'`"
   local NAME=`grep "<name>" "$MRA" | sed -ne '/name/{s/.*<name>\(.*\)<\/name>.*/\1/p;q;}'`
   local SETNAME=`grep "<setname>" "$MRA" | sed -ne '/setname/{s/.*<setname>\(.*\)<\/setname>.*/\1/p;q;}'`
   local CORE=`grep "<rbf" "$MRA" | sed 's/ alt=.*"//' | sed -ne '/rbf/{s/.*<rbf>\(.*\)<\/rbf>.*/\1/p;q;}'`
   local YEAR=`grep "<year>" "$MRA" | sed -ne '/year/{s/.*<year>\(.*\)<\/year>.*/\1/p;q;}'`
   local MANU=`grep "<manufacturer>" "$MRA" | sed -ne '/manufacturer/{s/.*<manufacturer>\(.*\)<\/manufacturer>.*/\1/p;q;}'`
   local CAT=`grep "<category>" "$MRA" | sed -ne '/category/{s/.*<category>\(.*\)<\/category>.*/\1/p;q;}' | tr -d '[:punct:]'`
   set -e

   if [[ "${CORE}" == "" ]] ; then
      echo "${MRA} is ill-formed, please delete and download it again."
      return
   fi

   if fix_core "${CORE}" ; then
      CORE="${FIX_CORE_RET}"
   fi

   local BASENAME_MRA="`basename "$MRA"`"
   printf '%-44s' "${BASENAME_MRA:0:44}"
   printf ' %-10s' "${CORE:0:10}"
   printf ' %-4s' "${YEAR:0:4}"
   printf ' %-10s' "${MANU:0:10}"
   printf ' %-8s' "${CAT:0:8}"
   echo

   if better_core_name "${CORE}" ; then
      CORE="${BETTER_CORE_NAME_RET}"
   fi

   #####Create symlinks for A-Z######

   if [[ "${BASENAME_MRA}" == [A-Ea-e0-9]* ]]
      then
         cd "${ORGDIR_1AE}"
         [ -e ./"$MRB" ] || ln -sv "$MRA" "${BASENAME_MRA}" >/dev/null 2>&1 || true

   elif [[ "${BASENAME_MRA}" == [F-Kf-k]* ]]
      then
         cd "${ORGDIR_1FK}"
         [ -e ./"$MRB" ] || ln -sv "$MRA" "${BASENAME_MRA}" >/dev/null 2>&1 || true

   elif [[ "${BASENAME_MRA}" == [L-Ql-q]* ]]
      then
         cd "${ORGDIR_1LQ}"
         [ -e ./"$MRB" ] || ln -sv "$MRA" "${BASENAME_MRA}" >/dev/null 2>&1 || true

   elif [[ "${BASENAME_MRA}" == [R-Tr-t]* ]]
      then
         cd "${ORGDIR_1RT}"
         [ -e ./"$MRB" ] || ln -sv "$MRA" "${BASENAME_MRA}" >/dev/null 2>&1 || true

   elif [[ "${BASENAME_MRA}" == [U-Zu-z]* ]]
      then
         cd "${ORGDIR_1UZ}"
         [ -e ./"$MRB" ] || ln -sv "$MRA" "${BASENAME_MRA}" >/dev/null 2>&1 || true
   fi


   #####Create symlinks for Core#####

   if [ ! -z "$CORE" ] && [ ! -e "${ORGDIR_2Core}/_$CORE/$MRB" ]
      then
         mkdir -p "${ORGDIR_2Core}/_${CORE//\?/X}"
         cd "${ORGDIR_2Core}/_${CORE//\?/X}"
         ln -v -s "$MRA" "$MRB" >/dev/null 2>&1 || true
   fi

   #####Create symlinks for Year#####

   if [ ! -z "$YEAR" ] && [ ! -e "${ORGDIR_3Year}/_$YEAR/$MRB" ]
      then
         mkdir -p "${ORGDIR_3Year}/_${YEAR//\?/X}"
         cd "${ORGDIR_3Year}/_${YEAR//\?/X}"
         ln -v -s "$MRA" "$MRB" >/dev/null 2>&1 || true
   fi

   #####Create symlinks for Manufacturer#####

   if [ ! -z "$MANU" ] && [ ! -e "${ORGDIR_4Manufacturer}/_$MANU/$MRB" ]
      then
         mkdir -p "${ORGDIR_4Manufacturer}/_${MANU//\?/X}"
         cd "${ORGDIR_4Manufacturer}/_${MANU//\?/X}"
         ln -v -s "$MRA" "$MRB" >/dev/null 2>&1 || true
   fi

   #####Create symlinks for Category#####

   if [ ! -z "$CAT" ] && [ ! -e "${ORGDIR_5Category}/_$CAT/$MRB" ]
      then
         mkdir -p "${ORGDIR_5Category}/_${CAT//\?/X}"
         cd "${ORGDIR_5Category}/_${CAT//\?/X}"
         ln -v -s "$MRA" "$MRB" >/dev/null 2>&1 || true
   fi

   #####Create symlinks for Rotation#####
   if [ ! -z "$SETNAME" ] && [ -e "${WORK_PATH}/mame-rotations.txt" ]
      then
         local ROTVAL=`grep "^${SETNAME}," ${WORK_PATH}/mame-rotations.txt |grep -o ROT[0-9]*`
         case "$ROTVAL" in
            ROT0)
               ROTDESC="Horizontal_ROT0"
               ;;
            ROT90)
               ROTDESC="Vertical-With-Left-Side-At-Top_ROT90"
               ;;
            ROT180)
               ROTDESC="Horizontal-Upside-Down_ROT180"
               ;;
            ROT270)
               ROTDESC="Vertical-With-Right-Side-At-Top_ROT270"
               ;;
            *)
               ROTDESC="Unknown-Rotation"
               ;;
         esac
         if [ ! -z "$ROTDESC" ] && [ ! -e "${ORGDIR_6Rotation}/_$ROTDESC/$MRB" ]
            then
               mkdir -p "${ORGDIR_6Rotation}/_${ROTDESC//\?/X}"
               cd "${ORGDIR_6Rotation}/_${ROTDESC//\?/X}"
               ln -v -s "$MRA" "$MRB" >/dev/null 2>&1 || true
         fi
   fi
}

optimized_arcade_organizer() {
   mkdir -p "${WORK_PATH}"

   echo
   echo "Reading INI ($(basename ${INIFILE})):"
   local INI_DATE=
   if [ -f "${INIFILE}" ] ; then
      INI_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ" -d "$(stat -c %y "${INIFILE}" 2> /dev/null)")
      echo "OK"
   else
      echo "Not found."
   fi
   echo

   local LAST_RUN_PATH="${WORK_PATH}/last_run"

   local LAST_INI_DATE=
   local LAST_MRA_DATE=
   if [ -f "${LAST_RUN_PATH}" ] ; then
      LAST_INI_DATE=$(cat "${LAST_RUN_PATH}" | sed '2q;d')
      LAST_MRA_DATE=$(cat "${LAST_RUN_PATH}" | sed '3q;d')
   fi

   local FROM_SCRATCH="false"
   if [ ! -d "${ORGDIR_1AE}/" ] || \
      [ ! -d "${ORGDIR_1FK}/" ] || \
      [ ! -d "${ORGDIR_1LQ}/" ] || \
      [ ! -d "${ORGDIR_1RT}/" ] || \
      [ ! -d "${ORGDIR_1UZ}/" ] || \
      [[ "${LAST_MRA_DATE}" =~ ^[[:space:]]*$ ]] || \
      ! date -d "${LAST_MRA_DATE}" > /dev/null 2>&1
   then
      FROM_SCRATCH="true"
      echo "No previous runs detected."
      echo
   fi

   local CACHED_NAMES="${WORK_PATH}/installed_names.txt"
   local REAL_NAMES="/media/fat/names.txt"
   if [ -f "${REAL_NAMES}" ] && ! diff "${REAL_NAMES}" "${CACHED_NAMES}" > /dev/null 2>&1 ; then
      FROM_SCRATCH="true"
      echo "The installed names.txt is new for the Arcade Organizer."
      echo
   fi

   if [[ "${INI_DATE}" != "${LAST_INI_DATE}" ]] ; then
      FROM_SCRATCH="true"
      echo "INI file has been modified."
      echo
   fi

   if [ -e "${TMP_ROTATIONS}" ] ; then
      if ! diff "${TMP_ROTATIONS}" "${WORK_PATH}/mame-rotations.txt" > /dev/null 2>&1 ; then
         cp "${TMP_ROTATIONS}" "${WORK_PATH}/mame-rotations.txt"
         echo "The mame-rotations.txt is new for the Arcade Organizer"
         echo
         FROM_SCRATCH="true"
      else
         echo "No changes detected in mame-rotations.txt"
         echo
         echo "Skipping mame-rotations.txt..."
         echo
      fi
      rm "${TMP_ROTATIONS}"
   fi
   # Not sure is this is needed anymore, it was in UA
   #local N_MRA_LINKED=$(find "${ORGDIR}/" -type f -print0 | xargs -r0 readlink -f | sort | uniq | wc -l)
   #local N_MRA_DEPTH1=$(find "${MRADIR}/" -maxdepth 1 -type f -iname "*.mra" | wc -l)
   #if [[ "${N_MRA_DEPTH1}" > "${N_MRA_LINKED}" ]] ; then
   #   FROM_SCRATCH="true"
   #   echo "N_MRA_LINKED > N_MRA_DEPTH1: ${N_MRA_LINKED} > ${N_MRA_DEPTH1}"
   #fi

   local FIND_ARGS=()
   FIND_ARGS+=("${MRADIR}" -type f -name *.mra)
   if [[ "${SKIPALTS^^}" != "FALSE" ]] ; then
      FIND_ARGS+=(-not -ipath \*_Alternatives\*)
   fi

   for dir in "${ORGDIR_DIRECTORIES[@]}" ; do
      FIND_ARGS+=(-not -path "${dir}"/\*)
   done

   if [[ "${FROM_SCRATCH}" == "false" ]] ; then
      FIND_ARGS+=(-newerct ${LAST_MRA_DATE})
   fi

   local UPDATED_MRAS=$(mktemp)
   local MRA_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

   if [[ "${FROM_SCRATCH}" == "true" ]] ; then
      echo "Performing a full build."
      if [ -f "${ORGDIR_FOLDERS_FILE}" ] ; then
         while IFS="" read -r dir || [ -n "${dir}" ] ; do
            remove_dir "${dir}"
         done < "${ORGDIR_FOLDERS_FILE}"
         rm "${ORGDIR_FOLDERS_FILE}"
      fi
      for dir in "${ORGDIR_DIRECTORIES[@]}" ; do
         remove_dir "${dir}"
      done
   fi

   for dir in "${ORGDIR_DIRECTORIES[@]}" ; do
      if ! grep -q "${dir}" "${ORGDIR_FOLDERS_FILE}" 2> /dev/null ; then
         echo "${dir}" >> "${ORGDIR_FOLDERS_FILE}"
      fi
   done

   (
      local ORG_RP=$(realpath "${ORGDIR}")
      local MRA_RP=$(realpath "${MRADIR}")
      if [[ "${ORG_RP}" != "${MRA_RP}" ]] && [[ "${ORG_RP}" != "${MRA_RP}"* ]] && \
         [ ! -e "${ORG_RP}/cores" ] && [ -d "${MRA_RP}/cores" ]
      then
         ln -s "${MRA_RP}/cores" "${ORG_RP}/cores"
         echo "${ORG_RP}/cores" >> "${ORGDIR_FOLDERS_FILE}"
      fi
   )

   if [[ "${FROM_SCRATCH}" != "true" ]] ; then
      echo "Performing an incremental build."
      echo "NOTE: Remove the Organized folders if you wish to start from scratch."
      if [ -f "${ORGDIR_FOLDERS_FILE}" ] ; then
         while IFS="" read -r dir || [ -n "${dir}" ] ; do
            remove_broken_symlinks "${dir}"
         done < "${ORGDIR_FOLDERS_FILE}"
      fi
   fi
   echo

   find "${FIND_ARGS[@]}" > ${UPDATED_MRAS}

   local TOTAL_MRAS="$(wc -l ${UPDATED_MRAS} | awk '{print $1}')"
   if [ ${TOTAL_MRAS} -eq 0 ] ; then
      echo "No new MRAs detected"
      echo
      echo "Skipping Arcade Organizer..."
      echo
      exit 0
   fi
   echo "Organizing $(wc -l ${UPDATED_MRAS} | awk '{print $1}') MRAs."
   sleep 4
   echo

   IFS=$'\n'
   local MRA_FROM_FILE=($(cat ${UPDATED_MRAS} | sort))
   unset IFS
   rm "${UPDATED_MRAS}"

   create_organized_directories
   header

   for i in "${MRA_FROM_FILE[@]}" ; do
      organize_mra "${i}"
   done

   echo "${ARCADE_ORGANIZER_VERSION}" > "${LAST_RUN_PATH}"
   echo "${INI_DATE}" >> "${LAST_RUN_PATH}"
   echo "${MRA_DATE}" >> "${LAST_RUN_PATH}"
   if [ -f "${REAL_NAMES}" ] ; then
      cp "${REAL_NAMES}" "${CACHED_NAMES}"
   fi
}

remove_dir() {
   local dir="${1}"
   if [ -d "${dir}" ] ; then
      rm -rf "${dir}"
   fi
}

remove_broken_symlinks() {
   local dir="${1}"
   if [ -d "${dir}" ] ; then
      find "${dir}/" -xtype l -exec rm {} \; || true
   fi
}

if [ ${#} -eq 1 ] && [ ${1} == "--optimized" ] ; then
   optimized_arcade_organizer
elif [ ${#} -eq 1 ] && [ ${1} == "--print-orgdir-folders" ] ; then
   declare -A DIR_SET
   for dir in "${ORGDIR_DIRECTORIES[@]}" ; do
      if [ -e "${dir}" ] ; then
         DIR_SET["${dir}"]="true"
      fi
   done
   if [ -f "${ORGDIR_FOLDERS_FILE}" ] ; then
      while IFS="" read -r dir || [ -n "${dir}" ] ; do
         if [ -e "${dir}" ] ; then
            DIR_SET["${dir}"]="true"
         fi
      done < "${ORGDIR_FOLDERS_FILE}"
   fi
   for dir in "${!DIR_SET[@]}" ; do
      echo "${dir}"
   done
   exit 0
elif [ ${#} -eq 1 ] && [ ${1} == "--print-ini-options" ] ; then
   echo MRADIR=\""${MRADIR}\""
   echo ORGDIR=\""${ORGDIR}\""
   echo SKIPALTS=\""${SKIPALTS}\""
   echo INSTALL=\""${INSTALL}\""
   exit 0
elif [ ${#} -ge 1 ] ; then
   echo "Invalid arguments."
   echo "Usage: ./${0} --print-orgdir-folders"
   echo "       ./${0} --print-ini-options"
   echo "       ./${0}"
   exit 1
else
   optimized_arcade_organizer
fi
echo "################################################################################"
