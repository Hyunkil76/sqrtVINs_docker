#!/bin/bash
set -euo pipefail

echo "Indoor Front start"
bash ./indoor_front_stereo.sh

sleep 1.0

echo "Indoor 45 start"
bash ./indoor_45_stereo.sh

sleep 1.0

echo "Outdoor Front start"
bash ./outdoor_front_stereo.sh

sleep 1.0

echo "Outdoor 45 start"
bash ./outdoor_45_stereo.sh