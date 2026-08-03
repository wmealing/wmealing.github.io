#!/bin/bash

# Define categories
CATEGORIES=("systems" "security" "tooling")

echo "Starting batch conversion..."

# 1. Convert all regular org files to HTML
for f in *.org; do
    # Skip setupfile and index-generating files
    if [[ "$f" != "setupfile.org" && "$f" != "systems.org" && "$f" != "security.org" && "$f" != "tooling.org" ]]; then
        echo "Converting $f to HTML..."
        # We use --eval to ignore broken links so the export finishes
        emacs --batch "$f" --eval '(setq org-export-with-broken-links t)' -f org-html-export-to-html
    fi
done

# 2. Generate Category Index Pages
for CAT in "${CATEGORIES[@]}"; do
    echo "Generating index for $CAT..."
    
    # Create a temporary org file for the category
    INDEX_FILE="${CAT}.org"
    
    # Capitalize the category name for the title (macOS compatible)
    CAP_CAT=$(echo "$CAT" | awk '{print toupper(substr($0,1,1))tolower(substr($0,2))}')
    
    echo "#+TITLE: Category: $CAP_CAT" > "$INDEX_FILE"
    echo "#+SETUPFILE: \"./setupfile.org\"" >> "$INDEX_FILE"
    echo "#+INCLUDE: \"navbar.html\" export html" >> "$INDEX_FILE"
    echo "" >> "$INDEX_FILE"
    echo "* Posts in $CAP_CAT" >> "$INDEX_FILE"
    echo "" >> "$INDEX_FILE"

    # Find all org files with the matching tag and extract their titles
    # We skip the index files themselves
    grep -l "#+FILETAGS: :$CAT:" *.org | while read -r f; do
        if [[ "$f" != "$INDEX_FILE" ]]; then
            TITLE=$(grep "^#+TITLE:" "$f" | sed 's/#+TITLE: //')
            # If no title found, use filename
            if [ -z "$TITLE" ]; then TITLE="$f"; fi
            
            HTML_FILE="${f%.org}.html"
            echo "- [[file:$HTML_FILE][$TITLE]]" >> "$INDEX_FILE"
        fi
    done

    # Export the generated index to HTML
    emacs --batch "$INDEX_FILE" -f org-html-export-to-html
done

echo "Batch conversion and category generation complete."
