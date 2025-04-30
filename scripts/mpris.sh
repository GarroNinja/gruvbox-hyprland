#!/usr/bin/env bash

# Save the current player status
PLAYER_STATUS=$(playerctl status 2>/dev/null || echo "Stopped")

# Get player info
PLAYER_NAME=$(playerctl -l 2>/dev/null | head -n 1 || echo "")
TITLE=$(playerctl metadata title 2>/dev/null || echo "")
ARTIST=$(playerctl metadata artist 2>/dev/null || echo "")

# Create the output object
if [ "$PLAYER_STATUS" = "Playing" ]; then
  # Playing status
  echo '{"text": "'"$TITLE - $ARTIST"'", "class": "playing", "alt": "'"$PLAYER_NAME"'"}'
elif [ "$PLAYER_STATUS" = "Paused" ]; then
  # Paused status
  echo '{"text": "'"$TITLE - $ARTIST"'", "class": "paused", "alt": "'"$PLAYER_NAME"'"}'
else
  # No player or stopped
  echo '{"text": "", "class": "stopped"}'
fi
