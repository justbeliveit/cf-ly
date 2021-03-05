# cf-ly
每天定时自动优选最新可用IP

# 前言
这是一个进阶版的教程，利用我们手中的软路由进行全自动优选IP！每天定时自动优选最新可用IP！设置好之后将会给你省去很多时间，期间不再需要任何额外设置！最后优选完成还会微信推送给你优选结果！

# 教程
用ssh连接软件连接opewrt

具体编译使用流程如下
 
 ```bash
cd /usr

创建dns目录

mkdir dns

进入目录

cd dns

下载优选ip文件

wget https://raw.githubusercontent.com/laowagong/cf-ly/main/cf-openwrt.sh

下载杀进程文件

wget https://raw.githubusercontent.com/laowagong/cf-ly/main/kill-cf-openwrt.sh
```

修改cf-openwrt.sh中的两处地方，一处是带宽选择，一处是微信推送token
