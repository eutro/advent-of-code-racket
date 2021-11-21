#!/usr/bin/env sh

COOKIES=$(find "$HOME/.mozilla/firefox/$1" -name cookies.sqlite | head -1)
COOKIES_TMP=$(mktemp /tmp/XXXcookies.sqlite)
cp "$COOKIES" "$COOKIES_TMP"
sqlite3 "$COOKIES_TMP" 'SELECT value FROM moz_cookies WHERE host GLOB "*adventofcode.com" AND name = "session";'
rm "$COOKIES_TMP"
