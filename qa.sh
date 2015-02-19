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

# Test Results Location
# used in the POSHI suite function
# where you want your test reports to end up
resultsDir=/home/username/results

# Portal Directories
sourceDir=/opt/dev/projects/github
bundleDir=/opt/dev/projects/bundles

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

setupDatabaseConnection(){
	cd $dir
	if [[ -e test.$username.properties ]] 
	# if test.username.properties exists(-e)
	then
		if grep -q database.mysql.schema test.$username.properties 
		# if there is a test.username.properties file that already defines the database name
		then
			sed -i "s/database.mysql.schema=.*/database.mysql.schema=${db}/" test.$username.properties
			# basic inline(-i) search and replace
			# using ".*" regex to denote that it can contain any string in the rest of that line
		else
			(echo "" ; echo "database.mysql.schema=${db}") >>test.$username.properties
			# append the file with the database property after adding an extra line. 
			# this is to prevent the property being added to the end of a already populated line
		fi
	else
		echo "database.mysql.schema=${db}" >test.$username.properties
		# create file test.username.properties and add the database.name property
	fi

	if grep -q database.mysql.username test.$username.properties 
	then
		sed -i "s/database.mysql.username=.*/database.mysql.username=${mysqlUsername}/" test.$username.properties
	else
		(echo "" ; echo "database.mysql.username=${mysqlUsername}") >>test.$username.properties
	fi

	if grep -q database.mysql.password test.$username.properties 
	then
		sed -i "s/database.mysql.password=.*/database.mysql.password=${mysqlPassword}/" test.$username.properties
	else
		(echo "" ; echo "database.mysql.password=${mysqlPassword}") >>test.$username.properties
	fi

	ant -f build-test.xml prepare-portal-ext-properties
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
		cd $bundleDir/tomcat-7.0.40/conf
	else
		cd $bundleDir/tomcat-7.0.42/conf
	fi

	echo "Writing ports to ${p}080"
	sed -i "s/8005/${p}005/; s/8080/${p}080/; s/8009/${p}009/; s/8443/${p}443/" server.xml
	
	if [[ $v != *ee-6.1* ]]
	then
		echo "Setting up portal-ext.properties"
		setupDatabaseConnection
	fi

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
	"1")  dir=$masterSourceDir bundleDir=$masterBundleDir v="master" db=$masterDB p=$masterPort bundleBuild ;;
	"2")  dir=$ee62xSourceDir bundleDir=$ee62xBundleDir v="ee-6.2.x" db=$ee62xDB p=$ee62xPort  bundleBuild ;;
	"3")  dir=$ee70xSourceDir  bundleDir=$ee70xBundleDir v="ee-7.0.x" db=$ee70xDB p=$ee70xPort bundleBuild ;;
	"4")  dir=$ee61xSourceDir  bundleDir=$ee61xBundleDir v="ee-6.1.x" db=$ee61xDB p=$ee61xPort bundleBuild ;;
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
				cd $dir/tomcat-7.0.40/webapps && ls | grep -v "^ROOT\|^marketplace-portlet"  | xargs rm -r
			else
				cd $dir/tomcat-7.0.42/webapps && ls | grep -v "^ROOT\|^marketplace-portlet"  | xargs rm -r
			fi
			
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

poshiRunTest(){
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
	mv $dir/portal-web/test-results/functional/report.html $dir/portal-web/test-results/functional/${v}_$testname.html
	echo "done"
	echo
	echo "Zipping Screenshots"
	echo
	cd $dir/portal-web/test-results/functional/screenshots
	zip Pictures$testname.zip *.jpg
	rm *.jpg
	echo "done"
}

poshiSuite(){
	T="$(date +%s)"

	echo "Choose a Test Suite to Run and hit [Enter]:"
	echo
	OPTIONS="Suite-1 Suite-2"
	select opt in $OPTIONS; do
		if [ "$opt" = "Suite-1" ]; then
			suiteNumber=1
			echo "$opt Selected"
			sleep 2
			break
		elif [ "$opt" = "Suite-2" ]; then
			suiteNumber=2
			echo "$opt Selected"
			sleep 2
			break
		else
			echo "Don't be a noob"
		fi
	done

	read -p "Do you need to Build Selenium First? (y/n)?" -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			cd $dir
			cd portal-impl
			echo "Building Selenium"
			ant build-selenium
			cd $dir
		elif [[ $REPLY =~ ^[Nn]$ ]] 
		then
			echo "No"
		else 
			echo "please choose Y or N"
			sleep 3
			continue
		fi
	echo "Clearing Old Screenshots"
	cd $dir/portal-web/test-results/functional/screenshots
	rm *.jpg
	cd $dir

	if [ -z "$suiteNumber" ]; then 
		echo "You didn't pick a test suite.";
		break
	fi

	# Runs all tests that are listed in the specified suite${suiteNumber}.txt. This file needs to be in your base source directory
	# The file also must contains an extra blank line at the end to ensure all the tests are read
	while read testname;
	do
		poshiRunTest
		cd $dir
		continue
	done<suite$suiteNumber.txt

	echo
	echo -e "\e[31mALL TESTS COMPLETE\e[0m"
	echo
	echo "Zipping up results for you"
	sleep 2

	date="$(date +"%m-%d-%y")"
	time="$(date +"%H:%M")"

	info=Suite${suiteNumber}_${date}_${time}
	cd $dir/portal-web/test-results/functional/screenshots
	echo "Zipping screenshots"
	zip Results-Pictures-$info *.zip
	mv Results-Pictures-$info.zip $dir
	rm *.zip
	cd $dir
	mv Results-Pictures-$info.zip $resultsDir/Results-$info-PICTURES
	echo "done"

	echo
	echo "Zipping reports"
	cd $dir/portal-web/test-results/functional

	mkdir failed
	grep -l -Z -r 'div class="fail"' . | xargs -0 -I{} mv {} ./failed

	cd $dir/portal-web/test-results/functional
	zip Results-$info-PASSED *.html
	mv Results-$info-PASSED.zip $dir
	rm *.html

	cd failed
	zip Results-$info-FAILED *.html
	mv Results-$info-FAILED.zip $dir
	cd $dir/portal-web/test-results/functional
	rm -r failed

	echo "Sending your results to $resultsDir"
	cd $dir
	unzip Results-$info-PASSED.zip -d $resultsDir/Results-$info-PASSED
	unzip Results-$info-FAILED.zip -d $resultsDir/Results-$info-FAILED
	echo "done"

	echo
	T="$(($(date +%s)-T))"
	echo "Time in seconds: ${T}"
	echo
	printf "Pretty format: %02d:%02d:%02d:%02d\n" "$((T/86400))" "$((T/3600%24))" "$((T/60%60))" "$((T%60))"
	echo "done"
	echo
	echo -e "\e[31mResults can be found in $dir\e[0m"
	echo -e "\e[31mor in $resultsDir\e[0m"
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

	poshiRunTest
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
	Run Test Suite    (5)


	                  (q)uit and go back
---------------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  build="true" poshiRun ;;
	"2")  build="false" poshiRun ;;
	"3")  poshiFormat ;;
	"4")  poshiSetTest ;;
	"5")  poshiSuite ;;
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

gitInfo(){
	cd $eeMasterSourceDir
	eeMasterPortalID="$(git log --pretty=format:'%H' -n 1)"
	cd $eeMasterPluginsDir
	eeMasterPluginsID="$(git log --pretty=format:'%H' -n 1)"
	cd $ee62xSourceDir
	ee62xPortalID="$(git log --pretty=format:'%H' -n 1)"
	cd $ee62xPluginsDir
	ee62xPluginsID="$(git log --pretty=format:'%H' -n 1)"
	cd $ee70xSourceDir
	ee70xPortalID="$(git log --pretty=format:'%H' -n 1)"
	cd $ee70xPluginsDir
	ee70xPluginsID="$(git log --pretty=format:'%H' -n 1)"
	cd $ee61xSourceDir
	ee61xPortalID="$(git log --pretty=format:'%H' -n 1)"
	cd $ee61xPluginsDir
	ee61xPluginsID="$(git log --pretty=format:'%H' -n 1)"

	cat<<EOF
Master:
Tomcat 7.0.42 + MySQL 5.5. Portal master GIT ID: $eeMasterPortalID.
Plugins master GIT ID: $eeMasterPluginsID.

ee-6.2.x:
Tomcat 7.0.42 + MySQL 5.5. Portal ee-6.2.x GIT ID: $ee62xPortalID.
Plugins ee-6.2.x GIT ID: $ee62xPluginsID.

ee-7.0.x:
Tomcat 7.0.42 + MySQL 5.5. Portal ee-7.0.x GIT ID: $ee70xPortalID.
Plugins ee-7.0.x GIT ID: $ee70xPluginsID.

ee-6.1.x:
Tomcat 7.0.40 + MySQL 5.5. Portal ee-6.1.x GIT ID: $ee61xPortalID.
Plugins ee-6.1.x GIT ID: $ee61xPluginsID.
EOF
	echo
	read -rsp $'Press any key to continue...\n' -n1 key
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
	Git Info           (5)

	                   (q)uit
-------------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  bundle ;;
	"2")  clearEnv ;;
	"3")  poshi ;;
	"4")  plugins ;;
	"5")  gitInfo ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  echo "quit" 
		  exit  ;; 
	* )   echo "Not a valid option" ;;
	esac
done