#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Indoor Front start"
bash "${SCRIPT_DIR}/indoor_front_stereo.sh"

sleep 1.0

echo "Indoor 45 start"
bash "${SCRIPT_DIR}/indoor_45_stereo.sh"

sleep 1.0

echo "Outdoor Front start"
bash "${SCRIPT_DIR}/outdoor_front_stereo.sh"

sleep 1.0

echo "Outdoor 45 start"
bash "${SCRIPT_DIR}/outdoor_45_stereo.sh"