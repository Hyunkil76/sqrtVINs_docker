# sqrtVINS

This guide explains how to run [sqrtVINS](https://github.com/rpng/sqrtVINS) with Docker Compose and GUI support. It also describes how to run sequence-based experiments manually inside a Docker container and evaluate the resulting trajectories with [EPICA](https://pypi.org/project/epica/).

This repository is based on [rpng/sqrtVINS](https://github.com/rpng/sqrtVINS) at commit:

`30fafc89d89cfb896d06fdaa68fbda8545e02e9f`

---

## Recommended Directory Structure

```text
sqrt_VINS/
└── docker_env/
    └── ...
    ...

dataset/
├── aqualoc/
│   ├── archaeo/
│   │   ├── archaeo_sequence_1.bag
│   │   ├── ...
│   │   └── archaeo_sequence_10.bag
│   └── harbor/
│       ├── harbor_sequence_1.bag
│       ├── ...
│       └── harbor_sequence_7.bag
├── euroc_mav/
│   ├── MH_01_easy.bag
│   ├── ...
│   └── V2_03_difficult.bag
├── grand_tour/
│   ├── 2024-10-01-11-29-55.bag
│   ├── ...
│   └── 2024-12-09-11-28-28.bag
├── grand_tour_compressed/
│   ├── 2024-10-01-11-29-55.bag
│   ├── ...
│   └── 2024-12-09-11-28-28.bag
├── lamaria/
│   ├── add1/
│   │   ├── sequence_1_19.bag
│   │   └── sequence_1_20.bag
│   ├── add2/
│   │   ├── sequence_2_11.bag
│   │   ├── ...
│   │   └── sequence_5_12.bag
│   ├── cp/
│   │   ├── R_11_5cp.bag
│   │   ├── R_12_10cp.bag
│   │   └── R_13_15cp.bag
│   ├── easy/
│   │   ├── R_01_easy.bag
│   │   ├── R_02_easy.bag
│   │   └── R_03_easy.bag
│   ├── hard/
│   │   ├── R_08_hard.bag
│   │   ├── R_09_hard.bag
│   │   └── R_10_hard.bag
│   └── medium/
│       ├── R_04_medium.bag
│       ├── ...
│       └── R_07_medium.bag
└── uzhfpv/
    ├── uzhfpv_indoor/
    │   ├── indoor_forward_10_snapdragon_with_gt.bag
    │   ├── ...
    │   └── indoor_forward_9_snapdragon_with_gt.bag
    ├── uzhfpv_indoor_45/
    │   ├── indoor_45_12_snapdragon_with_gt.bag
    │   ├── ...
    │   └── indoor_45_4_snapdragon_with_gt.bag
    ├── uzhfpv_outdoor/
    │   ├── outdoor_forward_1_snapdragon_with_gt.bag
    │   ├── outdoor_forward_3_snapdragon_with_gt.bag
    │   └── outdoor_forward_5_snapdragon_with_gt.bag
    └── uzhfpv_outdoor_45/
        └── outdoor_45_1_snapdragon_with_gt.bag

result/
└── ...
```


---

## Single Run with Docker Compose

Use this method to build and run the project through Docker Compose.

### 1. Build the Docker Image

Move to the directory containing the `Dockerfile`:

```bash
cd /path/to/sqrt_VINS
```

Build the image:

```bash
docker build -f docker_env/Dockerfile -t sqrt_vins_20_04:latest .
```

### 2. Configure the Environment File

Open the `.env` file used by `docker-compose.yaml` and update the paths to match your system.

Use absolute paths:

```dotenv
RESULT_PATH=/absolute/path/to/sqrt_docker/result
DATASET_PATH=/absolute/path/to/sqrt_docker/dataset
```

### 3. Move to the Docker Compose Directory

```bash
cd /path/to/sqrt_VINS/docker_env
```

This directory should contain the following file:

```text
docker-compose.yaml
```

### 4. Allow GUI Access

Allow Docker containers to connect to the host X server:

```bash
xhost +
```

> **Warning:** `xhost +` disables X server access control. Use it only on a trusted machine.

### 5. Start the Containers

```bash
docker compose up
```

### 6. Stop the Containers

Stop the containers without removing them:

```bash
docker compose stop
```

Stop and remove the containers and Docker Compose network:

```bash
docker compose down
```

Restore X server access control after finishing:

```bash
xhost -
```

---

## Sequence Run

Use this method to create a persistent container and manually run sequence scripts.

### 1. Create the Container

```bash
docker run -it \
  --name sqrt_sequence \
  -e DISPLAY="$DISPLAY" \
  -e QT_X11_NO_MITSHM=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /absolute/path/to/sqrt_docker/result:/result \
  -v /absolute/path/to/sqrt_docker/dataset:/dataset \
  --device /dev/dri:/dev/dri \
  sqrt_vins_20_04:latest \
  bash
```

Replace the following host paths with the corresponding absolute paths on your system:

```text
/absolute/path/to/sqrt_docker/result
/absolute/path/to/sqrt_docker/dataset
```

The directories are mounted inside the container as follows:

| Host directory | Container directory |
| --- | --- |
| `result` | `/result` |
| `dataset` | `/dataset` |

### 2. Enter the Container

```bash
docker exec -it sqrt_sequence bash
```

### 3. Run a Sequence Script

Move to the script directory:

```bash
cd /sqrt_ws/src/sqrtVINS/ov_srvins/scripts
```

Run the desired script:

```bash
./your_script.sh
```

Replace `your_script.sh` with the name of the sequence script you want to run.

### 4. Re-enter an Existing Container

If the container has stopped, restart it:

```bash
docker start sqrt_sequence
```

Then enter it again:

```bash
docker exec -it sqrt_sequence bash
```

---

## Result Evaluation with EPICA

[EPICA](https://pypi.org/project/epica/) provides tools for trajectory alignment and evaluation.

### 1. Install EPICA

```bash
python -m pip install epica
```

### 2. Evaluate a Single Trajectory

Provide a ground-truth trajectory and an estimated trajectory:

```bash
epa <gt_file> <est_file>
```

Example:

```bash
epa ./example_data/example_groundtruth.csv ./example_data/example_estimation.txt
```

### 3. Run OpenVINS-Compatible Evaluation

```bash
python -m epa.ov_eval_compat error_comparison se3 \
  /path/to/gt_folder \
  /path/to/algorithms
```

Replace the following paths:

- `/path/to/gt_folder`: directory containing the ground-truth trajectories
- `/path/to/algorithms`: directory containing the estimated trajectories for one or more algorithms

<details>
<summary>Example folder layout</summary>

```text
gt_folder/
└── euroc_mav/
    ├── MH_01_easy.txt
    ├── MH_02_easy.txt
    └── MH_03_medium.txt

algorithms/
└── sqrtVINS/
    ├── MH_01_easy/
    │   └── traj_estimate.txt
    ├── MH_02_easy/
    │   └── traj_estimate.txt
    └── MH_03_medium/
        └── traj_estimate.txt
```

</details>

---

## Acknowledgments

This workflow uses [sqrtVINS](https://github.com/rpng/sqrtVINS), developed by the Robot Perception and Navigation Group at the University of Delaware, and [EPICA](https://pypi.org/project/epica/), a trajectory alignment and evaluation toolkit.

We thank the authors and maintainers of both projects for making their work available to the research community.

When using these projects in academic or derivative work, consult their official repositories for the applicable citation and licensing requirements.
