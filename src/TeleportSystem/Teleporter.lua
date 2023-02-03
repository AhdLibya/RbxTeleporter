local RBXTeleprotSrvices  = game:GetService("TeleportService")
local config = require(script.Parent.Config)
local Options = require(script.Parent.TPoption)


local Teleport = {}

function Teleport:TeleporToFriend(Option: Options.option)
    local FriendName = Option:getPrameter()
    local handler = config[Option.type]
    local success , result = handler(FriendName):await()
    if not success then
        warn("[ERROR]:: Handling Friend Tp Requset")
        warn(result)
        return
    end
    local ops = Instance.new('TeleportOptions')
    ops.ServerInstanceId = result.instance
    ops.ShouldReserveServer = false
    local suc , err  = pcall(RBXTeleprotSrvices.TeleportAsync , RBXTeleprotSrvices , result.id , Option.Players, ops)
    return suc , err
end

function Teleport:TeleportAsync(Option: Options.option)
    local PlaceId , ServerId = Options:getPrameter()
    local handler = config[Option.type]
    local success , result = handler(
        PlaceId   ,
        ServerId  ,
        Option.Players
    ):await()
    return success , result
end

--[[
    @return tuple< boolean , TeleportAsyncResult>
]]
return function (Option: Options.option)
    if Option.type == "Friend" then
        return Teleport:TeleporToFriend(Option)
    elseif Option.type == "Private" or Option.type == "TP_ACCESS_CODE"then
        return Teleport:TeleportAsync(Option)
    end
end
