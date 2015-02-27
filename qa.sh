#!/bin/bash

# Welcome to the Liferay QA Tool - LINUX VERSION
# This script can be used to accomplish many repetative bundle tasks that we do in QA.
# In order to use it, you simply need to set the variables below for your enviroment.

## User Information ##
name="Victor"
# username is the value used to name your test.${username/computername}.properties
username="vicnate5"

## MySQL login ##
# this can usually be left blank
mysqlUsername=
mysqlPassword=

## MySQL Databases ##
masterDB="master"
ee62xDB="ee62"
ee70xDB="ee7"
ee61xDB="ee61"
ee6210DB="ee621"
publicMasterDB="publicmaster"

## Bundle ports ##
# e.g. for 9080 put 9
masterPort="8"
ee62xPort="7"
ee70xPort="8"
ee61xPort="6"
ee6210Port="8"
publicMasterPort="6"

## Test Results Location ##
# used in the POSHI suite function
# where you want your test reports to end up
resultsDir="/home/vicnate5/Desktop/RESULTS"

## Portal Directories ##
sourceDir="/home/vicnate5/liferay"
bundleDir="/home/vicnate5/bundles"

masterSourceDir="$sourceDir/liferay-portal-ee-master"
masterBundleDir="$bundleDir/master-ee-bundles"
masterPluginsDir="$sourceDir/liferay-plugins-master"

ee62xSourceDir="$sourceDir/liferay-portal-ee-6.2.x"
ee62xBundleDir="$bundleDir/ee-6.2.x-bundles"
ee62xPluginsDir="$sourceDir/liferay-plugins-ee-6.2.x"

ee70xSourceDir="$sourceDir/liferay-portal-ee-7.0.x"
ee70xBundleDir="$bundleDir/ee-7.0.x"
ee70xPluginsDir="$sourceDir/liferay-plugins-ee-7.0.x"

ee61xSourceDir="$sourceDir/liferay-portal-ee-6.1.x"
ee61xBundleDir="$bundleDir/ee-6.1.x-bundles"
ee61xPluginsDir="$sourceDir/liferay-plugins-ee-6.1.x"

ee6210SourceDir="$sourceDir/liferay-portal-ee-6.2.10"
ee6210BundleDir="$bundleDir/ee-6.2.10-bundles"
ee6210PluginsDir="$sourceDir/liferay-plugins-ee-6.2.10"

publicMasterSourceDir="$sourceDir/liferay-portal-master"
publicMasterBundleDir="$bundleDir/master-ce-bundles"

## Plugins ##
# This allows you to deploy a group of plugins that you use regularly
# There is one array variable for CE plugins and one for EE only plugins.
# You can list as many as you want.
# The CE plugins will be deployed on your EE bundles as well.

# ***These must be listed with their parent directory***
# e.g. webs/kaleo-web

cePlugins[0]="webs/kaleo-web"
cePlugins[1]="portlets/calendar-portlet"
cePlugins[2]="portlets/web-form-portlet"

eePlugins[0]="portlets/kaleo-forms-portlet"
eePlugins[1]="portlets/kaleo-designer-portlet"
eePlugins[2]="portlets/reports-portlet"
eePlugins[3]="webs/jasperreports-web"

## Bundle build sound ##
soundDir="/home/vicnate5/Dropbox/Work/Scripts"
soundFile="bundleFinished.mp3"

## Jenkins Results Links ##
baseJenkinsmaster="http://build-1/1/view/test-portal-branch-upstream-frontend-tomcat-mysql%28master%29/job/test-portal-branch-upstream-frontend-tomcat-mysql%5Bportal"
baseJenkinsee62x="http://build-1/1/view/test-portal-branch-upstream-frontend-tomcat-mysql%28ee-6.2.x%29/job/test-portal-branch-upstream-frontend-tomcat-mysql%5Bportal"
baseJenkinsee70x="http://build-1/1/view/test-portal-branch-upstream-frontend-tomcat-mysql%28ee-7.0.x%29/job/test-portal-branch-upstream-frontend-tomcat-mysql%5Bportal"
baseJenkinsee61x="http://build-1/1/view/test-portal-branch-upstream-frontend-tomcat-mysql%28ee-6.1.x%29/job/test-portal-branch-upstream-frontend-tomcat-mysql%5Bportal"
baseJenkinsee6210="http://build-1/1/view/test-portal-branch-upstream-frontend-tomcat-mysql%28ee-6.2.10%29/job/test-portal-branch-upstream-frontend-tomcat-mysql%5Bportal"

jenkinsUrlmaster[0]="$baseJenkinsmaster-workflow%5D(master)/lastCompletedBuild/testReport/"
jenkinsUrlmaster[1]="$baseJenkinsmaster-web-forms-and-data-lists%5D(master)/lastCompletedBuild/testReport/"
jenkinsUrlmaster[2]="$baseJenkinsmaster-calendar%5D(master)/lastCompletedBuild/testReport/"

jenkinsUrlee62x[0]="$baseJenkinsee62x-workflow%5D(ee-6.2.x)/lastCompletedBuild/testReport/"
jenkinsUrlee62x[1]="$baseJenkinsee62x-web-forms-and-data-lists%5D(ee-6.2.x)/lastCompletedBuild/testReport/"
jenkinsUrlee62x[2]="$baseJenkinsee62x-calendar%5D(ee-6.2.x)/lastCompletedBuild/testReport/"
jenkinsUrlee62x[3]="$baseJenkinsee62x-business-productivity-ee%5D(ee-6.2.x)/lastCompletedBuild/testReport/"

jenkinsUrlee70x[0]="$baseJenkinsee70x-workflow%5D(ee-7.0.x)/lastCompletedBuild/testReport/"
jenkinsUrlee70x[1]="$baseJenkinsee70x-web-forms-and-data-lists%5D(ee-7.0.x)/lastCompletedBuild/testReport/"
jenkinsUrlee70x[2]="$baseJenkinsee70x-calendar%5D(ee-7.0.x)/lastCompletedBuild/testReport/"
jenkinsUrlee70x[3]="$baseJenkinsee70x-business-productivity-ee%5D(ee-7.0.x)/lastCompletedBuild/testReport/"

jenkinsUrlee61x[0]="$baseJenkinsee61x-workflow%5D(ee-6.1.x)/lastCompletedBuild/testReport/"
jenkinsUrlee61x[1]="$baseJenkinsee61x-web-forms-and-data-lists%5D(ee-6.1.x)/lastCompletedBuild/testReport/"
jenkinsUrlee61x[2]="$baseJenkinsee61x-calendar%5D(ee-6.1.x)/lastCompletedBuild/testReport/"
jenkinsUrlee61x[3]="$baseJenkinsee61x-business-productivity-ee%5D(ee-6.1.x)/lastCompletedBuild/testReport/"

jenkinsUrlee6210[0]="$baseJenkinsee6210-workflow%5D(ee-6.2.10)/lastCompletedBuild/testReport/"
jenkinsUrlee6210[1]="$baseJenkinsee6210-web-forms-and-data-lists%5D(ee-6.2.10)/lastCompletedBuild/testReport/"
jenkinsUrlee6210[2]="$baseJenkinsee6210-calendar%5D(ee-6.2.10)/lastCompletedBuild/testReport/"
jenkinsUrlee6210[3]="$baseJenkinsee6210-business-productivity-ee%5D(ee-6.2.10)/lastCompletedBuild/testReport/"

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
			echo "Resetting Ivy Cache"
			rm -r $dir/.ivy/cache
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

	if [[ $v != *ee-6.1* ]]
	then
		echo "Setting up portal-ext.properties"
		setupDatabaseConnection
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
	echo "Remaking MySQL Database"
	dbClear
	echo "$db has been remade"

	if [[ $v != *ee-6.1* ]]
	then
		echo "Adding virtual hosts property"
		cd $bundleDir/tomcat-7.0.42/webapps/ROOT/WEB-INF/classes/
		ip=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

		if ! grep -q "virtual.hosts.valid.hosts" ./portal-ext.properties 
		then
			(echo "" ; echo "virtual.hosts.valid.hosts=localhost,127.0.0.1,$ip") >> portal-ext.properties
		fi
	fi

	echo "done"
	cd $soundDir
	mpg123 $soundFile &> /dev/null
	read -rsp $'Press any key to continue...\n' -n1 key
}

pluginsDeploy(){
	cd $pluginsDir
	echo "Plugins Branch Selected: $v"
	echo
	echo "--Plugins Selected--"
	echo "CE: ${cePlugins[*]}" | tr " " "\n" | sed 's/.*\///'
	echo
	echo "EE: ${eePlugins[*]}" | tr " " "\n" | sed 's/.*\///'
	echo
	echo

	updateToHeadOption

	for p in "${cePlugins[@]}"
	do
		echo "Deploying $p"
		cd $p && ant clean deploy
		echo "done"
		echo
		cd $pluginsDir 
	done

	if [[ $v == *ee* ]]
	then
		for p in "${eePlugins[@]}"
		do
			echo "Deploying $p"
			cd $p && ant clean deploy
			echo "done"
			echo
			cd $pluginsDir  
		done
	fi

	echo "done"
	read -rsp $'Press any key to continue...\n' -n1 key
}

clearEnv(){
	echo "Portal Version Selected: $v"
	echo
	read -p "Do you want to remove all plugins except marketplace? (y/n)?" -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			echo
			echo "Clearing Plugins"

			if [[ $v == *ee-6.1* ]]
			then
				cd $bundleDir/tomcat-7.0.40/webapps && ls | grep -v "^ROOT\|^marketplace-portlet"  | xargs rm -r
			else
				cd $bundleDir/tomcat-7.0.42/webapps && ls | grep -v "^ROOT\|^marketplace-portlet"  | xargs rm -r
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

	echo "Clearing Data and Logs"
	cd $bundleDir
	rm -r data logs
	echo "Remaking MySQL Database"
	dbClear
	echo "$db has been remade"
	echo "done"
	read -rsp $'Press any key to continue...\n' -n1 key
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

poshiBuildSeleniumOption(){
	read -p "Do you need to Build Selenium First? (y/n)?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		cd $dir/portal-impl
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
}

poshiRunTest(){
	poshiBuildSeleniumOption

	echo "Running $testname"
	sleep 2
	echo
	echo "Clearing Old Screenshots"
	cd $dir/portal-web/test-results/functional/screenshots
	rm *.jpg
	cd $dir

	if [ "$mobile" = "true" ]
	then
		sed -i 's/sleep seconds="120"/sleep seconds="30"/' build-test.xml
		ant -f run.xml run -Dtest.class=$testname -Dmobile.device.enabled=true < /dev/null
	else
		ant -f run.xml run -Dtest.class=$testname < /dev/null
	fi
	
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
			echo "Invalid option"
		fi
	done

	poshiBuildSeleniumOption

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

	poshiRunTest

	echo "Copying your results to $resultsDir"
	cp $dir/portal-web/test-results/functional/${v}_$testname.html $resultsDir/
	read -rsp $'Press any key to continue...\n' -n1 key
}

poshiSetUrl(){
	echo -n "Enter Portal URL and press [ENTER]: "
	read url
	cd $dir

	if grep -q "portal.url=" test.$username.properties 
	then
		sed -i "s/portal.url=.*/portal.url=${url}/" test.$username.properties
	else
		(echo "" ; echo "portal.url=${url}") >>test.$username.properties
	fi
}

poshiOption(){
	while :
	do
		clear
		portalURL=$(cat $dir/test.$username.properties | grep "portal.url=")
		cat<<EOF
========================================
POSHI $v
$testname
$portalURL
----------------------------------------
Choose Your Destiny:

	(1) Run Test
	(2) Run Mobile Test
	(3) Pick New Test
	(4) Format Source
	(5) Set Portal URL
	(6) Run Test Suite
	
	(q)uit - go back
----------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  mobile="false" poshiRun ;;
	"2")  mobile="true" poshiRun ;;
	"3")  poshiSetTest ;;
	"4")  poshiFormat ;;
	"5")  poshiSetUrl ;;
	"6")  poshiSuite ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  break ;; 
	* )   echo "Not a valid option" ;;
	esac
done
}

poshiSetTest(){
	echo -n "Enter full test name and press [ENTER]: "
	read testname
	echo "$testname"
}

openJenkinsURL(){
	jenkinsUrl=jenkinsUrl$jb[@]

	for url in ${!jenkinsUrl}
		do
			xdg-open $url &> /dev/null
		done
}

branchMenu(){
	while :
	do
		clear
		cd $dir
		portalID="$(git log --pretty=format:'%H' -n 1)"
		gitBranch="$(git rev-parse --abbrev-ref HEAD)"
		cat<<EOF
===========================================
$v

Git ID: $portalID
Git Branch: $gitBranch
-------------------------------------------
Please choose:

	(1) Build Bundle
	(2) Clear Enviroment
	(3) Run POSHI Test
	(4) Deploy Plugins
	(5) Jenkins Results

	(q)uit - Main Menu
-------------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  bundleBuild ;;
	"2")  clearEnv ;;
	"3")  poshiSetTest ; poshiOption ;;
	"4")  pluginsDeploy ;;
	"5")  openJenkinsURL ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  echo "quit" 
		  break  ;; 
	* )   echo "Not a valid option" ;;
	esac
	done
}

gitInfo(){
	cd $masterSourceDir
	masterPortalID="$(git log --pretty=format:'%H' -n 1)"
	cd $masterPluginsDir
	masterPluginsID="$(git log --pretty=format:'%H' -n 1)"
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
	cd $ee6210SourceDir
	ee6210PortalID="$(git log --pretty=format:'%H' -n 1)"
	cd $ee6210PluginsDir
	ee6210PluginsID="$(git log --pretty=format:'%H' -n 1)"
	cd $publicMasterSourceDir
	publicMasterPortalID="$(git log --pretty=format:'%H' -n 1)"

	cat<<EOF
Master:
Tomcat 7.0.42 + MySQL 5.5. Portal master GIT ID: $masterPortalID.
Plugins master GIT ID: $masterPluginsID.

ee-6.2.x:
Tomcat 7.0.42 + MySQL 5.5. Portal ee-6.2.x GIT ID: $ee62xPortalID.
Plugins ee-6.2.x GIT ID: $ee62xPluginsID.

ee-7.0.x:
Tomcat 7.0.42 + MySQL 5.5. Portal ee-7.0.x GIT ID: $ee70xPortalID.
Plugins ee-7.0.x GIT ID: $ee70xPluginsID.

ee-6.1.x:
Tomcat 7.0.40 + MySQL 5.5. Portal ee-6.1.x GIT ID: $ee61xPortalID.
Plugins ee-6.1.x GIT ID: $ee61xPluginsID.

ee-6.2.10:
Tomcat 7.0.42 + MySQL 5.5. Portal ee-6.2.10 GIT ID: $ee6210PortalID.
Plugins ee-6.2.10 GIT ID: $ee6210PluginsID.

Master PUBLIC:
Tomcat 7.0.42 + MySQL 5.5. Portal master GIT ID: $publicMasterPortalID.
Plugins master GIT ID: $masterPluginsID.
EOF
	echo
	read -rsp $'Press any key to continue...\n' -n1 key
}

######################################################################################################################
##MAIN MENU##

while :
do
	clear
	cat<<EOF

Liferay Portal QA Tool    
===========================================
Main Menu
-------------------------------------------
Hello $name 
Please choose a branch version:

	(1) Master
	(2) ee-6.2.x
	(3) ee-7.0.x
	(4) ee-6.1.x
	(5) ee-6.2.10
	(6) Master Public

	(7) Print git info

	(q)uit
-------------------------------------------
EOF
	read -n1 -s
	case "$REPLY" in
	"1")  dir=$masterSourceDir bundleDir=$masterBundleDir pluginsDir=$masterPluginsDir v="master" db=$masterDB p=$masterPort jb="master" branchMenu ;;
	"2")  dir=$ee62xSourceDir bundleDir=$ee62xBundleDir pluginsDir=$ee62xPluginsDir v="ee-6.2.x" db=$ee62xDB p=$ee62xPort jb="ee62x"  branchMenu ;;
	"3")  dir=$ee70xSourceDir bundleDir=$ee70xBundleDir pluginsDir=$ee70xPluginsDir v="ee-7.0.x" db=$ee70xDB p=$ee70xPort jb="ee70x" branchMenu ;;
	"4")  dir=$ee61xSourceDir bundleDir=$ee61xBundleDir pluginsDir=$ee61xPluginsDir v="ee-6.1.x" db=$ee61xDB p=$ee61xPort jb="ee61x" branchMenu ;;
	"5")  dir=$ee6210SourceDir bundleDir=$ee6210BundleDir pluginsDir=$ee6210PluginsDir v="ee-6.2.10" db=$ee6210DB p=$ee6210Port jb="ee6210"  branchMenu ;;
	"6")  dir=$publicMasterSourceDir bundleDir=$publicMasterBundleDir pluginsDir=$masterPluginsDir v="master-public" db=$publicMasterDB p=$publicMasterPort jb="master" branchMenu ;;
	"7")  gitInfo ;;
	"Q")  echo "case sensitive!!" ;;
	"q")  echo "quit" 
		  exit ;; 
	* )   echo "Not a valid option" ;;
	esac
done