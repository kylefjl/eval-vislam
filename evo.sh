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
data_path="/media/kyle/Mydata/data/vi/" #  数据集路径
result_path="/media/kyle/Mydata/New_VINS_result/" #  结果路径

evo_result_path=${result_path}evo_result.txt #  evo结果路径
if [ ! -f "$evo_result_path" ]; then # 如果不存在则创建
  touch "$evo_result_path"
else                                   # 如果存在则删除后创建
  rm "$evo_result_path"
  touch "$evo_result_path"
fi

cd ./bin #  进入bin文件夹
for loop in 0 1 2 3 4 5 6 7 8 9 10 11 # C 0-11 数据集
do
  result_file="${result_path}C${loop}/vins_result_loop.txt" # slam result 路径
  data="${data_path}C${loop}_train" # 数据集路径
  if [ ! -f "$result_file" ]||[ ! -d "$data" ]; then
    red_echo "The file $result_file or $data does not exist"
    continue
  fi
  echo "C ${loop} train  result  **************************" >> $evo_result_path
  ./accuracy $data $result_file "1" >> $evo_result_path
  find ${result_path}C${loop}/ -name "*.png" -type f -print -exec rm -rf {} \; # 删除所有png文件
  evo_traj tum $result_file --ref ${data}/groundtruth/data.txt  --plot_mode=xy -a --save_plot ${result_path}C${loop}/vins_result_loop_xy.png # 画图 保存  xy平面

done

for loop in 0 1 2 3 4 5 6 7 8 9 10 # D 0-10 数据集
do
  result_file="${result_path}D${loop}/vins_result_loop.txt"
#  result_file="${result_path}D${loop}/vins_result_loop.txt"
  data="${data_path}D${loop}_train"
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
