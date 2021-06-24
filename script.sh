#!/bin/bash

set -e

echo "REPO: $GITHUB_REPOSITORY"
echo "ACTOR: ${GITHUB_ACTOR}"

content_folder=${CONTENT_FOLDER:=content}
config_file=${CONFIG_FILE:=pelicanconf.py}

echo "Cheking file ======================================"
if [ -d "${content_folder}/" ]
then
    echo "content folder is exist."
else
    echo "content does not exist. please create one or more content file in content folder"
    exit 1
fi

if [ -f "${config_file}" ]
then
    echo "config file is exist."
else
    echo "config does not exist."
    exit 1
fi

echo 'Installing dependency ============================='
pip install -r ${REQUIREMENTS_FILE:=requirements.txt}

echo 'Pelican build ====================================='
echo "content folder: ${content_folder}"
echo "config file: ${config_file}"
pelican ${content_folder} -o output -s ${config_file}

pushd output 
git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
