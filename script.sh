#!/bin/bash

set -e

echo "REPO: $GITHUB_REPOSITORY"
echo "ACTOR: ${GITHUB_ACTOR}"

content_folder=${CONTENT_FOLDER:=content}
config_file=${CONFIG_FILE:=pelicanconf.py}
requirements_file=${REQUIREMENTS_FILE:=requirements.txt}

echo "Cheking file ======================================"
if [ -d "${content_folder}/" ]
then
    echo "content folder is exist."
else
    echo "content does not exist."
    echo "Please create one or more content file in content folder."
    exit 1
fi

if [ -f "${config_file}" ]
then
    echo "config file is exist."
else
    echo "config does not exist."
    exit 1
fi

if [ -f "${requirements_file}" ]
then
    echo "requirements.txt file is exist."
else
    echo "requirements.txt does not exist."
    echo "Please provide project python dependency."
    exit 1
fi

echo 'Installing dependency ============================='
pip install -r ${requirements_file}

echo 'Pelican build ====================================='
echo "content folder: ${content_folder}"
echo "config file: ${config_file}"
pelican ${content_folder} -o output -s ${config_file}

pushd output 
git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

remote_branch=${GH_PAGES_BRANCH:=gh-pages}
git remote add deploy "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git remote -v

echo "Pelican Publish ==================================="
git checkout ${remote_branch} || git checkout --orphan ${remote_branch}
git add .
git commit -m "[Automation] deploy with Github Actions from ${GITHUB_ACTOR}"
git push deploy ${remote_branch} --force
rm -rf .git

popd

echo "Finished"