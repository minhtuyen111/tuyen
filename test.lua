--==================================================
-- AUTO FARM / FLY ABOVE MOB
-- ROBLOX STUDIO - FULL VERSION
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local Settings = {
    Enabled = false,

    -- Folder chứa quái
    MobFolder = workspace:FindFirstChild("Mobs"),

    -- Khoảng cách tối đa tìm quái
    MaxTeleportDistance = 500,

    -- Độ cao đứng trên đầu quái
    HeightAboveMob = 8,

    -- Tốc độ bay
    -- Tối đa 200
    FlySpeed = 180,

    -- Phạm vi đánh
    AttackRange = 15,

    -- Tốc độ đánh
    AttackCooldown = 0.45,

    -- Loại vũ khí
    WeaponType = "Melee",
}

Settings.FlySpeed = math.clamp(Settings.FlySpeed, 1, 200)

--==================================================
-- CHARACTER
--==================================================

local Character
local Humanoid
local Root

local function UpdateCharacter()

    Character = Player.Character or Player.CharacterAdded:Wait()

    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")

end

UpdateCharacter()

Player.CharacterAdded:Connect(function()

    task.wait(1)

    UpdateCharacter()

end)

--==================================================
-- GET MOB FOLDER
--==================================================

local function GetMobFolder()

    if Settings.MobFolder
        and Settings.MobFolder.Parent then

        return Settings.MobFolder
    end

    Settings.MobFolder = workspace:FindFirstChild("Mobs")

    return Settings.MobFolder

end

--==================================================
-- CHECK MOB
--==================================================

local function IsValidMob(Mob)

    if not Mob then
        return false
    end

    if not Mob:IsA("Model") then
        return false
    end

    local Hum =
        Mob:FindFirstChildOfClass("Humanoid")

    local HRP =
        Mob:FindFirstChild("HumanoidRootPart")

    if not Hum or not HRP then
        return false
    end

    if Hum.Health <= 0 then
        return false
    end

    return true

end

--==================================================
-- FIND NEAREST MOB
--==================================================

local function GetNearestMob()

    if not Root then
        return nil
    end

    local Folder = GetMobFolder()

    if not Folder then
        return nil
    end

    local Nearest = nil
    local NearestDistance =
        Settings.MaxTeleportDistance

    for _, Mob in ipairs(Folder:GetChildren()) do

        if IsValidMob(Mob) then

            local MobRoot =
                Mob:FindFirstChild("HumanoidRootPart")

            if MobRoot then

                local Distance =
                    (Root.Position - MobRoot.Position).Magnitude

                if Distance <= NearestDistance then

                    Nearest = Mob
                    NearestDistance = Distance

                end

            end

        end

    end

    return Nearest

end

--==================================================
-- GET WEAPON
--==================================================

local function GetWeapon()

    if not Character then
        return nil
    end

    local Backpack =
        Player:FindFirstChild("Backpack")

    -- Tool đang cầm
    for _, Tool in ipairs(Character:GetChildren()) do

        if Tool:IsA("Tool") then
            return Tool
        end

    end

    -- Tool trong Backpack
    if Backpack then

        for _, Tool in ipairs(Backpack:GetChildren()) do

            if Tool:IsA("Tool") then
                return Tool
            end

        end

    end

    return nil

end

--==================================================
-- EQUIP WEAPON
--==================================================

local function EquipWeapon()

    if not Humanoid then
        return nil
    end

    local Tool = GetWeapon()

    if not Tool then
        return nil
    end

    if Tool.Parent ~= Character then

        Humanoid:EquipTool(Tool)

    end

    return Tool

end

--==================================================
-- ATTACK
--==================================================

local LastAttack = 0

local function Attack()

    local Now = os.clock()

    if Now - LastAttack <
        Settings.AttackCooldown then

        return

    end

    local Tool = EquipWeapon()

    if not Tool then
        return
    end

    LastAttack = Now

    pcall(function()

        Tool:Activate()

    end)

end

--==================================================
-- FLY ABOVE MOB
--==================================================

local function FlyAboveMob(Mob, DeltaTime)

    if not Root then
        return
    end

    if not Mob then
        return
    end

    local MobRoot =
        Mob:FindFirstChild("HumanoidRootPart")

    if not MobRoot then
        return
    end

    -- Vị trí trên đầu quái
    local TargetPosition =
        MobRoot.Position +
        Vector3.new(
            0,
            Settings.HeightAboveMob,
            0
        )

    local CurrentPosition =
        Root.Position

    local Offset =
        TargetPosition - CurrentPosition

    local Distance =
        Offset.Magnitude

    if Distance < 0.1 then

        Root.CFrame =
            CFrame.lookAt(
                TargetPosition,
                MobRoot.Position
            )

        Root.AssemblyLinearVelocity =
            Vector3.zero

        Root.AssemblyAngularVelocity =
            Vector3.zero

        return

    end

    -- Giới hạn tốc độ
    local MaxStep =
        Settings.FlySpeed * DeltaTime

    local NewPosition

    if Distance <= MaxStep then

        NewPosition =
            TargetPosition

    else

        NewPosition =
            CurrentPosition +
            Offset.Unit * MaxStep

    end

    -- Nhìn về phía quái
    Root.CFrame =
        CFrame.lookAt(
            NewPosition,
            Vector3.new(
                MobRoot.Position.X,
                NewPosition.Y,
                MobRoot.Position.Z
            )
        )

    -- Hạn chế rung
    Root.AssemblyLinearVelocity =
        Vector3.zero

    Root.AssemblyAngularVelocity =
        Vector3.zero

end

--==================================================
-- MAIN AUTO FARM
--==================================================

local CurrentMob = nil

RunService.Heartbeat:Connect(function(DeltaTime)

    if not Settings.Enabled then
        return
    end

    if not Character
        or not Humanoid
        or not Root then

        return
    end

    if Humanoid.Health <= 0 then
        return
    end

    -- Kiểm tra mục tiêu
    if not IsValidMob(CurrentMob) then

        CurrentMob =
            GetNearestMob()

    end

    if not CurrentMob then
        return
    end

    local MobRoot =
        CurrentMob:FindFirstChild(
            "HumanoidRootPart"
        )

    if not MobRoot then

        CurrentMob = nil

        return

    end

    local Distance =
        (Root.Position - MobRoot.Position).Magnitude

    -- Vượt quá range
    if Distance >
        Settings.MaxTeleportDistance then

        CurrentMob = nil

        return

    end

    -- Bay lên đầu quái
    FlyAboveMob(
        CurrentMob,
        DeltaTime
    )

    -- Đánh
    if Distance <= Settings.AttackRange then

        Attack()

    end

end)

--==================================================
-- API
--==================================================

_G.AutoFarmSettings = Settings

function _G.EnableAutoFarm()

    Settings.Enabled = true

end

function _G.DisableAutoFarm()

    Settings.Enabled = false

    if Root then

        Root.AssemblyLinearVelocity =
            Vector3.zero

        Root.AssemblyAngularVelocity =
            Vector3.zero

    end

end

function _G.SetWeaponType(Type)

    if Type == "Melee"
        or Type == "Sword"
        or Type == "Fruit" then

        Settings.WeaponType = Type

    end

end

function _G.SetFlySpeed(Speed)

    Settings.FlySpeed =
        math.clamp(
            tonumber(Speed) or 180,
            1,
            200
        )

end

function _G.SetAttackRange(Range)

    Settings.AttackRange =
        math.clamp(
            tonumber(Range) or 15,
            1,
            100
        )

end

function _G.SetMaxDistance(Distance)

    Settings.MaxTeleportDistance =
        math.clamp(
            tonumber(Distance) or 500,
            1,
            500
        )

end

--==================================================
-- GUI
--==================================================

local PlayerGui =
    Player:WaitForChild("PlayerGui")

local OldGui =
    PlayerGui:FindFirstChild(
        "AutoFarmGUI"
    )

if OldGui then
    OldGui:Destroy()
end

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name =
    "AutoFarmGUI"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.IgnoreGuiInset =
    true

ScreenGui.Parent =
    PlayerGui

--==================================================
-- MAIN MENU 16:9
--==================================================

local Main =
    Instance.new("Frame")

Main.Name =
    "Main"

Main.Parent =
    ScreenGui

Main.Size =
    UDim2.fromOffset(
        360,
        202
    )

Main.Position =
    UDim2.new(
        0.5,
        -180,
        0.5,
        -101
    )

Main.BackgroundColor3 =
    Color3.fromRGB(
        20,
        20,
        20
    )

Main.BorderSizePixel =
    0

Main.Active =
    true

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(
        0,
        12
    )

MainCorner.Parent =
    Main

local MainStroke =
    Instance.new("UIStroke")

MainStroke.Thickness =
    1

MainStroke.Color =
    Color3.fromRGB(
        70,
        70,
        70
    )

MainStroke.Parent =
    Main

--==================================================
-- DRAG MENU
--==================================================

local Dragging = false
local DragStart
local StartPosition

local function UpdateDrag(Input)

    local Delta =
        Input.Position - DragStart

    Main.Position =
        UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )

end

Main.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or Input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = true

        DragStart =
            Input.Position

        StartPosition =
            Main.Position

    end

end)

Main.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or Input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or Input.UserInputType ==
        Enum.UserInputType.Touch then

        UpdateDrag(Input)

    end

end)

--==================================================
-- TITLE
--==================================================

local Title =
    Instance.new("TextLabel")

Title.Parent =
    Main

Title.Size =
    UDim2.new(
        1,
        -50,
        0,
        30
    )

Title.Position =
    UDim2.fromOffset(
        12,
        5
    )

Title.BackgroundTransparency =
    1

Title.Text =
    "AUTO FARM"

Title.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

Title.TextSize =
    17

Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

local SubTitle =
    Instance.new("TextLabel")

SubTitle.Parent =
    Main

SubTitle.Size =
    UDim2.new(
        1,
        -50,
        0,
        18
    )

SubTitle.Position =
    UDim2.fromOffset(
        12,
        29
    )

SubTitle.BackgroundTransparency =
    1

SubTitle.Text =
    "Fly Above Mob • Auto Attack"

SubTitle.TextColor3 =
    Color3.fromRGB(
        140,
        140,
        140
    )

SubTitle.TextSize =
    9

SubTitle.Font =
    Enum.Font.Gotham

SubTitle.TextXAlignment =
    Enum.TextXAlignment.Left

--==================================================
-- CLOSE
--==================================================

local Close =
    Instance.new("TextButton")

Close.Parent =
    Main

Close.Size =
    UDim2.fromOffset(
        28,
        28
    )

Close.Position =
    UDim2.new(
        1,
        -34,
        0,
        6
    )

Close.BackgroundTransparency =
    1

Close.Text =
    "×"

Close.TextColor3 =
    Color3.fromRGB(
        220,
        220,
        220
    )

Close.TextSize =
    22

Close.Font =
    Enum.Font.GothamBold

--==================================================
-- LOGO
--==================================================

local Logo =
    Instance.new("TextButton")

Logo.Name =
    "OpenLogo"

Logo.Parent =
    ScreenGui

Logo.Size =
    UDim2.fromOffset(
        52,
        52
    )

Logo.Position =
    UDim2.new(
        0,
        15,
        0.5,
        -26
    )

Logo.BackgroundColor3 =
    Color3.fromRGB(
        20,
        20,
        20
    )

Logo.Text =
    "AF"

Logo.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

Logo.TextSize =
    18

Logo.Font =
    Enum.Font.GothamBold

Logo.Visible =
    false

local LogoCorner =
    Instance.new("UICorner")

LogoCorner.CornerRadius =
    UDim.new(
        1,
        0
    )

LogoCorner.Parent =
    Logo

local LogoStroke =
    Instance.new("UIStroke")

LogoStroke.Thickness =
    2

LogoStroke.Color =
    Color3.fromRGB(
        80,
        80,
        80
    )

LogoStroke.Parent =
    Logo

Close.MouseButton1Click:Connect(function()

    Main.Visible = false
    Logo.Visible = true

end)

Logo.MouseButton1Click:Connect(function()

    Main.Visible = true
    Logo.Visible = false

end)

--==================================================
-- BUTTON FUNCTION
--==================================================

local function CreateButton(
    Text,
    Position,
    Size
)

    local Button =
        Instance.new("TextButton")

    Button.Parent =
        Main

    Button.Size =
        Size

    Button.Position =
        Position

    Button.BackgroundColor3 =
        Color3.fromRGB(
            42,
            42,
            42
        )

    Button.Text =
        Text

    Button.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    Button.TextSize =
        10

    Button.Font =
        Enum.Font.GothamBold

    Button.AutoButtonColor =
        true

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            7
        )

    Corner.Parent =
        Button

    return Button

end

--==================================================
-- AUTO FARM BUTTON
--==================================================

local FarmButton =
    CreateButton(
        "AUTO FARM : OFF",
        UDim2.fromOffset(
            12,
            52
        ),
        UDim2.fromOffset(
            105,
            32
        )
    )

local function UpdateFarmButton()

    if Settings.Enabled then

        FarmButton.Text =
            "AUTO FARM : ON"

        FarmButton.BackgroundColor3 =
            Color3.fromRGB(
                45,
                125,
                70
            )

    else

        FarmButton.Text =
            "AUTO FARM : OFF"

        FarmButton.BackgroundColor3 =
            Color3.fromRGB(
                42,
                42,
                42
            )

    end

end

FarmButton.MouseButton1Click:Connect(function()

    Settings.Enabled =
        not Settings.Enabled

    UpdateFarmButton()

end)

--==================================================
-- WEAPON LABEL
--==================================================

local WeaponLabel =
    Instance.new("TextLabel")

WeaponLabel.Parent =
    Main

WeaponLabel.Size =
    UDim2.fromOffset(
        105,
        20
    )

WeaponLabel.Position =
    UDim2.fromOffset(
        12,
        89
    )

WeaponLabel.BackgroundTransparency =
    1

WeaponLabel.Text =
    "WEAPON"

WeaponLabel.TextColor3 =
    Color3.fromRGB(
        170,
        170,
        170
    )

WeaponLabel.TextSize =
    9

WeaponLabel.Font =
    Enum.Font.GothamBold

WeaponLabel.TextXAlignment =
    Enum.TextXAlignment.Left

--==================================================
-- WEAPON BUTTONS
--==================================================

local MeleeButton =
    CreateButton(
        "MELEE",
        UDim2.fromOffset(
            12,
            109
        ),
        UDim2.fromOffset(
            70,
            28
        )
    )

local SwordButton =
    CreateButton(
        "SWORD",
        UDim2.fromOffset(
            88,
            109
        ),
        UDim2.fromOffset(
            70,
            28
        )
    )

local FruitButton =
    CreateButton(
        "FRUIT",
        UDim2.fromOffset(
            164,
            109
        ),
        UDim2.fromOffset(
            70,
            28
        )
    )

local function UpdateWeaponButtons()

    MeleeButton.BackgroundColor3 =
        Settings.WeaponType == "Melee"
        and Color3.fromRGB(45, 125, 70)
        or Color3.fromRGB(42, 42, 42)

    SwordButton.BackgroundColor3 =
        Settings.WeaponType == "Sword"
        and Color3.fromRGB(45, 125, 70)
        or Color3.fromRGB(42, 42, 42)

    FruitButton.BackgroundColor3 =
        Settings.WeaponType == "Fruit"
        and Color3.fromRGB(45, 125, 70)
        or Color3.fromRGB(42, 42, 42)

end

MeleeButton.MouseButton1Click:Connect(function()

    Settings.WeaponType =
        "Melee"

    UpdateWeaponButtons()

end)

SwordButton.MouseButton1Click:Connect(function()

    Settings.WeaponType =
        "Sword"

    UpdateWeaponButtons()

end)

FruitButton.MouseButton1Click:Connect(function()

    Settings.WeaponType =
        "Fruit"

    UpdateWeaponButtons()

end)

--==================================================
-- SETTINGS LABELS
--==================================================

local function CreateSettingLabel(
    Text,
    Position
)

    local Label =
        Instance.new("TextLabel")

    Label.Parent =
        Main

    Label.Size =
        UDim2.fromOffset(
            110,
            22
        )

    Label.Position =
        Position

    Label.BackgroundTransparency =
        1

    Label.Text =
        Text

    Label.TextColor3 =
        Color3.fromRGB(
            180,
            180,
            180
        )

    Label.TextSize =
        9

    Label.Font =
        Enum.Font.Gotham

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    return Label

end

local FlyLabel =
    CreateSettingLabel(
        "FLY SPEED",
        UDim2.fromOffset(
            245,
            55
        )
    )

local RangeLabel =
    CreateSettingLabel(
        "MOB RANGE",
        UDim2.fromOffset(
            245,
            91
        )
    )

local HeightLabel =
    CreateSettingLabel(
        "HEIGHT",
        UDim2.fromOffset(
            245,
            127
        )
    )

--==================================================
-- VALUE BUTTONS
--==================================================

local FlyValue =
    CreateButton(
        "180",
        UDim2.fromOffset(
            315,
            52
        ),
        UDim2.fromOffset(
            32,
            28
        )
    )

local RangeValue =
    CreateButton(
        "500",
        UDim2.fromOffset(
            315,
            88
        ),
        UDim2.fromOffset(
            32,
            28
        )
    )

local HeightValue =
    CreateButton(
        "8",
        UDim2.fromOffset(
            315,
            124
        ),
        UDim2.fromOffset(
            32,
            28
        )
    )

--==================================================
-- FLY SPEED CYCLE
--==================================================

local FlySpeeds = {
    100,
    140,
    180,
    200
}

local FlyIndex = 3

FlyValue.MouseButton1Click:Connect(function()

    FlyIndex =
        FlyIndex + 1

    if FlyIndex >
        #FlySpeeds then

        FlyIndex = 1

    end

    Settings.FlySpeed =
        FlySpeeds[FlyIndex]

    FlyValue.Text =
        tostring(Settings.FlySpeed)

end)

--==================================================
-- MOB RANGE CYCLE
--==================================================

local MobRanges = {
    100,
    200,
    300,
    400,
    500
}

local RangeIndex = 5

RangeValue.MouseButton1Click:Connect(function()

    RangeIndex =
        RangeIndex + 1

    if RangeIndex >
        #MobRanges then

        RangeIndex = 1

    end

    Settings.MaxTeleportDistance =
        MobRanges[RangeIndex]

    RangeValue.Text =
        tostring(
            Settings.MaxTeleportDistance
        )

end)

--==================================================
-- HEIGHT CYCLE
--==================================================

local Heights = {
    5,
    6,
    8,
    10,
    12
}

local HeightIndex = 3

HeightValue.MouseButton1Click:Connect(function()

    HeightIndex =
        HeightIndex + 1

    if HeightIndex >
        #Heights then

        HeightIndex = 1

    end

    Settings.HeightAboveMob =
        Heights[HeightIndex]

    HeightValue.Text =
        tostring(
            Settings.HeightAboveMob
        )

end)

--==================================================
-- ATTACK RANGE
--==================================================

local AttackLabel =
    CreateSettingLabel(
        "ATTACK RANGE",
        UDim2.fromOffset(
            12,
            143
        )
    )

local AttackValue =
    CreateButton(
        "15",
        UDim2.fromOffset(
            90,
            140
        ),
        UDim2.fromOffset(
            45,
            28
        )
    )

local AttackRanges = {
    10,
    15,
    20,
    25,
    30
}

local AttackIndex = 2

AttackValue.MouseButton1Click:Connect(function()

    AttackIndex =
        AttackIndex + 1

    if AttackIndex >
        #AttackRanges then

        AttackIndex = 1

    end

    Settings.AttackRange =
        AttackRanges[AttackIndex]

    AttackValue.Text =
        tostring(
            Settings.AttackRange
        )

end)

--==================================================
-- ATTACK SPEED
--==================================================

local SpeedLabel =
    CreateSettingLabel(
        "ATTACK SPEED",
        UDim2.fromOffset(
            150,
            143
        )
    )

local SpeedValue =
    CreateButton(
        "0.45",
        UDim2.fromOffset(
            225,
            140
        ),
        UDim2.fromOffset(
            45,
            28
        )
    )

local AttackSpeeds = {
    0.30,
    0.45,
    0.60,
    0.80
}

local SpeedIndex = 2

SpeedValue.MouseButton1Click:Connect(function()

    SpeedIndex =
        SpeedIndex + 1

    if SpeedIndex >
        #AttackSpeeds then

        SpeedIndex = 1

    end

    Settings.AttackCooldown =
        AttackSpeeds[SpeedIndex]

    SpeedValue.Text =
        tostring(
            Settings.AttackCooldown
        )

end)

--==================================================
-- STATUS
--==================================================

local Status =
    Instance.new("TextLabel")

Status.Parent =
    Main

Status.Size =
    UDim2.fromOffset(
        105,
        18
    )

Status.Position =
    UDim2.fromOffset(
        245,
        163
    )

Status.BackgroundTransparency =
    1

Status.Text =
    "READY"

Status.TextColor3 =
    Color3.fromRGB(
        140,
        140,
        140
    )

Status.TextSize =
    9

Status.Font =
    Enum.Font.GothamBold

--==================================================
-- STATUS UPDATE
--==================================================

task.spawn(function()

    while task.wait(0.2) do

        if Settings.Enabled then

            if CurrentMob
                and IsValidMob(CurrentMob) then

                Status.Text =
                    "FARMING"

            else

                Status.Text =
                    "SEARCHING"

            end

        else

            Status.Text =
                "READY"

        end

    end

end)

--==================================================
-- INITIAL UPDATE
--==================================================

UpdateFarmButton()
UpdateWeaponButtons()

FlyValue.Text =
    tostring(Settings.FlySpeed)

RangeValue.Text =
    tostring(Settings.MaxTeleportDistance)

HeightValue.Text =
    tostring(Settings.HeightAboveMob)

AttackValue.Text =
    tostring(Settings.AttackRange)

SpeedValue.Text =
    tostring(Settings.AttackCooldown)

--==================================================
-- DONE
--==================================================