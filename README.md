# SqrtVINS Docker Environment

This guide explains how to run the project using Docker Compose with GUI support and how to run sequence-based experiments inside a Docker container.

---
```text
## Recommended Folder Tree

sqrt_docker
├── docker_env
│   └── ...
├── result
│   └── ...
├── dataset
│   ├── euroc_mav
│   │   ├── V1_01_easy
│   │   ├── V1_02_medium
│   │   ├── ...
│   │   ├── MH_01_easy
│   │   └── ...
│   ├── uzhfpv
│   │   ├── indoor
│   │   │   └── ...
│   │   ├── indoor_45
│   │   │   └── ...
│   │   └── ...
...   ...   ...   ...
...   ...   ...   ...
│   └── aqualoc
│       ├── archaeo
│       │   └── ...
│       └── habor
│           └── ...
└── sqrt_ws
    └── ...
```
---

## Single Run

### 1. Build Docker Image

docker build -t sqrt_vins_20_04 .

### 2. Edit the .env File

Update all paths and dataset settings in the .env file to match your local system.

Example:

SQRT_WS_PATH=/your_folder/sqrt_ws
RESULT_PATH=/your_folder/result
DATASET_PATH=/your_dataset

### 3. Open a Terminal in This Folder

Move into the directory that contains docker-compose.yaml.

cd /path/to/sqrt_docker

### 4. Allow GUI Access

xhost +

### 5. Start the Containers

docker compose up

### 6. Stop the Containers

docker compose down

---

## Sequence Run

This mode is useful when running multiple datasets or scripts manually inside the container.

### 1. Create a New Container

docker run -it \
  --name sqrt_sequence \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /your_folder/sqrt_ws/src:/sqrt_ws/src \
  -v /your_folder/result:/result \
  -v /your_dataset:/dataset \
  --device /dev/dri \
  sqrt_vins_20_04:latest

Replace the following paths with your actual paths:

/your_folder/sqrt_ws/src
/your_folder/result
/your_dataset

### 2. Enter the Container and Build the Workspace

Open another terminal and enter the running container.

docker exec -it sqrt_sequence bash

Inside the container, run:

source /opt/ros/noetic/setup.bash
catkin build
source devel/setup.bash

### 3. Run the Script

Move to the script directory.

cd src/sqrtVINs/ov_srvins/scripts

Run your sequence script.

./your_script.sh

---

## Notes

Make sure GUI access is enabled before running containers.

xhost +

If the GUI does not open, check that the DISPLAY environment variable is correctly set.

echo $DISPLAY

Make sure the dataset path inside the container matches the paths used in your configuration files or scripts.

Results are expected to be saved under:

/result

Datasets are expected to be mounted under:

/dataset
