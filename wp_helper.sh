#!/bin/bash

# Help / usage info.
USAGE=$'WordPress Helper script, built for EasyEngine but should be widely compatible.\nWithout any args it will search /var/www/ for WordPress sites, loop over them in alphabetical order and check for core and plugin updates.\nAlso accepts:\n\t--sites=[space seperated list of site paths relative to /var/www]\n\t--update=[plugins|wp|all].'


# Die function for exiting on errors.
die () {
  echo "${1}, exitting..." >&2 ; echo ; exit 1
}


# Read options.
for i in "$@"
	do
	case $i in
	    -h|--help)
	    HELP="true" # Display help / usage info.
	    shift # past argument with no value
	    ;;
	    --sites=*)
	    SITES="${i#*=}" # Space seperated list of sites paths under /var/www.
	    shift # past argument=value
	    ;;
	    --update=*)
	    UPDATE="${i#*=}" # Do updates - plugins | themes | wp | all.
	    shift # past argument=value
	    ;;
	    *)
	            # Unknown option.
	    ;;
	esac
done


# What am I.
echo ========================
echo WordPress helper
echo ========================


# Display help / usage.
if [ "$HELP" == "true" ]; then
	echo "$USAGE"
	echo ; exit 1
fi


# Webroot.
www_dir='/var/www'


# If no site(s) passed as arg, find within webroot.
if [ -z "${SITES}" ]; then
	for site_path in $( cd $www_dir ; find . -type d -name 'wp-admin' | sort -n ); do
		SITES="${SITES} ${site_path}"
	done
fi


# Output info messages.
if [ -z "${UPDATE}" ]; then
	echo ;
	echo === "Checking for updates" ===
	echo ;
else
	echo ;
	echo === Running updates ===
	echo ;
fi

# Loop over sites.
for site in ${SITES}; do

	# Pre-flight checks.
	[ -z $site ] && \
	  die "Error: no site(s) found or specified"
	[ -r ${www_dir}/${site} ] || \
	  die "Error: '${www_dir}/${site}' does not exist"

	# Move to current site dir.
	cd ${www_dir}/${site};

	# We're checking for updates.
	if [ -z "${UPDATE}" ]; then
		echo $(wp option get siteurl) \(v$(wp core version)\);
		echo $(wp core check-update);
		wp plugin list --format=csv --fields=name,status,update,version,update_version | awk -F',' '$3 == "available" {print "Plugin update: ",$1,"\t",$2,"\t",$4,"->",$5}' | column -t;
		wp theme list --format=csv --fields=name,status,update,version,update_version | awk -F',' '$3 == "available" {print "Theme update: ",$1,"\t",$2,"\t",$4,"->",$5}' | column -t;
		echo ========================
	fi


	if [ "${UPDATE}" == "plugins" ]; then
		echo $(wp option get siteurl);
		wp plugin update --all
		echo ========================
	elif [ "${UPDATE}" == "themes" ]; then
		echo $(wp option get siteurl);
		wp theme update --all
		echo ========================
	elif [ "${UPDATE}" == "wp" ]; then
		echo $(wp option get siteurl);
		wp core update
		echo ========================
	elif [ "${UPDATE}" == "all" ]; then
		echo $(wp option get siteurl);
		wp core update
		wp plugin update --all
		wp theme update --all
		echo ========================
	fi

done;
