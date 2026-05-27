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
│   |-- aqualoc
│   |   |-- archaeo
│   |   |   |-- archaeo_sequence_1.bag
│   |   |   |...
│   |   |   `-- archaeo_sequence_10.bag
│   |   └── harbor
│   |       |-- harbor_sequence_1.bag
│   |       |-- ...
│   |       `-- harbor_sequence_7.bag
│   |-- euroc_mav
│   |   |-- MH_01_easy.bag
│   |   |-- ...
│   |   └── V2_03_difficult.bag
│   |-- grand_tour
│   |   |-- 2024-10-01-11-29-55.bag
│   |   |-- ...
│   |   └── 2024-12-09-11-28-28.bag
│   |-- grand_tour_compressed
│   |   |-- 2024-10-01-11-29-55.bag
│   |   |-- ...
│   |   └── 2024-12-09-11-28-28.bag
│   |-- lamaria
│   |   |-- add1
│   |   |   |-- sequence_1_19.bag
│   |   |   └── sequence_1_20.bag
│   |   |-- add2
│   |   |   |-- sequence_2_11.bag
│   |   |   |-- ...
│   |   |   └── sequence_5_12.bag
│   |   |-- cp
│   |   |   |-- R_11_5cp.bag
│   |   |   |-- R_12_10cp.bag
│   |   |   └── R_13_15cp.bag
│   |   |-- easy
│   |   |   |-- R_01_easy.bag
│   |   |   |-- R_02_easy.bag
│   |   |   └── R_03_easy.bag
│   |   |-- hard
│   |   |   |-- R_08_hard.bag
│   |   |   |-- R_09_hard.bag
│   |   |   └── R_10_hard.bag
│   |   └── medium
│   |       |-- R_04_medium.bag
│   |       |-- ...
│   |       └── R_07_medium.bag
│   └── uzh_fpv
│       |-- uzhfpv_indoor
│       |   |-- indoor_forward_10_snapdragon_with_gt.bag
│       |   |-- ...
│       |   └── indoor_forward_9_snapdragon_with_gt.bag
│       |-- uzhfpv_indoor_45
│       |   |-- indoor_45_12_snapdragon_with_gt.bag
│       |   |-- ...
│       |   └── indoor_45_4_snapdragon_with_gt.bag
│       |-- uzhfpv_outdoor
│       |   |-- outdoor_forward_1_snapdragon_with_gt.bag
│       |   |-- outdoor_forward_3_snapdragon_with_gt.bag
│       |   └── outdoor_forward_5_snapdragon_with_gt.bag
│       └── uzhfpv_outdoor_45
│           └── outdoor_45_1_snapdragon_with_gt.bag
└── sqrt_ws
    └── ...
```


---

## Single Run

Use this mode when you want to run the Docker setup directly through `docker compose`.

### 1. Build the Docker Image

From the directory containing the `Dockerfile`, run:

```bash
docker build -t sqrt_vins_20_04 .
```

### 2. Configure the `.env` File

Edit the `.env` file and update all paths and dataset settings to match your local system.

Example:

```bash
SQRT_WS_PATH=/your_folder/sqrt_ws
RESULT_PATH=/your_folder/result
DATASET_PATH=/your_dataset
```

### 3. Move to the Docker Compose Directory

Open a terminal and move into the directory that contains `docker-compose.yaml`:

```bash
cd /path/to/sqrt_docker
```

### 4. Allow GUI Access

Run:

```bash
xhost +
```

### 5. Start the Containers

Run:

```bash
docker compose up
```

### 6. Stop the Containers

To stop the running containers, use:

```bash
docker compose stop
```

---

## Sequence Run

Use this mode when you want to manually run multiple datasets or scripts inside the container.

### 1. Create a New Container

Run the following command:

```bash
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
```

Replace these paths with your actual local paths:

```bash
/your_folder/sqrt_ws/src
/your_folder/result
/your_dataset
```

Inside the container, these paths will be available as:

```bash
/sqrt_ws/src
/result
/dataset
```

### 2. Enter the Running Container

Open another terminal and enter the container:

```bash
docker exec -it sqrt_sequence bash
```

### 3. Build the Workspace

Inside the container, run:

```bash
source /opt/ros/noetic/setup.bash
catkin build
source devel/setup.bash
```

### 4. Run a Sequence Script

Move to the script directory:

```bash
cd src/sqrtVINs/ov_srvins/scripts
```

Run your sequence script:

```bash
./your_script.sh
```

Replace `your_script.sh` with the script you want to run.

---

## Notes

GUI access must be enabled before starting containers:

```bash
xhost +
```

If the GUI does not open, check that the `DISPLAY` variable is set correctly:

```bash
echo $DISPLAY
```

Make sure the dataset path inside the container matches the paths used in your configuration files or scripts.

Results are expected to be saved under:

```bash
/result
```

Datasets are expected to be mounted under:

```bash
/dataset
```