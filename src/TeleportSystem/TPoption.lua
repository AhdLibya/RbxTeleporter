export type optionInfo = {
    SpawnName: string?;
    LoadingScreen: ScreenGui?;
    AccessCode: string?;
    tp_Data: {};
    PlaceId: number;
}
--[=[
    @type option
    .ID string
    setPrameter: (...any) -> option;
]=]
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

local function setPrameter(self: option , ...:any)
    local args = {...}
    for _ , v in args do
        self.args[#self.args+1] = v
    end
    return self
end

local function getPrameter(self: option)
    return table.unpack( self.args )
end

local function addPlayer( self: option , Players: Player | {Player})
    if typeof(Players) == "table" then
        for _, player: Player in Players do
            if typeof(player) ~= "Instance" then continue end
            if not player:IsA("Player") then continue end
            self.Players[#self.Players+1] = player
        end
    elseif typeof(Players) == "Instance" and Players:IsDescendantOf(game.Players) then
        self.Players[#self.Players+1] = Players
    else
        error("Expected Player or Array of Players got ( "..typeof(Players).." )" , 1)
    end
    return self
end

local function setExtraInfo(self: option , Info: optionInfo)
    for key , value in Info do
        self.ExtraInfo[key] = value
    end
    return self
end

local function removePrameter(self: option)
    table.clear(self.args)
    return self
end

local function setType(self: option ,_type: string)
    self.type = _type
    return self
end

local function Destroy(self)
    table.clear(self)
end

local function new()
    local guid = HttpService:GenerateGUID(false);
    return {
        setPrameter     = setPrameter;
        getPrameter     = getPrameter;
        addPlayer       = addPlayer;
        setExtraInfo    = setExtraInfo;
        removePrameter  = removePrameter;
        setType         = setType;
        Destroy         = Destroy;
        args            = {};
        ID              = guid;
        type            = "";
        Players         = {};
        ExtraInfo       = {};
    } :: option
end

return new