"# orbbec"
```bash 
lerobot-teleoperate \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM0 \
  --robot.id=my_awesome_follower_arm \
  --robot.cameras='{
    up_color: {type: orbbec_color, width: 640, height: 480, fps: 30},
    up_depth: {type: orbbec_depth, width: 640, height: 400, fps: 30, focus_area: [60, 300]}
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
    up_color: {type: orbbec_color, width: 640, height: 480, fps: 30},
    up_depth: {type: orbbec_depth, width: 640, height: 400, fps: 30, focus_area: [60, 300]}
  }'  \
  --robot.id=my_awesome_follower_arm \
  --display_data=false \
  --dataset.repo_id=seeedstudio123/eval_test11111 \
  --dataset.single_task="Put lego brick into the transparent box" \
  --policy.path=outputs/train/act_so101_test/checkpoints/last/pretrained_model
```
