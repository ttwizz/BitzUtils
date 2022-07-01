--// this shit is outdated af, should probs rewrite
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local GuiService       = game:GetService("GuiService")


local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer.GetMouse(LocalPlayer)
local Character   = LocalPlayer.Character
local Camera      = Workspace.CurrentCamera
local CountTeams  = function() return #game:GetService("Teams"):GetChildren() end
local GuiInset    = GuiService.GetGuiInset(GuiService)

local SilentAimbotFunctions
SilentAimbotFunctions = {
    Mode               = "Cursor"; 
    HitPart            = "Head";
    Target             = {
        Player         = nil;
        HitPart        = nil;
        IsVisible      = false;
        ViewportPoint  = nil;
    }; 
    TeamCheck          = false; 
    VisibleCheck       = true; 
    WhitelistedTeams   = {}; 
    WhitelistedPlayers = {}; 
    IgnoreList         = {Character; Camera;};

    CircleDrawing      = Drawing.new("Circle");

    CheckPlayer        = function(self, Player)
        if Player then 
            if self.WhitelistedPlayers[Player] then 
                return false 
            end
            if self.TeamCheck and (self.WhitelistedTeams[Player.Team]) or (CountTeams() > 0 and LocalPlayer.Team ~= Player.Team) then 
                return false
            end
        end

        return true
    end;

    CursorMode         = {
        Radius        = 200;
        Distance      = 999;
        AliveCheck    = function(self, Player)
            if not Player then return false, nil, nil end

            local PlayerCharacter = Player.Character
            local PlayerHumanoid  = (PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid")) or (nil)
            local PlayerRootPart  = (PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart")) or (nil)
            local PlayerHead      = (PlayerCharacter and PlayerCharacter:FindFirstChild("Head")) or (nil)
            local PlayerHitPart   = (PlayerCharacter and PlayerCharacter:FindFirstChild(SilentAimbotFunctions.HitPart)) or (nil)

            if (PlayerHumanoid and PlayerHumanoid.Health > 0) and PlayerRootPart and PlayerHead and PlayerHitPart then 
                return true, PlayerCharacter, PlayerHitPart
            end
            return false, nil, nil
        end;
        VisibleCheck  = function(self, Player) 
            local PlayerAlive, PlayerCharacter, PlayerHitPart = self:AliveCheck(Player)

            if not SilentAimbotFunctions.VisibleCheck then 
                if PlayerAlive and PlayerCharacter then 
                    return true, PlayerHitPart.Position, PlayerHitPart
                end
            end;

            if PlayerAlive and PlayerCharacter then 
                local Hit, Position = Workspace:FindPartOnRayWithIgnoreList(Ray.new(Character.Head.CFrame.p, (PlayerHitPart.Position - Character.Head.Position).unit * self.Distance), SilentAimbotFunctions.IgnoreList)

                if Hit and Hit:IsDescendantOf(PlayerCharacter) then 
                    return true, Position, PlayerHitPart
                end
            end

            return false, nil, nil
        end;
        GetTarget     = function(self)
            if not self:AliveCheck(LocalPlayer) then
                return 
            end

            local ChosenTarget     = nil;
            local ShortestDistance = self.Distance;
            local ShortestRadius   = self.Radius;
            local Visible, RayHit, HitPart, RayHit2D
            local ViewportPoint;

            for _,v in pairs(Players:GetPlayers()) do
                if v.Name ~= LocalPlayer.Name and SilentAimbotFunctions:CheckPlayer(v) then 
                    Visible, RayHit, HitPart = self:VisibleCheck(v)

                    if Visible and RayHit and HitPart then 
                        RayHit2D, OnScreen = Camera:WorldToScreenPoint(RayHit)
                        if OnScreen then
                            local MouseMagnitude   = (Vector2.new(RayHit2D.X, RayHit2D.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            local HitPartMagnitude = (HitPart.Position - Character.Head.Position).Magnitude

                            if (MouseMagnitude <= ShortestRadius) then 
                                ChosenTarget     = v
                                ShortestRadius   = MouseMagnitude
                                ShortestDistance = HitPartMagnitude
                                ViewportPoint    = Vector2.new(RayHit2D.X,RayHit2D.Y)
                            end
                        end
                    end
                end
            end

            if not ViewportPoint then HitPart = nil end
            return {
                Player         = ChosenTarget;
                HitPart        = HitPart;
                IsVisible      = Visible;
                ViewportPoint  = ViewportPoint;
            }; 
        end
    };
    CharacterMode      = {
        Distance      = 999;
        AliveCheck    = function(self, Player)
            if not Player then return false, nil, nil end

            local PlayerCharacter = Player.Character
            local PlayerHumanoid  = (PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid")) or (nil)
            local PlayerRootPart  = (PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart")) or (nil)
            local PlayerHead      = (PlayerCharacter and PlayerCharacter:FindFirstChild("Head")) or (nil)
            local PlayerHitPart   = (PlayerCharacter and PlayerCharacter:FindFirstChild(SilentAimbotFunctions.HitPart)) or (nil)

            if PlayerHumanoid and PlayerRootPart and PlayerHead and PlayerHitPart then 
                return true, PlayerCharacter, PlayerHitPart
            end
            return false, nil, nil
        end;
        VisibleCheck  = function(self, Player) 
            local PlayerAlive, PlayerCharacter, PlayerHitPart = self:AliveCheck(Player)

            if not SilentAimbotFunctions.VisibleCheck then 
                if PlayerAlive and PlayerCharacter then 
                    return true, PlayerHitPart.Position, PlayerHitPart
                end
            end;

            if PlayerAlive and PlayerCharacter then 
                local Hit, Position = Workspace:FindPartOnRayWithIgnoreList(Ray.new(Character.Head.CFrame.p, (PlayerHitPart.Position - Character.Head.Position).unit * self.Distance), SilentAimbotFunctions.IgnoreList)

                if Hit and Hit:IsDescendantOf(PlayerCharacter) then 
                    return true, Position, PlayerHitPart
                end
            end

            return false, nil, nil
        end;
        GetTarget     = function(self)
            if not self:AliveCheck(LocalPlayer) then
                return 
            end
            local ChosenTarget     = nil;
            local ShortestDistance = self.Distance;
            local Visible, RayHit, HitPart

            for _,v in pairs(Players:GetPlayers()) do
                if v.Name ~= LocalPlayer.Name and SilentAimbotFunctions:CheckPlayer(v) then 
                    Visible, RayHit, HitPart = self:VisibleCheck(v)

                    if Visible and RayHit and HitPart then 
                        RayHit2D               = Camera:WorldToScreenPoint(RayHit)
                        
                        local HitPartMagnitude = (HitPart.Position - Character.Head.Position).Magnitude
                        
                        if (HitPartMagnitude <= ShortestDistance) then
                            ChosenTarget     = v
                            ShortestDistance = HitPartMagnitude
                            ViewportPoint    = Vector2.new(RayHit2D.X,RayHit2D.Y)
                        end
                    end
                end
            end

            return {
                Player         = ChosenTarget;
                HitPart        = HitPart;
                IsVisible      = Visible;
                ViewportPoint  = ViewportPoint;
            }; 
        end;
    };

    GetTarget          = function(self)
        local TargetT
        if self.Mode == "Cursor" then 
            TargetT = self.CursorMode:GetTarget()
        else
            TargetT = self.CharacterMode:GetTarget()
        end
        return TargetT
    end;

    ChangeFOVSettings  = function(self, settings)
        if self.CircleDrawing then 
            for i,v in pairs(settings) do 
                self.CircleDrawing[i] = v
            end
        else
            self.CircleDrawing = Drawing.new("Circle")
            for i,v in pairs(settings) do 
                self.CircleDrawing[i] = v
            end
        end
    end;

    FOVSettings        = {
        Visible      = true;
        Radius       = 0;
        NumSides     = 1000;
        Filled       = false;
        Thickness    = 1;
        Transparency = 1;
        Color        = Color3.fromRGB(255,255,255);
        Position     = "Mouse";
    }
}

--[[
    SilentAimbotFunctions.Target: 
        Player = Player Instance
        HitPart = Chosen HitPart
        IsVisible = Player Visibilty
        ViewportPoint = For Drawing

    SilentAimbotFunctions.CursorMode: 
        Radius = Fov Radius
        Distance = Distance to check for Players 
        
    SilentAimbotFunctions.CharacterMode: 
        Distance = Max Distance to check for Players

    SilentAimbotFunctions.Mode:
        "Cursor";
        "Character";
    
    SilentAimbotFunctions.HitPart:
        yk
    SilentAimbotFunctions.VisibleCheck:
        yk
    SilentAimbotFunctions.TeamCheck:
        yk
]]


-- // RenderStepped Loop for Updating
RunService.RenderStepped:Connect(function()
    Character = LocalPlayer.Character
    Camera    = Workspace.CurrentCamera
    --// Update Circle
    local Settings = SilentAimbotFunctions.FOVSettings
    local Position = (Settings.Position == "Middle" and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)) or (Settings.Position == "Mouse" and UserInputService:GetMouseLocation())
    
    SilentAimbotFunctions:ChangeFOVSettings({
        Visible      = (SilentAimbotFunctions.Mode == "Cursor" and Settings.Visible) or (false);
        Radius       = SilentAimbotFunctions.CursorMode.Radius;
        NumSides     = Settings.NumSides;
        Filled       = Settings.Filled;
        Thickness    = Settings.Thickness;
        Transparency = Settings.Transparency;
        Color        = Settings.Color;
        Position     = Position;
    })

    --// Update Target
    SilentAimbotFunctions.Target = SilentAimbotFunctions:GetTarget();
end)

return SilentAimbotFunctions
