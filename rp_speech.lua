local language = GetModConfigData("language")

function get_msg(id, opts)
	local msg = ""
	--正常版
    if language == "normal" then
        if     id == 1 then  msg = "我已经把权限给了（"..opts[1].."）！"
        elseif id == 2 then  msg = "我获得了（"..opts[1].."）的权限！"
        elseif id == 3 then  msg = "按U输入#del 玩家数字，我还可以回收权限哦！"
        elseif id == 4 then  msg = "可惜，不能给自己权限！"
        elseif id == 5 then  msg = "没有玩家是这个数字，请重新给权限吧！"
        elseif id == 6 then  msg = "已经收回了给（"..opts[1].."）的权限！"
        elseif id == 7 then  msg = "（"..opts[1].."）给的权限已被收回！"
        elseif id == 8 then  msg = "不能收回自己的权限哦！"
        elseif id == 9 then  msg = "没有玩家是这个数字，请重新收回权限吧！"
        elseif id == 10 then msg = "命令输入错误，请重新输入吧！"
        elseif id == 11 then msg = "命令格式：\n给权限命令：#add  数字\n收权限命令：#del  数字\n按Tab键在玩家列表左边可以查看对应的玩家数字\n建议有玩家进出时不要收给权限"
        elseif id == 12 then msg = "离别人建筑群太近了，我需要权限才能挖！"
        elseif id == 13 then msg = "（"..opts[1].."）要挖我的东西！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 14 then msg = "这是（"..opts[1].."）的东西，我需要权限！"
        elseif id == 15 then msg = "（"..opts[1].."）要挖我的东西！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 16 then msg = "我需要眼骨才能打开！"
        elseif id == 17 then msg = "（"..opts[1].."）要砸我的东西！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 18 then msg = "（"..opts[1].."）要烧我的东西！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 19 then msg = "幽灵("..opts[1]..")要作祟我的东西！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 20 then msg = "（"..opts[1].."）要打开我的东西！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 21 then msg = "（"..opts[1].."）要采我的花！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 22 then msg = "东西的主人已经离开了这个世界！" 
		elseif id == 23 then msg = "（"..opts[1].."）要拿我的东西！\n按U输入#add "..opts[3].." 可以给权限"
		elseif id == 24 then msg = "啊，感谢红猪大人的恩赐！"
        end
	--红猪欢乐版
    elseif language == "redpig_fun" then 
        if     id == 1 then  msg = "我把糖糖给了（"..opts[1].."），宝宝要乖哦！"
        elseif id == 2 then  msg = "宝宝好开心，我获得了（"..opts[1].."）的糖糖！"
        elseif id == 3 then  msg = "宝宝不乖的话，按U输入#del 玩家数字，我还可以回收糖糖哦！"
        elseif id == 4 then  msg = "哦吼，我好自恋啊！"
        elseif id == 5 then  msg = "我要找的人貌似在外星球吧！"
        elseif id == 6 then  msg = "这宝宝不乖，我已经收回了给（"..opts[1].."）的糖糖！"
        elseif id == 7 then  msg = "宝宝心里委屈，（"..opts[1].."）给的糖糖被没收了！"
        elseif id == 8 then  msg = "我是大撒币！"
        elseif id == 9 then  msg = "我要找的人貌似在外星球吧！"
        elseif id == 10 then msg = "宝宝不开心，宝宝心里委屈，但宝宝不说！"
        elseif id == 11 then msg = "命令格式：\n给权限命令：#add  数字\n收权限命令：#del  数字\n按Tab键在玩家列表左边可以查看对应的玩家数字"
        elseif id == 12 then msg = "干，离别人建筑群太近了，不能挖！"
        elseif id == 13 then msg = "（"..opts[1].."）要挖我的"..opts[2].."！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 14 then msg = "宝宝不开心，这是（"..opts[1].."）的东西，我需要权限！"
        elseif id == 15 then msg = "（"..opts[1].."）这孙子要挖我的东西！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 16 then msg = "我需要眼骨才能打开！"
        elseif id == 17 then msg = "（"..opts[1].."）这撒币要砸我的"..opts[2].."！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 18 then msg = "（"..opts[1].."）这小子要烧我的"..opts[2].."！\n按U输入#add "..opts[3].." 可以给权限，想的美"
        elseif id == 19 then msg = "幽灵("..opts[1]..")这小样要作祟我的"..opts[2].."！\n按U输入#add "..opts[3].." 可以给权限，呵呵"
        elseif id == 20 then msg = "（"..opts[1].."）要打开我的"..opts[2].."！\n按U输入#add "..opts[3].." 可以给权限"
        elseif id == 21 then msg = "（"..opts[1].."）要采我的花！\n按U输入#add "..opts[3].." 可以给权限，WTF"
        elseif id == 22 then msg = "哈哈，这东西的主人已经狗带了..." 
		elseif id == 23 then msg = "（"..opts[1].."）要拿我的东西！\n按U输入#add "..opts[3].." 可以给权限"
        end
    end
	
	return msg
	
end