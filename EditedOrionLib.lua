local FlagGeneration = {} do
    function FlagGeneration:GenFlag(Properties)
        local Result = ""

        if Properties.Callback then
            for _, Constant in next, debug.getconstants(Properties.Callback) do
                if type(Constant) == "string" then
                    Result = Result .. Constant .. "-"
                end
            end
        end

        for _, String in next, Properties.Name:split("") do
            Result = Result .. String:byte() .. "-"
        end

        return (Result:sub(1, #Result - 1)):gsub("%s", "-")
    end
end

local FolderName     = "DarkHub"
local SettingsName   = (FolderName .. "/%s.json"):format( tostring(game.GameId) )
local Client         = isfile(SettingsName) and game:GetService("HttpService"):JSONDecode( readfile(SettingsName) ) or { Flags = {} }

function __makefolder(name)
    if isfolder(name) then return true end 
    makefolder(name)
    task.wait(0.1)
    return true
end

function __updatesettings(Client)
    if __makefolder(FolderName) then
        local Flags = {}
        for i,v in next, Client.Flags do
            Flags[i] = v.Value
        end

        writefile(SettingsName, game:GetService("HttpService"):JSONEncode({ ["Flags"] = Flags; }))    
    end
end

function GetSave(Name)
    return Client["Flags"][Name]
end

local Signal         = loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/NougatBitz/BitzUtils/main/Signal.lua"))()
local CallbackSignal = Signal.new()

local OrionLib   = loadstring(game:HttpGet(("https://raw.githubusercontent.com/shlexware/Orion/main/source")))()
OrionLib.Icons   = {
    Combat   = "rbxassetid://10401329089";
    Movement = "rbxassetid://10403468113";
    Visuals  = "rbxassetid://10403490626";
    Settings = "rbxassetid://10403508076";
    Others   = "rbxassetid://10403543022";
};
OrionLib.DefaultValues = {
    ["AddToggle"] = false;
    ["AddColorpicker"] = Color3.fromRGB(255, 255, 255);
    ["AddSlider"] = 0;
    ["AddTextbox"] = "default";
    ["AddBind"] = Enum.KeyCode.E;
}

local OldMakeWindow = OrionLib.MakeWindow; OrionLib.MakeWindow = function(self, Config)
    local NewWindow = OldMakeWindow(self, Config)

    local OldMakeTab = NewWindow.MakeTab; NewWindow.MakeTab = function(self, Config)
        local NewTab = OldMakeTab(self, Config)
        
        for Index, Value in next, NewTab do 
            NewTab[Index] = function(self, Config, ...)
                local Callback = Config and rawget(Config, "Callback") 
                if Callback and Index ~= "AddButton" then
                    local NewFlag = Config.Flag or FlagGeneration:GenFlag(Config)
                    local Default

                    if (not Config.IgnoreCustom) then
                        Default = (GetSave(NewFlag)) or (Config.Default) or (OrionLib.DefaultValues[Index])
                        rawset(Config, "Default", Default)
                        rawset(Config, "Flag", NewFlag)
                    end

                    rawset(Config, "Callback", function(...)
                        CallbackSignal:Fire(Index, NewFlag, ...)

                        if not Config.IgnoreCustom then 
                            __updatesettings(OrionLib)
                        end
    
                        return Callback(...)
                    end)


                    local Result = Value(self, Config, ...)
                    
                    if (not Config.IgnoreCustom) then
                        rawset(OrionLib.Flags[NewFlag], "Value", Default)
                    end
                    
                    return Result
                else
                    return Value(self, Config, ...)
                end
            end
        end
        return NewTab
    end
    return NewWindow
end

return OrionLib, CallbackSignal
