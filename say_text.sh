#!/bin/bash

# This script uses Elsabot TTS.  It depends on the
# jp_docker image and run_stt_tts.sh of the jetson_support
# package of Elsabot.

JSON_FMT='{"text":"%s"}'
cmd=$(printf "$JSON_FMT" "$1")
echo "TTS cmd: $cmd"

curl -X POST http://localhost:5000 \
    -H "Content-Type: application/json" \
    -d "$cmd" -o tmp_tts.wav && paplay tmp_tts.wav
