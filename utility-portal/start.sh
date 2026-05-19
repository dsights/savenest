#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOG_DIR="$DIR/../logs"
mkdir -p "$LOG_DIR"

if (echo > /dev/tcp/localhost/5000) >/dev/null 2>&1; then
    echo "Utility Switcher Backend is already running on port 5000."
else
    echo "Starting Utility Switcher Backend..."
    cd "$DIR/backend"
    nohup npm run dev < /dev/null > "$LOG_DIR/backend.log" 2>&1 &
    BACKEND_PID=$!
fi

if (echo > /dev/tcp/localhost/5173) >/dev/null 2>&1; then
    echo "Utility Switcher Frontend is already running on port 5173."
else
    echo "Starting Utility Switcher Frontend..."
    cd "$DIR/frontend"
    nohup npm run dev < /dev/null > "$LOG_DIR/frontend.log" 2>&1 &
    FRONTEND_PID=$!
fi

echo "======================================================="
echo "Systems check complete!"
echo "Please open your browser and go to:"
echo "http://localhost:5173"
echo "======================================================="
