
local Players             = game:GetService("Players")
local RBXTeleprotSrvices  = game:GetService("TeleportService")

local Packages = script.Parent.ThirdParty

local Promise = require(Packages.Promise)


local config
do
    config = {}
    function config.Friend(FrindName)
        local success , FrindId = pcall(Players.GetUserIdFromNameAsync , Players , FrindName)
        if success == false then
            -- Reject the promise If The Frind Is offline or any error Happend 
            return Promise.reject("Error : " , (FrindId) , " Can not Be Found")
        end
        return Promise.new(function(resolve, reject ,_)
            local currentInstance , errorMessage , placeId , jobId 
            local _success , _err = pcall(function()
                currentInstance , errorMessage , placeId , jobId  = RBXTeleprotSrvices:GetPlayerPlaceInstanceAsync(FrindId)
            end)
            if not _success then
                warn(_err)
                reject(_err)
                return
            end
            if currentInstance == false then
                warn('Tp From Private Server')
                warn(errorMessage)
            end
            warn('[SUCCRSS]:: Geting friend server')
            resolve({
                id = placeId,
                instance = jobId 
            })
        end)
    end

    function config.Private(PlaceId : number , Serverid : string , _players : {Player}  , spawnName , tp_Data, customScreen)
        return Promise.new(function(resolve , reject)
            local success ,result = pcall(RBXTeleprotSrvices.TeleportToPrivateServer ,RBXTeleprotSrvices , PlaceId , Serverid, _players ,spawnName,tp_Data,customScreen )
            
            if success then
                resolve(result)
            else
                reject("Faild To Teleport To Private Server")
            end
        end)
    end
end

return config
