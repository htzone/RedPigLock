---RedPig---2016-01-27
modimport("rp_speech.lua")
local admin_option = GetModConfigData("admin_option")
local give_start_item = GetModConfigData("give_start_item")
local firesuppressor_dig = GetModConfigData("firesuppressor_dig")
local is_allow_build_near = GetModConfigData("is_allow_build_near")
local remove_owner_time = GetModConfigData("remove_owner_time")

local wall_lock = GetModConfigData("wall_lock")
local cant_destroyby_monster = GetModConfigData("cant_destroyby_monster")
local portal_clear = GetModConfigData("portal_clear")
--print("log_new_world "..tostring(GLOBAL.os.date("%Y.%m.%d %H:%M:%S")))

TheSim = GLOBAL.TheSim
local tile_map = {}

--不可烧的物品列表
local remove_burnable_from =
{
	'beebox',
	'treasurechest', 
	'cookpot',
	'researchlab', 
	'researchlab2',
	'researchlab3',
	'researchlab4',
	'meatrack',
	'grass',
	'twig',
	'berrybush',
	'berrybush2',
	'sapling',
	'red_mushroom',
	'green_mushroom',
	'pandoraschest',
	'skullchest',
	'homesign',
	'tent',
	'siestahut',
	'dragonflychest',
	'wall_wood',
	'slow_farmplot',
	'fast_farmplot',
	'resurrectionstatue',
	'pighouse',
	'rabbithouse',
	"tallbirdnest",
	"backpack",
	"piggyback",
	"krampus_sack",
}

--不能被怪物摧毁的建筑列表
local cant_destroy_buildings = {
	"firepit", "coldfire", "coldfirepit", "cookpot", "icebox", "winterometer", "rainometer", "slow_farmplot", "fast_farmplot", "siestahut", "tent", "homesign",
	"arrowsign_post", "birdcage", "meatrack", "lightning_rod", "pottedfern", "nightlight", "nightmarelight", "researchlab",	"researchlab2",	"researchlab3",
	"researchlab4",	"treasurechest", "skullchest", "pandoraschest", "minotaurchest", "dragonflychest", "wall_hay", "wall_wood", "wall_stone", "wall_ruins",
	"wall_moonrock", "pighouse", "rabbithouse", "mermhouse", "resurrectionstatue", "ancient_altar", "ancient_altar_broken", "telebase", "eyeturret",
	"mermhead", "beebox", "firesuppressor", "catcoonden",
}


--出生点附近自动清理操作
local function portalnearautodeletefn(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.rp_near_autodelete then
			inst:AddComponent("rp_near_autodelete")
			inst.components.rp_near_autodelete:start()
		end
	end
end

if portal_clear then 
	AddPrefabPostInit("multiplayer_portal", portalnearautodeletefn)
end

--移除可燃烧属性
local function RemoveBurnable(inst)
	if GLOBAL.TheWorld.ismastersim then
		if inst and inst.components.burnable then
			inst:RemoveTag("canlight")
			inst:AddTag("nolight")
			inst:AddTag("fireimmune")
		end
	end
end

--让物品不起作用的函数（用于防止怪物摧毁建筑）
local function makeCantWorkale(inst)
	if GLOBAL.TheWorld.ismastersim then
		inst:DoTaskInTime(1, function()
			inst:AddTag("cant_destroyedby_monster")
			inst.components.hammerworkable = inst.components.workable
			inst.components.workable = nil
		end)
	end
end

--设置不可烧物品
for k,name in pairs(remove_burnable_from) do
	AddPrefabPostInit(name, RemoveBurnable)
end


if cant_destroyby_monster  then
	--设置不可被怪物摧毁的建筑
	for k, v in pairs(cant_destroy_buildings) do
		AddPrefabPostInit(v, makeCantWorkale)
	end

	--允许玩家能摧毁建筑
	AddStategraphPostInit("wilson", function(sg)
		if GLOBAL.TheWorld.ismastersim then
			local _TimeEvent14 = sg.states["hammer"].timeline[2].fn
			sg.states["hammer"].timeline[2].fn = function(inst)
				local sm = inst.sg.statemem.action
				if sm and sm.target and sm.target:HasTag("cant_destroyedby_monster") then
					sm.target.components.workable = sm.target.components.hammerworkable
				end
				_TimeEvent14(inst)
				if sm and sm.target and sm.target:HasTag("cant_destroyedby_monster") then
					sm.target.components.workable = nil
				end
			end
		end
	end)
	
end

--给多少东西给玩家
local function giveItemToPlayer(startInventory, num, prefab_name)
	for i = 1, num do
		table.insert(startInventory, prefab_name)
	end
end

--玩家初始物品（可根据自己需要自行修改）
local function StartingInventory(inst, player)

	local startInventory = {}
	
	--配置初始物品
	giveItemToPlayer(startInventory, 10, "cutgrass") --给10个草
	giveItemToPlayer(startInventory, 10, "twigs") --给10个树枝
	giveItemToPlayer(startInventory, 8, "log") --给8个木头
	giveItemToPlayer(startInventory, 8, "flint") --给8个燧石
	giveItemToPlayer(startInventory, 8, "rocks") --给8个岩石
	giveItemToPlayer(startInventory, 2, "meat") --给2个大肉
	
	--初始进入的时间是冬天或者临近冬天的时候
	if GLOBAL.TheWorld.state.iswinter or (GLOBAL.TheWorld.state.isautumn and GLOBAL.TheWorld.state.remainingdaysinseason < 5) then
		--额外给的东西
		giveItemToPlayer(startInventory, 5, "cutgrass")
		giveItemToPlayer(startInventory, 5, "twigs")
		giveItemToPlayer(startInventory, 5, "log")
		giveItemToPlayer(startInventory, 1, "heatrock") --热能石
		giveItemToPlayer(startInventory, 1, "winterhat") --冬帽
	end
		
	--春天
	if GLOBAL.TheWorld.state.isspring or (GLOBAL.TheWorld.state.iswinter and GLOBAL.TheWorld.state.remainingdaysinseason < 3) then
		giveItemToPlayer(startInventory, 1, "umbrella") --雨伞
	end		
	
	--夏天
	if GLOBAL.TheWorld.state.issummer or (GLOBAL.TheWorld.state.isspring and GLOBAL.TheWorld.state.remainingdaysinseason < 5) then
		giveItemToPlayer(startInventory, 6, "nitre") --硝石
		giveItemToPlayer(startInventory, 6, "ice") --冰
		giveItemToPlayer(startInventory, 1, "heatrock")
		giveItemToPlayer(startInventory, 1, "strawhat") --西瓜帽
	end

	--夜晚
	if GLOBAL.TheWorld.state.isnight or (GLOBAL.TheWorld.state.isdusk and GLOBAL.TheWorld.state.timeinphase > .8) then
		giveItemToPlayer(startInventory, 1, "torch") --火炬
	end

	--如果初始点在洞穴
	if GLOBAL.TheWorld:HasTag("cave") then
		giveItemToPlayer(startInventory, 1, "minerhat") --矿工帽
	end

	--如果是PVP模式
	if GLOBAL.TheNet:GetPVPEnabled() then
		giveItemToPlayer(startInventory, 1, "spear") --长矛
		giveItemToPlayer(startInventory, 1, "footballhat") --皮帽
	end

	--实现玩家第一次进入时获取初始物品的功能
	player.CurrentOnNewSpawn = player.OnNewSpawn or function() return true end
	player.OnNewSpawn = function(...)
		if math.random() < .1 and player.components.talker then
			player.components.talker:Say(get_msg(24), 5)
		end
		player.components.inventory.ignoresound = true
		if startInventory ~= nil and #startInventory > 0 then
			for i, itemName in pairs(startInventory) do
				player.components.inventory:GiveItem(GLOBAL.SpawnPrefab(itemName))
			end
		end
		return player.CurrentOnNewSpawn(...)
	end
	
end

--local AllPlayers = GLOBAL.AllPlayers
--保存所有玩家的集合
local AllPlayers = {}
--保存离开玩家的集合
local LeavedPlayers = {}

--通过id来获取到玩家
function GetPlayerById(id)
	local player  = ""
    for _,p in pairs(AllPlayers) do
        if p.userid == id then 
            player = p  
        end
    end
	return player
end

--命令处理 9种情况
AddPrefabPostInit("world", function(inst)
    if GLOBAL.TheWorld.ismastersim then --判断是不是主机
		--监听玩家安置，给初始物品
		if give_start_item then 
			inst:ListenForEvent("ms_playerspawn", StartingInventory, inst)
		end
		
		--根据玩家说的话来对命令进行处理
        local OldNetworking_Say = GLOBAL.Networking_Say
        GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper)
        local r = OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper)

        if GetPlayerById(userid) == "" then
            return r
        end
		
		--获取到玩家说的话
        local words = {}
        for word in string.gmatch(message, "%S+") do
            table.insert(words, word) --分词
        end

        local talker = GetPlayerById(userid)
        local recipient = nil
		--local content = string.gsub(message, "\s+", "") --去掉所有空格
		
		if string.sub(message,1,1) == "#" then
			if tablelength(words) == 2 and words[1] == "#add"  
			and GLOBAL.tonumber(words[2]) ~= nil and AllPlayers[GLOBAL.tonumber(words[2])] ~= nil 
			then
				--正常给权限
				recipient = AllPlayers[GLOBAL.tonumber(words[2])]
				for n,player in pairs(AllPlayers) do
				  
					if player.userid == recipient.userid  and recipient.userid ~= talker.userid then 
						--交个朋友吧
						if  talker.friends == nil then 
							talker.friends = {}
							talker.friends[recipient.userid] = 1
						else
							talker.friends[recipient.userid] = 1
						end
		
						if  player.friends == nil then 
							player.friends = {}
							player.friends[talker.userid] = 1
						else
							player.friends[talker.userid] = 1
						end
						
						--添加Tag
						local ents = GLOBAL.TheSim:FindEntities(0, 0, 0, 1000,{"userid_"..talker.userid})
						for _,obj in pairs(ents) do
							obj:AddTag("userid_"..recipient.userid)
							obj.saveTaglist[recipient.userid] = 1
						end
		
						--说话提示
						if talker and talker.components.talker and recipient then 
							talker.components.talker:Say(get_msg(1,{recipient.name}))
						end
						
						if recipient and recipient.components.talker and talker then
							recipient.components.talker:Say(get_msg(2,{talker.name}))				
						end
						
						if talker and talker.components.talker then 
							talker:DoTaskInTime(2.5, function ()
								talker.components.talker:Say(get_msg(3))
							end)
						end
						
					elseif  recipient.userid == talker.userid then --把权限给了自己
						if talker and talker.components.talker then 
							talker.components.talker:Say(get_msg(4))
						end
					end
					
				end
				   	   
			elseif tablelength(words) == 2 and words[1] == "#add"  
			and GLOBAL.tonumber(words[2]) ~= nil and AllPlayers[GLOBAL.tonumber(words[2])] == nil
			then
				--给的玩家不存在
				if talker and talker.components.talker then
					talker.components.talker:Say(get_msg(5))
				end
			
			elseif tablelength(words) == 1 and string.sub(message,1,4) == "#add" and GLOBAL.tonumber(string.sub(message,5,string.len(message))) ~= nil and AllPlayers[GLOBAL.tonumber(string.sub(message,5,string.len(message)))] ~= nil then
				--只有一个词，中间无空格，正常给权限
				recipient = AllPlayers[GLOBAL.tonumber(string.sub(message,5,string.len(message)))]
				for n,player in pairs(AllPlayers) do
			  
					if player.userid == recipient.userid  and recipient.userid ~= talker.userid then 
						--交个朋友吧
						if  talker.friends == nil then 
							talker.friends = {}
							talker.friends[recipient.userid] = 1
						else
							talker.friends[recipient.userid] = 1
						end
		
						if  player.friends == nil then 
							player.friends = {}
							player.friends[talker.userid] = 1
						else
							player.friends[talker.userid] = 1
						end
						
						--添加Tag
						local ents = GLOBAL.TheSim:FindEntities(0, 0, 0, 1000,{"userid_"..talker.userid})
						for _,obj in pairs(ents) do
							obj:AddTag("userid_"..recipient.userid)
							obj.saveTaglist[recipient.userid] = 1
						end
		
						--说话提示
						if talker and talker.components.talker and recipient then 
							talker.components.talker:Say(get_msg(1,{recipient.name}))
						end
						
						if recipient and recipient.components.talker and talker then
							recipient.components.talker:Say(get_msg(2,{talker.name}))				
						end
						
						if talker and talker.components.talker then 
							talker:DoTaskInTime(2.5, function ()
								talker.components.talker:Say(get_msg(3))
							end)
						end
						
					elseif  recipient.userid == talker.userid then --把权限给了自己
						if talker and talker.components.talker then 
							talker.components.talker:Say(get_msg(4))
						end
					end
				
			   end
			
			elseif tablelength(words) == 1 and string.sub(message,1,4) == "#add" and GLOBAL.tonumber(string.sub(message,5,string.len(message))) ~= nil and AllPlayers[GLOBAL.tonumber(string.sub(message,5,string.len(message)))] == nil then
				--一个词，给的玩家不存在
				if talker and talker.components.talker then
					talker.components.talker:Say(get_msg(5))
				end
				
			elseif tablelength(words) == 2 and words[1] == "#del"  
			and GLOBAL.tonumber(words[2]) ~= nil and AllPlayers[GLOBAL.tonumber(words[2])] ~= nil
			then
				--正常收回权限
				recipient = AllPlayers[GLOBAL.tonumber(words[2])]
				for n,player in pairs(AllPlayers) do
					if player.userid == recipient.userid and recipient.userid ~= talker.userid and recipient.friends ~= nil and talker.friends~=nil then 
						--解除朋友关系
						recipient.friends[talker.userid] = nil
						talker.friends[recipient.userid] = nil
						
						--移除Tag
						local ents = GLOBAL.TheSim:FindEntities(0, 0, 0, 1000,{"userid_"..talker.userid})
						for _,obj in pairs(ents) do
							 if obj.ownerlist ~= nil and tablelength(obj.ownerlist) ~= 0 and obj.ownerlist[talker.userid] == 1 and obj:HasTag("userid_"..recipient.userid) then
								obj:RemoveTag("userid_"..recipient.userid)
								obj.saveTaglist[recipient.userid] = nil
							end
						end
						
						--说话提示
						if talker and talker.components.talker and recipient then
							talker.components.talker:Say(get_msg(6,{recipient.name}))
						end
						
						if recipient and recipient.components.talker and talker then
							recipient.components.talker:Say(get_msg(7,{talker.name}))
						end
						
					elseif recipient.userid == talker.userid then 
						--不能收回自己的权限
						if talker and talker.components.talker then
							talker.components.talker:Say(get_msg(8))
						end
					end
				end
			
			elseif tablelength(words) == 2 and words[1] == "#del"  
			and GLOBAL.tonumber(words[2]) ~= nil and AllPlayers[GLOBAL.tonumber(words[2])] == nil
			then
				--收的玩家不存在
				if talker and talker.components.talker then
					talker.components.talker:Say(get_msg(9))
				end
				
			elseif tablelength(words) == 1 and string.sub(message,1,4) == "#del" and GLOBAL.tonumber(string.sub(message,5,string.len(message))) ~= nil and AllPlayers[GLOBAL.tonumber(string.sub(message,5,string.len(message)))] ~= nil then
				--一个词，正常收回权限
				recipient = AllPlayers[GLOBAL.tonumber(string.sub(message,5,string.len(message)))]
				for n,player in pairs(AllPlayers) do
					if player.userid == recipient.userid and recipient.userid ~= talker.userid and recipient.friends ~= nil and talker.friends~=nil then 
						--解除朋友关系
						recipient.friends[talker.userid] = nil
						talker.friends[recipient.userid] = nil
						
						--移除Tag
						local ents = GLOBAL.TheSim:FindEntities(0, 0, 0, 1000,{"userid_"..talker.userid})
						for _,obj in pairs(ents) do
							 if obj.ownerlist ~= nil and tablelength(obj.ownerlist) ~= 0 and obj.ownerlist[talker.userid] == 1 and obj:HasTag("userid_"..recipient.userid) then
								obj:RemoveTag("userid_"..recipient.userid)
								obj.saveTaglist[recipient.userid] = nil
							end
						end
						
						--说话提示
						if talker and talker.components.talker and recipient then
							talker.components.talker:Say(get_msg(6,{recipient.name}))
						end
						
						if recipient and recipient.components.talker and talker then
							recipient.components.talker:Say(get_msg(7,{talker.name}))
						end
						
					elseif recipient.userid == talker.userid then 
						--不能收回自己的权限
						if talker and talker.components.talker then
							talker.components.talker:Say(get_msg(8))
						end
					end
				end
				
			elseif tablelength(words) == 1 and string.sub(message,1,4) == "#del" and GLOBAL.tonumber(string.sub(message,5,string.len(message))) ~= nil and AllPlayers[GLOBAL.tonumber(string.sub(message,5,string.len(message)))] == nil then
				--一个词，收的玩家不存在
				if talker and talker.components.talker then
					talker.components.talker:Say(get_msg(9))
				end

			else
				--命令输入有误
				if talker and talker.components.talker then
					talker.components.talker:Say(get_msg(10))
				end
				
				talker:DoTaskInTime(2.5, function ()
				   if talker and talker.components.talker then
					talker.components.talker:Say(get_msg(11),4)
				   end
				end)
				
			end
		end

        return r
        end
    end
    
end)

-----权限保存与加载----
local function OnSave(inst, data)
	if inst.OldOnSave ~= nil then
		inst.OldOnSave(inst,data)
	end
	if inst.saveTaglist ~= nil then
		data.saveTaglist = inst.saveTaglist
	end
	if inst.ownerlist ~= nil then
		data.ownerlist = inst.ownerlist
	end
	if inst.saved_ownerlist ~= nil then 
		data.saved_ownerlist = inst.saved_ownerlist
	end
end

local function OnLoad(inst,data)
	if inst.OldOnLoad ~= nil then
		inst.OldOnLoad(inst,data)
	end
	if data ~= nil then 
		if data.saveTaglist ~= nil then
			inst.saveTaglist = data.saveTaglist
			for owner_userid,_ in pairs(data.saveTaglist) do
				inst:AddTag("userid_"..owner_userid)
			end
		end
		
		if data.ownerlist ~= nil then
			inst.ownerlist = data.ownerlist
		end
		
		if data.saved_ownerlist ~= nil then
			inst.saved_ownerlist = data.saved_ownerlist
		end	
	end 
end

for k, v in pairs(GLOBAL.AllRecipes) do
	local recipename = v.name
	AddPrefabPostInit(recipename,function(inst)
		inst.OldOnSave = inst.OnSave
		inst.OnSave = OnSave
		inst.OldOnLoad = inst.OnLoad
		inst.OnLoad = OnLoad
	end)
end

--防砸的墙
local walls_table = {
"wall_stone",
"wall_wood",
"wall_straw",
"wall_ruins",
"wall_moonrock",
}

for _, wall_name in pairs(walls_table) do
	AddPrefabPostInit(wall_name, function(inst)
		inst.OldOnSave = inst.OnSave
		inst.OnSave = OnSave
		inst.OldOnLoad = inst.OnLoad
		inst.OnLoad = OnLoad
	end)
end

--------------------添加Tag---------------------------
-------------------------------------------------------
--建造新的物品，为每个建造的新物品都添加Tag
local function OnBuildNew(doer, prod) 
	if prod and (not prod.components.inventoryitem or prod.components.container) then --仓库物品除了背包以外都不需要加Tag
		--print(doer.name.."--build-->"..prod.name)
		prod.ownerlist = {}
		prod.saveTaglist = {}
		prod.ownerlist[doer.userid] = 1
		prod:AddTag("userid_"..doer.userid)
		prod.saveTaglist[doer.userid] = 1
		
		if  doer.friends ~= nil then --如果有盆友，则盆友也可使用
			for friend,_ in pairs(doer.friends) do
				prod:AddTag("userid_"..friend)
				prod.saveTaglist[friend] = 1
			end
		end
	end
	
    if doer.components.builder.old_onBuild then
        doer.components.builder.old_onBuild(doer, prod)
    end
end

--丢东西
--[[
local old_DROP = GLOBAL.ACTIONS.DROP.fn
GLOBAL.ACTIONS.DROP.fn = function(act)

	if GLOBAL.TheWorld.ismastersim == false then return old_DROP(act) end
	
	local x = act.pos.x
    local y = act.pos.y
    local z = act.pos.z
	print("drop!!")
	act.doer:DoTaskInTime(0, function ()
		local ents = GLOBAL.TheSim:FindEntities(x, y, z, 0)
		for g,obj in pairs(ents) do
			--print(act.doer.name.."--drop-->"..obj.prefab)
		end
	end)
	
	return old_DROP(act)
	
end
]]--

--安置物品，为每个安置的新物品都添加Tag
local old_DEPLOY = GLOBAL.ACTIONS.DEPLOY.fn 
GLOBAL.ACTIONS.DEPLOY.fn = function(act)
    if GLOBAL.TheWorld.ismastersim == false then return old_DEPLOY(act) end
	
    local x = act.pos.x
    local y = act.pos.y
    local z = act.pos.z
	
	act.doer:DoTaskInTime(0, function ()

		if wall_lock and act and act.invobject and string.find(act.invobject.prefab, "wall_") then --判断安置的是否为墙
			x = math.floor(x) + .5
			z = math.floor(z) + .5
		end

		--if act and act.invobject and string.find(act.invobject.prefab, "turf_") then
			--print(act.doer.name.."--deploy-->"..act.invobject.prefab)
			--print("act_pos: "..tostring(act.pos))
			--tile_map[tostring(act.pos)] = act.doer.userid
		--end
		
		local ents = GLOBAL.TheSim:FindEntities(x, y, z, 0)
		
		for _,obj in pairs(ents) do
			--print(act.doer.name.."--deploy-->"..obj.prefab)
			obj.ownerlist = {}
			obj.saveTaglist = {}
			obj.ownerlist[act.doer.userid] = 1
			obj:AddTag("userid_"..act.doer.userid)
			obj.saveTaglist[act.doer.userid] = 1
			if  act.doer.friends ~= nil then --如果有盆友，则盆友也可使用
				for friend,_ in pairs(act.doer.friends) do
					obj:AddTag("userid_"..friend)
					obj.saveTaglist[friend] = 1
				end
			end
		end

	end)

    return old_DEPLOY(act)
end

--用晾肉架
local old_DRY = GLOBAL.ACTIONS.DRY.fn 
GLOBAL.ACTIONS.DRY.fn = function(act)
 if GLOBAL.TheWorld.ismastersim == false then return old_DRY(act) end
	--print(act.doer.name.."--dry--"..act.target.name)
	act.doer:DoTaskInTime(0, function ()
		act.target.ownerlist = {}
		act.target.saveTaglist = {}
		act.target.ownerlist[act.doer.userid] = 1
		act.target:AddTag("userid_"..act.doer.userid)
		act.target.saveTaglist[act.doer.userid] = 1
		--print(act.doer.name.."--dry--"..act.target.name)
		if  act.doer.friends ~= nil then 
			for friend,_ in pairs(act.doer.friends) do
				act.target:AddTag("userid_"..friend)
				act.target.saveTaglist[friend] = 1
			end
		end
	end)	
    return old_DRY(act)
end

--------------------检测Tag来防熊---------------------
--------------------------------------------------------
--防采肉架上的肉干和封箱蜂蜜
local old_HARVEST = GLOBAL.ACTIONS.HARVEST.fn 
GLOBAL.ACTIONS.HARVEST.fn = function(act)
if GLOBAL.TheWorld.ismastersim == false then return old_HARVEST(act) end
	--print(act.doer.name.."--harvest--"..act.target.prefab)
    if act.target and (act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or act.doer:HasTag("player") == false or act.target:HasTag("userid_"..act.doer.userid) or act.target.prefab == "cookpot" or (admin_option and act.doer.Network:IsServerAdmin())) then
		return old_HARVEST(act)
	else
        --print("HAUNT--"..tostring(doer).."--NoTag--fail--")
		--判断目标是否存在
		if not act.target then 
			return old_HARVEST(act)
		end 
		
        doer_num = ""
        for n,p in pairs(AllPlayers) do
            if act.doer.userid == p.userid then 
                doer_num = n
            end
        end
		local found = false
        for owner_userid,_ in pairs(act.target.ownerlist) do
            for _,p in pairs(AllPlayers) do
                if owner_userid == p.userid then 
					found = true
				    act.doer:DoTaskInTime(0, function ()
							--act.doer.components.talker:Say("这是（"..p.name.."）的东西，我不能作祟！")
							act.doer.components.talker:Say("这是（"..p.name.."）的东西，我不能拿！")
                    end)
                    p.components.talker:Say(get_msg(23,{act.doer.name,act.target.name,doer_num}))
                end
            end	
        end
		if not found then 
            act.doer.components.talker:Say(get_msg(22))
        end
        return false
	end
	return old_HARVEST(act)
end

--防止玩家挖别人东西
local old_DIG = GLOBAL.ACTIONS.DIG.fn 
GLOBAL.ACTIONS.DIG.fn = function(act)
  
	if GLOBAL.TheWorld.ismastersim == false then return old_DIG(act) end
	print(act.doer.name.."--dig--"..act.target.prefab)
	if  act.target and (act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or act.doer:HasTag("player") == false or act.target:HasTag("userid_"..act.doer.userid) or (admin_option and act.doer.Network:IsServerAdmin())) then
		--如果东西没有主人或为管理员则直接可挖
		return old_DIG(act)
	else 
		if not act.target then 
			return old_DIG(act)
		end 
	
		--主人不为自己时，判断周围有无别人的建筑群，如果有则不可挖，否则可挖
		if firesuppressor_dig > 0 then 
			local ents = {}
			local x, y, z = act.target.Transform:GetWorldPosition()
			ents = GLOBAL.TheSim:FindEntities(x, y, z, firesuppressor_dig)
			local structure_num = 0
			for _,obj in pairs(ents) do

				if obj and obj:HasTag("structure") and obj:HasTag("userid_"..act.doer.userid) == false then
					--print("has structure!!!")
					structure_num = structure_num + 1 
				end
				
			end
			if structure_num >= 2 then 
				act.doer:DoTaskInTime(0, function ()
						--act.doer.components.talker:Say("离别人建筑群太近了，我不能挖！")
					act.doer.components.talker:Say(get_msg(12))
				end)
				--print("dig NO")
				return false
			end
		end
		--print("dig OK")		
		return old_DIG(act)	 
	end
	
end

--防止玩家砸别人物品
local old_HAMMER = GLOBAL.ACTIONS.HAMMER.fn
GLOBAL.ACTIONS.HAMMER.fn = function(act)
	--print(act.doer.name.."--HAMMER--"..act.target.prefab)
	if act.doer:HasTag("beaver") then
		return false
	end
	
	if cant_destroyby_monster and act.target:HasTag("cant_destroyedby_monster") then
		act.target.components.workable = act.target.components.hammerworkable
	end
	
    if GLOBAL.TheWorld.ismastersim == false then
		local ret = old_HAMMER(act)
		if cant_destroyby_monster and act.target:HasTag("cant_destroyedby_monster") then
			act.target.components.workable = nil
		end
		return ret
	end
	
	
    if  act.target and (act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or act.doer:HasTag("player") == false or act.target:HasTag("userid_"..act.doer.userid) or (admin_option and act.doer.Network:IsServerAdmin())) then    
        
		local ret = old_HAMMER(act)
		if cant_destroyby_monster and act.target:HasTag("cant_destroyedby_monster") then
			act.target.components.workable = nil
		end
		return ret
		
    else

	   if not act.target then 
			local ret = old_HAMMER(act)
			if cant_destroyby_monster and act.target:HasTag("cant_destroyedby_monster") then
				act.target.components.workable = nil
			end
			return ret
	   end 
	   
       doer_num = ""
       for n,p in pairs(AllPlayers) do
                if act.doer.userid == p.userid then 
                    doer_num = n
                end
       end
	   
	   local found = false
       for owner_userid,_ in pairs(act.target.ownerlist) do
                for _,p in pairs(AllPlayers) do  
                    if owner_userid == p.userid then 
                        found = true
                        act.doer:DoTaskInTime(0, function ()	
							--act.doer.components.talker:Say("这是（"..p.name.."）的东西，我需要权限！")
							act.doer.components.talker:Say(get_msg(14,{p.name,act.target.name}))
                        end)
                        p.components.talker:Say(get_msg(17,{act.doer.name,act.target.name,doer_num}))
                    end
                end   
        end
		
		if not found then 
            act.doer.components.talker:Say(get_msg(22))
        end
		
        return false
		
    end   
end

--防止玩家作祟别人东西
local old_HAUNT = GLOBAL.ACTIONS.HAUNT.fn
GLOBAL.ACTIONS.HAUNT.fn = function(act)
    if GLOBAL.TheWorld.ismastersim == false then return old_HAUNT(act) end
    --print("GLOBAL.ACTIONS.HAUNT--"..tostring(act.doer.name).."--"..tostring(act.target))
    if  act.target and (act.target.ownerlist == nil or act.target:HasTag("userid_"..act.doer.userid) or (admin_option and act.doer.Network:IsServerAdmin())) then
        --print("HAUNT--"..tostring(doer).."--HasTag--ok--")
        return old_HAUNT(act)
    else
        --print("HAUNT--"..tostring(doer).."--NoTag--fail--")
		if not act.target then
			return old_HAUNT(act)
		end 
		
        doer_num = ""
        for n,p in pairs(AllPlayers) do
            if act.doer.userid == p.userid then 
                doer_num = n
            end
        end
		local found = false
        for owner_userid,_ in pairs(act.target.ownerlist) do
            for _,p in pairs(AllPlayers) do
                if owner_userid == p.userid then
				    found = true
				    act.doer:DoTaskInTime(0, function ()
							--act.doer.components.talker:Say("这是（"..p.name.."）的东西，我不能作祟！")
							act.doer.components.talker:Say(get_msg(14,{p.name,act.target.name}))
                    end)
				    
                    p.components.talker:Say(get_msg(19,{act.doer.name,act.target.name,doer_num}))
                end
            end	
        end
		if not found then 
            act.doer.components.talker:Say(get_msg(22))
        end
        return false
    end 
end

--防止玩家魔法攻击别人的建筑
local old_CASTSPELL = GLOBAL.ACTIONS.CASTSPELL.fn
GLOBAL.ACTIONS.CASTSPELL.fn = function(act)
    --For use with magical staffs
	if GLOBAL.TheWorld.ismastersim == false then return old_CASTSPELL(act) end
    local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    if staff and staff.components.spellcaster and staff.components.spellcaster:CanCast(act.doer, act.target, act.pos) then

		if act.target and (act.target:HasTag("structure") and act.target:HasTag("userid_"..act.doer.userid) == false and act.target.ownerlist ~= nil) then 
			act.doer:DoTaskInTime(0, function ()
				act.doer.components.talker:Say("这是别人的建筑不能这么做！")
            end)
			return false
		else
			if not act.target then
				staff.components.spellcaster:CastSpell(act.target, act.pos)
				return true
			end 
			local ents = {}
            local x, y, z = act.target.Transform:GetWorldPosition()
            ents = GLOBAL.TheSim:FindEntities(x, y, z, 6)
            for _,obj in ipairs(ents) do
                -- print("test",obj.persists, obj:IsValid(),obj.ownerlist,obj:HasTag("userid_"..act.doer.userid) )
                if obj:HasTag("structure") and ((obj.persists and obj:IsValid() and obj.ownerlist ~= nil ) and obj:HasTag("userid_"..act.doer.userid) == false ) then
                    --act.doer.components.talker:Say(get_msg(23))
					act.doer:DoTaskInTime(0, function ()
							--act.doer.components.talker:Say("离灭火器太近了，我不能挖！")
							act.doer.components.talker:Say("目标附近有别人的建筑，不能这么做！")
                    end)
                    return false
                end
            end
		end
       staff.components.spellcaster:CastSpell(act.target, act.pos)
       return true
    end
	
end

--别人建筑附近不能建造建筑
local old_BUILD = GLOBAL.ACTIONS.BUILD.fn
GLOBAL.ACTIONS.BUILD.fn = function(act)
	if GLOBAL.TheWorld.ismastersim == false then return old_BUILD(act) end

	if admin_option and act.doer.Network:IsServerAdmin() then --管理员直接可造
		return old_BUILD(act)
	end
	
	if not table.contains(cant_destroy_buildings, act.recipe) then --非建筑的话直接可造
		--print(act.doer.name.."--BUILD--"..act.recipe)
		return old_BUILD(act)
	end
	
	if not is_allow_build_near then 
		local cant_build_radius = 12
		if cant_build_radius > 0 then 
			local ents = {}
			local x, y, z = act.doer.Transform:GetWorldPosition()
			ents = GLOBAL.TheSim:FindEntities(x, y, z, cant_build_radius)
			for _,obj in ipairs(ents) do
						-- print("test",obj.persists, obj:IsValid(),obj.ownerlist,obj:HasTag("userid_"..act.doer.userid) )
				if (obj and obj:IsValid() and obj.ownerlist ~= nil ) and obj:HasTag("structure") and obj:HasTag("userid_"..act.doer.userid) == false  then
								--act.doer.components.talker:Say(get_msg(23))
					act.doer:DoTaskInTime(0, function ()
						act.doer.components.talker:Say("离别人建筑太近了，不能建造，需要权限！")
					end)

				return false
				end
			end
		end
	end
    return old_BUILD(act)
end


--tile_map[pos] = user_id

--防挖别人的草皮（还没来得及没写呢）
local old_TERRAFORM = GLOBAL.ACTIONS.TERRAFORM.fn
GLOBAL.ACTIONS.TERRAFORM.fn = function(act)
	--if tile_map[tostring(act.pos)] 
	--and tile_map[tostring(act.pos)] == act.doer.userid 
	--then
		--print(act.doer.name.."--TERRAFORM--"..act.invobject.prefab)
	--end

	return old_TERRAFORM(act)
    --if act.invobject ~= nil and act.invobject.components.terraformer ~= nil then
    --    return act.invobject.components.terraformer:Terraform(act.pos)
    --end
end

--右键开锁控制
local old_TURNON = GLOBAL.ACTIONS.TURNON.fn
GLOBAL.ACTIONS.TURNON.fn = function(act)
	if GLOBAL.TheWorld.ismastersim == false then return old_TURNON(act) end
	if act.target and (act.target.prefab == "treasurechest" or act.target.prefab == "icebox" or act.target.prefab == "dragonflychest" or act.target.prefab == "cellar") then
		if act.target.ownerlist ~= nil and act.target.ownerlist[act.doer.userid] == 1 then  
			act.doer:DoTaskInTime(0, function ()
				act.doer.components.talker:Say("已开锁！任何人都能打开")
			end)
			return old_TURNON(act)
		else
			act.doer:DoTaskInTime(0, function ()
				act.doer.components.talker:Say("可惜，我不能给它上锁和开锁！")
			end)
			return false
		end
	else
		return old_TURNON(act)
	end
	
end

--右键上锁控制
local old_TURNOFF = GLOBAL.ACTIONS.TURNOFF.fn
GLOBAL.ACTIONS.TURNOFF.fn = function(act)
    if GLOBAL.TheWorld.ismastersim == false then return old_TURNOFF(act) end
	if act.target and (act.target.prefab == "treasurechest" or act.target.prefab == "icebox" or act.target.prefab == "dragonflychest" or act.target.prefab == "cellar") then
		if act.target.saved_ownerlist ~= nil and act.target.saved_ownerlist[act.doer.userid] == 1 then   
			act.doer:DoTaskInTime(0, function ()
				act.doer.components.talker:Say("已上锁！只有自己能打开")
			end)
			return old_TURNOFF(act)
		else
			act.doer:DoTaskInTime(0, function ()
				act.doer.components.talker:Say("可惜，我不能给它上锁和开锁！")
			end)
			return false
		end
	else
		return old_TURNOFF(act)
	end
   
end

---防止炸药炸毁建筑---
AddComponentPostInit("explosive", function(explosive, inst)
		inst.buildingdamage = 0
		explosive.CurrentOnBurnt = explosive.OnBurnt
		function explosive:OnBurnt()
			local x, y, z = inst.Transform:GetWorldPosition()
			--local ents2 = GLOBAL.TheSim:FindEntities(x, y, z, explosive.explosiverange, nil, { "INLIMBO" })
			local ents2 = GLOBAL.TheSim:FindEntities(x, y, z, 10)
			local nearbyStructure = false
			for k, v in ipairs(ents2) do
				if v.components.burnable ~= nil and not v.components.burnable:IsBurning() then
					if v:HasTag("structure") then
						nearbyStructure = true
					end
				end
			end
			--
			if nearbyStructure then  --Make sure structures aren't lit on fire (indirectly) from explosives
				--for k, v in ipairs(ents3) do
				--	if v:IsValid() and not v:IsInLimbo() and v.components.burnable ~= nil and v.components.burnable:IsBurning() then
				--		v.components.burnable:Extinguish(true, 100)
				--	end
				--end
				inst:RemoveTag("canlight")
			else
				inst:AddTag("canlight")
				explosive:CurrentOnBurnt()
			end
		end
end)

--防止玩家采别人的花
AddComponentPostInit("pickable", function(Pickable, target)
    Pickable.oldPickFn = Pickable.Pick
    if GLOBAL.TheWorld.ismastersim == false then return Pickable:oldPickFn(doer) end
    function Pickable:Pick(doer)
		if target and target.prefab == "flower" then 
			if target.ownerlist == nil or tablelength(target.ownerlist) == 0 or doer:HasTag("player") == false or target:HasTag("userid_"..doer.userid) or (admin_option and doer.Network:IsServerAdmin()) then
				return Pickable:oldPickFn(doer)
			else
				local doer_num = ""
				for n,p in pairs(AllPlayers) do
					if doer.userid == p.userid then 
						doer_num = n
					end
				end
				for owner_userid,_ in pairs(target.ownerlist) do
					for _,p in pairs(AllPlayers) do
						if owner_userid == p.userid then 
							doer:DoTaskInTime(0, function ()
								doer.components.talker:Say("这是（"..p.name.."）的花，我不能采！ ")
							end)
							p.components.talker:Say(get_msg(21,{doer.name,target.name,doer_num}))
						end
					end
				end
				return false
			end
		end
		return Pickable:oldPickFn(doer)
    end
end)

--防止玩家打开别人的容器
AddComponentPostInit("container", function(Container, target)
    Container.OriginalOpenFn = Container.Open
    if GLOBAL.TheWorld.ismastersim == false then return Container:OriginalOpenFn(doer) end
    function Container:Open(doer)
        if target and (target.ownerlist == nil or tablelength(target.ownerlist) == 0 or target:HasTag("userid_"..doer.userid) or (target.prefab and target.prefab == "cookpot")) or (admin_option and doer.Network:IsServerAdmin()) then
            --print("OPEN--"..tostring(GLOBAL.os.date("%Y.%m.%d %H:%M:%S"))..tostring(doer.userid).."|"..tostring(doer.name).."|"..tostring(target).."--ok--")
            return Container:OriginalOpenFn(doer)
        else
            --print("OPEN--"..tostring(GLOBAL.os.date("%Y.%m.%d %H:%M:%S"))..tostring(doer.userid).."|"..tostring(doer.name).."|"..tostring(target).."--fail--")
			if not target then 
				return Container:OriginalOpenFn(doer)
			end 
			
            local doer_num = ""
            for n,p in pairs(AllPlayers) do
                if doer.userid == p.userid then 
                    doer_num = n
                end
            end
			local found = false
            for owner_userid,_ in pairs(target.ownerlist) do
                for _,p in pairs(AllPlayers) do     
                    if owner_userid == p.userid then 
                        found = true
                        doer:DoTaskInTime(0, function ()
                            --doer.components.talker:Say("这是（"..p.name.."）的东西，我需要权限！")
							doer.components.talker:Say(get_msg(14,{p.name,target.name}))
                        end)
                        p.components.talker:Say(get_msg(20,{doer.name,target.name,doer_num}))
                    end
                end    
            end
			if not found then 
                doer.components.talker:Say(get_msg(22))
            end
        end
    end
end)

--重写玩家建造方法
AddPlayerPostInit(function(inst) 
    if GLOBAL.TheWorld.ismastersim then 
        if inst.components.builder then
            if inst.components.builder.onBuild then

                inst.components.builder.old_onBuild = inst.components.builder.onBuild
            end
            inst.components.builder.onBuild = OnBuildNew
        end
    end

end)

--监听玩家进入游戏
AddComponentPostInit("playerspawner", function(OnPlayerSpawn, inst)
    inst:ListenForEvent("ms_playerjoined", function(inst, player)
		AllPlayers = {}

        if GLOBAL.TheNet:IsDedicated() then
             print("Its dedicated server")
             for n,p in ipairs(GLOBAL.TheNet:GetClientTable()) do
                    if n ~= 1 then 
                    --print("n "..tostring(n).." p "..tostring(p.name))
                        for n2,p2 in ipairs(GLOBAL.AllPlayers) do
                            --print("n2:"..tostring(n2))
                            if p2.userid == p.userid then 
                                --print("n:"..tostring(n).." p: "..tostring(p).." p2: "..tostring(p2))
                                AllPlayers[n-1] = p2
                            end
                        end
                    end
             end
        else
            print("Its standalone server")
            for n,p in ipairs(GLOBAL.TheNet:GetClientTable()) do
                    --print("n "..tostring(n).." p "..tostring(p.name))
                        for n2,p2 in ipairs(GLOBAL.AllPlayers) do
                            --print("n2:"..tostring(n2))
                            if p2.userid == p.userid then 
                                --print("n:"..tostring(n).." p: "..tostring(p).." p2: "..tostring(p2))
                                AllPlayers[n] = p2
                            end
                        end
            end
        end
			
        if player and player.components then
            if LeavedPlayers[player.userid] ~= nil then 
                LeavedPlayers[player.userid]:Cancel()
            end
            --print("try to add owner "..tostring(player.userid).."|"..tostring(player.name))
            local e=TheSim:FindEntities(0,0,0,10000)
            for i,v in ipairs(e) do
                if v.persists and v:HasTag("saved_userid_"..player.userid) and v:IsValid()  then
                    v:RemoveTag("saved_userid_"..player.userid)
                    v:AddTag("userid_"..player.userid)
					v.saveTaglist[player.userid] = 1
                    v.ownerlist[player.userid] = 1
                    --print(tostring(player).."--"..tostring(i).."--restored--"..tostring(v))
                end
            end
            
            for _,p in pairs(AllPlayers) do
                if p.userid ~= player.userid and p.friends ~= nil and tablelength(p.friends) ~= 0 then 
                    for check_friend,_ in pairs(p.friends) do
                        if player.userid == check_friend then 
                           -- print(player.userid .." found friend! "..check_friend)
                            if  player.friends == nil then 
                                player.friends = {}
                                player.friends[check_friend] = 1
                            else
                                player.friends[check_friend] = 1
                            end
                            for i,v in ipairs(e) do
                                if v.persists and v:HasTag("userid_"..check_friend) and v:IsValid()  then
                                    v:AddTag("userid_"..player.userid)
									v.saveTaglist[player.userid] = 1       
                                end
                            end
                        end
                    end
                end
            end

        end
    end)
end)

--监听玩家离开游戏
AddComponentPostInit("playerspawner", function(PlayerSpawner, inst)
	
    inst:ListenForEvent("ms_playerdespawn", function (inst, player)
        if player and player.components then
		
			doer_num = ""
            for n,p in pairs(AllPlayers) do
                if player.userid == p.userid then 
                    doer_num = n
                end
            end
			
		    if AllPlayers[GLOBAL.tonumber(doer_num)] ~= nil then 
				table.remove(AllPlayers,GLOBAL.tonumber(doer_num))
            end
		
            if remove_owner_time ~= "never" then
                LeavedPlayers[player.userid] =  GLOBAL.TheWorld:DoTaskInTime(remove_owner_time, function() 
                   -- print("removing owner "..tostring(player.userid).."|"..tostring(player.name))
                    local e=TheSim:FindEntities(0,0,0,10000)
                    for i,v in ipairs(e) do
                        if v.persists and v:HasTag("userid_"..player.userid) and v:IsValid() then
                            v:RemoveTag("userid_"..player.userid)
							v.saveTaglist[player.userid] = nil
                            v:AddTag("saved_userid_"..player.userid)
                            if v.ownerlist ~= nil then v.ownerlist[player.userid] = nil end   
                        end
                    end
                end)
            end

        end
    end)
end)

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

--防止火焰蔓延
local spreadFire = GetModConfigData("spread_fire")
if spreadFire ~= 2 then
	local CurrentMakeSmallPropagator = GLOBAL.MakeSmallPropagator
	GLOBAL.MakeSmallPropagator = function(inst)
		CurrentMakeSmallPropagator(inst)
		if inst.components.propagator then
			if spreadFire == 1 then --Half range
				inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2
			else
				inst.components.propagator.propagaterange = 0
			end
		end
	end

	local CurrentMakeMediumPropagator = GLOBAL.MakeMediumPropagator
	GLOBAL.MakeMediumPropagator = function(inst)
		CurrentMakeMediumPropagator(inst)
		if inst.components.propagator then
			if spreadFire == 1 then --Half range
				inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2
			else
				inst.components.propagator.propagaterange = 0
			end
		end
	end
	
	local MakeLargePropagator = GLOBAL.MakeLargePropagator
	GLOBAL.MakeLargePropagator = function(inst)
		MakeLargePropagator(inst)
		if inst.components.propagator then
			if spreadFire == 1 then --Half range
				inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2
			else
				inst.components.propagator.propagaterange = 0
			end
		end
	end
end

--------------------------右键开解锁--------------------------------------------

local rightLockTable = {
"treasurechest",
"icebox",
"cellar",
"dragonflychest",
}

local function addRightLock(inst)
		local function turnon(inst)
	    	inst.on = true
			--print("箱子开锁--------------")
			--让物品对所有人可用
			inst.saved_ownerlist = inst.ownerlist
            inst.ownerlist = nil
			inst.components.machine.ison = true
		end
		
		local function turnoff(inst)
	    	inst.on = false
			--print("箱子上锁--------------")
			--让物品只有自己能打开
			if inst.saved_ownerlist ~= nil then 
                inst.ownerlist = inst.saved_ownerlist
                inst.saved_ownerlist = nil
            end
			--移除该物品所有的tag（包括自己的）
			if inst.saveTaglist ~= nil then  
				for owner_userid,_ in pairs(inst.saveTaglist) do
					--print("removeTag----------userid_"..owner_userid)
					inst:RemoveTag("userid_"..owner_userid)
				end
				inst.saveTaglist = nil
			end
			--只添加自己的tag
			if inst.ownerlist ~= nil then 
				for owner_userid,_ in pairs(inst.ownerlist) do
					inst:AddTag("userid_"..owner_userid)
					inst.saveTaglist = {}
					inst.saveTaglist[owner_userid] = 1
				end
			end	
			inst.components.machine.ison = false
		end
		
		if inst.prefab then
			inst:AddComponent("machine")
			inst.components.machine.cooldowntime = 1
			inst.components.machine.turnonfn = turnon
			inst.components.machine.turnofffn = turnoff
		end
end

for k,name in pairs(rightLockTable) do
	AddPrefabPostInit(name, addRightLock)
end

