#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Easy start"
bash "${SCRIPT_DIR}/lamaria_easy.sh"

sleep 1.0

echo "Medium start"
bash "${SCRIPT_DIR}/lamaria_medium.sh"

sleep 1.0

echo "Hard start"
bash "${SCRIPT_DIR}/lamaria_hard.sh"

sleep 1.0

echo "CP start"
bash "${SCRIPT_DIR}/lamaria_cp.sh"

sleep 1.0

echo "Additional start"
bash "${SCRIPT_DIR}/lamaria_sequence_1.sh"
bash "${SCRIPT_DIR}/lamaria_sequence.sh"