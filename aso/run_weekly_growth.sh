#!/bin/bash
# Weekly compliant growth monitor — meant to be invoked by launchd
# (com.manifestai.growth) or run manually. Compliant only: public/authorized
# APIs, no posting/reviews/metadata changes.
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
cd "/Users/yageloshri/ManifestAI-Gratitude-Journal/aso" || exit 1
mkdir -p reports logs
echo "=== run $(date) ===" >> logs/growth.log
python3 growth_monitor.py >> logs/growth.log 2>&1
echo "exit=$? at $(date)" >> logs/growth.log
