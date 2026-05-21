#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "archaeo start"
bash "${SCRIPT_DIR}/aqualoc_archaeo.sh"

sleep 1.0

echo "harbor start"
bash "${SCRIPT_DIR}/aqualoc_harbor.sh"