#!/bin/bash
set -euo pipefail

echo "archaeo start"
bash ./aqualoc_archaeo.sh

sleep 1.0

echo "harbor start"
bash ./aqualoc_harbor.sh