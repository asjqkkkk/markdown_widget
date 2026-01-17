#!/bin/bash
# Sync README files to demo assets
# This script copies the README files from the root directory to the demo assets

echo "Syncing README files to demo assets..."
dart run example/build_script/sync_readme_to_demo.dart
