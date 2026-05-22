#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Indoor Front start"
bash "${SCRIPT_DIR}/indoor_front.sh"

sleep 1.0

echo "Indoor 45 start"
bash "${SCRIPT_DIR}/indoor_45.sh"

sleep 1.0

echo "Outdoor Front start"
bash "${SCRIPT_DIR}/outdoor_front.sh"

sleep 1.0

echo "Outdoor 45 start"
bash "${SCRIPT_DIR}/outdoor_45.sh"