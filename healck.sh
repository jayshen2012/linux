#!/bin/bash
echo "CPU load检测"
cores=`cat /proc/cpuinfo|grep processor|wc -l`
uptime|awk -v cores=$cores -F ":" '{print $5}'|awk -F "," '{ if (int($1)>cores) print "1分钟内压力"$1; else if ( int($2)>cores ) print "5分钟内压力"$2; else if ( int($3)>cores ) print "10分钟内压力"$3; else print "1、5、10分内CPU压力正常"}'
echo "=>done"
echo "总体CPU使用率检测,steal监测"
sar -u 1 3|tail -n 1|awk -F " " '{ if ( $3+$5 > 85 )  print "CPU总体使用率高于85%,为"$3+$5; else if ($7>5) print "当前CPU的steal值大于5，为"$7; else print "CPU总体正常"}'
echo "=>done"
echo "CPU队列情况检测"
vmstat 1 3|tail -n 1|awk -F " " '{if ($7>0||$8>0) print "内存可能不足，有swap发生"; else if ($1>10) print "CPU队列可能过长"; else print "CPU队列正常"}'
echo "=>done"
echo "CPU单核满情况检测"
mpstat -P ALL|awk -F " " 'NR>4{if ($12 < 5) print $3"核CPU繁忙，空闲度为"$12}'
echo "=>done"
echo "io延迟情况检测"
iostat -txm |awk -F " " 'NR>7 { if ($10>30)  print $1"的io延迟大于30ms，现在是"$10;}'
echo "=>done"
echo "网络丢包情况检测"
sar -n TCP,ETCP 1 3|tail -n 1|awk -F " " '{if ($4>0) print "有丢包情况，丢包数量为每秒"$4}'
echo "=>done"

echo "检测文件句柄上限"
linkNum=`netstat -an|wc -l`
filemax=`cat /proc/sys/fs/file-max`
soft=`ulimit -n`
hard=`ulimit -Hn`
if [[ $[linkNum*10] -gt $[filemax*8] || $[linkNum*10] -gt $[hard*8] || $[linkNum*10] -gt $[soft*8] ]]; then
        echo "文件句柄数大于最大值的80%"
fi
echo "=>done"

portNumMax=`cat /proc/sys/net/ipv4/ip_local_port_range|awk -F " " '{print $2-$1}'`
currentPortNum=`netstat -anp|awk -F " " '{if ($8 ~ /^[0-9].*/) print $8 }'|sort -u|wc -l`

if [ $[currentPortNum*10] -gt $[portNumMax*8] ];then
        echo "当前端口数超过上限的80%"
fi
