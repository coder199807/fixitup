-- ============================================================
--  Fix It Up — Smart GUI  v3.0
--  Executor: Xeno  |  Sprache: Lua
--  Rarity-System: Spawn-Rate basiert
--    0-5%   → Episch  (Pink)
--    6-15%  → Selten  (Blau)
--    16-25% → Ungewöhnlich (Grün)
--    >25% / N/A / Nicht verfügbar → Gewöhnlich (Grau)
-- ============================================================

-- ── Anti-Detection ───────────────────────────────────────────
local mt = getrawmetatable and getrawmetatable(game)
if mt then
    local _idx = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(t, k)
        return _idx(t, k)
    end)
    setreadonly(mt, true)
end

-- ── Services (cloneref für hook-safety) ──────────────────────
local function safe(s) return (cloneref and cloneref(s)) or s end
local Players    = safe(game:GetService("Players"))
local RunService = safe(game:GetService("RunService"))
local workspace  = safe(game:GetService("Workspace"))
local LP         = Players.LocalPlayer

-- ============================================================
--  HILFSFUNKTION: Spawn-Rate String → Zahl (%)
-- ============================================================
local function parseRate(s)
    if not s then return nil end
    -- "N/A", "Nicht verfügbar", "Außerverkauft" etc. → nil
    local num = s:match("([%d%.,]+)%%")
    if not num then return nil end
    num = num:gsub(",", ".")
    return tonumber(num)
end

-- ============================================================
--  RARITY aus Spawn-Rate berechnen
--  Rückgabe: 1=Gewöhnlich  2=Ungewöhnlich  3=Selten  4=Episch
-- ============================================================
local function calcRarity(spawnRateStr)
    local r = parseRate(spawnRateStr)
    if r == nil then
        -- N/A oder Nicht verfügbar → als Episch behandeln (nicht im regulären Spawn)
        return 4
    elseif r <= 5 then
        return 4  -- Episch
    elseif r <= 15 then
        return 3  -- Selten
    elseif r <= 25 then
        return 2  -- Ungewöhnlich
    else
        return 1  -- Gewöhnlich
    end
end

-- ============================================================
--  FAHRZEUG-DATENBANK  (aktualisiert nach Bild 2)
--  rarity wird automatisch aus spawnRate berechnet
-- ============================================================
local RAW_VEHICLES = {
    -- Fahrzeugname,          Spawn-Rate String,    Preis
    {"Wesla Modelo",          "N/A",                "HR+ Exklusiv"},
    {"Bananenauto",           "N/A",                "Moderator+ Exklusiv"},
    {"Mata FX7",              "N/A",                "Außer Haus"},
    {"Porx JT3 RF",           "N/A",                "Außer Haus"},
    {"BNV K4 G",              "N/A",                "799"},
    {"Audi RF6",              "N/A",                "699"},
    {"BNV K340i",             "N/A",                "599"},
    {"Merquis G Wafer",       "N/A",                "Exklusives Event"},
    {"Merquis JF",            "N/A",                "Nicht verfügbar"},
    {"Sigma Roma Quadri",     "N/A",                "Nicht verfügbar"},
    {"Kart",                  "Nicht verfügbar",    "Außerverkauft"},
    {"Lambemos-Iris",         "Nicht verfügbar",    "Außerbörslich"},
    {"BNV K3 F",              "0,02%",              "80.000€ – 120.000€"},
    {"DOGO Desafio",          "Nicht verfügbar",    "Außerbörslich"},
    {"Fia-Te Double",         "Nicht verfügbar",    "Außerhalb des regulären Verkaufs"},
    {"Toyoda Supwa A90",      "Nicht verfügbar",    "Außerverkauft"},
    {"Sucato Empresa",        "Nicht verfügbar",    "Nicht verfügbar"},
    {"Chule Curgette C7",     "Nicht verfügbar",    "Nicht verfügbar"},
    {"Skami Truk",            "0,05%",              "120.000€ – 200.000€"},
    {"BNV K8",                "0,05%",              "180.000€ – 230.000€"},
    {"Merquis SLX",           "0,05%",              "180.000€ – 280.000€"},
    {"Mine Copa S",           "0,05%",              "50.000€ – 70.000€"},
    {"Missah JTF",            "Nicht verfügbar",    "Außerverkauft"},
    {"Porx JT2 RF",           "Nicht verfügbar",    "Außerverkauft"},
    {"Missah Groundline F34", "Nicht verfügbar",    "Außerverkauft"},
    {"Ropes Ruyter Shadow",   "Nicht verfügbar",    "Außerverkauft"},
    {"Holde S2k",             "Nicht verfügbar",    "Außerverkauft"},
    {"Chule Curgete",         "0,1%",               "65.000€ – 120.000€"},
    {"Audi V7",               "Nicht verfügbar",    "Außerbörslich"},
    {"Audi F8",               "Nicht verfügbar",    "Außerverkauft"},
    {"Fia-Te 10026p",         "0,2%",               "3.000€ – 7.000€"},
    {"Audi F8 Performance",   "Nicht verfügbar",    "Außerverkauft"},
    {"Toyoda Supwa",          "Nicht verfügbar",    "Außerverkauft"},
    {"Vier Mustank 70s",      "Nicht verfügbar",    "Außerverkauft"},
    {"Toyoda AFF67",          "0,3%",               "25.000€ – 55.000€"},
    {"Auidy RF3 Limousine",   "0,3%",               "70.000€ – 90.000€"},
    {"Lokswag Brasiuiu",      "0,3%",               "5.000€ – 12.000€"},
    {"Audi V8",               "0,4%",               "120.000€ – 200.000€"},
    {"BNV K5 e60",            "0,5%",               "60.000€ – 90.000€"},
    {"Ratos Rotos Esporte",   "0,5%",               "100.000€ – 200.000€"},
    {"Holde TipeRar",         "0,5%",               "50.000€ – 90.000€"},
    {"Audi RF3",              "0,6%",               "40.000€ – 55.000€"},
    {"Holde Proluiz",         "0,8%",               "10.000€ – 25.000€"},
    {"Missah 750x",           "Nicht verfügbar",    "Außerbörslich"},
    {"Chule Camarao",         "1%",                 "60.000€ – 100.000€"},
    {"Four Rex",              "1%",                 "60.000€ – 80.000€"},
    {"Audi V5",               "1%",                 "40.000€ – 55.000€"},
    {"Merquis Z73",           "1%",                 "35.000€ – 65.000€"},
    {"BNV K3 e92",            "1%",                 "45.000€ – 60.000€"},
    {"Matsu Lanca",           "2%",                 "15.000€ – 55.000€"},
    {"Lokswag Golo GT",       "2%",                 "25.000€ – 55.000€"},
    {"Toyoda Yapp",           "2%",                 "25.000€ – 55.000€"},
    {"Vovo F60 Polo",         "2,5%",               "25.000€ – 45.000€"},
    {"BNV K5 e39",            "3%",                 "20.000€ – 50.000€"},
    {"BNV K140",              "Nicht verfügbar",    "Außerverkauft"},
    {"Merquis ZLA 45",        "Nicht verfügbar",    "Außerverkauft"},
    {"Fia-Te Alberto 300",    "3%",                 "18.000€ – 30.000€"},
    {"Ontel Astron",          "4%",                 "25.000€ – 40.000€"},
    {"Raguer XisR",           "5%",                 "20.000€ – 30.000€"},
    {"Renas Mugano",          "5%",                 "18.000€ – 30.000€"},
    {"Four Traffic",          "6%",                 "15.000€ – 30.000€"},
    {"Vier Party",            "6%",                 "23.000€ – 40.000€"},
    {"Lokswag Golo MK5",      "7%",                 "17.000€ – 25.000€"},
    {"Merquis C203",          "7%",                 "9.000€ – 22.000€"},
    {"Toyoda Hellox",         "7%",                 "28.000€ – 40.000€"},
    {"Holde Inteiro",         "7%",                 "9.000€ – 30.000€"},
    {"Leskus not200",         "10%",                "9.000€ – 20.000€"},
    {"BNV K3",                "10%",                "9.000€ – 20.000€"},
    {"Missah Silva",          "Nicht verfügbar",    "Außerbörslich"},
    {"Holde Ciwiq",           "11%",                "5.000€ – 15.000€"},
    {"Audi V4",               "15%",                "12.000€ – 18.000€"},
    {"Lokswag Golo MK4",      "15%",                "12.000€ – 17.000€"},
    {"Vovo Sr60",             "17%",                "12.000€ – 17.000€"},
    {"Peujo 400e6",           "20%",                "7.000€ – 17.000€"},
    {"Lokswag Passar",        "20%",                "8.000€ – 14.000€"},
    {"Sacode Oitava",         "20%",                "8.000€ – 14.000€"},
    {"Peujo 200e5",           "25%",                "7.000€ – 12.000€"},
    {"Renas Kapturado",       "30%",                "5.000€ – 11.000€"},
    {"Lokswag Golo",          "30%",                "4.000€ – 8.000€"},
    {"Ontel Costa",           "30%",                "700€ – 3.000€"},
    {"Xitro J3",              "40%",                "15.000€ – 20.000€"},
    {"Sabes Muito",           "40%",                "7.000€ – 15.000€"},
    {"Peujo 200e6",           "50%",                "1.000€ – 4.000€"},
    {"Fia-Te Ponto",          "50%",                "700€ – 3.000€"},
    {"Siath Lion",            "50%",                "1.500€ – 4.000€"},
}

-- Baue VEHICLES Tabelle mit auto-berechneter Rarity
local VEHICLES = {}
for _, v in ipairs(RAW_VEHICLES) do
    table.insert(VEHICLES, {
        name      = v[1],
        spawnRate = v[2],
        price     = v[3],
        rarity    = calcRarity(v[2]),
        rateNum   = parseRate(v[2]) or 999, -- für Sortierung
    })
end

-- Lookup-Map für schnellen Namensvergleich
local VEHICLE_MAP = {}
for _, v in ipairs(VEHICLES) do
    VEHICLE_MAP[string.lower(v.name)] = v
end

-- ============================================================
--  RARITY DARSTELLUNG
-- ============================================================
local RARITY = {
    [1] = { label="Gewöhnlich",    badge="●", col=Color3.fromRGB(160,160,160), glow=Color3.fromRGB(140,140,140) },
    [2] = { label="Ungewöhnlich",  badge="◆", col=Color3.fromRGB(80,230,80),   glow=Color3.fromRGB(60,255,60)   },
    [3] = { label="Selten",        badge="★", col=Color3.fromRGB(80,140,255),  glow=Color3.fromRGB(60,120,255)  },
    [4] = { label="Episch",        badge="✦", col=Color3.fromRGB(255,80,200),  glow=Color3.fromRGB(255,50,190)  },
}

-- ============================================================
--  STATE
-- ============================================================
local watchList       = {}
local highlights      = {}
local alertSound      = nil
local sniperActive    = false
local lastTpTime      = 0
local spawnedCache    = {}
local lastHash        = ""

-- Countdown state
local countdownValue  = 0   -- Sekunden bis nächster Spawn (0 = unbekannt)
local lastCountdownSrc= nil -- TextLabel Referenz im Spiel

-- ============================================================
--  UTILITY
-- ============================================================
local function PlayAlert()
    if not alertSound then
        alertSound = Instance.new("Sound", workspace)
        alertSound.SoundId = "rbxassetid://9125402735"
        alertSound.Volume  = 1
        alertSound.RollOffMaxDistance = 10000
    end
    if not alertSound.IsPlaying then alertSound:Play() end
end

local function TP(cf)
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = cf + Vector3.new(0, 4, 0) end
    end
end

local function ClearHighlights()
    for _, h in pairs(highlights) do pcall(function() h:Destroy() end) end
    highlights = {}
end

local function AddHighlight(model, rarity)
    local rd = RARITY[rarity]
    if not rd then return end
    local ok, h = pcall(function()
        local sel = Instance.new("SelectionBox", workspace)
        sel.Adornee            = model
        sel.Color3             = rd.glow
        sel.LineThickness      = 0.07
        sel.SurfaceTransparency= 0.75
        sel.SurfaceColor3      = rd.glow
        return sel
    end)
    if ok then table.insert(highlights, h) end
end

-- ============================================================
--  COUNTDOWN-DETEKTION
--  Sucht TextLabels im Spiel-GUI nach Zeitformaten wie "0:30"
-- ============================================================
local function FindCountdown()
    -- Suche in allen PlayerGui / CoreGui nach Countdown-Texten
    local sources = {
        LP:FindFirstChild("PlayerGui"),
        LP:FindFirstChild("PlayerScripts"),
    }
    -- Auch Workspace BillboardGuis
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            table.insert(sources, obj)
        end
    end

    for _, src in ipairs(sources) do
        if src then
            for _, lbl in ipairs(src:GetDescendants()) do
                if lbl:IsA("TextLabel") or lbl:IsA("TextButton") then
                    local t = lbl.Text or ""
                    -- Erkennt "0:30", "1:00", "30s", "00:30" etc.
                    local m, s = t:match("(%d+):(%d+)")
                    if m and s then
                        return lbl, tonumber(m)*60 + tonumber(s)
                    end
                    local sec = t:match("^(%d+)s$")
                    if sec then return lbl, tonumber(sec) end
                end
            end
        end
    end
    return nil, 0
end

-- ============================================================
--  DYNAMISCHER SCANNER
--  Kein hardcoded Junkyard — sucht alle Modelle im Workspace
--  die zur Datenbank passen. Leichtgewichtig durch Name-Lookup.
-- ============================================================
local function ScanWorkspace()
    local found = {}
    local seen  = {}

    -- Nur direkte Kinder + eine Ebene tief (Junkyard-Folder)
    local function checkModel(obj)
        if not obj:IsA("Model") then return end
        if obj == LP.Character then return end
        local key = string.lower(obj.Name)
        if seen[obj] then return end
        seen[obj] = true

        -- Exakter Match zuerst
        local vData = VEHICLE_MAP[key]
        -- Fuzzy Match: prüfe ob Fahrzeugname im Modellnamen vorkommt
        if not vData then
            for dbKey, dbData in pairs(VEHICLE_MAP) do
                if key:find(dbKey, 1, true) or dbKey:find(key, 1, true) then
                    vData = dbData
                    break
                end
            end
        end

        if vData then
            local root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if root then
                table.insert(found, {
                    model = obj,
                    data  = vData,
                    cf    = root.CFrame,
                })
            end
        end
    end

    for _, child in ipairs(workspace:GetChildren()) do
        checkModel(child)
        -- Ein Level tiefer (Folder/Model Container)
        if child:IsA("Folder") or child:IsA("Model") then
            for _, grandchild in ipairs(child:GetChildren()) do
                checkModel(grandchild)
            end
        end
    end

    -- Sort: Episch zuerst
    table.sort(found, function(a, b)
        if a.data.rarity ~= b.data.rarity then
            return a.data.rarity > b.data.rarity
        end
        return a.data.rateNum < b.data.rateNum
    end)

    return found
end

local function GetHash(found)
    local h = ""
    for _, e in ipairs(found) do h = h .. e.data.name end
    return h
end

local function FindRarestWatchedIn(found)
    local best = nil
    for _, entry in ipairs(found) do
        for _, wName in ipairs(watchList) do
            if string.lower(entry.data.name) == string.lower(wName) then
                if not best or entry.data.rarity > best.data.rarity then
                    best = entry
                end
                break
            end
        end
    end
    return best
end

-- ============================================================
--  GUI AUFBAU
-- ============================================================
local GUI = Instance.new("ScreenGui")
GUI.Name           = "FixItUpV3"
GUI.ResetOnSpawn   = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent         = (gethui and gethui()) or LP.PlayerGui

-- Haupt-Frame
local Main = Instance.new("Frame", GUI)
Main.Size             = UDim2.new(0, 500, 0, 580)
Main.Position         = UDim2.new(0.5, -250, 0.5, -290)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
Main.BorderSizePixel  = 0
Main.Active           = true
Main.Draggable        = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Hintergrund-Verlauf
local bg = Instance.new("UIGradient", Main)
bg.Color    = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(16, 14, 28)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 10, 20)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  8,  14)),
}
bg.Rotation = 145

-- Titelleiste
local TBar = Instance.new("Frame", Main)
TBar.Size             = UDim2.new(1, 0, 0, 42)
TBar.BackgroundColor3 = Color3.fromRGB(16, 14, 28)
TBar.BorderSizePixel  = 0
Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 12)

local TLabel = Instance.new("TextLabel", TBar)
TLabel.Size     = UDim2.new(1, -100, 1, 0)
TLabel.Position = UDim2.new(0, 14, 0, 0)
TLabel.Text     = "🔧  Fix It Up  —  Smart GUI  v3"
TLabel.Font     = Enum.Font.GothamBold
TLabel.TextSize = 14
TLabel.TextColor3           = Color3.fromRGB(220, 210, 255)
TLabel.BackgroundTransparency = 1
TLabel.TextXAlignment       = Enum.TextXAlignment.Left

-- Countdown Anzeige in Titelleiste
local CDLabel = Instance.new("TextLabel", TBar)
CDLabel.Size     = UDim2.new(0, 80, 1, 0)
CDLabel.Position = UDim2.new(1, -120, 0, 0)
CDLabel.Text     = "⏱ --:--"
CDLabel.Font     = Enum.Font.GothamBold
CDLabel.TextSize = 13
CDLabel.TextColor3           = Color3.fromRGB(255, 200, 80)
CDLabel.BackgroundTransparency = 1

-- Close
local CloseBtn = Instance.new("TextButton", TBar)
CloseBtn.Size             = UDim2.new(0, 28, 0, 28)
CloseBtn.Position         = UDim2.new(1, -34, 0.5, -14)
CloseBtn.Text             = "✕"
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 13
CloseBtn.TextColor3       = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
CloseBtn.BorderSizePixel  = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    ClearHighlights()
    GUI:Destroy()
end)

-- Minimize
local MinBtn = Instance.new("TextButton", TBar)
MinBtn.Size             = UDim2.new(0, 28, 0, 28)
MinBtn.Position         = UDim2.new(1, -66, 0.5, -14)
MinBtn.Text             = "−"
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.TextSize         = 16
MinBtn.TextColor3       = Color3.fromRGB(200, 200, 100)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 10)
MinBtn.BorderSizePixel  = 0
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local minimized = false
local ContentHolder = Instance.new("Frame", Main)
ContentHolder.Size             = UDim2.new(1, 0, 1, -42)
ContentHolder.Position         = UDim2.new(0, 0, 0, 42)
ContentHolder.BackgroundTransparency = 1

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentHolder.Visible = not minimized
    Main.Size = minimized and UDim2.new(0, 500, 0, 42) or UDim2.new(0, 500, 0, 580)
    MinBtn.Text = minimized and "+" or "−"
end)

-- ── Tab Leiste ────────────────────────────────────────────────
local TabBar = Instance.new("Frame", ContentHolder)
TabBar.Size             = UDim2.new(1, -16, 0, 36)
TabBar.Position         = UDim2.new(0, 8, 0, 6)
TabBar.BackgroundTransparency = 1

local function NewTabBtn(txt, xoff)
    local b = Instance.new("TextButton", TabBar)
    b.Size             = UDim2.new(0.485, 0, 1, 0)
    b.Position         = UDim2.new(xoff, 0, 0, 0)
    b.Text             = txt
    b.Font             = Enum.Font.GothamSemibold
    b.TextSize         = 12
    b.TextColor3       = Color3.fromRGB(160, 160, 200)
    b.BackgroundColor3 = Color3.fromRGB(22, 20, 36)
    b.BorderSizePixel  = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end
local Tab1Btn = NewTabBtn("📡  Junkyard — Live", 0)
local Tab2Btn = NewTabBtn("🎯  Auto Sniper", 0.515)

-- ── Content Area ─────────────────────────────────────────────
local CA = Instance.new("Frame", ContentHolder)
CA.Size             = UDim2.new(1, -16, 1, -54)
CA.Position         = UDim2.new(0, 8, 0, 48)
CA.BackgroundTransparency = 1

-- ============================================================
--  TAB 1: Junkyard Live-Liste
-- ============================================================
local T1 = Instance.new("Frame", CA)
T1.Size             = UDim2.new(1, 0, 1, 0)
T1.BackgroundTransparency = 1

-- Status + Countdown Bar
local StatBar = Instance.new("Frame", T1)
StatBar.Size             = UDim2.new(1, 0, 0, 30)
StatBar.BackgroundColor3 = Color3.fromRGB(18, 16, 32)
StatBar.BorderSizePixel  = 0
Instance.new("UICorner", StatBar).CornerRadius = UDim.new(0, 7)

local StatLbl = Instance.new("TextLabel", StatBar)
StatLbl.Size     = UDim2.new(0.6, 0, 1, 0)
StatLbl.Position = UDim2.new(0, 8, 0, 0)
StatLbl.Text     = "● Scanne..."
StatLbl.Font     = Enum.Font.Gotham
StatLbl.TextSize = 11
StatLbl.TextColor3           = Color3.fromRGB(80, 255, 120)
StatLbl.BackgroundTransparency = 1
StatLbl.TextXAlignment       = Enum.TextXAlignment.Left

local CountLbl = Instance.new("TextLabel", StatBar)
CountLbl.Size     = UDim2.new(0.38, 0, 1, 0)
CountLbl.Position = UDim2.new(0.62, 0, 0, 0)
CountLbl.Text     = "Gefunden: 0"
CountLbl.Font     = Enum.Font.Gotham
CountLbl.TextSize = 11
CountLbl.TextColor3           = Color3.fromRGB(160, 140, 220)
CountLbl.BackgroundTransparency = 1
CountLbl.TextXAlignment       = Enum.TextXAlignment.Right

-- Spawn Countdown Bar (unter Statusbar)
local SpawnBar = Instance.new("Frame", T1)
SpawnBar.Size             = UDim2.new(1, 0, 0, 26)
SpawnBar.Position         = UDim2.new(0, 0, 0, 34)
SpawnBar.BackgroundColor3 = Color3.fromRGB(14, 12, 24)
SpawnBar.BorderSizePixel  = 0
Instance.new("UICorner", SpawnBar).CornerRadius = UDim.new(0, 7)

local SpawnLbl = Instance.new("TextLabel", SpawnBar)
SpawnLbl.Size     = UDim2.new(0.55, 0, 1, 0)
SpawnLbl.Position = UDim2.new(0, 8, 0, 0)
SpawnLbl.Text     = "⏱ Nächster Spawn: wird gesucht..."
SpawnLbl.Font     = Enum.Font.Gotham
SpawnLbl.TextSize = 11
SpawnLbl.TextColor3           = Color3.fromRGB(255, 200, 80)
SpawnLbl.BackgroundTransparency = 1
SpawnLbl.TextXAlignment       = Enum.TextXAlignment.Left

-- Progress Bar für Countdown
local SpawnProgress = Instance.new("Frame", SpawnBar)
SpawnProgress.Size             = UDim2.new(1, 0, 0, 3)
SpawnProgress.Position         = UDim2.new(0, 0, 1, -3)
SpawnProgress.BackgroundColor3 = Color3.fromRGB(255, 180, 40)
SpawnProgress.BorderSizePixel  = 0
local spc = Instance.new("UICorner", SpawnProgress)
spc.CornerRadius = UDim.new(0, 2)

-- Legende
local LegFrame = Instance.new("Frame", T1)
LegFrame.Size             = UDim2.new(1, 0, 0, 18)
LegFrame.Position         = UDim2.new(0, 0, 0, 64)
LegFrame.BackgroundTransparency = 1

local legItems = {
    {col=RARITY[4].glow, txt="Episch 0–5%",      x=0},
    {col=RARITY[3].glow, txt="Selten 6–15%",     x=0.26},
    {col=RARITY[2].glow, txt="Ungew. 16–25%",    x=0.52},
    {col=RARITY[1].glow, txt="Gewöhnlich >25%",  x=0.76},
}
for _, li in ipairs(legItems) do
    local f = Instance.new("Frame", LegFrame)
    f.Size             = UDim2.new(0.24, 0, 1, 0)
    f.Position         = UDim2.new(li.x, 0, 0, 0)
    f.BackgroundTransparency = 1
    local dot = Instance.new("Frame", f)
    dot.Size             = UDim2.new(0, 8, 0, 8)
    dot.Position         = UDim2.new(0, 0, 0.5, -4)
    dot.BackgroundColor3 = li.col
    dot.BorderSizePixel  = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local t = Instance.new("TextLabel", f)
    t.Size     = UDim2.new(1, -12, 1, 0)
    t.Position = UDim2.new(0, 12, 0, 0)
    t.Text     = li.txt
    t.TextColor3 = li.col
    t.Font     = Enum.Font.Gotham
    t.TextSize = 10
    t.BackgroundTransparency = 1
    t.TextXAlignment = Enum.TextXAlignment.Left
end

-- Auto-Liste ScrollFrame
local CarScroll = Instance.new("ScrollingFrame", T1)
CarScroll.Size             = UDim2.new(1, 0, 1, -90)
CarScroll.Position         = UDim2.new(0, 0, 0, 86)
CarScroll.BackgroundColor3 = Color3.fromRGB(13, 11, 22)
CarScroll.BorderSizePixel  = 0
CarScroll.ScrollBarThickness    = 4
CarScroll.ScrollBarImageColor3  = Color3.fromRGB(80, 60, 140)
CarScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
CarScroll.CanvasSize       = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", CarScroll).CornerRadius = UDim.new(0, 9)
local cList = Instance.new("UIListLayout", CarScroll)
cList.Padding   = UDim.new(0, 3)
cList.SortOrder = Enum.SortOrder.LayoutOrder
local cPad = Instance.new("UIPadding", CarScroll)
cPad.PaddingTop    = UDim.new(0, 5)
cPad.PaddingBottom = UDim.new(0, 5)
cPad.PaddingLeft   = UDim.new(0, 5)
cPad.PaddingRight  = UDim.new(0, 5)

local function MakeCarRow(parent, entry, idx)
    local rd = RARITY[entry.data.rarity]
    local row = Instance.new("Frame", parent)
    row.LayoutOrder      = idx
    row.Size             = UDim2.new(1, -10, 0, 46)
    row.BackgroundColor3 = Color3.fromRGB(18, 16, 30)
    row.BorderSizePixel  = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    -- Seltenheits-Streifen links
    local stripe = Instance.new("Frame", row)
    stripe.Size             = UDim2.new(0, 4, 1, -10)
    stripe.Position         = UDim2.new(0, 4, 0, 5)
    stripe.BackgroundColor3 = rd.glow
    stripe.BorderSizePixel  = 0
    Instance.new("UICorner", stripe).CornerRadius = UDim.new(0, 2)

    -- Badge
    local badge = Instance.new("TextLabel", row)
    badge.Size     = UDim2.new(0, 18, 0, 18)
    badge.Position = UDim2.new(0, 14, 0.5, -9)
    badge.Text     = rd.badge
    badge.Font     = Enum.Font.GothamBold
    badge.TextSize = 14
    badge.TextColor3           = rd.glow
    badge.BackgroundTransparency = 1

    -- Name
    local nLbl = Instance.new("TextLabel", row)
    nLbl.Size     = UDim2.new(0.48, 0, 0.52, 0)
    nLbl.Position = UDim2.new(0, 36, 0, 4)
    nLbl.Text     = entry.data.name
    nLbl.Font     = Enum.Font.GothamSemibold
    nLbl.TextSize = 13
    nLbl.TextColor3           = rd.col
    nLbl.BackgroundTransparency = 1
    nLbl.TextXAlignment       = Enum.TextXAlignment.Left

    -- Spawn + Preis
    local sLbl = Instance.new("TextLabel", row)
    sLbl.Size     = UDim2.new(0.6, 0, 0.42, 0)
    sLbl.Position = UDim2.new(0, 36, 0.54, 0)
    sLbl.Text     = entry.data.spawnRate .. "  ·  " .. entry.data.price
    sLbl.Font     = Enum.Font.Gotham
    sLbl.TextSize = 10
    sLbl.TextColor3           = Color3.fromRGB(110, 105, 145)
    sLbl.BackgroundTransparency = 1
    sLbl.TextXAlignment       = Enum.TextXAlignment.Left

    -- Rarity-Pill
    local pill = Instance.new("TextLabel", row)
    pill.Size             = UDim2.new(0, 78, 0, 20)
    pill.Position         = UDim2.new(1, -140, 0.5, -10)
    pill.Text             = rd.label
    pill.Font             = Enum.Font.GothamBold
    pill.TextSize         = 11
    pill.TextColor3       = rd.glow
    pill.BackgroundColor3 = Color3.fromRGB(rd.glow.R*30, rd.glow.G*15, rd.glow.B*30)
    pill.BackgroundTransparency = 0.35
    pill.BorderSizePixel  = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 5)

    -- TP Button
    local tp = Instance.new("TextButton", row)
    tp.Size             = UDim2.new(0, 52, 0, 26)
    tp.Position         = UDim2.new(1, -58, 0.5, -13)
    tp.Text             = "TP →"
    tp.Font             = Enum.Font.GothamBold
    tp.TextSize         = 12
    tp.TextColor3       = Color3.fromRGB(255, 255, 255)
    tp.BackgroundColor3 = Color3.fromRGB(35, 70, 160)
    tp.BorderSizePixel  = 0
    Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 6)
    tp.MouseButton1Click:Connect(function() TP(entry.cf) end)

    return row
end

local function RefreshCarList(found)
    for _, c in ipairs(CarScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    ClearHighlights()
    for i, entry in ipairs(found) do
        MakeCarRow(CarScroll, entry, i)
        if entry.data.rarity >= 2 then   -- nur Ungewöhnlich+ highlighten
            AddHighlight(entry.model, entry.data.rarity)
        end
    end
    CountLbl.Text = "Gefunden: " .. #found
end

-- ============================================================
--  TAB 2: Sniper
-- ============================================================
local T2 = Instance.new("Frame", CA)
T2.Size             = UDim2.new(1, 0, 1, 0)
T2.BackgroundTransparency = 1
T2.Visible          = false

-- Suchfeld
local SBg = Instance.new("Frame", T2)
SBg.Size             = UDim2.new(1, 0, 0, 36)
SBg.BackgroundColor3 = Color3.fromRGB(18, 16, 32)
SBg.BorderSizePixel  = 0
Instance.new("UICorner", SBg).CornerRadius = UDim.new(0, 8)

local SBox = Instance.new("TextBox", SBg)
SBox.Size               = UDim2.new(1, -12, 1, -8)
SBox.Position           = UDim2.new(0, 8, 0, 4)
SBox.PlaceholderText    = "🔍  Auto suchen..."
SBox.Text               = ""
SBox.Font               = Enum.Font.Gotham
SBox.TextSize           = 13
SBox.TextColor3         = Color3.fromRGB(220, 210, 255)
SBox.PlaceholderColor3  = Color3.fromRGB(90, 85, 130)
SBox.BackgroundTransparency = 1
SBox.ClearTextOnFocus   = false

-- DB-Scroll (Suchergebnisse)
local TLbl1 = Instance.new("TextLabel", T2)
TLbl1.Size     = UDim2.new(1, 0, 0, 18)
TLbl1.Position = UDim2.new(0, 2, 0, 40)
TLbl1.Text     = "Datenbank  —  zum Hinzufügen klicken:"
TLbl1.Font     = Enum.Font.GothamSemibold
TLbl1.TextSize = 11
TLbl1.TextColor3           = Color3.fromRGB(140, 130, 190)
TLbl1.BackgroundTransparency = 1
TLbl1.TextXAlignment       = Enum.TextXAlignment.Left

local DbScroll = Instance.new("ScrollingFrame", T2)
DbScroll.Size             = UDim2.new(1, 0, 0.42, 0)
DbScroll.Position         = UDim2.new(0, 0, 0, 62)
DbScroll.BackgroundColor3 = Color3.fromRGB(13, 11, 22)
DbScroll.BorderSizePixel  = 0
DbScroll.ScrollBarThickness    = 4
DbScroll.ScrollBarImageColor3  = Color3.fromRGB(80, 60, 140)
DbScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
DbScroll.CanvasSize       = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", DbScroll).CornerRadius = UDim.new(0, 9)
local dbList = Instance.new("UIListLayout", DbScroll)
dbList.Padding   = UDim.new(0, 2)
dbList.SortOrder = Enum.SortOrder.LayoutOrder
local dbPad = Instance.new("UIPadding", DbScroll)
dbPad.PaddingAll = UDim.new(0, 4)

-- Watchlist
local TLbl2 = Instance.new("TextLabel", T2)
TLbl2.Size     = UDim2.new(1, 0, 0, 16)
TLbl2.Position = UDim2.new(0, 2, 0.45, 4)
TLbl2.Text     = "Meine Watchlist:"
TLbl2.Font     = Enum.Font.GothamSemibold
TLbl2.TextSize = 11
TLbl2.TextColor3           = Color3.fromRGB(140, 130, 190)
TLbl2.BackgroundTransparency = 1
TLbl2.TextXAlignment       = Enum.TextXAlignment.Left

local WScroll = Instance.new("ScrollingFrame", T2)
WScroll.Size             = UDim2.new(1, 0, 0.28, 0)
WScroll.Position         = UDim2.new(0, 0, 0.48, 0)
WScroll.BackgroundColor3 = Color3.fromRGB(13, 11, 22)
WScroll.BorderSizePixel  = 0
WScroll.ScrollBarThickness    = 4
WScroll.ScrollBarImageColor3  = Color3.fromRGB(80, 60, 140)
WScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
WScroll.CanvasSize       = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", WScroll).CornerRadius = UDim.new(0, 9)
local wList = Instance.new("UIListLayout", WScroll)
wList.Padding   = UDim.new(0, 2)
local wPad = Instance.new("UIPadding", WScroll)
wPad.PaddingAll = UDim.new(0, 4)

-- Sniper Button
local SniperBtn = Instance.new("TextButton", T2)
SniperBtn.Size             = UDim2.new(1, 0, 0, 36)
SniperBtn.Position         = UDim2.new(0, 0, 1, -38)
SniperBtn.Text             = "▶  Sniper STARTEN"
SniperBtn.Font             = Enum.Font.GothamBold
SniperBtn.TextSize         = 14
SniperBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
SniperBtn.BackgroundColor3 = Color3.fromRGB(25, 110, 55)
SniperBtn.BorderSizePixel  = 0
Instance.new("UICorner", SniperBtn).CornerRadius = UDim.new(0, 9)

-- Watchlist UI refresh
local function RefreshWatchUI()
    for _, c in ipairs(WScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    if #watchList == 0 then
        local empty = Instance.new("TextLabel", WScroll)
        empty.Size = UDim2.new(1, 0, 0, 28)
        empty.Text = "Noch keine Autos hinzugefügt."
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 11
        empty.TextColor3 = Color3.fromRGB(100, 95, 140)
        empty.BackgroundTransparency = 1
        return
    end
    for i, wName in ipairs(watchList) do
        local vd = VEHICLE_MAP[string.lower(wName)]
        local rd = vd and RARITY[vd.rarity] or RARITY[1]
        local row = Instance.new("Frame", WScroll)
        row.LayoutOrder      = i
        row.Size             = UDim2.new(1, -8, 0, 28)
        row.BackgroundColor3 = Color3.fromRGB(18, 16, 30)
        row.BorderSizePixel  = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local nl = Instance.new("TextLabel", row)
        nl.Size     = UDim2.new(1, -40, 1, 0)
        nl.Position = UDim2.new(0, 8, 0, 0)
        nl.Text     = rd.badge .. " " .. wName .. (vd and ("  [" .. rd.label .. "]") or "")
        nl.Font     = Enum.Font.Gotham
        nl.TextSize = 12
        nl.TextColor3           = rd.col
        nl.BackgroundTransparency = 1
        nl.TextXAlignment       = Enum.TextXAlignment.Left
        local rb = Instance.new("TextButton", row)
        rb.Size             = UDim2.new(0, 26, 0, 20)
        rb.Position         = UDim2.new(1, -30, 0.5, -10)
        rb.Text             = "✕"
        rb.Font             = Enum.Font.GothamBold
        rb.TextSize         = 11
        rb.TextColor3       = Color3.fromRGB(255, 70, 70)
        rb.BackgroundColor3 = Color3.fromRGB(40, 12, 12)
        rb.BorderSizePixel  = 0
        Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 4)
        rb.MouseButton1Click:Connect(function()
            table.remove(watchList, i)
            RefreshWatchUI()
        end)
    end
end

-- DB-Liste aufbauen
local function BuildDb(filter)
    for _, c in ipairs(DbScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local n = 0
    -- Sortiert: seltener zuerst
    local sorted = {}
    for _, v in ipairs(VEHICLES) do table.insert(sorted, v) end
    table.sort(sorted, function(a,b)
        if a.rarity ~= b.rarity then return a.rarity > b.rarity end
        return a.rateNum < b.rateNum
    end)
    for _, v in ipairs(sorted) do
        if filter == "" or string.lower(v.name):find(string.lower(filter), 1, true) then
            n += 1
            if n > 80 then break end
            local rd = RARITY[v.rarity]
            local row = Instance.new("Frame", DbScroll)
            row.LayoutOrder      = n
            row.Size             = UDim2.new(1, -8, 0, 30)
            row.BackgroundColor3 = Color3.fromRGB(16, 14, 26)
            row.BorderSizePixel  = 0
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
            -- Streifen
            local st = Instance.new("Frame", row)
            st.Size             = UDim2.new(0, 3, 1, -6)
            st.Position         = UDim2.new(0, 3, 0, 3)
            st.BackgroundColor3 = rd.glow
            st.BorderSizePixel  = 0
            Instance.new("UICorner", st).CornerRadius = UDim.new(0, 2)
            -- Name
            local nl = Instance.new("TextLabel", row)
            nl.Size     = UDim2.new(0.5, 0, 0.54, 0)
            nl.Position = UDim2.new(0, 12, 0, 2)
            nl.Text     = v.name
            nl.Font     = Enum.Font.GothamSemibold
            nl.TextSize = 12
            nl.TextColor3           = rd.col
            nl.BackgroundTransparency = 1
            nl.TextXAlignment       = Enum.TextXAlignment.Left
            -- Rate + Preis
            local sl = Instance.new("TextLabel", row)
            sl.Size     = UDim2.new(0.55, 0, 0.42, 0)
            sl.Position = UDim2.new(0, 12, 0.55, 0)
            sl.Text     = v.spawnRate .. "  ·  " .. v.price
            sl.Font     = Enum.Font.Gotham
            sl.TextSize = 10
            sl.TextColor3           = Color3.fromRGB(100, 95, 140)
            sl.BackgroundTransparency = 1
            sl.TextXAlignment       = Enum.TextXAlignment.Left
            -- Add Button
            local ab = Instance.new("TextButton", row)
            ab.Size             = UDim2.new(0, 52, 0, 22)
            ab.Position         = UDim2.new(1, -58, 0.5, -11)
            ab.Text             = "+ Add"
            ab.Font             = Enum.Font.GothamBold
            ab.TextSize         = 11
            ab.TextColor3       = Color3.fromRGB(255, 255, 255)
            ab.BackgroundColor3 = Color3.fromRGB(28, 72, 160)
            ab.BorderSizePixel  = 0
            Instance.new("UICorner", ab).CornerRadius = UDim.new(0, 5)
            local vRef = v
            ab.MouseButton1Click:Connect(function()
                for _, wn in ipairs(watchList) do
                    if string.lower(wn) == string.lower(vRef.name) then
                        ab.Text = "✓ Da"
                        task.delay(1.2, function() ab.Text = "+ Add" end)
                        return
                    end
                end
                table.insert(watchList, vRef.name)
                RefreshWatchUI()
                ab.Text             = "✓"
                ab.BackgroundColor3 = Color3.fromRGB(18, 110, 38)
                task.delay(1.5, function()
                    ab.Text             = "+ Add"
                    ab.BackgroundColor3 = Color3.fromRGB(28, 72, 160)
                end)
            end)
        end
    end
end

SBox:GetPropertyChangedSignal("Text"):Connect(function() BuildDb(SBox.Text) end)
BuildDb("")
RefreshWatchUI()

SniperBtn.MouseButton1Click:Connect(function()
    sniperActive = not sniperActive
    SniperBtn.Text             = sniperActive and "■  Sniper STOPPEN" or "▶  Sniper STARTEN"
    SniperBtn.BackgroundColor3 = sniperActive and Color3.fromRGB(130, 25, 25) or Color3.fromRGB(25, 110, 55)
end)

-- ============================================================
--  TAB SWITCHING
-- ============================================================
local function SetTab(n)
    T1.Visible = (n == 1)
    T2.Visible = (n == 2)
    Tab1Btn.BackgroundColor3 = (n==1) and Color3.fromRGB(38,55,140) or Color3.fromRGB(22,20,36)
    Tab1Btn.TextColor3       = (n==1) and Color3.fromRGB(220,210,255) or Color3.fromRGB(140,130,180)
    Tab2Btn.BackgroundColor3 = (n==2) and Color3.fromRGB(38,55,140) or Color3.fromRGB(22,20,36)
    Tab2Btn.TextColor3       = (n==2) and Color3.fromRGB(220,210,255) or Color3.fromRGB(140,130,180)
end
Tab1Btn.MouseButton1Click:Connect(function() SetTab(1) end)
Tab2Btn.MouseButton1Click:Connect(function() SetTab(2) end)
SetTab(1)

-- ============================================================
--  MAIN LOOP
-- ============================================================
local SCAN_RATE       = 0.9   -- Scan alle ~0.9s (Heartbeat-basiert, kein wait)
local SNIPER_RATE     = 0.7
local CD_RATE         = 0.5   -- Countdown-Suche alle 0.5s
local lastScan        = 0
local lastSnipe       = 0
local lastCDCheck     = 0
local maxCDSec        = 0     -- Maximalwert des Countdowns (für Progress-Bar)

RunService.Heartbeat:Connect(function()
    local now = tick()

    -- ── Countdown Detection ───────────────────────────────────
    if now - lastCDCheck >= CD_RATE then
        lastCDCheck = now
        local lbl, sec = FindCountdown()
        if lbl and sec and sec > 0 then
            countdownValue = sec
            if sec > maxCDSec then maxCDSec = sec end
            local m = math.floor(sec/60)
            local s = sec % 60
            local cdStr = string.format("%d:%02d", m, s)
            SpawnLbl.Text = "⏱ Nächster Spawn: " .. cdStr
            CDLabel.Text  = "⏱ " .. cdStr
            -- Progress Bar
            local pct = maxCDSec > 0 and (sec / maxCDSec) or 1
            SpawnProgress.Size = UDim2.new(pct, 0, 0, 3)
            -- Farbe wechsel je nach Zeit
            if sec <= 5 then
                SpawnProgress.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                SpawnLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            elseif sec <= 15 then
                SpawnProgress.BackgroundColor3 = Color3.fromRGB(255, 160, 40)
                SpawnLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
            else
                SpawnProgress.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
                SpawnLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
            end
        else
            CDLabel.Text = "⏱ --:--"
            SpawnLbl.Text = "⏱ Countdown nicht gefunden — scanne..."
        end
    end

    -- ── Spawned-Cars Scan ─────────────────────────────────────
    if now - lastScan >= SCAN_RATE then
        lastScan = now
        local ok, result = pcall(ScanWorkspace)
        if ok then
            spawnedCache = result
            local hash = GetHash(spawnedCache)
            if hash ~= lastHash then
                lastHash = hash
                RefreshCarList(spawnedCache)
            end
            StatLbl.Text = "● Live  —  " .. os.date("%H:%M:%S")
        else
            StatLbl.Text = "● Fehler — " .. tostring(result):sub(1,30)
        end
    end

    -- ── Sniper ────────────────────────────────────────────────
    if sniperActive and now - lastSnipe >= SNIPER_RATE then
        lastSnipe = now
        if #watchList > 0 and #spawnedCache > 0 then
            local target = FindRarestWatchedIn(spawnedCache)
            if target and now - lastTpTime > 3 then
                lastTpTime = now
                PlayAlert()
                TP(target.cf)
            end
        end
    end
end)

print("[FixItUp v3] ✓ Geladen | Xeno-kompatibel | Countdown-Sync aktiv")
