export type optionInfo = {
    SpawnName: string?;
    LoadingScreen: ScreenGui?;
    AccessCode: string?;
    tp_Data: {};
    PlaceId: number;
}
export type option = {
    ID: string;
    type: string;
    Players: {Player};
    ExtraInfo: optionInfo;
    setPrameter: (...any) -> option;
    getPrameter: ()-> ...any;
    AddPlayer: (Player: Player) -> option;
    setExtraInfo: (Info: optionInfo) -> option;
    setType: (_type: string) -> option;
    removePrameter: () -> option;
    Destroy: () -> nil
}


local HttpService = game:GetService("HttpService")

--[==[
@within class option
]==]

local option = {} :: option
option.__index = option


function option.new() 
    local guid = HttpService:GenerateGUID(false);
    local self = {
        args = {};
        ID = guid;
        type = "";
        Players = {};
        ExtraInfo = {};
    }::option
    return setmetatable(self , option)
end

function option:setPrameter(...)
    local args = {...}
    for _ , v in args do
        self.args[#self.args+1] = v
    end
    return self
end

function option:getPrameter()
    return table.unpack( self.args )
end

function option:AddPlayer( Players: Player | {Player})
    if typeof(Players) == "table" then
        self.Players = Players :: {Player}
    elseif typeof(Players) == "Instance" and Players:IsDescendantOf(game.Players) then
        self.Players[#self.Players+1] = Players
    else
        error("Expected Player or Array of Players got ( "..typeof(Players).." )" , 1)
    end
    return self
end

function option:setExtraInfo(Info: optionInfo)
    for key , value in Info do
        self.ExtraInfo[key] = value
    end
    return self
end

function option:removePrameter()
    table.clear(self.args)
    return self
end

function option:setType(_type: string)
    self.type = _type
    return self
end

function option:Destroy()
    table.clear(self)
end

return option
