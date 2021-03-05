# cf-ly
每天定时自动优选最新可用IP

# 前言
利用软路由进行全自动优选IP！每天定时自动优选最新可用IP！设置好之后将会为你省去很多时间，期间不再需要任何额外操作！最后优选完成还会微信推送给你优选结果！

# 教程
用ssh软件连接opewrt或直接软路由openwrt使用TTYD终端

具体编译流程如下（按顺序复制以下代码）
 
 ```bash
进入根usr目录

cd /usr

创建dns目录

mkdir dns

进入dns目录

cd dns

下载优选ip文件

wget https://raw.githubusercontent.com/laowagong/cf-ly/main/cf-openwrt.sh

下载杀进程文件

wget https://raw.githubusercontent.com/laowagong/cf-ly/main/kill-cf-openwrt.sh

显示当前目录的内容

ls

修改cf-openwrt.sh

vi cf-openwrt.sh

进入编辑模式

i

退出编辑并保存

:wq
```

修改cf-openwrt.sh中的两处地方，一处是带宽选择（默认20，可根据自己网络修改数值大小），一处是微信推送token（点击下面网址进入微信扫码、一对一推送、获得获取token复制替换最底行代码“微信推送key"保存完成。

pushplus API接口申请地址：https://pushplus.hxtrip.com  微信扫码登录获取token

添加计划任务

依次进入 系统-计划任务

添加一下命令

 ```bash
0 6 * * * bash /usr/dns/cf-openwrt.sh

5 6 * * * bash /usr/dns/kill-cf-openwrt
```

其中0代表分、6代表小时，意思是6：00整开始运行脚本,6:05结束脚本，可根据自己实际情况修改。
 
# 结束
 
 到这里就完成全部操作了，剩下的就是等待自动执行，当然，在自动执行之前，我们也可手动来执行一次，执行命令：
 
 ```bash
bash /usr/dns/cf-openwrt.sh
```

# 申明

收集于网络，仅供学习备用。
