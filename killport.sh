#!/bin/bash

# Check if port number is provided as input
if [[ $# -eq 0 ]]; then
  echo "Please provide the port number as input."
  exit 1
fi

# Get the process ID (PID) of the service running on the specified port
pid=$(lsof -t -i:$1)

# If PID exists, kill the service
if [[ -n $pid ]]; then
  echo "Killing service with PID $pid on port $1..."
  kill $pid
  echo "Service killed successfully!"
else
  echo "No service found running on port $1."
fi

# Force quit the service running on the specified port
echo "Force quitting service on port $1..."
sudo lsof -t -i:$1 | xargs kill -9
echo "Service force quit successfully!"
