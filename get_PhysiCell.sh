#!/bin/bash
# This script is produced for downloading/updating PhysiCell by MathCancer Lab.
# Written by Furkan Kurtoglu (fkurtog@iu.edu) - October, 2019.
# To use it, you must specify which version should be downloaded. Example usage:  bash get_PhysiCell.sh 1.6.0


# House-keeping
VERSION="1.1.1"
echo "Running 'get_PhysiCell.sh script' (version" $VERSION ") ... "
echo ""


# Learning the current version number
git_Ver=$(curl https://raw.githubusercontent.com/MathCancer/PhysiCell/master/VERSION.txt)


# In this section, script is looking for older versions and compares the user input. It raises error if the given version number does not exist in the repo.
# GitHub API is used to download metadata of repo. Python helps to parse json and compare the checks the availability of given version number.
python_ver=$(python --version 2>&1)
pyth_v=$(echo ${python_ver:7:1})
intended_Ver="$1"
export intended_Ver

# Checking the argument availability for the code
if [ ! "$#" = 1 ]; then
   echo -e "\e[31mNo version is provided! \nIf a specific version is preferred, please give an argument as a version of PhysiCell.\n\e[0mExample:";echo "bash get_PhysiCell.sh $git_Ver"
   echo ""
   echo "Note: Current version of PhysiCell is $git_Ver."
   echo "Downloading current PhysiCell version (" $git_Ver ") by default ..." 
   echo ""
   intended_Ver=$git_Ver 
fi


# The code is checking for installed Python version and acts accordingly. Having Python 2.x or 3.x is not a problem!
if [ "$pyth_v" = 2 ];then
     Existence=$(curl -s "https://api.github.com/repos/MathCancer/PhysiCell/tags" | python -c 'import sys, os, json
tags=json.load(sys.stdin)
user_vers=os.environ["intended_Ver"]
exist=0
for i in tags:
   if (i["name"] == user_vers):
       exist = 1
print exist
')
   if [ "$Existence" = 0 ];then
       echo -e "\e[31mThe version number you entered ("$intended_Ver") is not valid! Please enter valid version number.\e[0m"; exit 1
   fi
elif [ "$pyth_v" = 3 ];then
     Existence=$(curl -s "https://api.github.com/repos/MathCancer/PhysiCell/tags" | python -c 'import sys, os, json
tags=json.load(sys.stdin)
user_vers=os.environ["intended_Ver"]
exist=0
for i in tags:
   if (i["name"] == user_vers):
       exist = 1
print(exist)
')
   if [ "$Existence" = 0 ];then
      echo -e "\e[31mThe version number you entered ("$intended_Ver") is not valid! Please enter valid version number.\e[0m"; exit 1
   fi
else
   echo -e "\e[31mThere is a problem about Python version. Please contact fkurtog@iu.edu";exit 1
fi


# The script checks the existence of PhysiCell. And, if it does not find, clones the master repo.
# If there is a directory that is already built, it looks for the version of it.
# If it is up-to-date, program exits. However, if it is outdated, it asks user for an update.
# CAUTION !!! Updating is removing the local directory and downloading the current version.
DIR="PhysiCell/"
if [ -d $DIR ]; then
   local_Ver=$(cat PhysiCell/VERSION.txt)
   if [ "$local_Ver" = "$git_Ver" ]; then
      echo "Local version ("$local_Ver") is the current version. Nothing has been done!"
   else
      echo  "Local version ("$local_Ver") is outdated. Would you like to download the current version ("$git_Ver")? (CAUTION! Saying 'Yes' will remove your directory and download the current version. (Please select the best option for you)"
      select yn in "Yes" "No"; do
      case $yn in
          Yes ) echo "Removing Local Version..."; rm -rf $DIR; echo "Cloning Current Version..."; git clone https://github.com/MathCancer/PhysiCell;cd $DIR;git checkout --quiet $intended_Ver;echo "PhysiCell version ("$intended_Ver") is ready to use";exit;;
          No ) echo "Local version is remained. Nothing has been done!";exit;;
      esac
      done
   fi
else
   echo "No PhysiCell is found in this directory."
   echo "Cloning PhysiCell from GitHub..."
   echo "-----------------"
   git clone https://github.com/MathCancer/PhysiCell;
   if [ "$git_Ver" = "$intented_Ver" ];then
      echo "PhysiCell version ("$git_Ver") is ready to use."
   else
      cd PhysiCell/;git checkout --quiet  "$intended_Ver"
      echo "-----------------"
      echo "PhysiCell version ("$intended_Ver") is ready to use."
   fi
fi
