#!/bin/bash
echo "Starting Utility Switcher Backend..."
cd /home/dsights/project/savenest/utility-portal/backend
npm run dev > /home/dsights/project/savenest/logs/backend.log 2>&1 &
BACKEND_PID=$!

echo "Starting Utility Switcher Frontend..."
cd /home/dsights/project/savenest/utility-portal/frontend
npm run dev > /home/dsights/project/savenest/logs/frontend.log 2>&1 &
FRONTEND_PID=$!

echo "======================================================="
echo "Both systems are starting up!"
echo "Backend running on port 5000 (PID: $BACKEND_PID)"
echo "Frontend running on port 5173 (PID: $FRONTEND_PID)"
echo ""
echo "Please open your browser and go to:"
echo "http://localhost:5173"
echo "======================================================="
echo "To stop the servers later, run: kill $BACKEND_PID $FRONTEND_PID"
