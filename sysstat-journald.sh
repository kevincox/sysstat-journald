#! /bin/bash

set -e

sadc_flags="${SJ_SADC_TYPES:-DISK,XDISK,INT,IPV6,SNMP}"
unset SJ_SADC_FLAGS

sar_flags="${SJ_SAR_FLAGS:- -Fj LABEL -Bb -I SUM -n ALL -P ALL -u ALL -r ALL -S -vWw}"
unset SJ_SADF_FLAGS

duration="${SJ_DURATION:-8}"
unset SJ_DURATION

tmp="$(mktemp sysstat-journald.XXXXXXXX)"
trap 'rm -rf "$tmp"' EXIT

sadc -S "${sadc_flags}" "$duration" 2 > "$tmp"

(
	sadf -p "$tmp" -- $sar_flags | \
		sort | \
		awk -F $'\t' '
			function c(p) {
				$p = toupper($p);
				gsub("[^A-Z0-9_]", "_", $p);
				return $p;
			}
			
			{
				# print $0;
				if (last && ($4 != last4 || $5 != last5)) {
					print last;
				}
				last4 = $4;
				last5 = $5;
				
				if ($4 == "-") {
					$4 = "";
				} else {
					c(4);
					match($4, /^_*/);
					$4 = substr($4, RLENGTH+1) "___";
				}
				
				gsub("/", "_PER_", $5);
				gsub("%", "PCT_", $5);
				c(5)
				
				last = $4 $5 "=" $6;
			}
			
			END { if (last) { print last } }
		'
	
	cat <<-END
		MESSAGE_ID=847dc86c90f14ba7a864b05afdffd5d7
		SYSLOG_IDENTIFIER=sysstat-journald
		PRIORITY=6
	END
) | logger --journald
