--// ORIGINAL [!!!] - https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer

local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local GetGuiInset = GuiService.GetGuiInset
local Randomnew = Random.new
local mathfloor = math.floor
local RaycastParamsnew = RaycastParams.new
local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local Raycast = Workspace.Raycast
local GetPlayers = Players.GetPlayers
local Instancenew = Instance.new
local WorldToViewportPoint = Instancenew("Camera").WorldToViewportPoint
local IsAncestorOf = Instancenew("Part").IsAncestorOf
local FindFirstChildWhichIsA = Instancenew("Part").FindFirstChildWhichIsA
local FindFirstChild = Instancenew("Part").FindFirstChild
local tableremove = table.remove
local tableinsert = table.insert
local GetMouseLocation = UserInputService.GetMouseLocation
local CFramelookAt = CFrame.lookAt
local Vector2new = Vector2.new
local GetChildren = Instancenew("Part").GetChildren

local AimingSettings = {
    Enabled = true,
    VisibleCheck = true,
    HitChance = 100,
    TargetPart = {"Head", "HumanoidRootPart"},
    RaycastIgnore = nil,
    Offset = Vector2new(),

    FOVSettings = {
        Circle = Drawingnew("Circle"),
        Enabled = true,
        Scale = 60,
        Sides = 12,
        Colour = Color3fromRGB(231, 84, 128)
    },

    TracerSettings = {
        Tracer = Drawingnew("Line"),
        Enabled = true,
        Colour = Color3fromRGB(231, 84, 128)
    },

    Ignored = {
        WhitelistMode = {Players = false},
        Players = {LocalPlayer}
    }
}
local Aiming = {
    Loaded = false,
    ShowCredits = true,
    Settings = AimingSettings,

    Selected = {
        Instance = nil,
        Part = nil,
        Position = nil,
        OnScreen = false
    }
}

function AimingSettings.Get(...)
    local args = {...}
    local argsCount = #args
    local Identifier = args[argsCount]

    local Found = AimingSettings
    for i = 1, argsCount - 1 do
        local v = args[i]

        if (v) then
            Found = Found[v]
        end
    end

    return Found[Identifier]
end

local circle = AimingSettings.FOVSettings.Circle
circle.Transparency = 1
circle.Thickness = 2
circle.Color = AimingSettings.FOVSettings.Colour
circle.Filled = false

function Aiming.UpdateFOV()
    if not (circle) then
        return
    end

    local MousePosition = GetMouseLocation(UserInputService) + AimingSettings.Offset
    local Settings = AimingSettings.FOVSettings

    circle.Visible = Settings.Enabled
    circle.Radius = (Settings.Scale * 3)
    circle.Position = MousePosition
    circle.NumSides = Settings.Sides
    circle.Color = Settings.Colour

    return circle
end

local tracer = AimingSettings.TracerSettings.Tracer
function Aiming.UpdateTracer()
    if (not tracer) then
        return
    end

    local MousePosition = GetMouseLocation(UserInputService) + AimingSettings.Offset
    local Settings = AimingSettings.TracerSettings

    local Position = Aiming.Selected.Position
    local IsValid = Aiming.Checks.IsAvailable()

    if (IsValid) then
        tracer.Visible = Settings.Enabled
        tracer.Color = Settings.Colour
        tracer.From = MousePosition
        tracer.To = Position
    else
        tracer.Visible = false
    end

    return tracer
end

local Utilities = {}
Aiming.Utilities = Utilities
local GetCurrentCamera
do
    function Utilities.GetPlayers()
        return GetPlayers(Players)
    end

    function Utilities.GetCurrentCamera()
        return Workspace.CurrentCamera
    end
    GetCurrentCamera = Utilities.GetCurrentCamera

    function Utilities.CalculateVelocity(Before, After, deltaTime)
        local Displacement = (After - Before)
        local Velocity = Displacement / deltaTime

        return Velocity
    end

    function Utilities.CalculateChance(Percentage)
        Percentage = mathfloor(Percentage)

        local chance = mathfloor(Randomnew().NextNumber(Randomnew(), 0, 1) * 100) / 100

        return chance <= Percentage / 100
    end

    function Utilities.Character(Player)
        return Player.Character
    end

    function Utilities.GetBodyParts(Character)
        local Parts = Character:GetChildren()

        for i = #Parts, 1, -1 do
            if (not Parts[i]:IsA("BasePart")) then
                table.remove(Parts, i)
            end
        end

        return Parts
    end

    function Utilities.ArrayToString(Array, Function)
        Function = Function or tostring

        for i, v in pairs(Array) do
            Array[i] = Function(v)
        end

        return Array
    end

    function Utilities.TeamMatch(Player1, Player2)
        if (Player1:IsA("Player")) then
            Player1 = Player1.Team
        end
        if (Player2:IsA("Player")) then
            Player2 = Player2.Team
        end

        return Player1 == Player2
    end

    function Utilities.IsPartVisible(Part, PartAncestor)
        local Character = Utilities.Character(LocalPlayer)
        local Origin = GetCurrentCamera().CFrame.Position
        local _, OnScreen = WorldToViewportPoint(GetCurrentCamera(), Part.Position)

        if (OnScreen) then
            local raycastParams = RaycastParamsnew()
            raycastParams.FilterType = EnumRaycastFilterTypeBlacklist
            local RaycastIgnore = AimingSettings.RaycastIgnore
            raycastParams.FilterDescendantsInstances = (typeof(RaycastIgnore) == "function" and RaycastIgnore() or RaycastIgnore) or {Character, GetCurrentCamera()}

            local Result = Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)

            if (Result) then
                local PartHit = Result.Instance
                local Visible = PartHit == Part or IsAncestorOf(PartAncestor, PartHit)

                return Visible
            end
        end

        return false
    end

    function Utilities.Raycast(Origin, Destination, UnitMultiplier)
        if (typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3") then
            if (not UnitMultiplier) then UnitMultiplier = 1 end

            local Direction = (Destination - Origin).Unit * UnitMultiplier
            local Result = Raycast(Workspace, Origin, Direction)

            if (Result) then
                local Normal = Result.Normal
                local Material = Result.Material

                return Direction, Normal, Material
            end
        end

        return nil
    end

    function Utilities.SetCameraCFrame(CFr)
        GetCurrentCamera().CFrame = CFr
    end

    function Utilities.CameraLookAt(Position)
        local LookAt = CFramelookAt(GetCurrentCamera().CFrame.Position, Position)
        Utilities.SetCameraCFrame(LookAt)
    end

    function Utilities.ClosestPointOnObject(OriginPoint, Object)
        local ObjectPosition = Object.Position
        local ObjectSize = Object.Size

        if (typeof(OriginPoint) == "Ray") then
            if (OriginPoint.Direction.Magnitude ~= 1) then
                OriginPoint = OriginPoint.Unit
            end

            local Magnitude = (ObjectPosition - OriginPoint.Origin).Magnitude
            OriginPoint = OriginPoint.Origin + (OriginPoint.Direction * Magnitude)
        end

        local MatchedY = ObjectPosition + Vector3.new(0, -ObjectPosition.Y + OriginPoint.Y, 0)

        local Top = ObjectPosition + ObjectSize / 2
        local Bottom = ObjectPosition - ObjectSize / 2

        local Destination = (OriginPoint.Y >= Bottom.Y and OriginPoint.Y <= Top.Y) and MatchedY or ObjectPosition
        local Direction = (Destination - OriginPoint)

        local WhitelistParms = RaycastParams.new()
        WhitelistParms.FilterType = Enum.RaycastFilterType.Whitelist
        WhitelistParms.FilterDescendantsInstances = {Object}
        local RaycastResult = workspace:Raycast(OriginPoint, Direction, WhitelistParms)

        return RaycastResult.Position
    end

    function Utilities.SolveProjectileTravelTime(Position, ProjSpeed, TargetPos, Gravity)
        local Direction = TargetPos - Position
        local DirectionXZ = Vector3.new(Direction.X, 0, Direction.Z)
        local Distance = DirectionXZ.Magnitude
        local ProjSpeed2 = ProjSpeed * ProjSpeed
        local ProjSpeed4 = ProjSpeed2 * ProjSpeed2
        local InitialHeight = Direction.Y
        local GD = Gravity * Distance

        local Root = ProjSpeed4 - Gravity * (Gravity * Distance * Distance + 2 * InitialHeight * ProjSpeed2)
        if (Root < 0) then
            return nil
        end
        Root = math.sqrt(Root)

        local AngleLaunch = math.atan2(ProjSpeed2 - Root, GD)
        local BulletDirection = DirectionXZ.Unit * math.cos(AngleLaunch) * ProjSpeed + Vector3.new(0, 1, 0) * math.sin(AngleLaunch) * ProjSpeed
        local Time = Distance / (math.cos(AngleLaunch) * ProjSpeed)

        return BulletDirection, Time
    end

    function Utilities.SolvePrediction(Position, Velocity, Time)
        return Position + Velocity * Time
    end

    function Utilities.WorkoutDirection(Origin, Destination, PartVelocity, ProjSpeed, Gravity)
        local _, TimeA = Utilities.SolveProjectileTravelTime(Origin, ProjSpeed, Destination, Gravity)
        local SolvedPrediction = Utilities.SolvePrediction(Destination, PartVelocity, TimeA)
        local Direction = Utilities.SolveProjectileTravelTime(Origin, ProjSpeed, SolvedPrediction, Gravity)
        return Direction
    end
end

local Ignored = {}
Aiming.Ignored = Ignored
do
    local IgnoredSettings = Aiming.Settings.Ignored
    local WhitelistMode = IgnoredSettings.WhitelistMode

    function Ignored.IgnorePlayer(Player)
        local IgnoredPlayers = IgnoredSettings.Players

        for _, IgnoredPlayer in pairs(IgnoredPlayers) do
            if (IgnoredPlayer == Player) then
                return false
            end
        end

        tableinsert(IgnoredPlayers, Player)
        return true
    end

    function Ignored.UnIgnorePlayer(Player)
        local IgnoredPlayers = IgnoredSettings.Players

        for i, IgnoredPlayer in pairs(IgnoredPlayers) do
            if (IgnoredPlayer == Player) then
                tableremove(IgnoredPlayers, i)
                return true
            end
        end

        return false
    end

    function Ignored.IsIgnored(Player)
        local IgnoredPlayers = IgnoredSettings.Players

        for _, IgnoredPlayer in pairs(IgnoredPlayers) do
            local Return = WhitelistMode.Players

            if (typeof(IgnoredPlayer) == "number" and Player.UserId == IgnoredPlayer) then
                return not Return
            end

            if (IgnoredPlayer == Player) then
                return not Return
            end
        end

        if (WhitelistMode.Players) then
            return true
        end

        return false
    end
end

local Checks = {}
Aiming.Checks = Checks
do
    function Checks.Health(Player)
        local Character = Utilities.Character(Player)
        local Humanoid = FindFirstChildWhichIsA(Character, "Humanoid")

        local Health = (Humanoid and Humanoid.Health or 0)

        return Health > 0
    end

    function Checks.Custom(Player)
        return true
    end

    function Checks.IsAvailable()
        return (AimingSettings.Enabled == true and Aiming.Selected.Instance ~= nil)
    end
end

function Aiming.GetClosestTargetPartToCursor(Character)
    local TargetParts = AimingSettings.TargetPart

    local ClosestPart = nil
    local ClosestPartPosition = nil
    local ClosestPartOnScreen = false
    local ClosestPartMagnitudeFromMouse = nil
    local ShortestDistance = 1/0

    local function CheckTargetPart(TargetPart)
        if (typeof(TargetPart) == "string") then
            TargetPart = FindFirstChild(Character, TargetPart)
        end

        if not (TargetPart) then
            return
        end

        local PartPos, onScreen = WorldToViewportPoint(GetCurrentCamera(), TargetPart.Position)
        PartPos = Vector2new(PartPos.X, PartPos.Y)

        local MousePosition = GetMouseLocation(UserInputService) + AimingSettings.Offset
        local GuiInset = GetGuiInset(GuiService)
        local AccountedPos = PartPos - GuiInset

        local Magnitude = (AccountedPos - MousePosition).Magnitude

        if (Magnitude < ShortestDistance) then
            ClosestPart = TargetPart
            ClosestPartPosition = PartPos
            ClosestPartOnScreen = onScreen
            ClosestPartMagnitudeFromMouse = Magnitude
            ShortestDistance = Magnitude
        end
    end

    local function CheckAll()
        for _, v in pairs(GetChildren(Character)) do
            if (v:IsA("BasePart")) then
                CheckTargetPart(v)
            end
        end
    end

    if (typeof(TargetParts) == "string") then
        if (TargetParts == "All") then
            CheckAll()
        else
            CheckTargetPart(TargetParts)
        end
    end

    if (typeof(TargetParts) == "table") then
        if (table.find(TargetParts, "All")) then
            CheckAll()
        else
            for _, TargetPartName in pairs(TargetParts) do
                CheckTargetPart(TargetPartName)
            end
        end
    end

    return ClosestPart, ClosestPartPosition, ClosestPartOnScreen, ClosestPartMagnitudeFromMouse
end

local PreviousPosition = nil
function Aiming.GetClosestToCursor(deltaTime)
    local TargetPart = nil
    local ClosestPlayer = nil
    local PartPosition = nil
    local PartVelocity = nil
    local PartOnScreen = nil
    local Chance = Utilities.CalculateChance(AimingSettings.HitChance)
    local ShortestDistance = circle.Radius
    local AimingSelected = Aiming.Selected

    if (not Chance) then
        AimingSelected.Instance = nil
        AimingSelected.Part = nil
        AimingSelected.Position = nil
        PreviousPosition = nil
        AimingSelected.Velocity = nil
        AimingSelected.OnScreen = false

        return
    end

    for _, Player in pairs(Utilities.GetPlayers()) do
        local Character = Utilities.Character(Player)

        if (Ignored.IsIgnored(Player) == false and Character) then
            local TargetPartTemp, PartPositionTemp, PartPositionOnScreenTemp, Magnitude = Aiming.GetClosestTargetPartToCursor(Character)

            if (TargetPartTemp and Checks.Health(Player) and Checks.Custom(Player)) then
                if (Magnitude < ShortestDistance) then
                    if (AimingSettings.VisibleCheck and not Utilities.IsPartVisible(TargetPartTemp, Character)) then continue end

                    ClosestPlayer = Player
                    ShortestDistance = Magnitude
                    TargetPart = TargetPartTemp
                    PartPosition = PartPositionTemp
                    PartOnScreen = PartPositionOnScreenTemp

                    if (not PreviousPosition) then
                        PreviousPosition = TargetPart.Position
                    end
                    PartVelocity = Utilities.CalculateVelocity(PreviousPosition, TargetPart.Position, deltaTime)
                    PreviousPosition = TargetPart.Position
                end
            end
        end
    end

    if (AimingSelected.Part ~= TargetPart) then
        AimingSelected.Velocity = nil
        PreviousPosition = nil
    end

    AimingSelected.Instance = ClosestPlayer
    AimingSelected.Part = TargetPart
    AimingSelected.Position = PartPosition
    AimingSelected.Velocity = PartVelocity
    AimingSelected.OnScreen = PartOnScreen
end

Heartbeat:Connect(function(deltaTime)
    Aiming.UpdateFOV()
    Aiming.UpdateTracer()
    Aiming.GetClosestToCursor(deltaTime)

    Aiming.Loaded = true
end)

return Aiming
