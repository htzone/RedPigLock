name = " 小红猪防熊锁"
forumthread = ""
description = [[（收给权限的高级防熊锁, 防止其他玩家恶意搞破坏）
不会用的看这里哦！！！主机启用就可以了
按Y键或U键输入#add  玩家数字 可以给其他玩家权限
按Y键或U键输入#del  玩家数字 可以收回其他玩家权限
按tab键在玩家列表左边可查看相应玩家数字
例如：按U键输入#add3  即给编号3的玩家权限

鼠标右键点箱子还可以给箱子上锁和解锁哦（补充功能）

建议有玩家正在进出房间时不要收给权限，可能编号错位
更多功能请配置更多设置（离线解锁时间、防怪物摧毁等）
]]
author = "RedPig"
version = "1.4.0"
api_version = 10
priority = -9001
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true
all_clients_require_mod = false
client_only_mod = false
server_only_mod = true
server_filter_tags = {"ownership","lock","server","protect","RedPig"}

icon_atlas = "preview.xml"
icon = "preview.tex"


configuration_options =
{
    {
        name = "language",
        label = "选择语言风格",
        options =
        {
            {description = "正常版", data = "normal"},
            {description = "红猪欢乐版", data = "redpig_fun"},
        },
        default = "normal",
    },
	
	{
        name = "give_start_item",
        label = "是否给玩家初始物品",
        options =
        {
            {description = "是", data = true},
            {description = "否", data = false},
        },
        default = false,
    },
    
	{
        name = "wall_lock",
        label = "防墙砸",
        options =
        {
			{description = "开启", data = true},
            {description = "关闭", data = false},  
        },
        default = true,
    },
	
	{
        name = "cant_destroyby_monster",
        label = "防怪物摧毁建筑",
        options =
        {
			{description = "开启", data = true},
            {description = "关闭", data = false},  
        },
        default = false,
    },
	
	{
        name = "portal_clear",
        label = "防恶意封门(出生点)",
        options =
        {
			{description = "开启", data = true},
            {description = "关闭", data = false},  
        },
        default = true,
    },
	
	{
        name = "firesuppressor_dig",
        label = "防家里农作物被挖的范围",
        options =
        {
			{description = "关闭", data = -1},
            {description = "5码", data = 5},
            {description = "10码", data = 10},
			{description = "15码", data = 15},
			{description = "20码", data = 20},
			{description = "25码", data = 25},
			{description = "30码", data = 30},
        },
        default = 30,
    },
	
	{
        name = "is_allow_build_near",
        label = "防别人在自家造违规建筑",
        options =
        {
			{description = "开启", data = false}, 
			{description = "关闭", data = true}, 
        },
        default = false,
    },

	{
        name = "admin_option",
        label = "管理员要不要受权限控制",
        options =
        {
			{description = "不受", data = true},
            {description = "受<_<", data = false},  
        },
        default = true,
    },
	
    {
        name = "remove_owner_time",
        label = "玩家离线自动解锁的时间",
        options =
        {
            {description = "10秒", data = 10},
            {description = "8分钟", data = 480},
            {description = "40分钟", data = 2400},
            {description = "1小时", data = 3600},
            {description = "3小时", data = 10800},
            {description = "9小时", data = 32400},
            {description = "24小时", data = 86400},  
			{description = "永远不解锁", data = "never"},			
        },
        default = "never",
    },
	
	{
        name = "spread_fire",
        label = "火焰蔓延半径",
        options =
        {
			{description = "不蔓延", data = 0},
            {description = "一半半径", data = 1},  
			{description = "正常半径", data = 2},  
        },
        default = 1,
    },

}