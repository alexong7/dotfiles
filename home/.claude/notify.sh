#!/bin/bash
# Claude Code notification hook script
# Shows a notification with repo and iTerm tab context, focuses the correct tab on click.

# Read the JSON payload from stdin
INPUT=$(cat)

# Parse fields from JSON
MESSAGE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message','Needs attention'))" 2>/dev/null)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)

# Extract just the UUID from ITERM_SESSION_ID (strip "w0t0p0:" prefix)
ITERM_SID="${ITERM_SESSION_ID##*:}"
ITERM_SID="${ITERM_SID:-unknown}"
DIR_NAME=$(basename "${CWD:-$PWD}")

# Get the iTerm tab title for this session
ITERM_TAB_NAME=$(osascript -e '
tell application "iTerm2"
    repeat with w in windows
        tell w
            repeat with t in tabs
                tell t
                    repeat with s in sessions
                        tell s
                            if unique ID is equal to "'"${ITERM_SID}"'" then
                                return variable named "tab.title"
                            end if
                        end tell
                    end repeat
                end tell
            end repeat
        end tell
    end repeat
end tell
' 2>/dev/null)

# Build the subtitle: "repo - iTerm tab name"
if [ -n "$ITERM_TAB_NAME" ]; then
    SUBTITLE="${DIR_NAME} - ${ITERM_TAB_NAME}"
else
    SUBTITLE="$DIR_NAME"
fi

# Write a focus script that selects the correct iTerm tab on click
FOCUS_SCRIPT=$(mktemp /tmp/claude_focus_XXXXXXXX)
cat > "$FOCUS_SCRIPT" << INNEREOF
#!/bin/bash
osascript -e '
tell application "iTerm2"
    activate
    repeat with w in windows
        tell w
            repeat with t in tabs
                tell t
                    repeat with s in sessions
                        tell s
                            if unique ID is equal to "${ITERM_SID}" then
                                select t
                                return
                            end if
                        end tell
                    end repeat
                end tell
            end repeat
        end tell
    end repeat
end tell
'
INNEREOF
chmod +x "$FOCUS_SCRIPT"

# Remove any previous notification so the new one always shows as a fresh banner
terminal-notifier -remove "claude-${ITERM_SID}" 2>/dev/null

# Send the notification
terminal-notifier \
    -title "Claude Code" \
    -subtitle "$SUBTITLE" \
    -message "$MESSAGE" \
    -sound Submarine \
    -execute "$FOCUS_SCRIPT" \
    -group "claude-${ITERM_SID}" 2>/dev/null

# Clean up old focus scripts
find /tmp -name "claude_focus_*" -mmin +5 -delete 2>/dev/null
