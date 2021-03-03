# cf-ly
用ssh连接软件连接opewrt

cd /usr
创建dns目录
mkdir dns
进入目录
cd dns
下载优选ip文件
wget https://raw.githubusercontent.com/wxfyes/cf/main/cf-openwrt.sh
下载杀进程文件
wget https://raw.githubusercontent.com/wxfyes/cf/main/kill-cf-openwrt.sh
1
2
3
4
5
6
7
8
9
cd /usr
创建dns目录
mkdir dns
进入目录
cd dns
下载优选ip文件
wget https://raw.githubusercontent.com/wxfyes/cf/main/cf-openwrt.sh
下载杀进程文件
wget https://raw.githubusercontent.com/wxfyes/cf/main/kill-cf-openwrt.sh
修改cf-openwrt.sh中的两处地方，一处是带宽选择，一处是微信推送token

第一处



第二处



pushplus API接口申请地址：点击进入  微信扫码登录获取token



添加计划任务

依次进入 系统-计划任务

添加一下命令

##0代表分7代表小时，意思是7：00整开始运行脚本
0 7 * * * bash /usr/dns/cf-openwrt.sh  
5 7 * * * bash /usr/dns/kill-cf-openwrt
0 18 * * * bash /usr/dns/cf-openwrt.sh
5 18 * * * bash /usr/dns/kill-cf-openwtt.sh
1
2
3
4
5
##0代表分7代表小时，意思是7：00整开始运行脚本
0 7 * * * bash /usr/dns/cf-openwrt.sh  
5 7 * * * bash /usr/dns/kill-cf-openwrt
0 18 * * * bash /usr/dns/cf-openwrt.sh
5 18 * * * bash /usr/dns/kill-cf-openwtt.sh
完成后效果



到这里就完成全部操作了，剩下的就是等待自动执行，当然，再自动执行之前，我们可以手动来执行一次，执行命令：

bash /usr/dns/cf-openwrt.sh
1
bash /usr/dns/cf-openwrt.sh




pushplus推送效果



教程结束！
