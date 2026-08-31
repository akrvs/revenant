#!/bin/bash
# Set RGB to Unified Static White

# Device 0: GPU (Sapphire) - Static White (Clean & Professional)
openrgb -d 0 -m "Static" -c FFFFFF

# Device 1: Motherboard (Gigabyte) - Static White on ALL zones
# This will help you locate the lights!
openrgb -d 1 -z 0 -m "Static" -c FFFFFF
openrgb -d 1 -z 1 -m "Static" -c FFFFFF
openrgb -d 1 -z 2 -m "Static" -c FFFFFF
openrgb -d 1 -z 3 -m "Static" -c FFFFFF
