--[[




]]


export type AccessCode = {
    AccessCode : string ; ServerId : string;
}

local HttpService         = game:GetService("HttpService")
local DataStoreService    = game:GetService("DataStoreService")
local RBXTeleprotSrvices  = game:GetService("TeleportService")

local Packages = script.ThirdParty


local Promise  = require(Packages.Promise)
local option   = require(script.TPoption)
local Teleport = require(script.Teleporter)

local SERVER_LOCATION_API    = "http://ip-api.com/json/"
local DATA_STORE_NAME        = "TeleportData_Test"
local KEYS_STORE_NAME        = "__PS_KEY__"
-- local PLAYER_CACHE_DATA      = "__PLAYER__"
local RETRYS_AMOUNT          = 6


local TeleportData  = DataStoreService:GetDataStore(DATA_STORE_NAME   , "global")
local KeysStroe     = DataStoreService:GetDataStore(KEYS_STORE_NAME   , "global")
-- local PlayerData    = DataStoreService:GetDataStore(PLAYER_CACHE_DATA , "global")
-- Loacl Functions :

local function GetData(DataStore: DataStore , Key)
    local Counter = 0
    return Promise.new(function(resolve,reject)
        local success , key = pcall(DataStore.GetAsync , TeleportData , Key)
        while not success and Counter <= RETRYS_AMOUNT do
            Counter += 1
            task.wait(7) --Roblox CoolDown
            success , key = pcall(DataStore.GetAsync , TeleportData , Key)
            task.wait(1) -- Extra Time To Make Sure The Data Loaded Successfully
        end
        if Counter >= RETRYS_AMOUNT then
            reject("Timeout Max Retryes Riched and Filed To Load Data")
            return
        end
        resolve(key)
    end)
end

local function SetData(DataStore: DataStore , Key, value)
    local Counter = 0
    return Promise.new(function(resolve ,reject)
        local success , result = pcall(DataStore.SetAsync , TeleportData , Key , value)
        while not success and Counter <= RETRYS_AMOUNT do
            Counter += 1
            task.wait(7) --Roblox CoolDown
            success , result = pcall(DataStore.SetAsync , TeleportData , Key , value)
            task.wait(1) -- Extra Time To Make Sure The Data Loaded Successfully
        end
        if Counter >= RETRYS_AMOUNT then
            reject("Timeout Max Retryes Riched and Filed To Save Data")
            return
        end
        resolve(result)
    end)
end

local function RemoveData(DataStore: DataStore ,Key)
    local Counter = 0
    return Promise.new(function(resolve ,reject)
        local success , result = pcall(DataStore.RemoveAsync , TeleportData , Key)
        while not success and Counter <= RETRYS_AMOUNT do
            Counter += 1
            task.wait(7) --Roblox CoolDown
            success , result = pcall(DataStore.RemoveAsync , TeleportData , Key)
            task.wait(1) -- Extra Time To Make Sure The Data Loaded Successfully
        end
        if Counter >= RETRYS_AMOUNT then
            reject("Timeout Max Retryes Riched and Filed To Remove Data")
            return
        end
        resolve(result)
    end)
end


--[[

]]
local function GetAccessCodeAsync(Key)
    return GetData(TeleportData , Key)
end

--[[

]]
local function SetAccessCodeAsync(Key , value)
   return SetData(TeleportData , Key , value)
end

--[[

]]
local function GetKeyStore(Key)
    return GetData(KeysStroe , Key)
end

--[[

]]
local function SetKeyStore(Key, value)
    return SetData(KeysStroe , Key , value)
end

--[[
    @warn Thsi Call Well Remove Everthing From Current Scop
]]
local function WipeDataStore(Id)
    return Promise.new(function(resolve , reject)
        local success , Data = GetKeyStore(Id):await()
        if not success then 
            reject(Data)
            return 
        end
        local removed , result = RemoveData(TeleportData , Data.Id):await()
        if not removed then
            reject(result)
            return
        end
        RemoveData(KeysStroe , Id):await()
        resolve(result)
    end)
end




local TeleportSystem = {}
TeleportSystem.TeleportTyps = {
    Friend = "Friend";
    TP_ACCESS_CODE = "TP_ACCESS_CODE";
    Private = "Private"

}


function TeleportSystem:GetServerInfo()
    return Promise.new(function(resolve)
        local success , ServerInfo = pcall(HttpService.GetAsync , HttpService , SERVER_LOCATION_API)
        while not success do
            warn(ServerInfo , "Teleport Service Debug Id :: Server Info Requset")
            success , ServerInfo = pcall(HttpService.GetAsync , HttpService , SERVER_LOCATION_API)
            task.wait(6)
        end
        warn("successfully Get")
        ServerInfo = HttpService:JSONDecode(ServerInfo)
        resolve(ServerInfo)
    end)
end

-- Create Random String and ReserveServerCode
function TeleportSystem:GenerateCode(PlaceId : number) : AccessCode
    local Code , id = RBXTeleprotSrvices:ReserveServer(PlaceId) -- Code = game.jobid in the reserved server  , id = game.PrivateServerId in reserved server
    return {AccessCode = Code , ServerId = id}
end

function TeleportSystem:RegisterAccessCode(Player: Player , PlaceId: number , wipeOldServer: boolean?)
    -- First)
    if wipeOldServer and self:PlayerOwnsAccessCode(Player) then
        self:wipeAllKeys(Player)
    end
    local newAccessCode = self:GenerateCode(PlaceId)
    local accessCode = newAccessCode.AccessCode:sub(1,8)
    local _success , result = SetKeyStore(Player.UserId , {
        Id         = newAccessCode.ServerId;
        AccessCode = newAccessCode.AccessCode;
        OwnerId    = Player.UserId
    }):await()
    if not _success then
        warn(result)
        return
    end
    SetAccessCodeAsync(accessCode , {
        OwnerId    = Player.UserId;
        PlaceId    = PlaceId;
        AccessCode = newAccessCode.AccessCode;
        ServerId   = newAccessCode.ServerId;
    }):await()
    return accessCode
end

--[[
    @Yield
]]
function TeleportSystem:wipeAllKeys(Player: Player)
    return WipeDataStore(Player.UserId)
end

--[[
    @Yield
]]
function TeleportSystem:PlayerOwnsAccessCode(Player : Player)
    local success , Data = GetKeyStore(Player):await()
    return success and Data ~= nil or false
end

function TeleportSystem.newOption()
    return option.new()
end

function TeleportSystem:TeleportAsync(_option : option.option)
    if _option.type == TeleportSystem.TeleportTyps.TP_ACCESS_CODE then
        local accessCode = _option:getPrameter()
        local success , result = GetAccessCodeAsync(accessCode):await()
        if not success then
            warn(result)
            return
        end
        
        _option:removePrameter()
        :setPrameter(result.PlaceId ,result.AccessCode)
        return Teleport(_option)
    else
        return Teleport(_option)
    end
end

return TeleportSystem