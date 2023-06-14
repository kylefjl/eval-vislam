#!/bin/bash
# This script is used to start the evo server
# 绿色输出
function green_echo(){
    echo -e "\033[32m $1 \033[0m"
}
# 红色输出
function red_echo(){
    echo -e "\033[31m $1 \033[0m"
}
green_echo "Open the EVO server..."
##################################################################
data_path="/media/kyle/Mydata/data/slam_test/"  #  数据集路径 必须有解压下来的 groundtruth eg /media/kyle/Mydata/data/slam_test/C0_test/groundtruth
result_path="/media/kyle/Mydata/slam_test_result/"  #  slam结果路径 slam 输出结果 要求命名 slam_test_result/C0/vins_result_loop.txt
##########################################################

evo_result_path=${result_path}evo_result.txt
if [ ! -f "$evo_result_path" ]; then
  touch "$evo_result_path"
else
  rm "$evo_result_path"
  touch "$evo_result_path"
fi

cd ./bin
for loop in 0 1 2 3 4 5 6 7 8 9 10 11
do
 #  result_file="${result_path}KeyFrameTrajectory${loop}.txt"  # fjl path

#  result_file="${result_path}C${loop}/vins_result_loop.tum"
  result_file="${result_path}C${loop}/vins_result_loop.txt"
  data="${data_path}C${loop}_test"
  if [ ! -f "$result_file" ]||[ ! -d "$data" ]; then
    red_echo "The file $result_file or $data does not exist"
    continue
  fi
  echo "C ${loop} train  result  **************************" >> $evo_result_path
  ./accuracy $data $result_file "1" >> $evo_result_path
  find ${result_path}C${loop}/ -name "*.png" -type f -print -exec rm -rf {} \;
  evo_traj tum $result_file --ref ${data}/groundtruth/data.txt  --plot_mode=xy -a --save_plot ${result_path}C${loop}/vins_result_loop_xy.png

done

for loop in 0 1 2 3 4 5 6 7 8 9 10
do
  result_file="${result_path}D${loop}/vins_result_loop.txt"
#  result_file="${result_path}D${loop}/vins_result_loop.txt"
  data="${data_path}D${loop}_test"
  if [ ! -f "$result_file" ]||[ ! -d "$data" ]; then
    red_echo "The file $result_file or $data does not exist"
    continue
  fi
  echo "D ${loop} train  result  **************************" >> $evo_result_path
  find ${result_path}D${loop}/ -name "*.png" -type f -print -exec rm -rf {} \;

  ./accuracy $data $result_file "1" >> $evo_result_path
  evo_traj tum $result_file --ref ${data}/groundtruth/data.txt  --plot_mode=xy -a --save_plot ${result_path}D${loop}/vins_result_loop_xy.png
done

green_echo "Finish the EVO server..."
green_echo "The result is in the file $evo_result_path"
