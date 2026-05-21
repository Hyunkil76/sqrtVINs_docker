#!/bin/bash

CONFIG=aqualoc_harbor
BAG="/dataset/aqualoc/harbor"
RESULT_ROOT="/result"

# Common launch options
MAX_CAMERAS=1
USE_STEREO=false
BAG_START=0.0

# Per-dataset options
HISTOGRAM_METHOD=CLAHE
INIT_DYN_USE=true

# Get bag files in order
BAG_FILES=($(ls ${BAG}/*.bag | sort -V))

for i in "${!BAG_FILES[@]}"; do
    BAG_FILE="${BAG_FILES[$i]}"

    # Dataset name without .bag
    DATASET=$(basename "$BAG_FILE" .bag)

    POSE_DIR="${RESULT_ROOT}/pose/sqrtVINs_Mono/${DATASET}"
    TIME_DIR="${RESULT_ROOT}/time/sqrtVINs_Mono/${DATASET}"

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
    echo "Histogram method: ${HISTOGRAM_METHOD}"
    echo "Init dyn use: ${INIT_DYN_USE}"
    echo "Result dir: ${RESULT_DIR}"
    echo "=========================================="

    sleep 3.0

    roslaunch ov_srvins serial.launch \
        config:=${CONFIG} \
        bag:=${BAG_FILE} \
        path_est:=${RESULT_DIR}/traj_estimate.txt \
        path_time:=${RESULT_DIR}/traj_timing.txt \
        bag_start:=${BAG_START} \
        max_cameras:=${MAX_CAMERAS} \
        use_stereo:=${USE_STEREO} \
        histogram_method:=${HISTOGRAM_METHOD} \
        init_dyn_use:=${INIT_DYN_USE}

done