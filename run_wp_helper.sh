#!/bin/bash

PUBLIC="/var/www/public_html"

for D in "$PUBLIC"/*; do
	if [ -d "$D" ]
	then
		if [ -e "$D"/.wp_helper_flags ]
		then
			FLAGS=$(cat "$D"/.wp_helper_flags)
		else
			FLAGS="--update=all"
		fi

		SITE=$(basename "$D")
		SITEFLAG="--sites=public_html/""$SITE""/public"

		if [[ "$FLAGS" != *"none"* ]]; then
			echo "Updating" "$SITE""..."
			bash /usr/local/bin/rhd_wp_helper/wp_helper.sh "$FLAGS" "$SITEFLAG"
		else
			echo "Skipping" "$SITE""..."
		fi

		echo "All done."
	else
		echo "Uh-oh.  Things went poopy and I can't tell you why."
	fi
done
