#!/bin/sh
echo 'architecture: (arm64/armhf/i386/amd64) (run "dpkg --print-architecture" in Termux to display it)'
read arch

file=bionic-server-cloudimg-$arch.squashfs
out="$PWD/ubuntu-$arch.tar.gz"
[ -f "$out" ] && exit 0
[ -f $file ] || wget "http://mirrors.ustc.edu.cn/ubuntu-cloud-images/bionic/current/bionic-server-cloudimg-$arch.squashfs" || exit 1
m=$(mktemp -d)
dir="$PWD"
sudo mount $file $m || exit 1
cd $m
sudo tar -czf "$out" * || exit 1
cd "$dir"
sudo chown a+r "$out" || exit 1
sudo umount $m
