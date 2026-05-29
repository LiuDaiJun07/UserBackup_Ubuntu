#!/bin/bash

show_manu(){
	clear
	echo "[1] 用户备份"
	echo "[2] 恢复用户"
	echo "[3] 退出"
}
backup(){
	read -p "请输入用户名: " username
	if ! grep -q "^$username:" /etc/passwd; then
		echo "错误：用户 $username 不存在！"
		read -p "按回车继续..."
		return
	fi
	home_dir="/home/$username"
	backup_dir="$home_dir/backups"
	timestamp=$(date +"%Y-%m-%d_%s")
	backup_file="$backup_dir/$timestamp-$username.tar.gz"
	mkdir -p "$backup_dir"
	echo "正在备份..."
	tar -zcfv "$backup_file" -C "/home" "$username"
	if [ $? -eq 0 ]; then
		echo "成功:$backup_file"
	else
		echo "失败"
	fi
	read -p "按回车继续..."
}
restore_user() {
    read -p "请输入要恢复的用户名: " username

    if ! grep -q "^$username:" /etc/passwd; then
        echo "错误：用户 $username 不存在！"
        read -p "按回车继续..."
        return
    fi

    backup_dir="/home/$username/backups"

    if [ ! -d "$backup_dir" ]; then
        echo "错误：$username 没有备份目录！"
        read -p "按回车继续..."
        return
    fi

    # 列出备份文件
    echo -e "\n可用备份文件："
    files=($backup_dir/*.tar.gz)
    if [ ${#files[@]} -eq 0 ]; then
        echo "没有找到备份文件！"
        read -p "按回车继续..."
        return
    fi

    select file in "${files[@]}"; do
        if [ -n "$file" ]; then
            restore_dir="/home/$username/restore"
            mkdir -p "$restore_dir"
            echo "正在恢复：$file"
            tar -zxvf "$file" -C "$restore_dir"
            echo "恢复完成！文件已解压到：$restore_dir"
            break
        else
            echo "无效选择！"
        fi
    done

    read -p "按回车继续..."
}

# 主程序循环
while true; do
    show_manu
    read -p "请选择菜单 [1-3]: " choice

    case $choice in
        1) backup ;;
        2) restore_user ;;
        3) echo "再见！"; exit 0 ;;
        *) echo "无效选项！"; read -p "按回车继续..." ;;
    esac
done