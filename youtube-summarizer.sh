#!/bin/bash

. ./config.sh

set -eaxo pipefail

mkdir -p audio audio-summary-text audio-summary summaries transcripts

cd audio
for URL in "${CHANNELS[@]}"; do
    echo "--- Processing: $URL ---"
	yt-dlp --extract-audio --audio-format mp3 \
		--cookies-from-browser chrome \
		--lazy-playlist --break-match-filters "upload_date >= 20260101" \
		--no-post-overwrites \
		--no-overwrites \
		--download-archive downloaded-videos.txt \
		--write-description \
		--add-metadata \
		--write-info-json \
		--restrict-filenames \
		-o "%(timestamp>%Y-%m-%d_%H-%M)s_%(uploader_id|replace:@:)s.%(ext)s" \
		"${URL}" \
		|| true
done

URL="$PLAYLIST"
echo "--- Processing: $URL ---"
yt-dlp --extract-audio --audio-format mp3 \
	--cookies-from-browser chrome \
	--no-post-overwrites \
	--no-overwrites \
	--download-archive downloaded-videos.txt \
	--write-description \
	--add-metadata \
	--write-info-json \
	--restrict-filenames \
	-o "%(timestamp>%Y-%m-%d_%H-%M)s_%(uploader_id|replace:@:)s_playlist.%(ext)s" \
	"${URL}" \
	|| true

for i in *.mp3; do
	if [ -f ../transcripts/${i%.mp3}.txt ]; then
		echo "Transcript for $i already exists, skipping."
		continue
	fi
	uvx --python 3.13 parakeet-mlx --output-format txt --output-dir ../transcripts $i
done
cd ..

cd transcripts
for i in *.txt; do
	dest="../summaries/${i%.txt}.md"
	if [ -f "$dest" ]; then
		echo "Summary for $i already exists, skipping."
		continue
	fi
	cat $i | ollama run ministral-3-32k \
		"Write a 2-3 paragraph summary of the following text focusing on the main ideas, topics, and conclusions. The text is a transcript of a Youtube video and may contain transcription errors. For context, the video deals with Artificial Intelligence, LLMs, Agents, and so on. Output the summary in markdown format, starting directly with the summary without any preceeding remarks. TEXT:\n\n" > "$dest"
	
	if [ -n "$SEND_EMAIL_TO" ]; then
		title=$(cat ../audio/${i%.txt}.info.json | jq  -r ".title")
		cat "$dest" | mail -s "New summary ${i%.txt}: $title" "$SEND_EMAIL_TO"
	fi
done
cd ..

cd summaries
for i in *.md; do
	dest="../audio-summary-text/${i%.md}.txt"
	if [ -f "$dest" ]; then
		echo "Audio summary text for $i already exists, skipping."
		continue
	fi
	cat $i | ollama run ministral-3-32k \
		"Turn the following markdown document into text suitable for text-to-speech. Do not use any special characters in the output. Remove any conversational intro that comes before the first headline.  Output only the text without introductory remarks.  TEXT:\n\n" > "$dest"

done
cd ..

cd audio-summary-text
for i in *.txt; do
	if [ -f ../audio-summary/${i%.txt}.mp3 ]; then
		echo "Audio summary for $i already exists, skipping."
		continue
	fi
	# (!) --file_prefix needs to be just ${i%.txt} without the .mp3 extension
	uvx --python=3.13 --with mlx-audio --with pip python -m mlx_audio.tts.generate --model mlx-community/Kokoro-82M-bf16 --lang_code a --join_audio --audio_format mp3 --file_prefix ../audio-summary/${i%.txt} --text "$(cat $i)"
done
cd ..