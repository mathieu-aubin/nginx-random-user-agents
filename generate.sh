#!/bin/bash

############### USER-EDITABLE CONFIG ###############
# Settings can be of either numerical/boolean type (0/false | 1/true)

# Base output directory - mandatory
# Can be either absolute or relative path
baseDir="./output";

# Filename prefix to use
fileNamePrefix="index";

# Generate TEXT indexes?
asTxt=true;
# Text files output directory
textDir="${baseDir}/text";

# Generate HTML indexes?
asHtml=true;
# Html files output directory
htmlDir="${baseDir}/html";

# Input file to process
uaFile="./data/all_user.agents.txt";

# Filename numbering padding with zeros?
padWithZeros=false;

# Generate files containing ALL user-agents?
# File will be named ALL while also using defined prefix
# ${fileNamePrefix}_ALL.ext
indexAll=false

# Cleanup/remove previous run directories?
# Should be set to true in order to avoid problems if generating
# nginx configuration
cleanUp=true;

### NGINX CONFIG

# Generate nginx configuration?
nginx_Config=true;
# Name of configuration file to output
nginx_ConfigFile=random-ua.conf;

# Output as location blocks only
nginx_LocOnly=0;

# If entire server block is generated, use ipv6? (ipv4 is always used)
nginx_ipv6=0;

# Universal/catch-all server_name set as default. Respond to anything
nginx_ServerName="__";

# Respond to robots by catching requests to robots.txt
nginx_RobotsTxt=true;

# Cache-Control header settings (in seconds)
# This sets the Cache-Control header for both normal (max-age) usage and
# sites behind cloudflare proxy (s-maxage)
nginx_CacheTime=0;

nginx_Secure=0;
#### END NGINX CONFIG

####################### END USER-EDITABLE CONFIG #######################

# Generate nginx configuration based on data
_genNginxConfig() {

	# Not yet implemented
	echo -e "\033[1;38;5;208mWARNING\033[0;1m:\033[0m nginx config generation has not yet been implemented." >&2;

}

# Check for input file existance
_checkInputFile() {

	if [[ ! -f ${uaFile} ]]; then
		# If file doesn't exist, notify and exit with error code 1
		echo -e "\033[1;38;5;196mERROR\033[0;1m:\033[0m file ${uaFile} doesn't exist." >&2;
		exit 1;
	else
		# If file exist, proceed
		echo -e "\033[1;38;5;28mINFO\033[0;1m:\033[0m file ${uaFile} present, proceeding...";
		sleep 1;
	fi

}

# Create directories needed beforehand keeping the
# check outside of the loop for faster processing
#
# Directories will be created and/or removed depending
# on the values set for each possible generated format
_checkDirectories() {

	# Clean any previous run directories if required
	if [[ ${cleanUp} -eq 1 || "${cleanUp}" == "true" ]]; then
		rm -rf --preserve-root "${baseDir}";
		rm -f "${nginx_ConfigFile}";
	fi

	# Check for text index directory
	if [[ ${asTxt} -eq 1 || "${asTxt}" == "true" ]]; then
		mkdir -p "${textDir}";
	else
		rm -rf --preserve-root "${textDir}";
	fi

	# Check for html index directory
	if [[ ${asHtml} -eq 1 || "${asHtml}" == "true" ]]; then
		mkdir -p "${htmlDir}"
	else
		rm -rf --preserve-root "${htmlDir}";
	fi
}

# Generate text index based on input
_genIndexes() {

	# local declaration of variables
	local fNum fType fExt preText="" postText="";
	# sets file number and shift args
	fNum=${1}; shift;
	# sets file type and shift args
	fType=${1}; shift;
	# sets file extension and shift args
	fExt=${1}; shift;

	# If html output, sets pre/post text
	if [[ "${fType}" == "html" ]]; then
		preText="<p>"; postText="</p>";
	fi

	# Sends rest of input to defined output
	echo "${preText}${@}${postText}" > ${baseDir}/${fType}/${fileNamePrefix}_${fNum}.${fExt};

	# Sends rest of input to ALL file if required by config
	if [[ ${indexAll} -eq 1 || "${indexAll}" == "true" ]]; then
		echo "${preText}${@}${postText}" >> ${baseDir}/${fType}/${fileNamePrefix}_ALL.${fExt};
	fi

}

# Loop thru file and generate stuff
_loopThruFile() {

	# Local declaration of variables
	local fileNum userAgent indexNum=0;

	# Loop thru user-agents file
	while read userAgent; do

		# Increment filename number
		indexNum=$(expr ${indexNum} + 1);

		# Store index number into variable
		if [[ ${padWithZeros} -eq 1 || "${padWithZeros}" == "true" ]]; then
			# If padding required
			printf -v fileNum '%05d' ${indexNum};
		else
			# If no padding required
			fileNum=${indexNum};
		fi

		# If text generation is required
		if [[ ${asTxt} -eq 1 || "${asTxt}" == "true" ]]; then
			_genIndexes ${fileNum} text txt "${userAgent}";
		fi

		# If Html generation is required
		if [[ ${asHtml} -eq 1 || "${asHtml}" == "true" ]]; then
			_genIndexes ${fileNum} html html "${userAgent}";
		fi

	done < ${uaFile}

}

# Call to create/remove/cleanup stuff needed;
_checkDirectories;

# Check for file existance
_checkInputFile;

# Proceed to generation
_loopThruFile;

# Generate nginx configuration file
if [[ ${nginx_Config} -eq 1 || "${nginx_Config}" == "true" ]]; then
	_genNginxConfig;
fi