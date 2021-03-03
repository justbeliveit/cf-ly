#!/bin/bash
# random cloudflare anycast ip
#使用说明：加在openwrt上系统--计划任务里添加定时运行，如30 8 * * * bash /usr/dns/cf-openwrt.sh     8点30运行一次。路由上的爬墙软件节点IP全部换成路由IP，如192.168.1.1，端口全部8443


localport=8443
remoteport=443

	declare -i bandwidth
	declare -i speed
	bandwidth=20
	speed=bandwidth*128*1024
	starttime=`date +'%Y-%m-%d %H:%M:%S'`

	while true
	do
		while true
		do
			declare -i n
			declare -i per
			declare -i count
			rm -rf icmp temp log.txt anycast.txt temp.txt
			mkdir icmp
			datafile="/usr/cf/data.txt"
			if [[ ! -f "$datafile" ]]
			then
				echo 获取CF节点IP
				curl --retry 3 https://update.udpfile.com -o data.txt -#
			fi
			domain=$(cat data.txt | grep domain= | cut -f 2- -d'=')
			file=$(cat data.txt | grep file= | cut -f 2- -d'=')
			databaseold=$(cat data.txt | grep database= | cut -f 2- -d'=')
			n=0
			count=$(($RANDOM%5))
			for i in `cat data.txt | sed '1,7d'`
			do
				if [ $n -eq $count ]
				then
					randomip=$(($RANDOM%256))
					echo 生成随机IP $i$randomip
					echo $i$randomip>>anycast.txt
					count+=4
				else
					n+=1
				fi
			done
			n=0
			m=$(cat anycast.txt | wc -l)
			count=m/30+1
			for i in `cat anycast.txt`
			do
				ping -c $count -i 1 -n -q $i > icmp/$n.log&
				n=$[$n+1]
				per=$n*100/$m
				while true
				do
					p=$(ps -ef | grep ping | grep -v "grep" | wc -l)
					if [ $p -ge 200 ]
					then
						echo 正在测试 ICMP 丢包率:进程数 $p,已完成 $per %
						sleep 1
					else
						echo 正在测试 ICMP 丢包率:进程数 $p,已完成 $per %
						break
					fi
				done
			done
			rm -rf anycast.txt
			while true
			do
				p=$(ps -ef | grep ping | grep -v "grep" | wc -l)
				if [ $p -ne 0 ]
				then
					echo 等待 ICMP 进程结束:剩余进程数 $p
					sleep 1
				else
					echo ICMP 丢包率测试完成
					break
				fi
			done
			cat icmp/*.log | grep 'statistics\|loss' | sed -n '{N;s/\n/\t/p}' | cut -f 1 -d'%' | awk '{print $NF,$2}' | sort -n | awk '{print $2}' | sed '31,$d' > ip.txt
			rm -rf icmp
			echo 选取30个丢包率最少的IP地址下载测速
			mkdir temp
			for i in `cat ip.txt`
			do
				echo $i 启动测速
				curl --resolve $domain:443:$i https://$domain/$file -o temp/$i -s --connect-timeout 2 --max-time 10&
			done
			echo 等待测速进程结束,筛选出三个优选的IP
			sleep 15
			echo 测速完成
			ls -S temp > ip.txt
			rm -rf temp
			n=$(wc -l ip.txt | awk '{print $1}')
			if [ $n -ge 3 ]; then
				first=$(sed -n '1p' ip.txt)
				second=$(sed -n '2p' ip.txt)
				third=$(sed -n '3p' ip.txt)
				rm -rf ip.txt
				echo 优选的IP地址为 $first - $second - $third
				echo 第一次测试 $first
				curl --resolve $domain:443:$first https://$domain/$file -o /dev/null --connect-timeout 5 --max-time 10 > log.txt 2>&1
				cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep -v 'k\|M' >> speed.txt
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep k | sed 's/k//g'`
				do
					declare -i k
					k=$i
					k=k*1024
					echo $k >> speed.txt
				done
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep M | sed 's/M//g'`
				do
					i=$(echo | awk '{print '$i'*10 }')
					declare -i M
					M=$i
					M=M*1024*1024/10
					echo $M >> speed.txt
				done
				declare -i max
				max=0
				for i in `cat speed.txt`
				do
					max=$i
					if [ $i -ge $max ]; then
						max=$i
					fi
				done
				rm -rf log.txt speed.txt
				if [ $max -ge $speed ]; then
					anycast=$first
					break
				fi
				max=$[$max/1024]
				echo 峰值速度 $max kB/s
				echo 第二次测试 $first
				curl --resolve $domain:443:$first https://$domain/$file -o /dev/null --connect-timeout 5 --max-time 10 > log.txt 2>&1
				cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep -v 'k\|M' >> speed.txt
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep k | sed 's/k//g'`
				do
					declare -i k
					k=$i
					k=k*1024
					echo $k >> speed.txt
				done
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep M | sed 's/M//g'`
				do
					i=$(echo | awk '{print '$i'*10 }')
					declare -i M
					M=$i
					M=M*1024*1024/10
					echo $M >> speed.txt
				done
				declare -i max
				max=0
				for i in `cat speed.txt`
				do
					max=$i
					if [ $i -ge $max ]; then
						max=$i
					fi
				done
				rm -rf log.txt speed.txt
				if [ $max -ge $speed ]; then
					anycast=$first
					break
				fi
				max=$[$max/1024]
				echo 峰值速度 $max kB/s
				echo 第一次测试 $second
				curl --resolve $domain:443:$second https://$domain/$file -o /dev/null --connect-timeout 5 --max-time 10 > log.txt 2>&1
				cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep -v 'k\|M' >> speed.txt
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep k | sed 's/k//g'`
				do
					declare -i k
					k=$i
					k=k*1024
					echo $k >> speed.txt
				done
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep M | sed 's/M//g'`
				do
					i=$(echo | awk '{print '$i'*10 }')
					declare -i M
					M=$i
					M=M*1024*1024/10
					echo $M >> speed.txt
				done
				declare -i max
				max=0
				for i in `cat speed.txt`
				do
					max=$i
					if [ $i -ge $max ]; then
						max=$i
					fi
				done
				rm -rf log.txt speed.txt
				if [ $max -ge $speed ]; then
					anycast=$second
					break
				fi
				max=$[$max/1024]
				echo 峰值速度 $max kB/s
				echo 第二次测试 $second
				curl --resolve $domain:443:$second https://$domain/$file -o /dev/null --connect-timeout 5 --max-time 10 > log.txt 2>&1
				cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep -v 'k\|M' >> speed.txt
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep k | sed 's/k//g'`
				do
					declare -i k
					k=$i
					k=k*1024
					echo $k >> speed.txt
				done
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep M | sed 's/M//g'`
				do
					i=$(echo | awk '{print '$i'*10 }')
					declare -i M
					M=$i
					M=M*1024*1024/10
					echo $M >> speed.txt
				done
				declare -i max
				max=0
				for i in `cat speed.txt`
				do
					max=$i
					if [ $i -ge $max ]; then
						max=$i
					fi
				done
				rm -rf log.txt speed.txt
				if [ $max -ge $speed ]; then
					anycast=$second
					break
				fi
				max=$[$max/1024]
				echo 峰值速度 $max kB/s
				echo 第一次测试 $third
				curl --resolve $domain:443:$third https://$domain/$file -o /dev/null --connect-timeout 5 --max-time 10 > log.txt 2>&1
				cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep -v 'k\|M' >> speed.txt
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep k | sed 's/k//g'`
				do
					declare -i k
					k=$i
					k=k*1024
					echo $k >> speed.txt
				done
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep M | sed 's/M//g'`
				do
					i=$(echo | awk '{print '$i'*10 }')
					declare -i M
					M=$i
					M=M*1024*1024/10
					echo $M >> speed.txt
				done
				declare -i max
				max=0
				for i in `cat speed.txt`
				do
					max=$i
					if [ $i -ge $max ]; then
						max=$i
					fi
				done
				rm -rf log.txt speed.txt
				if [ $max -ge $speed ]; then
					anycast=$third
					break
				fi
				max=$[$max/1024]
				echo 峰值速度 $max kB/s
				echo 第二次测试 $third
				curl --resolve $domain:443:$third https://$domain/$file -o /dev/null --connect-timeout 5 --max-time 10 > log.txt 2>&1
				cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep -v 'k\|M' >> speed.txt
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep k | sed 's/k//g'`
				do
					declare -i k
					k=$i
					k=k*1024
					echo $k >> speed.txt
				done
				for i in `cat log.txt | tr '\r' '\n' | awk '{print $NF}' | sed '1,3d;$d' | grep M | sed 's/M//g'`
				do
					i=$(echo | awk '{print '$i'*10 }')
					declare -i M
					M=$i
					M=M*1024*1024/10
					echo $M >> speed.txt
				done
				declare -i max
				max=0
				for i in `cat speed.txt`
				do
					max=$i
					if [ $i -ge $max ]; then
						max=$i
					fi
				done
				rm -rf log.txt speed.txt
				if [ $max -ge $speed ]; then
					anycast=$third
					break
				fi
				max=$[$max/1024]
				echo 峰值速度 $max kB/s
			fi
		done
			break
	done
		max=$[$max/1024]
		endtime=`date +'%Y-%m-%d %H:%M:%S'`
		start_seconds=$(date --date="$starttime" +%s)
		end_seconds=$(date --date="$endtime" +%s)
		clear
		curl --ipv4 --resolve update.freecdn.workers.dev:443:$anycast --retry 3 -s -X POST -d '"CF-IP":"'$anycast'","Speed":"'$max'"' 'https://update.freecdn.workers.dev' -o temp.txt
		publicip=$(cat temp.txt | grep publicip= | cut -f 2- -d'=')
		colo=$(cat temp.txt | grep colo= | cut -f 2- -d'=')
		url=$(cat temp.txt | grep url= | cut -f 2- -d'=')
		url=$(cat temp.txt | grep url= | cut -f 2- -d'=')
		app=$(cat temp.txt | grep app= | cut -f 2- -d'=')
		databasenew=$(cat temp.txt | grep database= | cut -f 2- -d'=')
		if [ "$app" != "20210226" ]
		then
			echo 发现新版本程序: $app
			echo 更新地址: $url
			echo 更新后才可以使用
			exit
		fi
		if [ "$databasenew" != "$databaseold" ]
		then
			echo 发现新版本数据库: $databasenew
			mv temp.txt data.txt
			echo 数据库 $databasenew 已经自动更新完毕
		fi
		rm -rf temp.txt
		echo 优选IP $anycast 满足 $bandwidth Mbps带宽需求
		echo 峰值速度 $max kB/s
		echo 公网IP $publicip
		echo 数据中心 $colo
		echo 总计用时 $((end_seconds-start_seconds)) 秒
		iptables -t nat -D OUTPUT $(iptables -t nat -nL OUTPUT --line-number | grep $localport | awk '{print $1}')
		iptables -t nat -A OUTPUT -p tcp --dport $localport -j DNAT --to-destination $anycast:$remoteport
		echo $(date +'%Y-%m-%d %H:%M:%S') IP指向 $anycast>>/usr/dns/cfnat.txt
                     
                            curl -s -o /dev/null --data "token=85226d2842024f4581f749a9882a6669&title=$anycast更新成功！&content= 优选IP $anycast 满足 $bandwidth Mbps带宽需求<br>峰值速度 $max kB/s<br>数据中心 $colo<br>总计用时 $((end_seconds-start_seconds)) 秒<br>&template=html" http://pushplus.hxtrip.com/send
