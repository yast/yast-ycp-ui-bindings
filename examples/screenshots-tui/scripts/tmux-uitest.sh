SESSION=uitest
: ${VERBOSE=false}

# $@ commands
tmux_new_session() {
    if $VERBOSE; then
        echo Starting session
    fi
    # -s session name
    # -x width -y height,
    # -d detached
    tmux new-session -s "$SESSION" -x 80 -y 24 -d "$@"
}

# $1 regex (POSIX ERE) to find in captured pane
tmux_await() {
    local REGEX="$1"

    local SLEEPS=(0.1 0.2 0.2 0.5 1 2 2 5)
    for S in "${SLEEPS[@]}"; do
        tmux capture-pane -t "$SESSION" -p | grep -E --quiet "$REGEX"
        RESULT=(${PIPESTATUS[@]})

        if [ ${RESULT[0]} != 0 ]; then
            # capturing the pane failed; the session may have exited already
            return 1
        fi
        if [ ${RESULT[1]} = 0 ]; then
            # found the expected REGEX
            return 0
        fi

        sleep "$S"
    done
    false
}

# $1
# $1.txt plain text
# $1.esc text with escape sequences for colors
tmux_capture_pane() {
    local OUT="$1"

    # -t target-pane, -p to stdout,
    # -e escape sequences for text and background attributes
    tmux capture-pane -t "$SESSION" -p -e > "$OUT.esc"
    tmux capture-pane -t "$SESSION" -p    > "$OUT.txt"
    # this is racy. if it is a problem we should make .txt from .esc
    # by filtering out the escape sequences
}

# $1 keys; see:
#   man tmux | less +/"^KEY BINDINGS"
tmux_send_keys() {
    if $VERBOSE; then
        echo Sending "$1"
    fi
    # -t target-pane
    tmux send-keys -t "$SESSION" "$1"
}

# $1 session name
# ret code: true or false
tmux_has_session() {
    if $VERBOSE; then
        echo Detecting the session
    fi
    # -t target-session
    tmux has-session -t "$SESSION"
}


# $1 session name
tmux_kill_session() {
    if $VERBOSE; then
        echo Killing the session
    fi
    # -t target-session
    tmux kill-session -t "$SESSION"
}

function dump_screen()
{
  echo "----------------------- Screen Dump Begin -----------------------------"
  if [ "$TRAVIS" == "1" ]; then
    # the sed call transforms spaces to non-breakable spaces because
    # Travis does not display a normal space sequence correctly
    tmux capture-pane -p -t "$1" | sed $'s/ /\u00a0/g'
  else
      # -t target-pane, -p to stdout,
      # -e escape sequences for text and background attributes
    tmux capture-pane -p -t "$1" | tee dump-p$COUNTER
  fi
  echo "----------------------- Screen Dump End -------------------------------"
}

function expect_text()
{
  if tmux capture-pane -p -t "$1" | grep -q "$2"; then
    echo "Matched expected text: '$2'"
  else
    echo "ERROR: No match for expected text '$2'"
    kill_session "$SESSION"
    exit 1
  fi
}

function not_expect_text()
{
  if tmux capture-pane -p -t "$1" | grep -q "$2"; then
    echo "ERROR: Matched unexpected text: '$2'"
    kill_session "$SESSION"
    exit 1
  fi
}

function send_keys()
{
  echo "Sending keys: $2"
  # -t target-pane
  tmux send-keys -t "$1" "$2"
}

function process_exited()
{
  # -t target-session
  if tmux has-session "$1" 2> /dev/null; then
    echo "ERROR: The process is still running!"
    exit 1
  else
    echo "The process exited, OK"
  fi
}

