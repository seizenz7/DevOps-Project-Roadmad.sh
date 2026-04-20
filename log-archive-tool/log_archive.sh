#!/bin/bash

set -euo pipefail

dryrun=false
if [[ "${1:-}" == "--dry-run" ]]
then
  dryrun=true
  shift
fi

# Cek jumlah argumen
cekArgumen() {
  if [[ $# != 2 ]]
  then
    echo "log_archive.sh target_directory_name destination_directory_name"
    exit 1
  fi
}

targetDirectory="$1"
destinationDirectory="$2"

# Cek validitas direktori
cekDirektori() {
  if [[ ! -d $targetDirectory ]]
  then
    echo "Target directory not found"
    exit 1
  fi
  if [[ ! -d $destinationDirectory ]]
  then
    echo "Destination directory not found"
    exit 1
  fi
}

# Cek file .log
cekLogFiles() {
  logFiles=()
  for file in "$targetDirectory"/*.log
  do
    if [[ -f "$file" ]]
    then
      logFiles+=("$file")
    else
      echo "No .log files found in the target directory"
      exit 1
    fi
  done
}

cd "$targetDirectory" || exit 1

# Date timestamp untuk nama arsip
currentTS=$(date '+%Y%m%d_%H%M%S')
backupFileName="log_archive_$currentTS.tar.gz"

# Membuat arsip
arsip() {
    if $dryrun
    then
        echo "Dry run: would create archive $backupFileName from ${logFiles[@]}"
        echo "Dry run: would move archive to $destinationDirectory/$backupFileName"
        return
    fi
  echo "Creating archive $backupFileName from ${logFiles[@]}"
  tar -czf "$destinationDirectory/$backupFileName" -C "$targetDirectory" "${logFiles[@]##*/}"
  echo "Archive created at $destinationDirectory/$backupFileName"
}

cekArgumen "$@"
cekDirektori
cekLogFiles
arsip