#!/bin/bash
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

VAR="$(parse_yaml pubspec.yaml | grep 'dependencies_monero_libs_version=')"
# VAR="dependencies_monero_libs_version=\"0.018003001.044\""

# Extracting version components
version="${VAR#*=}"      # Remove everything before '='
version="${version#\"}"  # Remove leading double quote
version="${version%\"}"  # Remove trailing double quote

# Reformatting version
formatted_version="v0.${version:2:3}.${version:5:3}.${version:8:3}-RC${version:12}"

# Output the formatted version

version="${formatted_version#v}"  # Remove the leading 'v'
version="${version%-RC*}"    # Remove the trailing '-RC' and everything after it

# Remove leading zeros from each version component
version_without_zeros=$(echo "$version" | awk -F'.' '{printf "v%s.%s.%s.%s", $1+0, $2+0, $3+0, $4+0}')

# Extract the RC part
rc_part="${formatted_version##*-RC}"

# Output the formatted version
echo "${version_without_zeros}-RC${rc_part}" | sed 's/RC0/RC/' | sed 's/RC00/RC/'