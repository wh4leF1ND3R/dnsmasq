#!/bin/sh
echo
echo " Copyright (c) 2014-2017,by clion007"
echo " 本脚本仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）"
echo " 未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规，文明上网。"
echo
#LOGFILE=/tmp/fq_update.log
#LOGSIZE=$(wc -c < $LOGFILE)
#if [ $LOGSIZE -ge 5000 ]; then
#	sed -i -e 1,10d $LOGFILE
#fi
echo -e "\e[1;36m 3秒钟后开始更新规则\e[0m"
echo
sleep 3
echo " 开始更新dnsmasq规则"
# 下载sy618扶墙规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/sy618 https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq

# 下载racaljk规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/racaljk https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf

# 删除racaljk规则中google'youtube相关规则
#sed -i '/google/d' /tmp/racaljk
#sed -i '/youtube/d' /tmp/racaljk

# 创建用户自定规则缓存
cp /etc/dnsmasq.d/userlist /tmp/userlist

# 删除dnsmasq缓存注释
sed -i '/#/d' /tmp/sy618
sed -i '/#/d' /tmp/racaljk
sed -i '/#/d' /tmp/userlist

# 扶墙网站指定到#443端口访问
awk '{print $0"#443"}' /tmp/sy618 > /tmp/sy618.conf
awk '{print $0"#443"}' /tmp/racaljk > /tmp/racaljk.conf
awk '{print $0"#443"}' /tmp/userlist > /tmp/userlist.conf

# 合并dnsmasq缓存
cat /tmp/userlist.conf /tmp/racaljk.conf /tmp/sy618.conf > /tmp/fq
#cat /tmp/userlist.conf /tmp/sy618.conf > /tmp/fq

# 删除dnsmasq临时文件
rm -rf /tmp/userlist
rm -rf /tmp/userlist.conf
rm -rf /tmp/sy618.conf
rm -rf /tmp/sy618
rm -rf /tmp/racaljk.conf
rm -rf /tmp/racaljk

# 删除本地规则
sed -i '/::1/d' /tmp/fq
sed -i '/localhost/d' /tmp/fq

# 删除被误杀的广告规则
sed -i '/360/d' /tmp/fq
sed -i '/toutiao/d' /tmp/fq
sed -i '/taobao/d' /tmp/fq
sed -i '/jd/d' /tmp/fq



# 创建dnsmasq规则文件
cat > /tmp/fq.conf <<EOF

############################################################
##【Copyright (c) 2014-2017, clion007】                           ##
##                                                                ##
## 感谢https://github.com/sy618/hosts                             ##
## 感谢https://github.com/racaljk/hosts                           ##
####################################################################

# Localhost (DO NOT REMOVE) Start
address=/localhost/127.0.0.1
address=/localhost/::1
address=/ip6-localhost/::1
address=/ip6-loopback/::1
# Localhost (DO NOT REMOVE) End

#Modified hosts start
EOF

# 删除dnsmasq重复规则
sort /tmp/fq | uniq >> /tmp/fq.conf

# 删除dnsmasq合并缓存
rm -rf /tmp/fq
echo
if [ -s "/tmp/fq.conf" ]; then
	if ( ! cmp -s /tmp/fq.conf /etc/dnsmasq.d/fq.conf ); then
		mv /tmp/fq.conf /etc/dnsmasq.d/fq.conf
		echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到fq规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart >/dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: fq规则转换完成，应用新规则。"
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: fq本地规则和在线规则相同，无需更新！" && rm -f /tmp/fq.conf
	fi	
fi
echo
echo -e "\e[1;36m 规则更新完成\e[0m"
echo
exit 0
