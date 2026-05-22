#!/bin/bash
set -euo pipefail

DATASET_DIR="/dataset/resource"
RESULT_ROOT="/result/benchmark"
SUPPORT_STEREO=true
SUPPORT_MONO=true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$DATASET_DIR" ]; then
    echo "Error: Dataset directory $DATASET_DIR does not exist."
    exit 1
fi

mkdir -p "$RESULT_ROOT"

files=("$DATASET_DIR"/*.bag)
total_runs=0
if [ "$SUPPORT_STEREO" = true ]; then
    total_runs=3
fi
if [ "$SUPPORT_MONO" = true ]; then
    total_runs=$((total_runs + 5))
fi
current=0

# Check if there are actually files to process
if [ "$total_runs" -eq 0 ]; then
    echo "No .bag files found in $DATASET_DIR"
    exit 0
fi

# Function to draw the progress bar
# Usage: draw_progress_bar <current> <total> <text>
draw_progress_bar() {
    local _current=$1
    local _total=$2
    local _text=$3
    
    # Calculate percentage
    local _percent=$((100 * _current / _total))
    # Define bar width (e.g., 20 chars)
    local _width=20
    local _filled=$((_width * _percent / 100))
    local _empty=$((_width - _filled))
    
    # Create the bar string (e.g., "#####")
    local _bar=$(printf "%${_filled}s" | tr ' ' '#')
    local _spaces=$(printf "%${_empty}s" | tr ' ' '.')
    
    # Print the bar using \r to overwrite the line
    # \r returns cursor to start of line, allowing animation
    printf "\r[%s%s] %d%% (%d/%d) %s\033[K" "$_bar" "$_spaces" "$_percent" "$_current" "$_total" "$_text"
}
# ==========================================

echo "Starting batch processing for $total_runs datasets..."


modes=()
if [ "$SUPPORT_STEREO" = true ]; then
    modes+=("stereo")
fi

if [ "$SUPPORT_MONO" = true ]; then
    modes+=("mono")
fi


# 4. Loop through all .bag files
for mode in "${modes[@]}"; do
    for BAG_FILE in "${files[@]}"; do
        # Dataset name without .bag
        DATASET=$(basename "$BAG_FILE" .bag)

        if [ "$mode" == "stereo" ]; then
            if [[ "$DATASET" == "harbor_sequence_6" ]] || [[ "$DATASET" == "R_02_easy" ]]; then
                continue
            fi
        fi


        POSE_DIR="${RESULT_ROOT}/pose/sqrtVINs_${mode}/${DATASET}"
        TIME_DIR="${RESULT_ROOT}/time/sqrtVINs_${mode}/${DATASET}"
        RESOURCE_DIR="${RESULT_ROOT}/resource/sqrtVINs_${mode}/${DATASET}"

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
            current=$((current + 1))
            continue
        fi

        mkdir -p "${POSE_DIR}"
        mkdir -p "${TIME_DIR}"
        mkdir -p "${RESOURCE_DIR}"

        if [ "$DATASET" == "V1_01_easy" ]; then
            if [ "$mode" == "stereo" ]; then
                CONFIG=euroc_mav
                BAG_START=0
                MAX_CAMERAS=2
                USE_STEREO=true
                HISTOGRAM_METHOD=HISTOGRAM
                INIT_DYN_USE=false
            else
                CONFIG=euroc_mav
                BAG_START=0
                MAX_CAMERAS=1
                USE_STEREO=false
                HISTOGRAM_METHOD=HISTOGRAM
                INIT_DYN_USE=false
            fi
        elif [ "$DATASET" == "indoor_45_12_snapdragon_with_gt" ]; then
            if [ "$mode" == "stereo" ]; then
                CONFIG=uzhfpv_indoor_45
                BAG_START=0
                MAX_CAMERAS=2
                USE_STEREO=true
                HISTOGRAM_METHOD=HISTOGRAM
                INIT_DYN_USE=false
            else
                CONFIG=uzhfpv_indoor_45
                BAG_START=0
                MAX_CAMERAS=1
                USE_STEREO=false
                HISTOGRAM_METHOD=HISTOGRAM
                INIT_DYN_USE=false
            fi
        elif [ "$DATASET" == "R_02_easy" ]; then
            CONFIG=lamaria
            BAG_START=0
            MAX_CAMERAS=1
            USE_STEREO=false
            HISTOGRAM_METHOD=HISTOGRAM
            INIT_DYN_USE=true
        elif [ "$DATASET" == "2024-11-15-11-37-15" ]; then
            if [ "$mode" == "stereo" ]; then
                CONFIG=grand_tour_stereo
                BAG_START=0
                MAX_CAMERAS=2
                USE_STEREO=true
                HISTOGRAM_METHOD=HISTOGRAM
                INIT_DYN_USE=false
            else
                CONFIG=grand_tour
                BAG_START=0
                MAX_CAMERAS=1
                USE_STEREO=false
                HISTOGRAM_METHOD=HISTOGRAM
                INIT_DYN_USE=false
            fi
        elif [ "$DATASET" == "harbor_sequence_6" ]; then
            CONFIG=aqualoc_harbor
            BAG_START=0
            MAX_CAMERAS=1
            USE_STEREO=false
            HISTOGRAM_METHOD=CLAHE
            INIT_DYN_USE=true
        fi

        draw_progress_bar "$current" "$total_runs" "-> Processing: $DATASET"
        python3 "$SCRIPT_DIR/monitor_cpu_only.py" --output "$RESOURCE_DIR/monitor_cpu_only.csv" --interval 0.2 & MONITOR_PID=$!

                
        roslaunch ov_srvins serial.launch \
            config:="${CONFIG}" \
            bag:="${BAG_FILE}" \
            path_est:="${PATH_EST}" \
            path_time:="${PATH_TIME}" \
            bag_start:="${BAG_START}" \
            max_cameras:="${MAX_CAMERAS}" \
            use_stereo:="${USE_STEREO}" \
            histogram_method:="${HISTOGRAM_METHOD}" \
            init_dyn_use:="${INIT_DYN_USE}" &> /dev/null &

        ROSLAUNCH_PID=$!

        wait "$ROSLAUNCH_PID"

        if kill -0 "$MONITOR_PID" 2>/dev/null; then
            kill "$MONITOR_PID" 2>/dev/null || true
            wait "$MONITOR_PID" 2>/dev/null || true
        fi

        sleep 1

        current=$((current + 1))
    done
done

# Final update to show 100%
draw_progress_bar "$current" "$total_runs" "Done!"
echo "" # New line at the end
echo "All datasets have been processed!"