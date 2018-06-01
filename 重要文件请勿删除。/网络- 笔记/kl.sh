#!/bin/bash
mkdir /wang
mv /etc/yum.repos.d/*.repo /wang/
yum clean all  &> /dev/null
s=`yum repolist | tail -1 | sed -r 's/repolist: //;s/,//' `
echo "YUM 可用软件包 :$s"
	 if [ "$s" -eq 0  ];then
	 echo "peizhi YUM"
	 mkdir /YUM
	 mv /etc/yum.repos.d/*.repo  /YUM
	 yum-config-manager --add file:///mnt
	 echo gpgcheck=0 >> /etc/yum.repos.d/mnt.repo
	 mount /iso/rhel-server-7* /mnt
	 fi
an=`rpm -qa expect | wc -l `
if [ $an -eq 0  ];then
yum -y install expect
fi
read -p "输入虚拟机序号" t
expect << EOF
spawn clone-vm7 
expect "number: " {send "$t\r"}
expect "]#"	{send "echo \r"}
EOF
yum -y install libguestfs-tools &> /dev/null
if [ $? -eq 0 ];then
echo "硬盘挂载命令  安ok" 
else
	echo ！！！！！！！！！！！！！！！！
fi
#*********************************************************
mkdir /clone"$t"
sleep 4
guestmount -a /var/lib/libvirt/images/rh7_node0"$t".img  -i  /clone$t &> /dev/null
read -p "请输入你的IP地址 ： " IP
cd /clone$t/etc/sysconfig/network-scripts
sed -ri 's/(BOOTPROTO=)(.*)/\1note/' ifcfg-eth0
sed -ri "4aIPADDR=$IP" ifcfg-eth0
sed -ri '4aNETMASK=255.255.255.0' ifcfg-eth0
sed -ri 's/(ONBOOT=)(.*)/\1yes/' ifcfg-eth0
cp /etc/yum.repos.d/mnt.repo   /clone"$t"/etc/yum.repos.d/yum.repo
sed -ri 's#(baseurl=)(.*)#\1ftp://192.168.4.254/rhel7/#' /clone$t/etc/yum.repos.d/yum.repo
cd /
umount  /clone"$t"/
read -p "输入1开机" j
if  [ $j -eq 1 ];then
 
virsh start rh7_node0$t
else
echo "设置完成，请自行启动"
fi
rm -rf /etc/yum.repos.d/*.repo
mv /wang/* /etc/yum.repos.d/
rm -rf /wang




















