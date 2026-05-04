#!/bin/bash

CONFIG=grand_tour
BAG="/dataset/grand_tour/group_4"
RESULT_ROOT="/result/mono"

# Common launch options
MAX_CAMERAS=1
USE_STEREO=false
BAG_STARTS=(0.0 0.0 0.0 0.0 0.0) 

# Per-dataset options
HISTOGRAM_METHODS=(CLAHE HISTOGRAM HISTOGRAM HISTOGRAM CLAHE)  # [HISTOGRAM or CLAHE]
INIT_DYN_USES=(false true false false false)

# Get bag files in order
BAG_FILES=($(ls ${BAG}/*.bag | sort -V))

# Safety check
if [ ${#BAG_FILES[@]} -ne ${#HISTOGRAM_METHODS[@]} ]; then
    echo "Error: number of bag files and HISTOGRAM_METHODS does not match"
    echo "bags: ${#BAG_FILES[@]}, histogram_methods: ${#HISTOGRAM_METHODS[@]}"
    exit 1
fi

if [ ${#BAG_FILES[@]} -ne ${#INIT_DYN_USES[@]} ]; then
    echo "Error: number of bag files and INIT_DYN_USES does not match"
    echo "bags: ${#BAG_FILES[@]}, init_dyn_uses: ${#INIT_DYN_USES[@]}"
    exit 1
fi

if [ ${#BAG_FILES[@]} -ne ${#BAG_STARTS[@]} ]; then
    echo "Error: number of bag files and BAG_STARTS does not match"
    echo "bags: ${#BAG_FILES[@]}, bag_starts: ${#BAG_STARTS[@]}"
    exit 1
fi

for i in "${!BAG_FILES[@]}"; do
    BAG_FILE="${BAG_FILES[$i]}"
    BAG_START="${BAG_STARTS[$i]}"

    # Dataset name without .bag
    DATASET=$(basename "$BAG_FILE" .bag)

    HISTOGRAM_METHOD="${HISTOGRAM_METHODS[$i]}"
    INIT_DYN_USE="${INIT_DYN_USES[$i]}"
    

    RESULT_DIR="${RESULT_ROOT}/${CONFIG}/${DATASET}"
    mkdir -p "${RESULT_DIR}"

    echo "=========================================="
    echo "Running dataset: ${DATASET}"
    echo "Bag: ${BAG_FILE}"
    echo "Histogram method: ${HISTOGRAM_METHOD}"
    echo "Init dyn use: ${INIT_DYN_USE}"
    echo "Result dir: ${RESULT_DIR}"
    echo "=========================================="

    sleep 1.0

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