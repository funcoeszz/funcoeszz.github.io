#!/bin/bash
# 2015-02-12, Aurelio Jargas
#
# Generate the functions help YAML datafile.

gitroot='../../funcoeszz'
zz='./funcoeszz.tmp'
out='help.yml'

cd $(dirname "$0")

> $out  # truncate
echo "########### DO NOT EDIT -- NÃO EDITE ###########"    >> $out
echo "########### Generated by $(basename $0) ###########" >> $out
echo >> $out

# The all-in-one script is *way* faster to load
echo "Generating funcoeszz script..."
ZZOFF= ZZDIR=$gitroot/zz $gitroot/funcoeszz --tudo-em-um > "$zz"
chmod +x "$zz"

echo "Generating help YAML..."
(
	export ZZCOR=0
	for func in $("$zz" zzajuda --lista | cut -d ' ' -f 1)
	do
		printf . >&2  # show progress on screen

		# YAML key, with the function name
		# The | means the next indented lines will be literal
		echo "$func: |"

		# Get this function help text
		"$zz" $func -h |
			# Remove leading blank line and the next
			sed 1,2d |
			# Remove trailing blank line
			sed '$ { /^$/d; }' |
			# Remove Tabs that break YAML
			sed 's/	/    /g' |
			# Two-space indent, required by YAML
			sed 's/^/  /'
	done
) >> $out

echo
echo "$PWD/$out done."
rm "$zz"