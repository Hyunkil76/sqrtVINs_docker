#!/bin/bash
set -euo pipefail

CONFIG=lamaria
BAG="/dataset/lamaria/add2"
RESULT_ROOT="/result"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARAM_FILE="${SCRIPT_DIR}/lamaria_params.txt"

# Common launch options
MAX_CAMERAS=1
USE_STEREO=false

# Load per-dataset params
declare -A BAG_START_MAP
declare -A HISTOGRAM_METHOD_MAP
declare -A INIT_DYN_USE_MAP

while IFS= read -r line || [[ -n "$line" ]]; do
    # Remove Windows carriage return if present
    line="${line%$'\r'}"

    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    IFS=':' read -r dataset bag_start histogram_method init_dyn_use <<< "$line"

    if [[ -z "${dataset:-}" || -z "${bag_start:-}" || -z "${histogram_method:-}" || -z "${init_dyn_use:-}" ]]; then
        echo "Error: invalid params line:"
        echo "$line"
        echo "Expected format: dataset_name:bag_start:histogram_method:init_dyn_use"
        exit 1
    fi

    BAG_START_MAP["$dataset"]="$bag_start"
    HISTOGRAM_METHOD_MAP["$dataset"]="$histogram_method"
    INIT_DYN_USE_MAP["$dataset"]="$init_dyn_use"
done < "$PARAM_FILE"

# Get bag files in order
mapfile -t BAG_FILES < <(ls "${BAG}"/*.bag | sort -V)

for BAG_FILE in "${BAG_FILES[@]}"; do
    # Dataset name without .bag
    DATASET=$(basename "$BAG_FILE" .bag)

    # Safety check: dataset must exist in params file
    if [[ -z "${BAG_START_MAP[$DATASET]+x}" ]]; then
        echo "Error: no BAG_START found for dataset: ${DATASET}"
        echo "Please add this line to ${PARAM_FILE}:"
        echo "${DATASET}:0.0:HISTOGRAM:false"
        exit 1
    fi

    BAG_START="${BAG_START_MAP[$DATASET]}"
    HISTOGRAM_METHOD="${HISTOGRAM_METHOD_MAP[$DATASET]}"
    INIT_DYN_USE="${INIT_DYN_USE_MAP[$DATASET]}"

    POSE_DIR="${RESULT_ROOT}/pose/lamaria/sqrtVINs_Mono/${DATASET}"
    TIME_DIR="${RESULT_ROOT}/time/lamaria/sqrtVINs_Mono/${DATASET}"

    PATH_EST="${POSE_DIR}/traj_estimate.txt"
    PATH_TIME="${TIME_DIR}/traj_timing.txt"

    # Skip if result already exists
    if [[ -s "$PATH_EST" && -s "$PATH_TIME" ]]; then
        echo "=========================================="
        echo "Skipping dataset: ${DATASET}"
        echo "Reason: result already exists"
        echo "Path est: ${PATH_EST}"
        echo "Path time: ${PATH_TIME}"
        echo "=========================================="
        continue
    fi

    mkdir -p "${POSE_DIR}"
    mkdir -p "${TIME_DIR}"

    echo "=========================================="
    echo "Running dataset: ${DATASET}"
    echo "Bag: ${BAG_FILE}"
    echo "Bag start: ${BAG_START}"
    echo "Histogram method: ${HISTOGRAM_METHOD}"
    echo "Init dyn use: ${INIT_DYN_USE}"
    echo "Pose dir: ${POSE_DIR}"
    echo "Time dir: ${TIME_DIR}"
    echo "=========================================="

    sleep 3.0

    roslaunch ov_srvins serial.launch \
        config:=${CONFIG} \
        bag:=${BAG_FILE} \
        path_est:=${PATH_EST} \
        path_time:=${PATH_TIME} \
        bag_start:=${BAG_START} \
        max_cameras:=${MAX_CAMERAS} \
        use_stereo:=${USE_STEREO} \
        histogram_method:=${HISTOGRAM_METHOD} \
        init_dyn_use:=${INIT_DYN_USE}
done