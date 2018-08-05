#!/data/data/com.termux/files/usr/bin/bash
folder=ubuntu-fs
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
arch=$(dpkg --print-architecture)
tarball=ubuntu-$arch.tar.gz
if [ "$first" != 1 ];then
	if [ ! -f $tarball ]; then
		echo "You need to run make-ubuntu-tar.sh in Debian GNU/Linux architecture:$arch"
		exit 1
	fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "decompressing ubuntu image"
	proot --link2symlink tar -xf ${cur}/${tarball} --exclude='dev'||:
	echo "nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 223.5.5.5
nameserver 223.6.6.6" > etc/resolv.conf
	cd "$cur"
fi
mkdir -p binds
bin=start-ubuntu.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/data/data/com.termux/files/usr/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A binds)" ]; then
    for f in binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" USER=root"
command+=" HOME=/root"
command+=" DISPLAY=:0"
command+=" LD_LIBRARY_PATH=/usr/local/lib"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=zh_CN.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

chmod +x $bin
echo "You can now launch Ubuntu with the ./${bin} script"
