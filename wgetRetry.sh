#!/bin/bash
if [ "$#" -lt 1 ]; then
	echo "Please provide an URL"
	exit 1
fi

url=$1
currentDate=`date '+%Y-%m-%d_%H%M%S'`
outputDocument=${2:-"response-$currentDate.txt"}
retryCount=${3:-10}
allowedResponseCodes=("200", "400")

responseCode=-1
currentTry=1
while [[ ! "${allowedResponseCodes[@]}" =~ "${responseCode}" ]]; do
	responseCode=`wget --server-response --no-http-keep-alive --output-document=$outputDocument -q "$url" 2>&1 | grep "HTTP/" | cut -d' ' -f4`
	logger "HTTP response code for $url is $responseCode (Try: $currentTry / $retryCount)"
	if [[ ! "${allowedResponseCodes[@]}" =~ "${responseCode}" ]]; then
		sleep 4
		currentTry=$((currentTry+1))
		if [ "$currentTry" -gt "$retryCount" ]; then
			logger "Giving up on $url"
			exit 1;
		fi
	fi
done

