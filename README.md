# eval-vislam

Toolkit for VSLAM and VISLAM evaluation.

For more information, please refer to our [project website](http://www.zjucvg.net/eval-vislam/).

## License

This project is released under the Apache 2.0 license.

## Prerequisites

- [Eigen3](http://eigen.tuxfamily.org/index.php?title=Main_Page)
- [yaml-cpp](https://github.com/jbeder/yaml-cpp)

## Toolkit Usage

### Accuracy (APE, RPE, ARE, RRE, Completeness)

```docopt
Usage:
  ./accuracy <groundtruth> <input> <fix scale>

Arguments:
  <groundtruth>   Path to sequence folder, e.g. ~/VISLAM-Dataset/A0.
  <input>         SLAM camera trajectory file in TUM format(timestamp[s] px py pz qx qy qz qw).
  <fix scale>     Set to 1 for VISLAM, set to 0 for VSLAM.
```

`evo_test.sh` 和`evo.sh` 脚本为对vi 比赛数据集结果进行批量评估的脚本，**里面有用到evo_traj 进行画图**


#### .sh 使用
- run_vins.sh 
  - 参数1 ：`data_path`   数据集路径 必须有解压下来的 groundtruth **要求命令**：  slam_test/C0_test/groundtruth
  -  参数2 ：`result_path` slam结果路径 slam 输出结果 **要求命名** slam_test_result/C0/vins_result_loop.txt

### Initialization Scale Error and Time

```docopt
Usage:
  ./initialization <groundtruth> <input> <has inertial>

Arguments:
  <groundtruth>   Path to sequence folder, e.g. ~/VISLAM-Dataset/A0.
  <input>         SLAM camera trajectory file in TUM format(timestamp[s] px py pz qx qy qz qw).
  <has inertial>  Set to 1 for VISLAM, set to 0 for VSLAM.
```

### Robustness

```docopt
Usage:
  ./robustness <groundtruth> <input> <fix scale>

Arguments:
  <groundtruth>   Path to sequence folder, e.g. ~/VISLAM-Dataset/A0.
  <input>         SLAM camera trajectory file in TUM format(timestamp[s] px py pz qx qy qz qw).
  <fix scale>     Set to 1 for VISLAM, set to 0 for VSLAM.
```

### Relocalization Time

```docopt
Usage:
  relocalization <groundtruth> <input> <has inertial>

Arguments:
  <groundtruth>   Path to sequence folder, e.g. ~/VISLAM-Dataset/A0.
  <input>         SLAM camera trajectory file in TUM format(timestamp[s] px py pz qx qy qz qw).
  <has inertial>  Set to 1 for VISLAM, set to 0 for VSLAM.
```



evo_traj tum CameraTrajectory_TUM.txt groundtruth.txt -p

## Citation

If you are using our codebase or dataset for research, please cite the following publication:

```bibtex
@article{
  title={Survey and Evaluation of Monocular Visual-Inertial SLAM Algorithms for Augmented Reality},
  author={Jinyu Li, Bangbang Yang, Danpeng Chen, Nan Wang, Guofeng Zhang*, Hujun Bao*},
  journal={Journal of Virtual Reality & Intelligent Hardware},
  year={2019},
  url = {http://www.vr-ih.com/vrih/html/EN/10.3724/SP.J.2096-5796.2018.0011/article.html},
  doi = {10.3724/SP.J.2096-5796.2018.0011}
}
```
