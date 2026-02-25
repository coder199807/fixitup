-- ================================================================
--  Fix It Up — Smart GUI  v5.0
--  Executor : Xeno
--  Auto-Struktur: ReplicatedStorage.Cache.CarList.[AutoName]
--  Countdown : "WIEDERBELEBEN IN X SEKUNDEN" (SurfaceGui im WS)
--  Rarity    : 0-5%=Episch(Pink) 6-15%=Selten(Blau)
--              16-25%=Ungewöhnlich(Grün) >25%=Gewöhnlich(Grau)
-- ================================================================

local Players  = game:GetService("Players")
local WS       = game:GetService("Workspace")
local RS       = game:GetService("ReplicatedStorage")
local LP       = Players.LocalPlayer

-- ================================================================
--  RARITY SYSTEM
-- ================================================================
local function parseRate(s)
    if not s then return nil end
    local n = s:match("([%d%.,]+)%s*%%")
    if not n then return nil end
    return tonumber((n:gsub(",",".")))
end

local function calcRarity(sr)
    local r = parseRate(sr)
    if r == nil  then return 4 end  -- N/A = Episch
    if r <= 5    then return 4 end  -- Episch
    if r <= 15   then return 3 end  -- Selten
    if r <= 25   then return 2 end  -- Ungewöhnlich
    return 1                        -- Gewöhnlich
end

local RARITY = {
    [1] = {label="Gewöhnlich",   badge="●", col=Color3.fromRGB(160,160,160), glow=Color3.fromRGB(160,160,160)},
    [2] = {label="Ungewöhnlich", badge="◆", col=Color3.fromRGB(80,230,80),   glow=Color3.fromRGB(60,255,60)  },
    [3] = {label="Selten",       badge="★", col=Color3.fromRGB(80,150,255),  glow=Color3.fromRGB(60,130,255) },
    [4] = {label="Episch",       badge="✦", col=Color3.fromRGB(255,80,200),  glow=Color3.fromRGB(255,50,190) },
}

-- ================================================================
--  FAHRZEUG DATENBANK
-- ================================================================
local RAW = {
    {"Wesla Modelo",          "N/A",             "HR+ Exklusiv"},
    {"Bananenauto",           "N/A",             "Moderator+ Exklusiv"},
    {"Mata FX7",              "N/A",             "Außer Haus"},
    {"Porx JT3 RF",           "N/A",             "Außer Haus"},
    {"BNV K4 G",              "N/A",             "799"},
    {"Audi RF6",              "N/A",             "699"},
    {"BNV K340i",             "N/A",             "599"},
    {"Merquis G Wafer",       "N/A",             "Exklusives Event"},
    {"Merquis JF",            "N/A",             "Nicht verfügbar"},
    {"Sigma Roma Quadri",     "N/A",             "Nicht verfügbar"},
    {"Kart",                  "N/A",             "Außerverkauft"},
    {"Lambemos-Iris",         "N/A",             "Außerbörslich"},
    {"BNV K3 F",              "0,02%",           "80.000€ – 120.000€"},
    {"DOGO Desafio",          "N/A",             "Außerbörslich"},
    {"Fia-Te Double",         "N/A",             "Außerhalb d. reg. Verkaufs"},
    {"Toyoda Supwa A90",      "N/A",             "Außerverkauft"},
    {"Sucato Empresa",        "N/A",             "Nicht verfügbar"},
    {"Chule Curgette C7",     "N/A",             "Nicht verfügbar"},
    {"Skami Truk",            "0,05%",           "120.000€ – 200.000€"},
    {"BNV K8",                "0,05%",           "180.000€ – 230.000€"},
    {"Merquis SLX",           "0,05%",           "180.000€ – 280.000€"},
    {"Mine Copa S",           "0,05%",           "50.000€ – 70.000€"},
    {"Missah JTF",            "N/A",             "Außerverkauft"},
    {"Porx JT2 RF",           "N/A",             "Außerverkauft"},
    {"Missah Groundline F34", "N/A",             "Außerverkauft"},
    {"Ropes Ruyter Shadow",   "N/A",             "Außerverkauft"},
    {"Holde S2k",             "N/A",             "Außerverkauft"},
    {"Chule Curgete",         "0,1%",            "65.000€ – 120.000€"},
    {"Audi V7",               "N/A",             "Außerbörslich"},
    {"Audi F8",               "N/A",             "Außerverkauft"},
    {"Fia-Te 10026p",         "0,2%",            "3.000€ – 7.000€"},
    {"Audi F8 Performance",   "N/A",             "Außerverkauft"},
    {"Toyoda Supwa",          "N/A",             "Außerverkauft"},
    {"Vier Mustank 70s",      "N/A",             "Außerverkauft"},
    {"Toyoda AFF67",          "0,3%",            "25.000€ – 55.000€"},
    {"Auidy RF3 Limousine",   "0,3%",            "70.000€ – 90.000€"},
    {"Lokswag Brasiuiu",      "0,3%",            "5.000€ – 12.000€"},
    {"Audi V8",               "0,4%",            "120.000€ – 200.000€"},
    {"BNV K5 e60",            "0,5%",            "60.000€ – 90.000€"},
    {"Ratos Rotos Esporte",   "0,5%",            "100.000€ – 200.000€"},
    {"Holde TipeRar",         "0,5%",            "50.000€ – 90.000€"},
    {"Audi RF3",              "0,6%",            "40.000€ – 55.000€"},
    {"Holde Proluiz",         "0,8%",            "10.000€ – 25.000€"},
    {"Missah 750x",           "N/A",             "Außerbörslich"},
    {"Chule Camarao",         "1%",              "60.000€ – 100.000€"},
    {"Four Rex",              "1%",              "60.000€ – 80.000€"},
    {"Audi V5",               "1%",              "40.000€ – 55.000€"},
    {"Merquis Z73",           "1%",              "35.000€ – 65.000€"},
    {"BNV K3 e92",            "1%",              "45.000€ – 60.000€"},
    {"Matsu Lanca",           "2%",              "15.000€ – 55.000€"},
    {"Lokswag Golo GT",       "2%",              "25.000€ – 55.000€"},
    {"Toyoda Yapp",           "2%",              "25.000€ – 55.000€"},
    {"Vovo F60 Polo",         "2,5%",            "25.000€ – 45.000€"},
    {"BNV K5 e39",            "3%",              "20.000€ – 50.000€"},
    {"BNV K140",              "N/A",             "Außerverkauft"},
    {"Merquis ZLA 45",        "N/A",             "Außerverkauft"},
    {"Fia-Te Alberto 300",    "3%",              "18.000€ – 30.000€"},
    {"Ontel Astron",          "4%",              "25.000€ – 40.000€"},
    {"Raguer XisR",           "5%",              "20.000€ – 30.000€"},
    {"Renas Mugano",          "5%",              "18.000€ – 30.000€"},
    {"Four Traffic",          "6%",              "15.000€ – 30.000€"},
    {"Vier Party",            "6%",              "23.000€ – 40.000€"},
    {"Lokswag Golo MK5",      "7%",              "17.000€ – 25.000€"},
    {"Merquis C203",          "7%",              "9.000€ – 22.000€"},
    {"Toyoda Hellox",         "7%",              "28.000€ – 40.000€"},
    {"Holde Inteiro",         "7%",              "9.000€ – 30.000€"},
    {"Leskus not200",         "10%",             "9.000€ – 20.000€"},
    {"BNV K3",                "10%",             "9.000€ – 20.000€"},
    {"Missah Silva",          "N/A",             "Außerbörslich"},
    {"Holde Ciwiq",           "11%",             "5.000€ – 15.000€"},
    {"Audi V4",               "15%",             "12.000€ – 18.000€"},
    {"Lokswag Golo MK4",      "15%",             "12.000€ – 17.000€"},
    {"Vovo Sr60",             "17%",             "12.000€ – 17.000€"},
    {"Peujo 400e6",           "20%",             "7.000€ – 17.000€"},
    {"Lokswag Passar",        "20%",             "8.000€ – 14.000€"},
    {"Sacode Oitava",         "20%",             "8.000€ – 14.000€"},
    {"Peujo 200e5",           "25%",             "7.000€ – 12.000€"},
    {"Renas Kapturado",       "30%",             "5.000€ – 11.000€"},
    {"Lokswag Golo",          "30%",             "4.000€ – 8.000€"},
    {"Ontel Costa",           "30%",             "700€ – 3.000€"},
    {"Xitro J3",              "40%",             "15.000€ – 20.000€"},
    {"Sabes Muito",           "40%",             "7.000€ – 15.000€"},
    {"Peujo 200e6",           "50%",             "1.000€ – 4.000€"},
    {"Fia-Te Ponto",          "50%",             "700€ – 3.000€"},
    {"Siath Lion",            "50%",             "1.500€ – 4.000€"},
}

-- DB aufbauen
local DB = {}
local DB_MAP = {}  -- lowercase name → entry
for _, v in ipairs(RAW) do
    local e = {
        name      = v[1],
        spawnRate = v[2],
        price     = v[3],
        rarity    = calcRarity(v[2]),
        rateNum   = parseRate(v[2]) or 999,
    }
    table.insert(DB, e)
    DB_MAP[v[1]:lower()] = e
end

-- ================================================================
--  AUTO-SCAN: Liest ReplicatedStorage.Cache.CarList
--  Gibt Liste der aktuell gespawnten Autos zurück
-- ================================================================
local CAR_LIST_PATH = {"Cache", "CarList"}  -- RS.Cache.CarList

local function getCarList()
    local container = RS
    for _, part in ipairs(CAR_LIST_PATH) do
        container = container:FindFirstChild(part)
        if not container then return nil end
    end
    return container
end

local function scanCars()
    local result = {}
    local carList = getCarList()
    if not carList then
        return result, "RS.Cache.CarList nicht gefunden!"
    end

    for _, obj in ipairs(carList:GetChildren()) do
        local name = obj.Name
        local lo   = name:lower()

        -- DB Match
        local dbEntry = DB_MAP[lo]
        if not dbEntry then
            -- Fuzzy: DB-Name in Objekt-Name oder umgekehrt
            for key, entry in pairs(DB_MAP) do
                if lo:find(key, 1, true) or key:find(lo, 1, true) then
                    dbEntry = entry
                    break
                end
            end
        end

        -- Auch unbekannte Autos anzeigen (mit Default-Rarity 1)
        if not dbEntry then
            dbEntry = {
                name      = name,
                spawnRate = "?",
                price     = "Unbekannt",
                rarity    = 1,
                rateNum   = 999,
            }
        end

        -- Position aus dem Objekt holen (kann Model oder Value sein)
        local cf = nil
        if obj:IsA("Model") then
            local root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if root then cf = root.CFrame end
        end
        -- Falls CFrame als Attribut gespeichert
        if not cf then
            local cfAttr = obj:FindFirstChild("CFrame") or obj:FindFirstChild("Position") or obj:FindFirstChild("SpawnCFrame")
            if cfAttr and cfAttr:IsA("CFrameValue") then
                cf = cfAttr.Value
            elseif cfAttr and cfAttr:IsA("Vector3Value") then
                cf = CFrame.new(cfAttr.Value)
            end
        end

        table.insert(result, {
            name    = name,
            data    = dbEntry,
            obj     = obj,
            cf      = cf,
        })
    end

    -- Sortieren: seltenste zuerst
    table.sort(result, function(a, b)
        if a.data.rarity ~= b.data.rarity then
            return a.data.rarity > b.data.rarity
        end
        return a.data.rateNum < b.data.rateNum
    end)

    return result, nil
end

-- ================================================================
--  HIGHLIGHTS im Workspace
--  Sucht das Model im Workspace anhand des Namens
-- ================================================================
local highlights = {}

local function clearHighlights()
    for _, h in pairs(highlights) do
        if h and h.Parent then h:Destroy() end
    end
    highlights = {}
end

local function highlightCar(carName, rarity)
    if rarity < 2 then return end
    local rd = RARITY[rarity]
    -- Suche Model im Workspace
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower() == carName:lower() then
            local h = Instance.new("SelectionBox", WS)
            h.Adornee             = obj
            h.Color3              = rd.glow
            h.LineThickness       = 0.08
            h.SurfaceTransparency = 0.75
            h.SurfaceColor3       = rd.glow
            table.insert(highlights, h)
        end
    end
end

-- ================================================================
--  TELEPORT: Auto kaufen / zu Auto TP
--  Versucht ClickDetector oder ProximityPrompt zu finden
--  Fallback: direkte Position-Teleportation
-- ================================================================
local function tpToCar(entry)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Suche das Model im Workspace
    local wsModel = nil
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower() == entry.name:lower() then
            wsModel = obj
            break
        end
    end

    if wsModel then
        local root = wsModel.PrimaryPart or wsModel:FindFirstChildWhichIsA("BasePart")
        if root then
            hrp.CFrame = root.CFrame + Vector3.new(0, 5, 0)
            return
        end
    end

    -- Fallback: CF aus CarList
    if entry.cf then
        hrp.CFrame = entry.cf + Vector3.new(0, 5, 0)
    end
end

-- ================================================================
--  COUNTDOWN ERKENNUNG
--  "WIEDERBELEBEN IN 82 SEKUNDEN" in WS SurfaceGuis
-- ================================================================
local function getCountdown()
    -- Workspace TextLabels
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local t = obj.Text or ""
            -- "IN 82 SEKUNDEN" Pattern
            local sec = t:match("[Ii][Nn]%s+(%d+)%s+[Ss][Ee][Kk][Uu][Nn][Dd][Ee][Nn]")
            if sec then return tonumber(sec) end
            -- Nur Zahl + SEKUNDEN
            sec = t:match("(%d+)%s+[Ss][Ee][Kk][Uu][Nn][Dd][Ee][Nn]")
            if sec then return tonumber(sec) end
            -- MM:SS
            local m, s = t:match("(%d+):(%d+)")
            if m and s then return tonumber(m)*60 + tonumber(s) end
        end
    end
    -- PlayerGui
    for _, obj in ipairs(LP.PlayerGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local t = obj.Text or ""
            local sec = t:match("[Ii][Nn]%s+(%d+)%s+[Ss][Ee][Kk][Uu][Nn][Dd][Ee][Nn]")
            if sec then return tonumber(sec) end
            sec = t:match("(%d+)%s+[Ss][Ee][Kk][Uu][Nn][Dd][Ee][Nn]")
            if sec then return tonumber(sec) end
        end
    end
    return nil
end

-- ================================================================
--  ALERT SOUND
-- ================================================================
local alertSound = Instance.new("Sound", WS)
alertSound.SoundId = "rbxassetid://9125402735"
alertSound.Volume  = 1
alertSound.RollOffMaxDistance = 99999

local function playAlert()
    if not alertSound.IsPlaying then
        alertSound:Play()
    end
end

-- ================================================================
--  GUI AUFBAU
-- ================================================================
local guiParent = (gethui and gethui()) or LP.PlayerGui

-- Alte GUI entfernen
for _, g in ipairs(guiParent:GetChildren()) do
    if g.Name == "FIU_V5" then g:Destroy() end
end

local GUI = Instance.new("ScreenGui")
GUI.Name           = "FIU_V5"
GUI.ResetOnSpawn   = false
GUI.IgnoreGuiInset = true
GUI.Parent         = guiParent

-- Haupt-Frame
local Main = Instance.new("Frame", GUI)
Main.Size             = UDim2.new(0, 500, 0, 580)
Main.Position         = UDim2.new(0.5,-250,0.5,-290)
Main.BackgroundColor3 = Color3.fromRGB(10, 9, 18)
Main.BorderSizePixel  = 0
Main.Active           = true
Main.Draggable        = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Titelleiste
local TBar = Instance.new("Frame", Main)
TBar.Size             = UDim2.new(1,0,0,40)
TBar.BackgroundColor3 = Color3.fromRGB(16,13,30)
TBar.BorderSizePixel  = 0
Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 12)

local TLbl = Instance.new("TextLabel", TBar)
TLbl.Size                 = UDim2.new(1,-130,1,0)
TLbl.Position             = UDim2.new(0,12,0,0)
TLbl.Text                 = "🔧  Fix It Up  v5"
TLbl.Font                 = Enum.Font.GothamBold
TLbl.TextSize             = 14
TLbl.TextColor3           = Color3.fromRGB(220,210,255)
TLbl.BackgroundTransparency = 1
TLbl.TextXAlignment       = Enum.TextXAlignment.Left

local CDLbl = Instance.new("TextLabel", TBar)
CDLbl.Size                = UDim2.new(0,90,1,0)
CDLbl.Position            = UDim2.new(1,-130,0,0)
CDLbl.Text                = "⏱ --s"
CDLbl.Font                = Enum.Font.GothamBold
CDLbl.TextSize            = 13
CDLbl.TextColor3          = Color3.fromRGB(255,200,60)
CDLbl.BackgroundTransparency = 1

-- Buttons Titelleiste
local function mkTBtn(txt, x, bg, tc)
    local b = Instance.new("TextButton", TBar)
    b.Size             = UDim2.new(0,28,0,28)
    b.Position         = UDim2.new(1,x,0.5,-14)
    b.Text             = txt
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 13
    b.TextColor3       = tc
    b.BackgroundColor3 = bg
    b.BorderSizePixel  = 0
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    return b
end
local CloseBtn = mkTBtn("✕", -6,  Color3.fromRGB(40,12,12), Color3.fromRGB(255,70,70))
local MinBtn   = mkTBtn("−", -38, Color3.fromRGB(30,28,10), Color3.fromRGB(220,200,60))

local Body = Instance.new("Frame", Main)
Body.Size             = UDim2.new(1,0,1,-40)
Body.Position         = UDim2.new(0,0,0,40)
Body.BackgroundTransparency = 1

CloseBtn.MouseButton1Click:Connect(function()
    clearHighlights()
    alertSound:Destroy()
    GUI:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Body.Visible = not minimized
    Main.Size = minimized and UDim2.new(0,500,0,40) or UDim2.new(0,500,0,580)
    MinBtn.Text = minimized and "+" or "−"
end)

-- Tab-Leiste
local TabBar = Instance.new("Frame", Body)
TabBar.Size             = UDim2.new(1,-16,0,34)
TabBar.Position         = UDim2.new(0,8,0,6)
TabBar.BackgroundTransparency = 1

local function mkTab(txt, xpct)
    local b = Instance.new("TextButton", TabBar)
    b.Size             = UDim2.new(0.32,0,1,0)
    b.Position         = UDim2.new(xpct,0,0,0)
    b.Text             = txt
    b.Font             = Enum.Font.GothamSemibold
    b.TextSize         = 11
    b.TextColor3       = Color3.fromRGB(150,140,190)
    b.BackgroundColor3 = Color3.fromRGB(20,18,34)
    b.BorderSizePixel  = 0
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
    return b
end
local TB1 = mkTab("📡  Junkyard",   0)
local TB2 = mkTab("🎯  Sniper",     0.34)
local TB3 = mkTab("🛒  Datenbank",  0.68)

local CA = Instance.new("Frame", Body)
CA.Size             = UDim2.new(1,-16,1,-50)
CA.Position         = UDim2.new(0,8,0,46)
CA.BackgroundTransparency = 1

-- ================================================================
--  TAB 1 — JUNKYARD
-- ================================================================
local T1 = Instance.new("Frame", CA)
T1.Size             = UDim2.new(1,0,1,0)
T1.BackgroundTransparency = 1

-- Status Bar
local StatFrame = Instance.new("Frame", T1)
StatFrame.Size             = UDim2.new(1,0,0,50)
StatFrame.BackgroundColor3 = Color3.fromRGB(16,13,28)
StatFrame.BorderSizePixel  = 0
Instance.new("UICorner", StatFrame).CornerRadius = UDim.new(0,8)

local StatLbl = Instance.new("TextLabel", StatFrame)
StatLbl.Size     = UDim2.new(0.65,0,0.5,0)
StatLbl.Position = UDim2.new(0,10,0,2)
StatLbl.Text     = "● Starte..."
StatLbl.Font     = Enum.Font.Gotham
StatLbl.TextSize = 11
StatLbl.TextColor3 = Color3.fromRGB(80,255,120)
StatLbl.BackgroundTransparency = 1
StatLbl.TextXAlignment = Enum.TextXAlignment.Left

local CntLbl = Instance.new("TextLabel", StatFrame)
CntLbl.Size     = UDim2.new(0.33,0,0.5,0)
CntLbl.Position = UDim2.new(0.67,0,0,2)
CntLbl.Text     = "Autos: 0"
CntLbl.Font     = Enum.Font.Gotham
CntLbl.TextSize = 11
CntLbl.TextColor3 = Color3.fromRGB(160,140,220)
CntLbl.BackgroundTransparency = 1
CntLbl.TextXAlignment = Enum.TextXAlignment.Right

local SpawnLbl = Instance.new("TextLabel", StatFrame)
SpawnLbl.Size     = UDim2.new(0.65,0,0.46,0)
SpawnLbl.Position = UDim2.new(0,10,0.52,0)
SpawnLbl.Text     = "⏱ Suche Countdown..."
SpawnLbl.Font     = Enum.Font.Gotham
SpawnLbl.TextSize = 11
SpawnLbl.TextColor3 = Color3.fromRGB(255,200,60)
SpawnLbl.BackgroundTransparency = 1
SpawnLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Fortschrittsbalken
local PBg = Instance.new("Frame", StatFrame)
PBg.Size             = UDim2.new(1,0,0,4)
PBg.Position         = UDim2.new(0,0,1,-4)
PBg.BackgroundColor3 = Color3.fromRGB(28,22,48)
PBg.BorderSizePixel  = 0
Instance.new("UICorner",PBg).CornerRadius = UDim.new(0,2)
local PBar = Instance.new("Frame", PBg)
PBar.Size             = UDim2.new(0,0,1,0)
PBar.BackgroundColor3 = Color3.fromRGB(80,220,100)
PBar.BorderSizePixel  = 0
Instance.new("UICorner",PBar).CornerRadius = UDim.new(0,2)

-- Legende
local LegFrame = Instance.new("Frame", T1)
LegFrame.Size             = UDim2.new(1,0,0,16)
LegFrame.Position         = UDim2.new(0,0,0,54)
LegFrame.BackgroundTransparency = 1
local legItems = {
    {RARITY[4].glow, "Episch 0-5%",     0},
    {RARITY[3].glow, "Selten 6-15%",    0.25},
    {RARITY[2].glow, "Ungew. 16-25%",   0.5},
    {RARITY[1].glow, "Gew. >25%",       0.76},
}
for _, li in ipairs(legItems) do
    local lf = Instance.new("Frame",LegFrame)
    lf.Size=UDim2.new(0.24,0,1,0) lf.Position=UDim2.new(li[3],0,0,0) lf.BackgroundTransparency=1
    local dot=Instance.new("Frame",lf) dot.Size=UDim2.new(0,7,0,7) dot.Position=UDim2.new(0,0,0.5,-3.5)
    dot.BackgroundColor3=li[1] dot.BorderSizePixel=0 Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local lt=Instance.new("TextLabel",lf) lt.Size=UDim2.new(1,-11,1,0) lt.Position=UDim2.new(0,11,0,0)
    lt.Text=li[2] lt.Font=Enum.Font.Gotham lt.TextSize=9 lt.TextColor3=li[1]
    lt.BackgroundTransparency=1 lt.TextXAlignment=Enum.TextXAlignment.Left
end

-- Auto-Liste
local CarSc = Instance.new("ScrollingFrame", T1)
CarSc.Size             = UDim2.new(1,0,1,-76)
CarSc.Position         = UDim2.new(0,0,0,74)
CarSc.BackgroundColor3 = Color3.fromRGB(12,10,22)
CarSc.BorderSizePixel  = 0
CarSc.ScrollBarThickness    = 4
CarSc.ScrollBarImageColor3  = Color3.fromRGB(70,55,130)
CarSc.AutomaticCanvasSize   = Enum.AutomaticSize.Y
CarSc.CanvasSize       = UDim2.new(0,0,0,0)
Instance.new("UICorner",CarSc).CornerRadius = UDim.new(0,9)
local cLL = Instance.new("UIListLayout",CarSc)
cLL.Padding   = UDim.new(0,3)
cLL.SortOrder = Enum.SortOrder.LayoutOrder
local cPad = Instance.new("UIPadding",CarSc)
cPad.PaddingAll = UDim.new(0,5)

local emptyLbl = Instance.new("TextLabel", CarSc)
emptyLbl.Size     = UDim2.new(1,-10,0,60)
emptyLbl.Text     = "Warte auf Autos in RS.Cache.CarList...\n(Startet automatisch nach dem Countdown)"
emptyLbl.Font     = Enum.Font.Gotham
emptyLbl.TextSize = 12
emptyLbl.TextColor3 = Color3.fromRGB(120,110,160)
emptyLbl.BackgroundTransparency = 1
emptyLbl.TextWrapped = true

local function makeCarRow(parent, entry, idx)
    local rd = RARITY[entry.data.rarity]
    local row = Instance.new("Frame", parent)
    row.LayoutOrder      = idx
    row.Size             = UDim2.new(1,-10,0,48)
    row.BackgroundColor3 = Color3.fromRGB(18,15,32)
    row.BorderSizePixel  = 0
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)

    -- Farbstreifen links
    local stripe = Instance.new("Frame",row)
    stripe.Size             = UDim2.new(0,4,1,-10)
    stripe.Position         = UDim2.new(0,4,0,5)
    stripe.BackgroundColor3 = rd.glow
    stripe.BorderSizePixel  = 0
    Instance.new("UICorner",stripe).CornerRadius = UDim.new(0,2)

    -- Badge
    local bdg = Instance.new("TextLabel",row)
    bdg.Size=UDim2.new(0,18,0,18) bdg.Position=UDim2.new(0,14,0.5,-9)
    bdg.Text=rd.badge bdg.Font=Enum.Font.GothamBold bdg.TextSize=14
    bdg.TextColor3=rd.glow bdg.BackgroundTransparency=1

    -- Name
    local nm = Instance.new("TextLabel",row)
    nm.Size=UDim2.new(0.48,0,0.52,0) nm.Position=UDim2.new(0,36,0,3)
    nm.Text=entry.name nm.Font=Enum.Font.GothamSemibold nm.TextSize=13
    nm.TextColor3=rd.col nm.BackgroundTransparency=1
    nm.TextXAlignment=Enum.TextXAlignment.Left nm.TextTruncate=Enum.TextTruncate.AtEnd

    -- Spawn + Preis
    local sl = Instance.new("TextLabel",row)
    sl.Size=UDim2.new(0.58,0,0.42,0) sl.Position=UDim2.new(0,36,0.54,0)
    sl.Text=entry.data.spawnRate.."  ·  "..entry.data.price
    sl.Font=Enum.Font.Gotham sl.TextSize=10
    sl.TextColor3=Color3.fromRGB(105,100,148)
    sl.BackgroundTransparency=1 sl.TextXAlignment=Enum.TextXAlignment.Left

    -- Rarity Pill
    local pill=Instance.new("TextLabel",row)
    pill.Size=UDim2.new(0,72,0,20) pill.Position=UDim2.new(1,-132,0.5,-10)
    pill.Text=rd.label pill.Font=Enum.Font.GothamBold pill.TextSize=11
    pill.TextColor3=rd.glow pill.BackgroundColor3=Color3.fromRGB(20,15,30)
    pill.BackgroundTransparency=0.3 pill.BorderSizePixel=0
    Instance.new("UICorner",pill).CornerRadius=UDim.new(0,5)

    -- TP Button
    local tp = Instance.new("TextButton",row)
    tp.Size=UDim2.new(0,50,0,26) tp.Position=UDim2.new(1,-56,0.5,-13)
    tp.Text="TP →" tp.Font=Enum.Font.GothamBold tp.TextSize=12
    tp.TextColor3=Color3.fromRGB(255,255,255)
    tp.BackgroundColor3=Color3.fromRGB(32,65,160) tp.BorderSizePixel=0
    Instance.new("UICorner",tp).CornerRadius=UDim.new(0,6)
    local capEntry = entry
    tp.MouseButton1Click:Connect(function()
        tpToCar(capEntry)
    end)
    return row
end

local lastCarHash = ""
local function refreshT1(cars, errMsg)
    -- Leere Liste
    for _, c in ipairs(CarSc:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    clearHighlights()

    if errMsg then
        emptyLbl.Parent = CarSc
        emptyLbl.Text = "⚠ " .. errMsg
        CntLbl.Text   = "Autos: 0"
        StatLbl.Text  = "● Warte..."
        return
    end

    if #cars == 0 then
        emptyLbl.Parent = CarSc
        emptyLbl.Text   = "Keine Autos in RS.Cache.CarList\n(Noch nicht gespawnt?)"
        CntLbl.Text     = "Autos: 0"
        return
    end

    emptyLbl.Parent = nil

    for i, entry in ipairs(cars) do
        makeCarRow(CarSc, entry, i)
        highlightCar(entry.name, entry.data.rarity)
    end
    CntLbl.Text  = "Autos: " .. #cars
    StatLbl.Text = "● Live  " .. os.date("%H:%M:%S")
end

-- ================================================================
--  TAB 2 — SNIPER
-- ================================================================
local T2 = Instance.new("Frame", CA)
T2.Size             = UDim2.new(1,0,1,0)
T2.BackgroundTransparency = 1
T2.Visible          = false

-- Info
local sniperInfo = Instance.new("Frame", T2)
sniperInfo.Size             = UDim2.new(1,0,0,42)
sniperInfo.BackgroundColor3 = Color3.fromRGB(16,13,28)
sniperInfo.BorderSizePixel  = 0
Instance.new("UICorner",sniperInfo).CornerRadius = UDim.new(0,8)

local sniperStatus = Instance.new("TextLabel", sniperInfo)
sniperStatus.Size     = UDim2.new(1,-10,1,0)
sniperStatus.Position = UDim2.new(0,8,0,0)
sniperStatus.Text     = "Sniper inaktiv — füge Autos in der Datenbank hinzu"
sniperStatus.Font     = Enum.Font.Gotham
sniperStatus.TextSize = 11
sniperStatus.TextColor3 = Color3.fromRGB(160,150,200)
sniperStatus.BackgroundTransparency = 1
sniperStatus.TextXAlignment = Enum.TextXAlignment.Left
sniperStatus.TextWrapped = true

-- Watchlist
local wTitle = Instance.new("TextLabel", T2)
wTitle.Size=UDim2.new(1,0,0,16) wTitle.Position=UDim2.new(0,2,0,46)
wTitle.Text="Watchlist:" wTitle.Font=Enum.Font.GothamSemibold wTitle.TextSize=11
wTitle.TextColor3=Color3.fromRGB(130,120,180) wTitle.BackgroundTransparency=1
wTitle.TextXAlignment=Enum.TextXAlignment.Left

local WSc = Instance.new("ScrollingFrame", T2)
WSc.Size=UDim2.new(1,0,0.35,0) WSc.Position=UDim2.new(0,0,0,64)
WSc.BackgroundColor3=Color3.fromRGB(12,10,22) WSc.BorderSizePixel=0
WSc.ScrollBarThickness=4 WSc.ScrollBarImageColor3=Color3.fromRGB(70,55,130)
WSc.AutomaticCanvasSize=Enum.AutomaticSize.Y WSc.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",WSc).CornerRadius=UDim.new(0,9)
local wLL=Instance.new("UIListLayout",WSc) wLL.Padding=UDim.new(0,2)
local wPad=Instance.new("UIPadding",WSc) wPad.PaddingAll=UDim.new(0,4)

-- Sniper Button
local SniperBtn = Instance.new("TextButton", T2)
SniperBtn.Size=UDim2.new(1,0,0,38) SniperBtn.Position=UDim2.new(0,0,1,-40)
SniperBtn.Text="▶  Sniper STARTEN" SniperBtn.Font=Enum.Font.GothamBold SniperBtn.TextSize=14
SniperBtn.TextColor3=Color3.fromRGB(255,255,255) SniperBtn.BackgroundColor3=Color3.fromRGB(22,100,48)
SniperBtn.BorderSizePixel=0
Instance.new("UICorner",SniperBtn).CornerRadius=UDim.new(0,9)

local watchList = {}
local sniperActive = false
local lastTpTime = 0

local function refreshWatchUI()
    for _, c in ipairs(WSc:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    if #watchList == 0 then
        local e=Instance.new("TextLabel",WSc)
        e.Size=UDim2.new(1,0,0,28) e.Text="Keine Autos — gehe zur Datenbank und drücke + Add"
        e.Font=Enum.Font.Gotham e.TextSize=11 e.TextColor3=Color3.fromRGB(90,85,130) e.BackgroundTransparency=1
        return
    end
    for i, wName in ipairs(watchList) do
        local dbE = DB_MAP[wName:lower()]
        local rd  = dbE and RARITY[dbE.rarity] or RARITY[1]
        local row = Instance.new("Frame",WSc)
        row.LayoutOrder=i row.Size=UDim2.new(1,-8,0,28)
        row.BackgroundColor3=Color3.fromRGB(17,14,28) row.BorderSizePixel=0
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
        local nl=Instance.new("TextLabel",row)
        nl.Size=UDim2.new(1,-36,1,0) nl.Position=UDim2.new(0,8,0,0)
        nl.Text=rd.badge.." "..wName..(dbE and ("  ["..rd.label.."]") or "")
        nl.Font=Enum.Font.Gotham nl.TextSize=12 nl.TextColor3=rd.col nl.BackgroundTransparency=1 nl.TextXAlignment=Enum.TextXAlignment.Left
        local rb=Instance.new("TextButton",row)
        rb.Size=UDim2.new(0,26,0,20) rb.Position=UDim2.new(1,-30,0.5,-10)
        rb.Text="✕" rb.Font=Enum.Font.GothamBold rb.TextSize=11
        rb.TextColor3=Color3.fromRGB(255,70,70) rb.BackgroundColor3=Color3.fromRGB(38,10,10) rb.BorderSizePixel=0
        Instance.new("UICorner",rb).CornerRadius=UDim.new(0,4)
        local capI=i
        rb.MouseButton1Click:Connect(function()
            table.remove(watchList,capI) refreshWatchUI()
        end)
    end
end
refreshWatchUI()

SniperBtn.MouseButton1Click:Connect(function()
    sniperActive = not sniperActive
    SniperBtn.Text             = sniperActive and "■  Sniper STOPPEN" or "▶  Sniper STARTEN"
    SniperBtn.BackgroundColor3 = sniperActive and Color3.fromRGB(120,22,22) or Color3.fromRGB(22,100,48)
    sniperStatus.Text = sniperActive
        and ("✦ Sniper aktiv — überwache " .. #watchList .. " Auto(s)")
        or  "Sniper inaktiv"
    sniperStatus.TextColor3 = sniperActive and Color3.fromRGB(80,255,120) or Color3.fromRGB(160,150,200)
end)

-- ================================================================
--  TAB 3 — DATENBANK
-- ================================================================
local T3 = Instance.new("Frame", CA)
T3.Size             = UDim2.new(1,0,1,0)
T3.BackgroundTransparency = 1
T3.Visible          = false

-- Suchfeld
local SBg = Instance.new("Frame", T3)
SBg.Size=UDim2.new(1,0,0,34) SBg.BackgroundColor3=Color3.fromRGB(16,13,28) SBg.BorderSizePixel=0
Instance.new("UICorner",SBg).CornerRadius=UDim.new(0,8)
local SBox = Instance.new("TextBox",SBg)
SBox.Size=UDim2.new(1,-12,1,-8) SBox.Position=UDim2.new(0,8,0,4)
SBox.PlaceholderText="🔍  Auto suchen..." SBox.Text=""
SBox.Font=Enum.Font.Gotham SBox.TextSize=13
SBox.TextColor3=Color3.fromRGB(220,210,255) SBox.PlaceholderColor3=Color3.fromRGB(80,75,120)
SBox.BackgroundTransparency=1 SBox.ClearTextOnFocus=false

local DbSc = Instance.new("ScrollingFrame",T3)
DbSc.Size=UDim2.new(1,0,1,-40) DbSc.Position=UDim2.new(0,0,0,38)
DbSc.BackgroundColor3=Color3.fromRGB(12,10,22) DbSc.BorderSizePixel=0
DbSc.ScrollBarThickness=4 DbSc.ScrollBarImageColor3=Color3.fromRGB(70,55,130)
DbSc.AutomaticCanvasSize=Enum.AutomaticSize.Y DbSc.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",DbSc).CornerRadius=UDim.new(0,9)
local dbLL=Instance.new("UIListLayout",DbSc) dbLL.Padding=UDim.new(0,2)
local dbPad=Instance.new("UIPadding",DbSc) dbPad.PaddingAll=UDim.new(0,4)

local function buildDB(filter)
    for _,c in ipairs(DbSc:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local sorted = {}
    for _,v in ipairs(DB) do table.insert(sorted,v) end
    table.sort(sorted, function(a,b)
        if a.rarity~=b.rarity then return a.rarity>b.rarity end
        return a.rateNum < b.rateNum
    end)
    local n=0
    for _,v in ipairs(sorted) do
        if filter=="" or v.name:lower():find(filter:lower(),1,true) then
            n=n+1 if n>80 then break end
            local rd=RARITY[v.rarity]
            local row=Instance.new("Frame",DbSc)
            row.LayoutOrder=n row.Size=UDim2.new(1,-8,0,32)
            row.BackgroundColor3=Color3.fromRGB(15,12,25) row.BorderSizePixel=0
            Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
            -- Stripe
            local st=Instance.new("Frame",row) st.Size=UDim2.new(0,3,1,-6) st.Position=UDim2.new(0,3,0,3)
            st.BackgroundColor3=rd.glow st.BorderSizePixel=0 Instance.new("UICorner",st).CornerRadius=UDim.new(0,2)
            -- Name
            local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(0.5,0,0.55,0) nl.Position=UDim2.new(0,12,0,2)
            nl.Text=v.name nl.Font=Enum.Font.GothamSemibold nl.TextSize=12 nl.TextColor3=rd.col nl.BackgroundTransparency=1 nl.TextXAlignment=Enum.TextXAlignment.Left
            -- Rate + Preis
            local sl=Instance.new("TextLabel",row) sl.Size=UDim2.new(0.55,0,0.42,0) sl.Position=UDim2.new(0,12,0.55,0)
            sl.Text=v.spawnRate.."  ·  "..v.price sl.Font=Enum.Font.Gotham sl.TextSize=10
            sl.TextColor3=Color3.fromRGB(95,90,135) sl.BackgroundTransparency=1 sl.TextXAlignment=Enum.TextXAlignment.Left
            -- Add Button
            local ab=Instance.new("TextButton",row) ab.Size=UDim2.new(0,52,0,24) ab.Position=UDim2.new(1,-58,0.5,-12)
            ab.Text="+ Add" ab.Font=Enum.Font.GothamBold ab.TextSize=11
            ab.TextColor3=Color3.fromRGB(255,255,255) ab.BackgroundColor3=Color3.fromRGB(25,65,155) ab.BorderSizePixel=0
            Instance.new("UICorner",ab).CornerRadius=UDim.new(0,5)
            local capV=v
            ab.MouseButton1Click:Connect(function()
                for _,wn in ipairs(watchList) do
                    if wn:lower()==capV.name:lower() then
                        ab.Text="✓" task.delay(1.2,function() ab.Text="+ Add" end) return
                    end
                end
                table.insert(watchList,capV.name)
                refreshWatchUI()
                ab.Text="✓" ab.BackgroundColor3=Color3.fromRGB(16,100,32)
                task.delay(1.5,function() ab.Text="+ Add" ab.BackgroundColor3=Color3.fromRGB(25,65,155) end)
            end)
        end
    end
end
SBox:GetPropertyChangedSignal("Text"):Connect(function() buildDB(SBox.Text) end)
buildDB("")

-- ================================================================
--  TAB SWITCHING
-- ================================================================
local function setTab(n)
    T1.Visible=(n==1) T2.Visible=(n==2) T3.Visible=(n==3)
    local tabs={TB1,TB2,TB3}
    for i,btn in ipairs(tabs) do
        btn.BackgroundColor3=(i==n) and Color3.fromRGB(36,50,140) or Color3.fromRGB(20,18,34)
        btn.TextColor3=(i==n) and Color3.fromRGB(220,210,255) or Color3.fromRGB(140,130,180)
    end
end
TB1.MouseButton1Click:Connect(function() setTab(1) end)
TB2.MouseButton1Click:Connect(function() setTab(2) end)
TB3.MouseButton1Click:Connect(function() setTab(3) end)
setTab(1)

-- ================================================================
--  MAIN LOOP
-- ================================================================
local SCAN_IV  = 1.0
local CD_IV    = 0.5
local SNIPE_IV = 0.8
local lastScan  = 0
local lastCD    = 0
local lastSnipe = 0
local maxCD     = 0
local cachedCars = {}

game:GetService("RunService").Heartbeat:Connect(function()
    local now = tick()

    -- Countdown
    if now - lastCD >= CD_IV then
        lastCD = now
        local sec = getCountdown()
        if sec and sec > 0 then
            if sec > maxCD then maxCD = sec end
            local pct = maxCD > 0 and (sec / maxCD) or 1
            PBar.Size = UDim2.new(math.max(0, math.min(1, pct)), 0, 1, 0)
            CDLbl.Text    = "⏱ " .. sec .. "s"
            SpawnLbl.Text = "⏱ Wiederbeleben in " .. sec .. "s"
            if sec <= 10 then
                PBar.BackgroundColor3  = Color3.fromRGB(255,60,60)
                SpawnLbl.TextColor3    = Color3.fromRGB(255,100,100)
                CDLbl.TextColor3       = Color3.fromRGB(255,100,100)
            elseif sec <= 20 then
                PBar.BackgroundColor3  = Color3.fromRGB(255,160,40)
                SpawnLbl.TextColor3    = Color3.fromRGB(255,200,60)
                CDLbl.TextColor3       = Color3.fromRGB(255,200,60)
            else
                PBar.BackgroundColor3  = Color3.fromRGB(80,220,100)
                SpawnLbl.TextColor3    = Color3.fromRGB(255,200,60)
                CDLbl.TextColor3       = Color3.fromRGB(255,200,60)
            end
        else
            CDLbl.Text    = "⏱ --s"
            SpawnLbl.Text = "⏱ Kein Countdown gefunden"
        end
    end

    -- Scanner
    if now - lastScan >= SCAN_IV then
        lastScan = now
        local cars, err = scanCars()
        cachedCars = cars

        -- Hash zum Vergleich
        local hash = ""
        for _, e in ipairs(cars) do hash = hash .. e.name end

        if hash ~= lastCarHash then
            lastCarHash = hash
            refreshT1(cars, err)
        end

        if err then
            StatLbl.Text = "⚠ " .. err
            StatLbl.TextColor3 = Color3.fromRGB(255,100,100)
        else
            StatLbl.Text = "● Aktiv  " .. os.date("%H:%M:%S")
            StatLbl.TextColor3 = Color3.fromRGB(80,255,120)
        end
    end

    -- Sniper
    if sniperActive and now - lastSnipe >= SNIPE_IV then
        lastSnipe = now
        if #watchList > 0 and #cachedCars > 0 then
            local best = nil
            for _, entry in ipairs(cachedCars) do
                for _, wn in ipairs(watchList) do
                    if entry.name:lower() == wn:lower() then
                        if not best or entry.data.rarity > best.data.rarity then
                            best = entry
                        end
                        break
                    end
                end
            end
            if best and now - lastTpTime > 3 then
                lastTpTime = now
                playAlert()
                tpToCar(best)
                sniperStatus.Text = "✦ GEFUNDEN: " .. best.name .. " [" .. RARITY[best.data.rarity].label .. "]"
                sniperStatus.TextColor3 = RARITY[best.data.rarity].glow
            end
        end
    end
end)

print("[FIU v5] ✓ Geladen! Liest RS.Cache.CarList")
