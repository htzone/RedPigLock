--自动清理时间间隔
local clear_period = 480
--自动清理范围
local clear_near = 30
--附近要清理的物品列表(可自定义)
local clear_item = {
"spiderden",
"skeleton_player",
"wall_wood",
"wall_stone",
"wall_ruins",
"wall_hay",
"rabbithouse",
"tentacle",
}

local RP_NearAutoDelete = Class(function(self, inst)
	self.inst = inst	
end)

local function AutoDeleteTask(inst, dt)
	--print("delete handle!")
	local owner = nil
	local ents = {}
	local x = nil
	local y = nil
	local z = nil
	
	x, y, z = inst.Transform:GetWorldPosition()
	
	if x ~= nil and y ~= nil and z ~= nil then
		--print("x="..x..", y="..y.."z="..z)
		ents = TheSim:FindEntities(x, y, z, clear_near)
		
		for _,obj in pairs(ents) do
			local should_remove = false
			for i = 1, #clear_item do
				if obj and obj.prefab == clear_item[i] then 
					should_remove = true
				end
			end
			
			if should_remove then 
				if obj.components.occupier then
					owner = obj.components.occupier:GetOwner()
				end
				
				if not owner and obj then
					obj:Remove()
				end
			end
	
		end
	end	
end

----执行附近指定物品的删除操作
function RP_NearAutoDelete:start()
	self.inst:DoPeriodicTask(clear_period, AutoDeleteTask)
end

return RP_NearAutoDelete