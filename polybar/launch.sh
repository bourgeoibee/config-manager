#!/bin/bash

# Terminate running bar instances
killall -q polybar

# Launch Polybar
polybar $1 | tee -a /tmp/polybar.log & disown

echo "Polybar Launched..."
