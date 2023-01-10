# !/bin/bash

# This script uses two arguments: githubUser and juliaPackageName
# the first one being optional (default value: "ollecram").

# The environment variable JULIA_TMP_DEVDIR is assumed to have been
# correctly set to the file path under the user home directory where 
# the user creates the skeleton of Julia packages using the Julia 
# Pkg.generate() function or a PkgTemplates.jl project template.

# The environment variable JULIA_PKG_DEVDIR is assumed to have been
# correctly set to the file path under the user home directory where 
# the user stores clones of GitHub repositories holding a Julia package. 
# After completion, this script issues a warning if that is not the case.

# A. Arguments checking

# A1. Check on the the number of arguments

githubUser=ollecram
if [ $# == 1 ]
then
	juliaPackageName=$1 
elif [ $# == 2 ]
then
	githubUser=$1
	juliaPackageName=$2
else
	echo Usage: initJuliaPackage [githubUser] juliaPackageName
	exit
fi

# A2. Check that the JULIA_TMP_DEVDIR environment variable is set 

if [[ -z "${JULIA_TMP_DEVDIR}" ]]; then
	echo ERROR: Environment variable JULIA_TMP_DEVDIR is not set. 
	echo The environment variable JULIA_TMP_DEVDIR must be set to
	echo the file path under the user home directory where the user
        echo creates the skeleton of Julia packages using the Julia 
        echo Pkg.generate function or a PkgTemplates.jl project template.
fi

# A3. Check that a folder named "$juliaPackageName.jl" exists under $JULIA_TMP_DEVDIR

if [ -d "$JULIA_TMP_DEVDIR/$juliaPackageName" ] 
then 
	echo	A folder named "$juliaPackageName.jl" exists under $JULIA_TMP_DEVDIR
else	
	echo	ERROR: A folder named "$juliaPackageName.jl" DOES NOT exist under $JULIA_TMP_DEVDIR
	exit
fi

# B. Save current working directory
cwd=$(pwd)

# ---------------------------------------------------------------------------------------------

# 1. cd $JULIA_TMP_DEVDIR/<package-name> 
#				Note that <package-name> MUST NOT include the ".jl" 
#				suffix mandated for the GitHub repository name
#
cd "$JULIA_TMP_DEVDIR/$juliaPackageName"

# 2. git init -b main	
#    				Create the .git/ subfolder. "-b main" causes the main branch 
#				to be given the same name as that of the main branch on GitHub
#
echo @ git init -b main
git init -b main

# 3. git add .
#				All files previously created by @pkg> generate must be staged 
#				(i.e. be made locally known) to Git
#
echo @ git add . 
git add . 

# 4. git commit -a -m "msg"
#				Commit all staged files
#
commit_msg="Initial structure of Julia package $juliaPackageName"
echo @ git commit -a -m "$commit_msg"
git commit -a -m "$commit_msg"

# 5. git remote add origin <URL>
#				Provide SSH URL of the GitHub remote repository. See note (a).
#
SSH_URL="git@github.com:$githubUser/$juliaPackageName.jl.git"
echo @ git remote add origin $SSH_URL
git remote add origin $SSH_URL

# 6. git config pull.rebase false
#				Avoids Git complaining on the next command about bringing 
#				two divergent branches together 
#
echo @ git config pull.rebase false
git config pull.rebase false


# 7. git pull origin main --no-edit initJuliaPackage.sh--allow-unrelated-histories
#
#				Pulls from GitHub the README.md, LICENSE and .gitignore files
#                               --no-edit avoids promptinng the user for a merge message!
#
git pull origin main --no-edit --allow-unrelated-histories
echo @ git pull origin main --no-edit --allow-unrelated-histories

# 8. git status
#				Expected output:
#						On branch main
#						nothing to commit, working tree clean
echo @ git status
git status

# 9. git push --set-upstream origin main
#				Expected output:
#						To $SSH_URL
#						nothing to commit, working tree clean
#
echo @ git push --set-upstream origin main
git push --set-upstream origin main

# ---------------------------------------------------------------------------------------------

# C. Warn the user that development should now continue on a local clone of the
#    GitHub repository under the JULIA_PKG_DEVDIR directory. See note (b).
echo
echo
echo The skeleton files under $JULIA_TMP_DEVDIR can now be safely 
echo eliminated by the following command:
echo      
echo 	rm -rf $juliaPackageName
echo
echo Development should now continue on the GitHub project "$juliaPackageName.jl"
echo of which you should now create a local clone by the following commands:
echo    cd \$JULIA_PKG_DEVDIR
echo    git clone $SSH_URL 
echo
  

# D. Restore the working directory that was current on entry to this script
cd $cwd

# E. Warn the user if the environment variable JULIA_PKG_DEVDIR is not set.

if [[ -z "${JULIA_PKG_DEVDIR}" ]]; then
	echo 
	echo WARNING: The environment variable JULIA_PKG_DEVDIR is not set. 
	echo JULIA_PKG_DEVDIR should be correctly set to the file path under 
	echo the home directory where the user stores clones of GitHub repositories.
	echo
fi

# =============================================================================================

# Notes:

# (a) The HTTPS form would cause the Git CLI to issue an 
#     authentication prompt, but then authentication would 
#     fail anyway, because GitHub has abolished HTTPS 
#     authentication in this context.

# (b) One reason for NOT using the JULIA_PKG_DEVDIR path to also
#     store the skeleton of Julia packages created using the Julia 
#     Pkg.generate() function or a PkgTemplates.jl project template
#     is that the parent folder of these skeletons takes the bare name
#     of the Julia package (e.g. "MyAwesomePackage") while the name of 
#     the corresponding GitHub project must take the ".jl" suffix.       


