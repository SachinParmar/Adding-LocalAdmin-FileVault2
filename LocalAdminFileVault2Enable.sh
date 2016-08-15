#!/bin/bash

######################################################################################
# Enable Local Admin for FileVault 2 Automated 
# Script Adapted from https://jamfnation.jamfsoftware.com/discussion.html?id=12143
#
# Adapted by Sachin Parmar
# Version 1.0
#
# Parameters: 
# $4 = Management Account Username
# $5 = Management Account Password
# $6 = Local Admin Username
# $7 = Local Admin Password
######################################################################################

######################################################################################
# Pass the credentials for an admin account that is authorized with FileVault 2
######################################################################################

adminName=$4
adminPass=$5

if [ "${adminName}" == "" ]; then
echo "Username undefined. Please pass the management account username in parameter 4"
fi

if [ "${adminPass}" == "" ]; then
echo "Password undefined. Please pass the management account password in parameter 5"
fi

######################################################################################
# Local Admin Username and Password
######################################################################################

userName=$6
userPass=$7

######################################################################################
# Check if Local Admin is enabled for FileVault 2
######################################################################################

userCheck=`fdesetup list | awk -v usrN='localadmin' -F, 'index($0, usrN) {print $1}'`
if [ "${userCheck}" == "${userName}" ]; then
echo "This user is already added to the FileVault 2 list."
elif [ "${userCheck}" != "${userName}" ]; then
echo "Local Admin is not enabled for FileVault 2 list."
fi

######################################################################################
# Check to see if FileVault 2 is enabled
######################################################################################

encryptCheck=`fdesetup status`
statusCheck=$(echo "${encryptCheck}" | grep "FileVault is On.")
expectedStatus="FileVault is On."
if [ "${statusCheck}" != "${expectedStatus}" ]; then
echo "The encryption process has not completed, unable to add user at this time."
elif [ "${statusCheck}" == "${expectedStatus}" ]; then
echo "FileVault Encryption is Complete"
fi

######################################################################################
# Create a temporary plist file
######################################################################################

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Username</key>
<string>'$adminName'</string>
<key>Password</key>
<string>'$adminPass'</string>
<key>AdditionalUsers</key>
<array>
    <dict>
        <key>Username</key>
        <string>'$userName'</string>
        <key>Password</key>
        <string>'$userPass'</string>
    </dict>
</array>
</dict>
</plist>' > /tmp/fvenable.plist

echo "created /tmp/fvenable.plist"

######################################################################################
# Enable FileVault 2 for Local Admin
######################################################################################

fdesetup add -i < /tmp/fvenable.plist

######################################################################################
# Check if Local Admin account has been enabled for FileVault 2
######################################################################################

userCheck=`fdesetup list | awk -v usrN="$userName" -F, 'index($0, usrN) {print $1}'`
if [ "${userCheck}" != "${userName}" ]; then
echo "Failed to add user to FileVault 2 list."
elif [ "${userCheck}" == "${userName}" ]; then
echo "Local Admin enabled for FileVault 2"
fi

######################################################################################
# Remove temporary plist file
######################################################################################

if [[ -e /tmp/fvenable.plist ]]; then
    rm /tmp/fvenable.plist
fi
exit 0
