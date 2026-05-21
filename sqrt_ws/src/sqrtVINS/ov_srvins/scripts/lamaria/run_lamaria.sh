#!/bin/bash
set -euo pipefail

echo "Easy start"
bash ./lamaria_easy.sh

sleep 1.0

echo "Medium start"
bash ./lamaria_medium.sh

sleep 1.0

echo "Hard start"
bash ./lamaria_hard.sh

sleep 1.0

echo "CP start"
bash ./lamaria_cp.sh

sleep 1.0

echo "Additional start"
bash ./lamaria_sequence_1.sh
bash ./lamaria_sequence.sh