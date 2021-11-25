#!/bin/sh
rm wordshk-installer.dmg && rm rw.wordshk-installer.dmg

create-dmg \
  --volname "words.hk installer" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "wordshk.app" 180 160 \
  --hide-extension "wordshk.app" \
  --app-drop-link 600 160 \
  "wordshk-installer.dmg" \
  "build/macos/Build/Products/Release/"
