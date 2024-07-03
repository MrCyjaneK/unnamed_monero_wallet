#!/bin/bash
# Simple wrapper that loops over all files and does some fun stuff
# please keep list of all defines below:
# LIBSTEALTH_CALCULATOR - build stealthmode calculator
# COIN_MONERO - build monero version
# COIN_WOWNERO - build wownero version
#note: only one COIN_* can be set at a time
set - -DXMRUW_VERSION_PLAIN=$(git describe --tags | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/') "$@"
set - -DXMRUW_VERSION_BUILDID=$(git rev-list --count HEAD) "$@"
set - -DXMRUW_VERSION_COMBINED_PLUS=$(git describe --tags | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')+$(git rev-list --count HEAD) "$@"
set - -DXMRUW_VERSION_PRETTY=$(git describe --tags --dirty) "$@"
set -e

FILES=$(( git status --short| grep '^?' | cut -d\  -f2- && git ls-files ) | sort -u | grep -E '\.pproc |\.pproc$')

# update gitignore

(cat .gitignore; echo "# codegen.sh"; echo $FILES | tr ' ' '\n' | sed 's/\.[^\.]*$//') | awk '!seen[$0]++' > .gitignore_
mv .gitignore_ .gitignore
git add .gitignore

for i in $FILES
do
    [[ -f $i ]] || continue
    # cpp -nostdinc -fno-show-column -trigraphs -CC -E $@ $i | sed '/^# [0-9]\+/d'
    # Run cpp with the provided options and save the output to a temporary file
    cpp -I. -nostdinc -fno-show-column -trigraphs -CC -E "$@" "$i" |\
        sed '/^# [0-9] "\+/d' > temp_output
    # Initialize the output file
    output_file=$(echo $i | sed 's/\.[^\.]*$//')
    > "$output_file"

    # Read through the temp output and process line by line
    current_line=1
    while IFS= read -r line; do
    if [[ $line =~ ^#\ ([0-9]+)\ .*$ ]]; then
        # Extract the line number from the preprocessor directive
        target_line=${BASH_REMATCH[1]}

        [[ "x$(echo $line | grep $i)" == "x" ]] && continue

        # Calculate the number of lines to insert
        newlines_to_insert=$((target_line - current_line))
        
        # Insert the new lines
        for ((n=0; n<newlines_to_insert; n++)); do
        echo "" >> "$output_file"
        done

        # Update the current line number
        current_line=$target_line
    else
        # Print the line to the output file
        echo "$line" >> "$output_file"
        current_line=$((current_line + 1))
    fi
    [[ ! "x${CODEGEN_CLEANUP}" == "x" ]] && rm $output_file || true
    done < temp_output
    rm temp_output || true
done