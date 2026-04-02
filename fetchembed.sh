#!/bin/bash

MUSIC="$(dirname "$(realpath "$0")")"
SUCCESS=0
FAIL=0
SKIPPED=0
FALLBACK=0

while IFS= read -r audio; do
  base="${audio%.*}"
  lrc="${base}.lrc"
  title=$(kid3-cli -c "get TITLE" "$audio" 2>/dev/null)
  artist=$(kid3-cli -c "get ARTIST" "$audio" 2>/dev/null)

  # Skip if .lrc already exists
  if [ -f "$lrc" ]; then
    echo "⏭ SKIPPED (already has .lrc): $(basename $audio)"
    ((SKIPPED++))
    continue
  fi

  # Skip if no title or artist tag
  if [ -z "$title" ] || [ -z "$artist" ]; then
    echo "✗ NO TAGS: $(basename $audio)"
    ((FAIL++))
    continue
  fi

  # Try synced lyrics first
  if syncedlyrics "$artist - $title" --synced-only -o "$lrc" 2>/dev/null; then
    echo "✓ SYNCED: $(basename $audio)"
  # Fall back to plain lyrics
  elif syncedlyrics "$artist - $title" -o "$lrc" 2>/dev/null; then
    echo "↓ FALLBACK (plain lyrics): $(basename $audio)"
    ((FALLBACK++))
  else
    echo "✗ NOT FOUND: $(basename $audio)"
    ((FAIL++))
    continue
  fi

  # Embed into audio file
  lyrics=$(cat "$lrc")
  if kid3-cli -c "set LYRICS \"$lyrics\"" "$audio" 2>/dev/null; then
    ((SUCCESS++))
  else
    echo "✗ EMBED FAILED: $(basename $audio)"
    ((FAIL++))
  fi

done < <(find "$MUSIC" \( -name "*.mp3" -o -name "*.flac" \) )

echo ""
echo "Done!"
echo "✓ Embedded: $SUCCESS"
echo "↓ Fallback plain lyrics: $FALLBACK"
echo "⏭ Skipped: $SKIPPED"
echo "✗ Failed/Not found: $FAIL"
