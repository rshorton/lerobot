## Fork of Seeed Fork for Elsabot robot using Jetson AGX Orin

This fork supports using a wrist_yaw joint which gives the arm 6 DOF. I did that to make it easier to also control it with MoveIt.  See this page for the STL files:  https://makerworld.com/en/models/1913316-so101-arm-wrist-yaw-6dof#profileId-2088553


### Build docker

#### Prerequisite: Build Jetson container that includes support for Pytorch version used by Lerobot project.

This is necessary so that inferencing is accelerated.  Otherwise arm control is extremely slow.

See this related post:
https://forums.developer.nvidia.com/t/install-pytorch-on-jetson-orin-nano/357445

To build (assumes you already have the Nvidia jetson containers repo cloned): 

```
cd ~/path_to/jetson-containers
./build.sh pytorch:2.7-builder torchvision:0.22.0-builder
```

I was building for Jetpack 6.2 support.

#### Build Lerobot container

```
docker build  -f docker/Dockerfile.internal -t lerobot-internal_seeed .
```

### Run Docker

```
cd ~/lerobot; docker run -it --net=host --privileged --rm --gpus all -v ~/lerobot_config_files/:/home/user_lerobot/.cache/huggingface/  -v /dev/elsabot_dev_links:/dev/elsabot_dev_links -v .:/opt/lerobot --device-cgroup-rule "c 81:* rmw"  --device-cgroup-rule "c 189:* rmw"  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:$HOME/.Xauthority -e XAUTHORITY=$HOME/.Xauthority  --shm-size 16gb -e WANDB_API_KEY=${WANDB_API_KEY} 
lerobot-internal_seeed
```

### Teleoperate with 3 cameras

This was done after calibrating both arms.

Note the added option 'has_wrist_yaw' for both follower and leader.

```
lerobot-teleoperate  \
--robot.type=so101_follower \
--robot.port=/dev/elsabot_dev_links/so101_follower \
--robot.has_wrist_yaw=True \
--robot.id=my_follower_arm_6dof \
--teleop.type=so101_leader \
--teleop.port=/dev/elsabot_dev_links/so101_leader \
--teleop.has_wrist_yaw=True \
--teleop.id=my_leader_arm_6dof \
--robot.cameras="{front: {type: opencv, index_or_path: /dev/video8, width: 640, height: 480, fps: 30, fourcc: "MJPG"}, wrist: {type: opencv, index_or_path: /dev/video2, width: 640, height: 480, fps: 30, fourcc: "MJPG"}, side: {type: opencv, index_or_path: /dev/video0, width: 640, height: 480, fps: 30, fourcc: "MJPG"}}" \
--display_data=true
```

Cameras:
  * Front - mounted below robot base looking below arm
  * wrist - mounted on robot wrist
  * side - mounted above and to the side a bit to see overall workspace

(The robot arm is mounted on the front of my Elsabot robot which puts it approximately 22cm from the floor.)

### Record training episodes

```
export REPO_ID="063024/test1"; lerobot-record \
--robot.type=so101_follower \
--robot.port=/dev/elsabot_dev_links/so101_follower \
--robot.has_wrist_yaw=True \
--robot.id=my_follower_arm_6dof \
--teleop.type=so101_leader \
--teleop.port=/dev/elsabot_dev_links/so101_leader \
--teleop.has_wrist_yaw=True \
--teleop.id=my_leader_arm_6dof \
--robot.cameras="{front: {type: opencv, index_or_path: /dev/video8, width: 640, height: 480, fps: 30, fourcc: "MJPG"}, wrist: {type: opencv, index_or_path: /dev/video2, width: 640, height: 480, fps: 30, fourcc: "MJPG"}, side: {type: opencv, index_or_path: /dev/video0, width: 640, height: 480, fps: 30, fourcc: "MJPG"}}" \
--display_data=true \
--dataset.single_task="Grab the green block" \
--dataset.push_to_hub=False \
--dataset.repo_id=${REPO_ID} \
--dataset.episode_time_s=60 \
--dataset.reset_time_s=2 \
--dataset.num_episodes=25
```

The above was used to capture episodes for two positions of a 1"x1"x2" green block.

### Training

I tried training on a local computer with an older Nvidia GPU but it took more than a day and produced poor results.  (The batch size was limited to 12.)

I also tried using Google Colab with a Pro subscription.  That used an A100-high-memory instance.  That required 6.5 hours and cost 44.2 compute units ($4.42).  It required 27.3GB of GPU memory for a batch size of 64.  20000 total steps.  1.2M samples.  I saved the notebook file I used in the notebooks directory of this repo.

### Evaluation

```
export REPO_ID="063026/eval_smolvla"; lerobot-record \
--robot.type=so101_follower \
--robot.port=/dev/elsabot_dev_links/so101_follower \
--robot.has_wrist_yaw=True \
--robot.id=my_follower_arm_6dof \
--robot.cameras="{ front: {type: opencv, index_or_path: /dev/video8, width: 640, height: 480, fps: 30, fourcc: "MJPG"}, wrist: {type: opencv, index_or_path: /dev/video2, width: 640, height: 480, fps: 30, fourcc: "MJPG"}, side: {type: opencv, index_or_path: /dev/video0, width: 640, height: 480, fps: 30, fourcc: "MJPG"}}" \
--display_data=true \
--dataset.single_task="Grab the green block" \
--dataset.repo_id=${REPO_ID} \
--dataset.episode_time_s=500 \
--dataset.num_episodes=10 \
--policy.path=/home/user_lerobot/.cache/huggingface/lerobot/colab_063026/014000/pretrained_model \
--policy.n_action_steps=25
```

Also tried action_steps of various sizes.

Poor results.  I assume more training episodes are needed?

<p align="center">
  <img alt="LeRobot, Hugging Face Robotics Library" src="./media/readme/lerobot-logo-thumbnail.png" width="100%">
</p>

<div align="center">

[![Tests](https://github.com/huggingface/lerobot/actions/workflows/nightly.yml/badge.svg?branch=main)](https://github.com/huggingface/lerobot/actions/workflows/nightly.yml?query=branch%3Amain)
[![Python versions](https://img.shields.io/pypi/pyversions/lerobot)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/huggingface/lerobot/blob/main/LICENSE)
[![Status](https://img.shields.io/pypi/status/lerobot)](https://pypi.org/project/lerobot/)
[![Version](https://img.shields.io/pypi/v/lerobot)](https://pypi.org/project/lerobot/)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.1-ff69b4.svg)](https://github.com/huggingface/lerobot/blob/main/CODE_OF_CONDUCT.md)
[![Discord](https://img.shields.io/badge/Discord-Join_Us-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/q8Dzzpym3f)

</div>

**LeRobot** aims to provide models, datasets, and tools for real-world robotics in PyTorch. The goal is to lower the barrier to entry so that everyone can contribute to and benefit from shared datasets and pretrained models.

🤗 A hardware-agnostic, Python-native interface that standardizes control across diverse platforms, from low-cost arms (SO-100) to humanoids.

🤗 A standardized, scalable LeRobotDataset format (Parquet + MP4 or images) hosted on the Hugging Face Hub, enabling efficient storage, streaming and visualization of massive robotic datasets.

🤗 State-of-the-art policies that have been shown to transfer to the real-world ready for training and deployment.

🤗 Comprehensive support for the open-source ecosystem to democratize physical AI.

## Quick Start

LeRobot can be installed directly from PyPI.

```bash
pip install lerobot
lerobot-info
```

> [!IMPORTANT]
> For detailed installation guide, please see the [Installation Documentation](https://huggingface.co/docs/lerobot/installation).

## Robots & Control

<div align="center">
  <img src="./media/readme/robots_control_video.webp" width="640px" alt="Reachy 2 Demo">
</div>

LeRobot provides a unified `Robot` class interface that decouples control logic from hardware specifics. It supports a wide range of robots and teleoperation devices.

```python
from lerobot.robots.myrobot import MyRobot

# Connect to a robot
robot = MyRobot(config=...)
robot.connect()

# Read observation and send action
obs = robot.get_observation()
action = model.select_action(obs)
robot.send_action(action)
```

**Supported Hardware:** SO100, LeKiwi, Koch, HopeJR, OMX, EarthRover, Reachy2, Gamepads, Keyboards, Phones, OpenARM, Unitree G1.

While these devices are natively integrated into the LeRobot codebase, the library is designed to be extensible. You can easily implement the Robot interface to utilize LeRobot's data collection, training, and visualization tools for your own custom robot.

For detailed hardware setup guides, see the [Hardware Documentation](https://huggingface.co/docs/lerobot/integrate_hardware).

## LeRobot Dataset

To solve the data fragmentation problem in robotics, we utilize the **LeRobotDataset** format.

- **Structure:** Synchronized MP4 videos (or images) for vision and Parquet files for state/action data.
- **HF Hub Integration:** Explore thousands of robotics datasets on the [Hugging Face Hub](https://huggingface.co/lerobot).
- **Tools:** Seamlessly delete episodes, split by indices/fractions, add/remove features, and merge multiple datasets.

```python
from lerobot.datasets.lerobot_dataset import LeRobotDataset

# Load a dataset from the Hub
dataset = LeRobotDataset("lerobot/aloha_mobile_cabinet")

# Access data (automatically handles video decoding)
episode_index=0
print(f"{dataset[episode_index]['action'].shape=}\n")
```

Learn more about it in the [LeRobotDataset Documentation](https://huggingface.co/docs/lerobot/lerobot-dataset-v3)

## SoTA Models

LeRobot implements state-of-the-art policies in pure PyTorch, covering Imitation Learning, Reinforcement Learning, and Vision-Language-Action (VLA) models, with more coming soon. It also provides you with the tools to instrument and inspect your training process.

<p align="center">
  <img alt="Gr00t Architecture" src="./media/readme/VLA_architecture.jpg" width="640px">
</p>

Training a policy is as simple as running a script configuration:

```bash
lerobot-train \
  --policy=act \
  --dataset.repo_id=lerobot/aloha_mobile_cabinet
```

| Category                   | Models                                                                                                                                                                                                       |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Imitation Learning**     | [ACT](./docs/source/policy_act_README.md), [Diffusion](./docs/source/policy_diffusion_README.md), [VQ-BeT](./docs/source/policy_vqbet_README.md)                                                             |
| **Reinforcement Learning** | [HIL-SERL](./docs/source/hilserl.mdx), [TDMPC](./docs/source/policy_tdmpc_README.md) & QC-FQL (coming soon)                                                                                                  |
| **VLAs Models**            | [Pi0Fast](./docs/source/pi0fast.mdx), [Pi0.5](./docs/source/pi05.mdx), [GR00T N1.5](./docs/source/policy_groot_README.md), [SmolVLA](./docs/source/policy_smolvla_README.md), [XVLA](./docs/source/xvla.mdx) |

Similarly to the hardware, you can easily implement your own policy & leverage LeRobot's data collection, training, and visualization tools, and share your model to the HF Hub

For detailed policy setup guides, see the [Policy Documentation](https://huggingface.co/docs/lerobot/bring_your_own_policies).

## Inference & Evaluation

Evaluate your policies in simulation or on real hardware using the unified evaluation script. LeRobot supports standard benchmarks like **LIBERO**, **MetaWorld** and more to come.

```bash
# Evaluate a policy on the LIBERO benchmark
lerobot-eval \
  --policy.path=lerobot/pi0_libero_finetuned \
  --env.type=libero \
  --env.task=libero_object \
  --eval.n_episodes=10
```

Learn how to implement your own simulation environment or benchmark and distribute it from the HF Hub by following the [EnvHub Documentation](https://huggingface.co/docs/lerobot/envhub)

## Resources

- **[Documentation](https://huggingface.co/docs/lerobot/index):** The complete guide to tutorials & API.
- **[Chinese Tutorials: LeRobot+SO-ARM101中文教程-同济子豪兄](https://zihao-ai.feishu.cn/wiki/space/7589642043471924447)** Detailed doc for assembling, teleoperate, dataset, train, deploy. Verified by Seed Studio and 5 global hackathon players.
- **[Discord](https://discord.gg/q8Dzzpym3f):** Join the `LeRobot` server to discuss with the community.
- **[X](https://x.com/LeRobotHF):** Follow us on X to stay up-to-date with the latest developments.
- **[Robot Learning Tutorial](https://huggingface.co/spaces/lerobot/robot-learning-tutorial):** A free, hands-on course to learn robot learning using LeRobot.

## Citation

If you use LeRobot in your research, please cite:

```bibtex
@misc{cadene2024lerobot,
    author = {Cadene, Remi and Alibert, Simon and Soare, Alexander and Gallouedec, Quentin and Zouitine, Adil and Palma, Steven and Kooijmans, Pepijn and Aractingi, Michel and Shukor, Mustafa and Aubakirova, Dana and Russi, Martino and Capuano, Francesco and Pascal, Caroline and Choghari, Jade and Moss, Jess and Wolf, Thomas},
    title = {LeRobot: State-of-the-art Machine Learning for Real-World Robotics in Pytorch},
    howpublished = "\url{https://github.com/huggingface/lerobot}",
    year = {2024}
}
```

## Contribute

We welcome contributions from everyone in the community! To get started, please read our [CONTRIBUTING.md](./CONTRIBUTING.md) guide. Whether you're adding a new feature, improving documentation, or fixing a bug, your help and feedback are invaluable. We're incredibly excited about the future of open-source robotics and can't wait to work with you on what's next—thank you for your support!

<p align="center">
  <img alt="SO101 Video" src="./media/readme/so100_video.webp" width="640px">
</p>

<div align="center">
<sub>Built by the <a href="https://huggingface.co/lerobot">LeRobot</a> team at <a href="https://huggingface.co">Hugging Face</a> with ❤️</sub>
</div>
