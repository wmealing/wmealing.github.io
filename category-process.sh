#!/bin/bash

echo "Starting batch conversion..."

# Function to generate an index page
generate_index() {
    local TAG=$1
    local FILENAME=$2
    local TITLE=$3

    echo "Generating index for $TAG ($FILENAME)..."
    
    local INDEX_FILE="${FILENAME}.org"
    
    echo "#+TITLE: $TITLE" > "$INDEX_FILE"
    echo "#+SETUPFILE: \"./setupfile.org\"" >> "$INDEX_FILE"
    echo "#+INCLUDE: \"navbar.html\" export html" >> "$INDEX_FILE"
    echo "" >> "$INDEX_FILE"
    echo "* Posts tagged with $TAG" >> "$INDEX_FILE"
    echo "" >> "$INDEX_FILE"

    # Find all org files with the matching tag and extract their titles
    # We use a more precise grep to match the tag within the :colon:separated:list:
    grep -l "#+FILETAGS: .*:$TAG:" *.org | while read -r f; do
        # Skip the index file itself if it happens to match
        if [[ "$f" != "$INDEX_FILE" ]]; then
            TITLE_VAL=$(grep "^#+TITLE:" "$f" | sed 's/#+TITLE: //')
            # If no title found, use filename
            if [ -z "$TITLE_VAL" ]; then TITLE_VAL="$f"; fi
            
            HTML_FILE="${f%.org}.html"
            echo "- [[file:$HTML_FILE][$TITLE_VAL]]" >> "$INDEX_FILE"
        fi
    done

    # Export the generated index to HTML
    emacs --batch "$INDEX_FILE" --eval '(setq org-export-with-broken-links t)' -f org-html-export-to-html
}

# 1. Generate Main Category Pages
# Systems
generate_index "systems" "systems" "Category: Systems"
# Security
generate_index "security" "security" "Category: Security"
# Tooling
generate_index "tooling" "tooling" "Category: Tooling"

# 2. Generate Subcategory Pages
# Systems Subcategories
for SUB in erlang clojure lfe cellium lisp cobol midi; do
    CAP_SUB=$(echo "$SUB" | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')
    if [[ "$SUB" == "lfe" ]]; then CAP_SUB="LFE"; fi
    generate_index "$SUB" "systems-${SUB}" "Subcategory: $CAP_SUB"
done

# Security Subcategories
for SUB in kernel ebpf malware rust; do
    CAP_SUB=$(echo "$SUB" | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')
    if [[ "$SUB" == "ebpf" ]]; then CAP_SUB="eBPF"; fi
    generate_index "$SUB" "security-${SUB}" "Subcategory: $CAP_SUB"
done

# Tooling Subcategories
for SUB in emacs cicd openscad git janet; do
    CAP_SUB=$(echo "$SUB" | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')
    if [[ "$SUB" == "cicd" ]]; then CAP_SUB="CI/CD"; fi
    generate_index "$SUB" "tooling-${SUB}" "Subcategory: $CAP_SUB"
done

echo "Category and subcategory generation complete."
