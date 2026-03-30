# Orbbec Cameras

This folder provides split color/depth camera support for:

- `orbbec_color`
- `orbbec_depth`

## Features

- Select cameras by `serial_number_or_name`
- Shared pipeline per physical camera
- `depth_alpha` support for depth visualization
- `rotation` and `warmup_s` support on both color and depth cameras

## Example: Teleoperate

```bash
lerobot-teleoperate \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM0 \
  --robot.id=my_awesome_follower_arm \
  --robot.cameras='{
    up_color: {
      type: orbbec_color,
      serial_number_or_name: "AY3794302V9",
      width: 640,
      height: 480,
      fps: 30,
      color_mode: rgb,
      rotation: 0,
      warmup_s: 1
    },
    up_depth: {
      type: orbbec_depth,
      serial_number_or_name: "AY3794302V9",
      width: 640,
      height: 400,
      fps: 30,
      depth_alpha: 0.2,
      rotation: 0,
      warmup_s: 5
    }
  }' \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM1 \
  --teleop.id=my_awesome_leader_arm \
  --display_data=true
```

```bash
lerobot-record \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM0 \
  --robot.cameras='{
    up_color: {
      type: orbbec_color,
      serial_number_or_name: "AY3794302V9",
      width: 640,
      height: 480,
      fps: 30,
      color_mode: rgb,
      rotation: 0,
      warmup_s: 1
    },
    up_depth: {
      type: orbbec_depth,
      serial_number_or_name: "AY3794302V9",
      width: 640,
      height: 400,
      fps: 30,
      depth_alpha: 0.2,
      rotation: 0,
      warmup_s: 5
    }
  }'  \
  --robot.id=my_awesome_follower_arm \
  --display_data=false \
  --dataset.repo_id=seeedstudio123/eval_test11111 \
  --dataset.single_task="Put lego brick into the transparent box" \
  --policy.path=outputs/train/act_so101_test/checkpoints/last/pretrained_model
```

## Example: Find cameras

```bash
lerobot-find-cameras orbbec
```
