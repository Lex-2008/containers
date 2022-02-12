#!/bin/sh
# based on https://stackoverflow.com/questions/51150505/bash-country-code-to-emoji

read -r co

CHAR_TO_INT_1=$(printf '%d' "'${co::1}")
NEW_CHAR_CODE_1=$(($CHAR_TO_INT_1 + 101))

CHAR_TO_INT_2=$(printf '%d' "'${co:1:1}")
NEW_CHAR_CODE_2=$(($CHAR_TO_INT_2 + 101))

# for advanced printf, with vanilla NEW_CHAR_CODE_
# EMOJI_UC="$(printf '\\U%08x\\U%08x' $NEW_CHAR_CODE_1 $NEW_CHAR_CODE_2)"

EMOJI_UC='\xf0\x9f\x87\x'$(printf '%x' "$NEW_CHAR_CODE_1")'\xf0\x9f\x87\x'$(printf '%x' "$NEW_CHAR_CODE_2")

printf "$EMOJI_UC"

