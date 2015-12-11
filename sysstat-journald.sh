#! /bin/bash

set -e

sadc_flags="${SJ_SADF_TYPES:-DISK,XDISK,INT,IPV6,SNMP}"
unset SJ_SADC_FLAGS

sadf_flags="${SJ_SADC_FLAGS:- -Fj LABEL -Bb -I SUM -n ALL -P ALL -u ALL -r ALL -S -vWw}"
unset SJ_SADF_FLAGS

tmp="$(mktemp)"
static="$(mktemp)"

sadc -S "${sadc_flags}" 2 2 > "$tmp"

(
	sadf -p "$tmp" -- $sadf_flags | \
		awk -F $'\t' '
			function c(p) {
				$p = toupper($p);
				gsub("%", "PCT_", $p);
				gsub("/", "_PER_", $p);
				gsub("[^A-Z0-9_-]", "_", $p);
				return $p;
			}
			
			{
				if ($4 == "-")
					$4 = "";
				else
					$4 += "___";
					
				printf "%s%s=%s\n", c(4), c(5), $6;
			}
		'
	cat <<-END
		MESSAGE_ID=847dc86c90f14ba7a864b05afdffd5d7
		SYSLOG_IDENTIFIER=sysstat-journald
		PRIORITY=6
	END
) |logger --journald
