#!/bin/bash

# Welcome to the Liferay QA Tool - LINUX VERSION
# This script can be used to accomplish many repetative bundle tasks that we do in QA.
# In order to use it, you simply need to set the variables below for your enviroment.

# User Information
name=YourName

# MySQL login 
# this can usually be left blank
mysqlUsername=
mysqlPassword=

# MySQL Databases
masterDB=master
ee62xDB=ee62
ee70xDB=ee7
ee61xDB=ee61

# Bundle ports
# e.g. for 9080 put 9
masterPort=9
ee62xPort=7
ee70xPort=8
ee61xPort=6

# Portal Directories
sourceDir=/home/username/Liferay/Source/private
bundleDir=/home/username/Liferay/Source/private

masterSourceDir=$sourceDir/master-build
masterBundleDir=$bundleDir/master-bundles
masterPluginsDir=$sourceDir/master-plugins

ee62xSourceDir=$sourceDir/ee-6.2.x-build
ee62xBundleDir=$bundleDir/ee-6.2.x-bundles
ee62xPluginsDir=$sourceDir/ee-6.2.x-plugins

ee70xSourceDir=$sourceDir/ee-7.0.x-build
ee70xBundleDir=$bundleDir/ee-7.0.x-bundles
ee70xPluginsDir=$sourceDir/ee-7.0.x-plugins

ee61xSourceDir=$sourceDir/ee-6.1.x-build
ee61xBundleDir=$bundleDir/ee-6.1.x-bundles
ee61xPluginsDir=$sourceDir/ee-6.1.x-plugins

# Plugins
#
# This allows you to deploy a group of plugins that you use regularly
# There is one array variable for CE plugins and one for EE only plugins.
# You can list as many as you want.
# The CE plugins will be deployed on your EE bundles as well.
#
# ***These must be listed with their parent directory***
# e.g. webs/kaleo-web
declare -a cePlugins=("webs/kaleo-web" "portlets/notifications-portlet")
declare -a eePlugins=("portlets/kaleo-forms-portlet" "portlets/kaleo-designer-portlet")


######################################################################################################################


dbClear(){
		if [[ -n "$mysqlUsername" ]]; then
			if [[ -n "$mysqlPassword" ]]
			then
				mysql -u $mysqlUsername -p $mysqlPassword -e "drop database if exists $db; create database $db char set utf8;"
			else
				mysql -u $mysqlUsername -e "drop database if exists $db; create database $db char set utf8;"
			fi
		else
			mysql -e "drop database if exists $db; create database $db char set utf8;"
		fi
}

updateToHeadOption(){
	read -p "Update to HEAD? (y/n)?" -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			echo "Yes"
			echo "Pulling Upstream"
			echo
			git pull upstream $v
			echo
			echo "Pushing to Origin"
			echo
			git push origin $v
		elif [[ $REPLY =~ ^[Nn]$ ]] 
		then
			echo "No"
		else 
			echo "please choose Y or N"
			continue
		fi
}

bundleBuild(){
	cd $dir

	read -p "Switch to main branch and update to HEAD? (y/n)?" -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			echo "Switching to branch $v"
			git checkout $v
			git status
			echo
			echo -e "\e[31mAny modified files will be cleared, are you sure you want to continue?\e[0m"
			echo -e "\e[31m[y/n?]\e[0m"

			read -n 1 -r
				echo
				if [[ $REPLY =~ ^[Yy]$ ]]
				then
					echo "Sweetness"
				elif [[ $REPLY =~ ^[Nn]$ ]] 
				then
					echo "No"
					echo "Come back when you have committed or stashed your modified files."
					break
				else 
					echo "please choose y or n"
					sleep 3
					continue
				fi
				
			echo "Clearing main branch"
			git reset --hard
			echo
			echo "Pulling Upstream"
			echo
			git pull upstream $v
			echo
			echo "Pushing to Origin"
			echo
			git push origin $v
		elif [[ $REPLY =~ ^[Nn]$ ]] 
		then
			echo "No"
		else 
			echo "please choose y or n"
			sleep 3
			continue
		fi

	echo "Building $v"
	ant -f build-dist.xml unzip-tomcat
	ant all
	
	if [[ $v == *ee-6.1* ]]
	then
		cd $bun_dir/tomcat-7.0.40/conf
	else
		cd $bun_dir/tomcat-7.0.42/conf
	fi

	echo "Writing ports to ${p}080"
	sed -i "s/8005/${p}005/; s/8080/${p}080/; s/8009/${p}009/; s/8443/${p}443/" server.xml
	echo "Remaking MySQL Database"
	
	dbClear

	echo "$db has been remade"
	echo "done"
	read -rsp $'Press any key to continue...\n' -n1 key
}

bundle(){
	while :
	do
		clear
		cat<<EOF
========================================
Build Bundle
----------------------------------------
Which bundle?

	Master     (1)
	ee-6.2.x   (2)
	ee-7.0.x   (3)
	ee-6.1.x   (4)

	           (q)uit to main menu
----------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  dir=$masterSourceDir bun_dir=$masterBundleDir v="master" db=$masterDB p=$masterPort bundleBuild ;;
	"2")  dir=$ee62xSourceDir bun_dir=$ee62xBundleDir v="ee-6.2.x" db=$ee62xDB p=$ee62xPort  bundleBuild ;;
	"3")  dir=$ee70xSourceDir  bun_dir=$ee70xBundleDir v="ee-7.0.x" db=$ee70xDB p=$ee70xPort bundleBuild ;;
	"4")  dir=$ee61xSourceDir  bun_dir=$ee61xBundleDir v="ee-6.1.x" db=$ee61xDB p=$ee61xPort bundleBuild ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  break  ;; 
	* )   echo "Not a valid option" ;;
	esac
done
}

pluginsDeploy(){
	cd $dir
	echo "Plugins Branch Selected: $v"
	echo

	updateToHeadOption

	for p in "${cePlugins[@]}"
	do
		echo "Deploying $p"
		cd $p && ant clean deploy
		echo "done"
		echo
		cd $dir 
	done

	if [[ $v == *ee* ]]
	then
		for p in "${eePlugins[@]}"
		do
			echo "Deploying $p"
			cd $p && ant clean deploy
			echo "done"
			echo
			cd $dir  
		done
	fi

	echo "done"
	read -rsp $'Press any key to continue...\n' -n1 key
}

plugins(){
	while :
	do
		clear
		cat<<EOF
========================================
Deploy Plugins

Plugins that will be deployed:
CE: ${cePlugins[*]}
EE: ${eePlugins[*]}
----------------------------------------
Which Bundle?

	Master     (1)
	ee-6.2.x   (2)
	ee-7.0.x   (3)
	ee-6.1.x   (4)

	           (q)uit to main menu
----------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  dir=$masterPluginsDir v="master" pluginsDeploy ;;
	"2")  dir=$ee62xPluginsDir v="ee-6.2.x" pluginsDeploy ;;
	"3")  dir=$ee70xPluginsDir v="ee-7.0.x" pluginsDeploy ;;
	"3")  dir=$ee61xPluginsDir v="ee-6.1.x" pluginsDeploy ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  break  ;; 
	* )   echo "Not a valid option" ;;
	esac
done
}

clearEnvCmd(){
	echo "Portal Version Selected: $v"
	sleep 2
	echo "Clearing Data and Logs"
	cd $dir
	rm -r data logs

	read -p "Do you want to remove all plugins except marketplace? (y/n)?" -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			echo
			echo "Clearing Plugins"

			if [[ $v == *ee-6.1* ]]
			then
				cd $bun_dir/tomcat-7.0.40/webapps
			else
				cd $bun_dir/tomcat-7.0.42/webapps
			fi
			
			ls | grep -v "^ROOT\|^marketplace-portlet"  | xargs rm -r
			echo "done"
		elif [[ $REPLY =~ ^[Nn]$ ]] 
		then
			echo "No"
			echo "Plugins untouched"
		else 
			echo "please choose y or n"
			sleep 3
			continue
		fi
	echo "Remaking MySQL Database"
	dbClear
	echo "$db has been remade"
	echo "done"
	read -rsp $'Press any key to continue...\n' -n1 key
}

clearEnv(){
	while :
	do
		clear
		cat<<EOF
========================================
Clear Enviroment
----------------------------------------
Which Bundle?

	Master     (1)
	ee-6.2.x   (2)
	ee-7.0.x   (3)
	ee-6.1.x   (4)

	           (q)uit to main menu
----------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  dir=$masterBundleDir v="master" db=$masterDB clearEnvCmd ;;
	"2")  dir=$ee62xBundleDir v="ee-6.2.x" db=$ee62xDB clearEnvCmd ;;
	"3")  dir=$ee70xBundleDir v="ee-7.0.x" db=$ee70xDB clearEnvCmd ;;
	"4")  dir=$ee61xBundleDir v="ee-6.1.x" db=$ee61xDB clearEnvCmd ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  break  ;; 
	* )   echo "Not a valid option" ;;
	esac
done
}

poshiFormat(){
	echo "Formatting POSHI files for $v"
	sleep 2
	cd $dir/portal-impl
	ant format-source
	echo
	echo "done"
	read -rsp $'Press any key to continue...\n' -n1 key
}

poshiRun(){
	echo "Running POSHI test for $v"
	sleep 2

	if [ "$build" = "true" ]
	then
		echo "Building Selenium"
		sleep 1
		cd $dir/portal-impl
		ant build-selenium
	fi

	echo "Running $testname"
	sleep 2
	echo
	echo "Clearing Old Screenshots"
	cd $dir/portal-web/test-results/functional/screenshots
	rm *.jpg
	cd $dir
	ant -f run.xml run -Dtest.class=$testname < /dev/null
	echo
	echo "Finished $testname"
	echo
	echo "Renaming report.html"
	mv $dir/portal-web/test-results/functional/report.html $dir/portal-web/test-results/functional/$testname.html
	echo "done"
	echo
	echo "Zipping Screenshots"
	echo
	cd $dir/portal-web/test-results/functional/screenshots
	zip Pictures$testname.zip *.jpg
	rm *.jpg
	echo "done"
	read -rsp $'Press any key to continue...\n' -n1 key
}

poshiOption(){
	while :
	do
		clear
		cat<<EOF
============================================
POSHI $v
$testname
--------------------------------------------
Choose Your Destiny:

	Build and Run     (1)
	Run               (2)
	Format            (3)
	Pick New Test     (4)


	                  (q)uit and go back
---------------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  build="true" poshiRun ;;
	"2")  build="false" poshiRun ;;
	"3")  poshiFormat ;;
	"4")  poshiSetTest ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  break  ;; 
	* )   echo "Not a valid option" ;;
	esac
done
}

poshiSetTest(){
	echo -n "Enter full test name and press [ENTER]: "
	read testname
	echo "$testname"
}

poshi(){
	while :
	do
		clear
		cat<<EOF
========================================
POSHI
----------------------------------------
Which Branch?

	Master     (1)
	ee-6.2.x   (2)
	ee-7.0.x   (3)
	ee-6.1.x   (4)

	           (q)uit to main menu
----------------------------------------
EOF
    read -n1 -s
    case "$REPLY" in
    "1")   poshiSetTest ; dir=$masterSourceDir v="master" poshiOption ;;
	"2")   poshiSetTest ; dir=$ee62xSourceDir v="ee-6.2.x" poshiOption ;;
	"3")   poshiSetTest ; dir=$ee70xSourceDir v="ee-7.0.x" poshiOption ;;
	"4")   poshiSetTest ; dir=$ee61xSourceDir v="ee-6.1.x" poshiOption ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  break  ;; 
	* )   echo "Not a valid option" ;;
	esac
done
}

######################################################################################################################
# MAIN MENU

while :
do
	clear
	cat<<EOF

Liferay Portal QA Tool    
===========================================
Main Menu

Hello $name, What would you like to do?
-------------------------------------------
Please choose:

	Build Bundle       (1)
	Clear Enviroment   (2)
	Run POSHI Test     (3)
	Deploy Plugins     (4)

	                   (q)uit
-------------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  bundle ;;
	"2")  clearEnv ;;
	"3")  poshi ;;
	"4")  plugins ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  echo "quit" 
		  exit  ;; 
	* )   echo "Not a valid option" ;;
	esac
done