#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
function extract_pkg() {
    local repo_url="$1"
    local repo_path="$2"    # 远程仓库内的路径，例如: applications/luci-app-eqos
    local local_path="$3"   # 本地存放路径，例如: package/luci-app-eqos
    local branch="${4:-master}"
    local tmp_dir="tmp_extract_$(date +%s%N)" # 使用纳秒防止重名

    echo ">>> 正在提取: $repo_path (分支: $branch)"
    
    # 使用稀疏检出模式
    git clone --depth 1 --filter=blob:none --sparse -b "$branch" "$repo_url" "$tmp_dir"
    
    if [ $? -eq 0 ]; then
        pushd "$tmp_dir" > /dev/null
        git sparse-checkout set "$repo_path"
        popd > /dev/null
        
        # 确保目标父目录存在
        mkdir -p "$(dirname "$local_path")"
        
        # 如果目标已存在则删除
        [ -d "$local_path" ] && rm -rf "$local_path"
        
        # 核心拷贝逻辑
        if [ -d "$tmp_dir/$repo_path" ]; then
            cp -r "$tmp_dir/$repo_path" "$local_path"
            echo ">>> 成功保存至: $local_path"
        else
            echo ">>> [错误] 未在仓库中找到路径: $repo_path"
        fi
    else
        echo ">>> [错误] Git 克隆失败: $repo_url"
    fi
    
    # 无论成功失败都清理
    rm -rf "$tmp_dir"
}

# --- 使用示例 ---
# 移植 immortalwrt 25.12 分支的插件
# extract_pkg "https://github.com/immortalwrt/luci" "applications/luci-app-eqos" "package/luci-app-eqos" "openwrt-25.12"

git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/passwall-packages
git clone https://github.com/Openwrt-Passwall/openwrt-passwall.git package/passwall-luci
git clone https://github.com/nikkinikki-org/OpenWrt-nikki.git package/OpenWrt-nikki
git clone https://github.com/tty228/luci-app-wechatpush.git package/luci-app-wechatpush
git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky
git clone https://github.com/sirpdboy/luci-app-advanced.git package/luci-app-advanced
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/sirpdboy/luci-app-adguardhome package/luci-app-adguardhome
extract_pkg "https://github.com/kenzok8/openwrt-packages" "adguardhome" "package/adguardhome"
extract_pkg "https://github.com/vernesong/OpenClash" "luci-app-openclash" "package/luci-app-openclash"
extract_pkg "https://github.com/timsaya/luci-app-bandix" "luci-app-bandix" "package/luci-app-bandix"
extract_pkg "https://github.com/timsaya/openwrt-bandix" "openwrt-bandix" "package/openwrt-bandix"
extract_pkg "https://github.com/immortalwrt/luci" "applications/luci-app-msd_lite" "package/luci-app-msd_lite" "openwrt-25.12"
extract_pkg "https://github.com/immortalwrt/packages" "net/msd_lite" "package/msd_lite" "openwrt-25.12"
