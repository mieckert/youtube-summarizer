cd summaries
for file in *.md; do
    if grep -aq $'\e\[' "$file"; then
        AST="../audio-summary-text/${file%.md}.txt"
        AS="../audio-summary/${file%.md}.mp3"
        rm "$AST" "$AS" "$file"
    fi
done