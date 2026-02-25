-- ================================================================
--  Fix It Up — Smart GUI  v4.0
--  Executor : Xeno
--  Fixes    : Countdown "WIEDERBELEBEN IN X SEKUNDEN" erkannt
--             Scanner zeigt ALLE Workspace-Models (Debug-Tab)
--             Flexibles Name-Matching gegen Fahrzeug-DB
-- ================================================================

-- ── Safe Services ───────────────────────────────────────────────
local function S(n) return (cloneref and cloneref(game:GetService(n))) or game:GetService(n) end
local Players    = S("Players")
local RunService = S("RunService")
local WS         = S("Workspace")
local LP         = Players.LocalPlayer

-- ================================================================
--  RARITY BERECHNUNG  (nach Spawn-Rate %)
--  0-5%   = 4  Episch      (Pink)
--  6-15%  = 3  Selten      (Blau)
--  16-25% = 2  Ungewöhnlich(Grün)
--  >25%   = 1  Gewöhnlich  (Grau)
--  N/A    = 4  Episch (Sonder-Fahrzeug)
-- ================================================================
local function parseRate(s)
    if not s then return nil end
    local n = s:match("([%d%.,]+)%s*%%")
    if not n then return nil end
    return tonumber((n:gsub(",",".")))
end

local function calcRarity(sr)
    local r = parseRate(sr)
    if r == nil  then return 4 end
    if r <= 5    then return 4 end
    if r <= 15   then return 3 end
    if r <= 25   then return 2 end
    return 1
end

local RARITY = {
    [1]={label="Gewöhnlich",   badge="●", col=Color3.fromRGB(160,160,160), glow=Color3.fromRGB(160,160,160)},
    [2]={label="Ungewöhnlich", badge="◆", col=Color3.fromRGB(80,230,80),   glow=Color3.fromRGB(60,255,60)  },
    [3]={label="Selten",       badge="★", col=Color3.fromRGB(80,150,255),  glow=Color3.fromRGB(60,130,255) },
    [4]={label="Episch",       badge="✦", col=Color3.fromRGB(255,80,200),  glow=Color3.fromRGB(255,50,190) },
}

-- ================================================================
--  FAHRZEUG-DATENBANK
-- ================================================================
local RAW = {
    {"Wesla Modelo","N/A","HR+ Exklusiv"},
    {"Bananenauto","N/A","Moderator+ Exklusiv"},
    {"Mata FX7","N/A","Außer Haus"},
    {"Porx JT3 RF","N/A","Außer Haus"},
    {"BNV K4 G","N/A","799"},
    {"Audi RF6","N/A","699"},
    {"BNV K340i","N/A","599"},
    {"Merquis G Wafer","N/A","Exklusives Event"},
    {"Merquis JF","N/A","Nicht verfügbar"},
    {"Sigma Roma Quadri","N/A","Nicht verfügbar"},
    {"Kart","Nicht verfügbar","Außerverkauft"},
    {"Lambemos-Iris","Nicht verfügbar","Außerbörslich"},
    {"BNV K3 F","0,02%","80.000€ – 120.000€"},
    {"DOGO Desafio","Nicht verfügbar","Außerbörslich"},
    {"Fia-Te Double","Nicht verfügbar","Außerhalb d. reg. Verkaufs"},
    {"Toyoda Supwa A90","Nicht verfügbar","Außerverkauft"},
    {"Sucato Empresa","Nicht verfügbar","Nicht verfügbar"},
    {"Chule Curgette C7","Nicht verfügbar","Nicht verfügbar"},
    {"Skami Truk","0,05%","120.000€ – 200.000€"},
    {"BNV K8","0,05%","180.000€ – 230.000€"},
    {"Merquis SLX","0,05%","180.000€ – 280.000€"},
    {"Mine Copa S","0,05%","50.000€ – 70.000€"},
    {"Missah JTF","Nicht verfügbar","Außerverkauft"},
    {"Porx JT2 RF","Nicht verfügbar","Außerverkauft"},
    {"Missah Groundline F34","Nicht verfügbar","Außerverkauft"},
    {"Ropes Ruyter Shadow","Nicht verfügbar","Außerverkauft"},
    {"Holde S2k","Nicht verfügbar","Außerverkauft"},
    {"Chule Curgete","0,1%","65.000€ – 120.000€"},
    {"Audi V7","Nicht verfügbar","Außerbörslich"},
    {"Audi F8","Nicht verfügbar","Außerverkauft"},
    {"Fia-Te 10026p","0,2%","3.000€ – 7.000€"},
    {"Audi F8 Performance","Nicht verfügbar","Außerverkauft"},
    {"Toyoda Supwa","Nicht verfügbar","Außerverkauft"},
    {"Vier Mustank 70s","Nicht verfügbar","Außerverkauft"},
    {"Toyoda AFF67","0,3%","25.000€ – 55.000€"},
    {"Auidy RF3 Limousine","0,3%","70.000€ – 90.000€"},
    {"Lokswag Brasiuiu","0,3%","5.000€ – 12.000€"},
    {"Audi V8","0,4%","120.000€ – 200.000€"},
    {"BNV K5 e60","0,5%","60.000€ – 90.000€"},
    {"Ratos Rotos Esporte","0,5%","100.000€ – 200.000€"},
    {"Holde TipeRar","0,5%","50.000€ – 90.000€"},
    {"Audi RF3","0,6%","40.000€ – 55.000€"},
    {"Holde Proluiz","0,8%","10.000€ – 25.000€"},
    {"Missah 750x","Nicht verfügbar","Außerbörslich"},
    {"Chule Camarao","1%","60.000€ – 100.000€"},
    {"Four Rex","1%","60.000€ – 80.000€"},
    {"Audi V5","1%","40.000€ – 55.000€"},
    {"Merquis Z73","1%","35.000€ – 65.000€"},
    {"BNV K3 e92","1%","45.000€ – 60.000€"},
    {"Matsu Lanca","2%","15.000€ – 55.000€"},
    {"Lokswag Golo GT","2%","25.000€ – 55.000€"},
    {"Toyoda Yapp","2%","25.000€ – 55.000€"},
    {"Vovo F60 Polo","2,5%","25.000€ – 45.000€"},
    {"BNV K5 e39","3%","20.000€ – 50.000€"},
    {"BNV K140","Nicht verfügbar","Außerverkauft"},
    {"Merquis ZLA 45","Nicht verfügbar","Außerverkauft"},
    {"Fia-Te Alberto 300","3%","18.000€ – 30.000€"},
    {"Ontel Astron","4%","25.000€ – 40.000€"},
    {"Raguer XisR","5%","20.000€ – 30.000€"},
    {"Renas Mugano","5%","18.000€ – 30.000€"},
    {"Four Traffic","6%","15.000€ – 30.000€"},
    {"Vier Party","6%","23.000€ – 40.000€"},
    {"Lokswag Golo MK5","7%","17.000€ – 25.000€"},
    {"Merquis C203","7%","9.000€ – 22.000€"},
    {"Toyoda Hellox","7%","28.000€ – 40.000€"},
    {"Holde Inteiro","7%","9.000€ – 30.000€"},
    {"Leskus not200","10%","9.000€ – 20.000€"},
    {"BNV K3","10%","9.000€ – 20.000€"},
    {"Missah Silva","Nicht verfügbar","Außerbörslich"},
    {"Holde Ciwiq","11%","5.000€ – 15.000€"},
    {"Audi V4","15%","12.000€ – 18.000€"},
    {"Lokswag Golo MK4","15%","12.000€ – 17.000€"},
    {"Vovo Sr60","17%","12.000€ – 17.000€"},
    {"Peujo 400e6","20%","7.000€ – 17.000€"},
    {"Lokswag Passar","20%","8.000€ – 14.000€"},
    {"Sacode Oitava","20%","8.000€ – 14.000€"},
    {"Peujo 200e5","25%","7.000€ – 12.000€"},
    {"Renas Kapturado","30%","5.000€ – 11.000€"},
    {"Lokswag Golo","30%","4.000€ – 8.000€"},
    {"Ontel Costa","30%","700€ – 3.000€"},
    {"Xitro J3","40%","15.000€ – 20.000€"},
    {"Sabes Muito","40%","7.000€ – 15.000€"},
    {"Peujo 200e6","50%","1.000€ – 4.000€"},
    {"Fia-Te Ponto","50%","700€ – 3.000€"},
    {"Siath Lion","50%","1.500€ – 4.000€"},
}

-- DB mit Rarity aufbauen
local DB = {}
local DB_LOWER = {}   -- key: lowercase name → DB entry
for _, v in ipairs(RAW) do
    local entry = {name=v[1], spawnRate=v[2], price=v[3], rarity=calcRarity(v[2]), rateNum=parseRate(v[2]) or 999}
    table.insert(DB, entry)
    DB_LOWER[v[1]:lower()] = entry
end

-- ================================================================
--  NAME-MATCHING  (versucht DB-Eintrag zu finden)
--  Gibt DB-Eintrag zurück oder nil
-- ================================================================
local function matchDB(modelName)
    if not modelName or modelName == "" then return nil end
    local lo = modelName:lower()
    -- 1. Exakter Match
    if DB_LOWER[lo] then return DB_LOWER[lo] end
    -- 2. DB-Name in Model-Name enthalten
    for key, entry in pairs(DB_LOWER) do
        if lo:find(key, 1, true) then return entry end
    end
    -- 3. Model-Name in DB-Name enthalten (mindestens 4 Zeichen)
    if #lo >= 4 then
        for key, entry in pairs(DB_LOWER) do
            if key:find(lo, 1, true) then return entry end
        end
    end
    return nil
end

-- ================================================================
--  COUNTDOWN DETEKTION
--  "WIEDERBELEBEN IN 82 SEKUNDEN"
--  Sucht in ALLEN TextLabels des gesamten Spiels
-- ================================================================
local function FindCountdown()
    -- Pattern: "... IN [ZAHL] SEKUNDEN" oder "[ZAHL] SEKUNDEN"
    local patterns = {
        "IN%s+(%d+)%s+SEKUNDEN",   -- WIEDERBELEBEN IN 82 SEKUNDEN
        "(%d+)%s+SEKUNDEN",         -- 82 SEKUNDEN
        "(%d+)%s+SECS?",            -- englisch fallback
        "(%d+):(%d+)",              -- MM:SS
        "in%s+(%d+)%s+sekunden",    -- lowercase
    }

    local function checkText(t)
        if not t or t == "" then return nil end
        for _, p in ipairs(patterns) do
            local a, b = t:match(p)
            if a and b then
                -- MM:SS Format
                return tonumber(a)*60 + tonumber(b)
            elseif a then
                return tonumber(a)
            end
        end
        return nil
    end

    -- Workspace vollständig durchsuchen (SurfaceGui, BillboardGui, ScreenGui)
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local sec = checkText(obj.Text)
            if sec and sec > 0 and sec < 600 then
                return obj, sec
            end
        end
    end
    -- Auch PlayerGui prüfen
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local sec = checkText(obj.Text)
                if sec and sec > 0 and sec < 600 then
                    return obj, sec
                end
            end
        end
    end
    return nil, 0
end

-- ================================================================
--  WORKSPACE SCANNER
--  Findet alle Models im Workspace + matched gegen DB
--  WICHTIG: Zeigt auch UNBEKANNTE Models an (Debug)
-- ================================================================
local function ScanAll()
    local matched   = {}  -- hat DB-Eintrag
    local unmatched = {}  -- kein DB-Eintrag (für Debug)

    local function processModel(obj)
        if not obj:IsA("Model") then return end
        if obj == LP.Character then return end
        if obj.Name == "Workspace" or obj.Name == "" then return end

        local root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if not root then return end

        local dbEntry = matchDB(obj.Name)
        if dbEntry then
            table.insert(matched, {model=obj, data=dbEntry, cf=root.CFrame, rawName=obj.Name})
        else
            -- Unbekannt: trotzdem anzeigen wenn es keine System-Namen sind
            local skip = {["Camera"]=true,["Terrain"]=true,["SpawnLocation"]=true,["Baseplate"]=true}
            if not skip[obj.Name] and obj.Name:len() > 1 then
                table.insert(unmatched, {model=obj, rawName=obj.Name, cf=root.CFrame})
            end
        end
    end

    -- Alle Descendants scannen
    for _, obj in ipairs(WS:GetDescendants()) do
        processModel(obj)
    end

    -- Matched nach Rarity sortieren
    table.sort(matched, function(a,b)
        if a.data.rarity ~= b.data.rarity then return a.data.rarity > b.data.rarity end
        return (a.data.rateNum or 999) < (b.data.rateNum or 999)
    end)

    return matched, unmatched
end

-- ================================================================
--  STATE
-- ================================================================
local watchList    = {}
local highlights   = {}
local sniperActive = false
local lastTpTime   = 0
local cachedMatch  = {}
local cachedUnmatch= {}
local lastHash     = ""
local alertSound   = nil
local maxCD        = 0

-- ================================================================
--  HILFSFUNKTIONEN
-- ================================================================
local function PlayAlert()
    if not alertSound then
        alertSound = Instance.new("Sound", WS)
        alertSound.SoundId = "rbxassetid://9125402735"
        alertSound.Volume  = 1
        alertSound.RollOffMaxDistance = 99999
    end
    pcall(function() if not alertSound.IsPlaying then alertSound:Play() end end)
end

local function TP(cf)
    local ch = LP.Character
    if ch then
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function() hrp.CFrame = cf + Vector3.new(0, 5, 0) end)
        end
    end
end

local function ClearHL()
    for _, h in pairs(highlights) do pcall(function() h:Destroy() end) end
    highlights = {}
end

local function AddHL(model, rarity)
    if rarity < 2 then return end  -- Gewöhnliche nicht highlighten
    local rd = RARITY[rarity]
    pcall(function()
        local h = Instance.new("SelectionBox", WS)
        h.Adornee            = model
        h.Color3             = rd.glow
        h.LineThickness      = 0.08
        h.SurfaceTransparency= 0.7
        h.SurfaceColor3      = rd.glow
        table.insert(highlights, h)
    end)
end

-- ================================================================
--  GUI
-- ================================================================
-- Bestehende GUI entfernen
pcall(function()
    for _, g in ipairs((gethui and gethui() or LP.PlayerGui):GetChildren()) do
        if g.Name == "FIU_GUI" then g:Destroy() end
    end
end)

local GUI = Instance.new("ScreenGui")
GUI.Name           = "FIU_GUI"
GUI.ResetOnSpawn   = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent         = (gethui and gethui()) or LP.PlayerGui

-- Haupt-Frame
local Main = Instance.new("Frame", GUI)
Main.Size             = UDim2.new(0, 520, 0, 600)
Main.Position         = UDim2.new(0.5,-260, 0.5,-300)
Main.BackgroundColor3 = Color3.fromRGB(10, 9, 18)
Main.BorderSizePixel  = 0
Main.Active           = true
Main.Draggable        = true
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,12)

-- Titelleiste
local TBar = Instance.new("Frame", Main)
TBar.Size             = UDim2.new(1,0, 0,40)
TBar.BackgroundColor3 = Color3.fromRGB(16,13,30)
TBar.BorderSizePixel  = 0
Instance.new("UICorner",TBar).CornerRadius = UDim.new(0,12)

local TLbl = Instance.new("TextLabel",TBar)
TLbl.Size=UDim2.new(1,-120,1,0) TLbl.Position=UDim2.new(0,12,0,0)
TLbl.Text="🔧  Fix It Up — v4.0"
TLbl.Font=Enum.Font.GothamBold TLbl.TextSize=14
TLbl.TextColor3=Color3.fromRGB(220,210,255)
TLbl.BackgroundTransparency=1 TLbl.TextXAlignment=Enum.TextXAlignment.Left

local CDLbl = Instance.new("TextLabel",TBar)
CDLbl.Size=UDim2.new(0,90,1,0) CDLbl.Position=UDim2.new(1,-120,0,0)
CDLbl.Text="⏱ --s" CDLbl.Font=Enum.Font.GothamBold CDLbl.TextSize=13
CDLbl.TextColor3=Color3.fromRGB(255,200,60) CDLbl.BackgroundTransparency=1

local function makeBtn(parent,txt,x,col,tcol)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(0,28,0,28) b.Position=UDim2.new(1,x,0.5,-14)
    b.Text=txt b.Font=Enum.Font.GothamBold b.TextSize=13
    b.TextColor3=tcol b.BackgroundColor3=col b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    return b
end
local CloseBtn = makeBtn(TBar,"✕",-32,Color3.fromRGB(40,12,12),Color3.fromRGB(255,70,70))
local MinBtn   = makeBtn(TBar,"−",-64,Color3.fromRGB(30,30,10),Color3.fromRGB(220,200,60))

local Body = Instance.new("Frame",Main)
Body.Size=UDim2.new(1,0,1,-40) Body.Position=UDim2.new(0,0,0,40)
Body.BackgroundTransparency=1

CloseBtn.MouseButton1Click:Connect(function() ClearHL() GUI:Destroy() end)
local minimized=false
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    Body.Visible=not minimized
    Main.Size=minimized and UDim2.new(0,520,0,40) or UDim2.new(0,520,0,600)
    MinBtn.Text=minimized and "+" or "−"
end)

-- Tabs
local TabBar=Instance.new("Frame",Body)
TabBar.Size=UDim2.new(1,-16,0,34) TabBar.Position=UDim2.new(0,8,0,6)
TabBar.BackgroundTransparency=1

local function NewTab(txt,x)
    local b=Instance.new("TextButton",TabBar)
    b.Size=UDim2.new(0.32,0,1,0) b.Position=UDim2.new(x,0,0,0)
    b.Text=txt b.Font=Enum.Font.GothamSemibold b.TextSize=11
    b.TextColor3=Color3.fromRGB(150,140,190)
    b.BackgroundColor3=Color3.fromRGB(20,18,34) b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    return b
end
local TB1=NewTab("📡 Junkyard",0)
local TB2=NewTab("🎯 Sniper",0.34)
local TB3=NewTab("🔍 Debug",0.68)

local CA=Instance.new("Frame",Body)
CA.Size=UDim2.new(1,-16,1,-50) CA.Position=UDim2.new(0,8,0,46)
CA.BackgroundTransparency=1

-- ================================================================
--  TAB 1 — JUNKYARD LIVE
-- ================================================================
local T1=Instance.new("Frame",CA)
T1.Size=UDim2.new(1,0,1,0) T1.BackgroundTransparency=1

-- Info-Bar
local IBar=Instance.new("Frame",T1)
IBar.Size=UDim2.new(1,0,0,52) IBar.BackgroundColor3=Color3.fromRGB(16,13,28)
IBar.BorderSizePixel=0 Instance.new("UICorner",IBar).CornerRadius=UDim.new(0,8)

local StatLbl=Instance.new("TextLabel",IBar)
StatLbl.Size=UDim2.new(0.6,0,0.5,0) StatLbl.Position=UDim2.new(0,8,0,2)
StatLbl.Text="● Starte Scanner..." StatLbl.Font=Enum.Font.Gotham StatLbl.TextSize=11
StatLbl.TextColor3=Color3.fromRGB(80,255,120) StatLbl.BackgroundTransparency=1
StatLbl.TextXAlignment=Enum.TextXAlignment.Left

local CntLbl=Instance.new("TextLabel",IBar)
CntLbl.Size=UDim2.new(0.38,0,0.5,0) CntLbl.Position=UDim2.new(0.62,0,0,2)
CntLbl.Text="Gefunden: 0" CntLbl.Font=Enum.Font.Gotham CntLbl.TextSize=11
CntLbl.TextColor3=Color3.fromRGB(160,140,220) CntLbl.BackgroundTransparency=1
CntLbl.TextXAlignment=Enum.TextXAlignment.Right

local SpawnLbl=Instance.new("TextLabel",IBar)
SpawnLbl.Size=UDim2.new(0.65,0,0.45,0) SpawnLbl.Position=UDim2.new(0,8,0.5,2)
SpawnLbl.Text="⏱ Suche Countdown..." SpawnLbl.Font=Enum.Font.Gotham SpawnLbl.TextSize=11
SpawnLbl.TextColor3=Color3.fromRGB(255,200,60) SpawnLbl.BackgroundTransparency=1
SpawnLbl.TextXAlignment=Enum.TextXAlignment.Left

-- Progress Bar
local PBg=Instance.new("Frame",IBar)
PBg.Size=UDim2.new(1,0,0,4) PBg.Position=UDim2.new(0,0,1,-4)
PBg.BackgroundColor3=Color3.fromRGB(30,25,50) PBg.BorderSizePixel=0
Instance.new("UICorner",PBg).CornerRadius=UDim.new(0,2)
local PBar=Instance.new("Frame",PBg)
PBar.Size=UDim2.new(0,0,1,0) PBar.BackgroundColor3=Color3.fromRGB(80,220,100) PBar.BorderSizePixel=0
Instance.new("UICorner",PBar).CornerRadius=UDim.new(0,2)

-- Legende
local Leg=Instance.new("Frame",T1)
Leg.Size=UDim2.new(1,0,0,16) Leg.Position=UDim2.new(0,0,0,56)
Leg.BackgroundTransparency=1
local legData={{RARITY[4].glow,"Episch 0-5%",0},{RARITY[3].glow,"Selten 6-15%",0.25},{RARITY[2].glow,"Ungew. 16-25%",0.5},{RARITY[1].glow,"Gew. >25%",0.76}}
for _,li in ipairs(legData) do
    local f=Instance.new("Frame",Leg)
    f.Size=UDim2.new(0.24,0,1,0) f.Position=UDim2.new(li[3],0,0,0) f.BackgroundTransparency=1
    local d=Instance.new("Frame",f) d.Size=UDim2.new(0,7,0,7) d.Position=UDim2.new(0,0,0.5,-3.5)
    d.BackgroundColor3=li[1] d.BorderSizePixel=0 Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    local t=Instance.new("TextLabel",f) t.Size=UDim2.new(1,-11,1,0) t.Position=UDim2.new(0,11,0,0)
    t.Text=li[2] t.Font=Enum.Font.Gotham t.TextSize=9 t.TextColor3=li[1]
    t.BackgroundTransparency=1 t.TextXAlignment=Enum.TextXAlignment.Left
end

-- Auto-Scroll
local CS=Instance.new("ScrollingFrame",T1)
CS.Size=UDim2.new(1,0,1,-78) CS.Position=UDim2.new(0,0,0,76)
CS.BackgroundColor3=Color3.fromRGB(12,10,22) CS.BorderSizePixel=0
CS.ScrollBarThickness=4 CS.ScrollBarImageColor3=Color3.fromRGB(70,55,130)
CS.AutomaticCanvasSize=Enum.AutomaticSize.Y CS.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",CS).CornerRadius=UDim.new(0,9)
local cLL=Instance.new("UIListLayout",CS) cLL.Padding=UDim.new(0,3) cLL.SortOrder=Enum.SortOrder.LayoutOrder
local cLP=Instance.new("UIPadding",CS) cLP.PaddingTop=UDim.new(0,5) cLP.PaddingBottom=UDim.new(0,5) cLP.PaddingLeft=UDim.new(0,5) cLP.PaddingRight=UDim.new(0,5)

local function MakeRow(parent, entry, idx)
    local rd=RARITY[entry.data.rarity]
    local row=Instance.new("Frame",parent)
    row.LayoutOrder=idx row.Size=UDim2.new(1,-10,0,48)
    row.BackgroundColor3=Color3.fromRGB(18,15,32) row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    -- Rarity Stripe
    local st=Instance.new("Frame",row) st.Size=UDim2.new(0,4,1,-10) st.Position=UDim2.new(0,4,0,5)
    st.BackgroundColor3=rd.glow st.BorderSizePixel=0 Instance.new("UICorner",st).CornerRadius=UDim.new(0,2)
    -- Badge
    local bg2=Instance.new("TextLabel",row) bg2.Size=UDim2.new(0,18,0,18) bg2.Position=UDim2.new(0,14,0.5,-9)
    bg2.Text=rd.badge bg2.Font=Enum.Font.GothamBold bg2.TextSize=14 bg2.TextColor3=rd.glow bg2.BackgroundTransparency=1
    -- Name (DB-Name + Raw-Name wenn unterschiedlich)
    local showName = entry.data.name
    if entry.rawName and entry.rawName:lower() ~= entry.data.name:lower() then
        showName = entry.data.name .. " (" .. entry.rawName .. ")"
    end
    local nL=Instance.new("TextLabel",row) nL.Size=UDim2.new(0.5,0,0.52,0) nL.Position=UDim2.new(0,36,0,3)
    nL.Text=showName nL.Font=Enum.Font.GothamSemibold nL.TextSize=12 nL.TextColor3=rd.col
    nL.BackgroundTransparency=1 nL.TextXAlignment=Enum.TextXAlignment.Left nL.TextTruncate=Enum.TextTruncate.AtEnd
    -- Spawn + Preis
    local sL=Instance.new("TextLabel",row) sL.Size=UDim2.new(0.58,0,0.42,0) sL.Position=UDim2.new(0,36,0.54,0)
    sL.Text=entry.data.spawnRate.."  ·  "..entry.data.price
    sL.Font=Enum.Font.Gotham sL.TextSize=10 sL.TextColor3=Color3.fromRGB(105,100,148)
    sL.BackgroundTransparency=1 sL.TextXAlignment=Enum.TextXAlignment.Left
    -- Rarity Pill
    local pill=Instance.new("TextLabel",row) pill.Size=UDim2.new(0,72,0,20) pill.Position=UDim2.new(1,-132,0.5,-10)
    pill.Text=rd.label pill.Font=Enum.Font.GothamBold pill.TextSize=11 pill.TextColor3=rd.glow
    pill.BackgroundColor3=Color3.fromRGB(20,15,30) pill.BackgroundTransparency=0.3 pill.BorderSizePixel=0
    Instance.new("UICorner",pill).CornerRadius=UDim.new(0,5)
    -- TP Button
    local tp=Instance.new("TextButton",row) tp.Size=UDim2.new(0,50,0,26) tp.Position=UDim2.new(1,-56,0.5,-13)
    tp.Text="TP →" tp.Font=Enum.Font.GothamBold tp.TextSize=12 tp.TextColor3=Color3.fromRGB(255,255,255)
    tp.BackgroundColor3=Color3.fromRGB(32,65,160) tp.BorderSizePixel=0
    Instance.new("UICorner",tp).CornerRadius=UDim.new(0,6)
    local capCF=entry.cf
    tp.MouseButton1Click:Connect(function() TP(capCF) end)
    return row
end

local function RefreshT1(matched)
    for _,c in ipairs(CS:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    ClearHL()
    for i,e in ipairs(matched) do
        MakeRow(CS,e,i)
        AddHL(e.model, e.data.rarity)
    end
    CntLbl.Text="Gefunden: "..#matched
end

-- ================================================================
--  TAB 2 — SNIPER
-- ================================================================
local T2=Instance.new("Frame",CA)
T2.Size=UDim2.new(1,0,1,0) T2.BackgroundTransparency=1 T2.Visible=false

local SBg=Instance.new("Frame",T2)
SBg.Size=UDim2.new(1,0,0,34) SBg.BackgroundColor3=Color3.fromRGB(16,13,28) SBg.BorderSizePixel=0
Instance.new("UICorner",SBg).CornerRadius=UDim.new(0,8)
local SBox=Instance.new("TextBox",SBg)
SBox.Size=UDim2.new(1,-12,1,-8) SBox.Position=UDim2.new(0,8,0,4)
SBox.PlaceholderText="🔍  Auto suchen..." SBox.Text=""
SBox.Font=Enum.Font.Gotham SBox.TextSize=13
SBox.TextColor3=Color3.fromRGB(220,210,255) SBox.PlaceholderColor3=Color3.fromRGB(80,75,120)
SBox.BackgroundTransparency=1 SBox.ClearTextOnFocus=false

-- DB-Scroll
local DbH=Instance.new("TextLabel",T2)
DbH.Size=UDim2.new(1,0,0,16) DbH.Position=UDim2.new(0,2,0,38)
DbH.Text="Datenbank (Seltenste zuerst) — klick zum Hinzufügen:"
DbH.Font=Enum.Font.GothamSemibold DbH.TextSize=10 DbH.TextColor3=Color3.fromRGB(130,120,180)
DbH.BackgroundTransparency=1 DbH.TextXAlignment=Enum.TextXAlignment.Left

local DbSc=Instance.new("ScrollingFrame",T2)
DbSc.Size=UDim2.new(1,0,0.42,0) DbSc.Position=UDim2.new(0,0,0,58)
DbSc.BackgroundColor3=Color3.fromRGB(12,10,22) DbSc.BorderSizePixel=0
DbSc.ScrollBarThickness=4 DbSc.ScrollBarImageColor3=Color3.fromRGB(70,55,130)
DbSc.AutomaticCanvasSize=Enum.AutomaticSize.Y DbSc.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",DbSc).CornerRadius=UDim.new(0,9)
local dbLL=Instance.new("UIListLayout",DbSc) dbLL.Padding=UDim.new(0,2)
local dbLP=Instance.new("UIPadding",DbSc) dbLP.PaddingAll=UDim.new(0,4)

-- Watchlist
local WH=Instance.new("TextLabel",T2)
WH.Size=UDim2.new(1,0,0,14) WH.Position=UDim2.new(0,2,0.445,4)
WH.Text="Meine Watchlist:" WH.Font=Enum.Font.GothamSemibold WH.TextSize=10
WH.TextColor3=Color3.fromRGB(130,120,180) WH.BackgroundTransparency=1 WH.TextXAlignment=Enum.TextXAlignment.Left

local WSc=Instance.new("ScrollingFrame",T2)
WSc.Size=UDim2.new(1,0,0.28,0) WSc.Position=UDim2.new(0,0,0.475,0)
WSc.BackgroundColor3=Color3.fromRGB(12,10,22) WSc.BorderSizePixel=0
WSc.ScrollBarThickness=4 WSc.ScrollBarImageColor3=Color3.fromRGB(70,55,130)
WSc.AutomaticCanvasSize=Enum.AutomaticSize.Y WSc.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",WSc).CornerRadius=UDim.new(0,9)
local wLL=Instance.new("UIListLayout",WSc) wLL.Padding=UDim.new(0,2)
local wLP=Instance.new("UIPadding",WSc) wLP.PaddingAll=UDim.new(0,4)

local SniperBtn=Instance.new("TextButton",T2)
SniperBtn.Size=UDim2.new(1,0,0,36) SniperBtn.Position=UDim2.new(0,0,1,-38)
SniperBtn.Text="▶  Sniper STARTEN" SniperBtn.Font=Enum.Font.GothamBold SniperBtn.TextSize=14
SniperBtn.TextColor3=Color3.fromRGB(255,255,255) SniperBtn.BackgroundColor3=Color3.fromRGB(22,100,48)
SniperBtn.BorderSizePixel=0 Instance.new("UICorner",SniperBtn).CornerRadius=UDim.new(0,9)

local function RefreshWatchUI()
    for _,c in ipairs(WSc:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    if #watchList==0 then
        local e=Instance.new("TextLabel",WSc) e.Size=UDim2.new(1,0,0,24)
        e.Text="Noch keine Autos hinzugefügt." e.Font=Enum.Font.Gotham e.TextSize=11
        e.TextColor3=Color3.fromRGB(90,85,130) e.BackgroundTransparency=1
        return
    end
    for i,wName in ipairs(watchList) do
        local vd=DB_LOWER[wName:lower()]
        local rd=vd and RARITY[vd.rarity] or RARITY[1]
        local row=Instance.new("Frame",WSc) row.LayoutOrder=i
        row.Size=UDim2.new(1,-8,0,26) row.BackgroundColor3=Color3.fromRGB(17,14,28) row.BorderSizePixel=0
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
        local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(1,-36,1,0) nl.Position=UDim2.new(0,8,0,0)
        nl.Text=rd.badge.." "..wName..(vd and ("  ["..rd.label.."]") or "")
        nl.Font=Enum.Font.Gotham nl.TextSize=12 nl.TextColor3=rd.col nl.BackgroundTransparency=1 nl.TextXAlignment=Enum.TextXAlignment.Left
        local rb=Instance.new("TextButton",row) rb.Size=UDim2.new(0,26,0,20) rb.Position=UDim2.new(1,-30,0.5,-10)
        rb.Text="✕" rb.Font=Enum.Font.GothamBold rb.TextSize=11 rb.TextColor3=Color3.fromRGB(255,70,70)
        rb.BackgroundColor3=Color3.fromRGB(38,10,10) rb.BorderSizePixel=0
        Instance.new("UICorner",rb).CornerRadius=UDim.new(0,4)
        local cap=i rb.MouseButton1Click:Connect(function()
            table.remove(watchList,cap) RefreshWatchUI()
        end)
    end
end

local function BuildDb(filter)
    for _,c in ipairs(DbSc:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local sorted={}
    for _,v in ipairs(DB) do table.insert(sorted,v) end
    table.sort(sorted,function(a,b)
        if a.rarity~=b.rarity then return a.rarity>b.rarity end
        return (a.rateNum or 999)<(b.rateNum or 999)
    end)
    local n=0
    for _,v in ipairs(sorted) do
        if filter=="" or v.name:lower():find(filter:lower(),1,true) then
            n=n+1 if n>80 then break end
            local rd=RARITY[v.rarity]
            local row=Instance.new("Frame",DbSc) row.LayoutOrder=n
            row.Size=UDim2.new(1,-8,0,30) row.BackgroundColor3=Color3.fromRGB(15,12,25) row.BorderSizePixel=0
            Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
            local st=Instance.new("Frame",row) st.Size=UDim2.new(0,3,1,-6) st.Position=UDim2.new(0,3,0,3)
            st.BackgroundColor3=rd.glow st.BorderSizePixel=0 Instance.new("UICorner",st).CornerRadius=UDim.new(0,2)
            local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(0.5,0,0.55,0) nl.Position=UDim2.new(0,12,0,2)
            nl.Text=v.name nl.Font=Enum.Font.GothamSemibold nl.TextSize=12 nl.TextColor3=rd.col nl.BackgroundTransparency=1 nl.TextXAlignment=Enum.TextXAlignment.Left
            local sl=Instance.new("TextLabel",row) sl.Size=UDim2.new(0.55,0,0.42,0) sl.Position=UDim2.new(0,12,0.55,0)
            sl.Text=v.spawnRate.."  ·  "..v.price sl.Font=Enum.Font.Gotham sl.TextSize=10
            sl.TextColor3=Color3.fromRGB(95,90,135) sl.BackgroundTransparency=1 sl.TextXAlignment=Enum.TextXAlignment.Left
            local ab=Instance.new("TextButton",row) ab.Size=UDim2.new(0,50,0,22) ab.Position=UDim2.new(1,-56,0.5,-11)
            ab.Text="+ Add" ab.Font=Enum.Font.GothamBold ab.TextSize=11 ab.TextColor3=Color3.fromRGB(255,255,255)
            ab.BackgroundColor3=Color3.fromRGB(25,65,155) ab.BorderSizePixel=0
            Instance.new("UICorner",ab).CornerRadius=UDim.new(0,5)
            local capV=v
            ab.MouseButton1Click:Connect(function()
                for _,wn in ipairs(watchList) do if wn:lower()==capV.name:lower() then
                    ab.Text="✓ Da" task.delay(1,function() ab.Text="+ Add" end) return
                end end
                table.insert(watchList,capV.name) RefreshWatchUI()
                ab.Text="✓" ab.BackgroundColor3=Color3.fromRGB(16,100,32)
                task.delay(1.5,function() ab.Text="+ Add" ab.BackgroundColor3=Color3.fromRGB(25,65,155) end)
            end)
        end
    end
end

SBox:GetPropertyChangedSignal("Text"):Connect(function() BuildDb(SBox.Text) end)
BuildDb("") RefreshWatchUI()

SniperBtn.MouseButton1Click:Connect(function()
    sniperActive=not sniperActive
    SniperBtn.Text=sniperActive and "■  Sniper STOPPEN" or "▶  Sniper STARTEN"
    SniperBtn.BackgroundColor3=sniperActive and Color3.fromRGB(120,22,22) or Color3.fromRGB(22,100,48)
end)

-- ================================================================
--  TAB 3 — DEBUG (zeigt ALLE Models im Workspace)
-- ================================================================
local T3=Instance.new("Frame",CA)
T3.Size=UDim2.new(1,0,1,0) T3.BackgroundTransparency=1 T3.Visible=false

local D_Info=Instance.new("TextLabel",T3)
D_Info.Size=UDim2.new(1,0,0,30) D_Info.BackgroundColor3=Color3.fromRGB(14,10,28)
D_Info.BorderSizePixel=0 Instance.new("UICorner",D_Info).CornerRadius=UDim.new(0,7)
D_Info.Text="🔍 Zeigt ALLE Models — so erkennt man die echten Auto-Namen"
D_Info.Font=Enum.Font.Gotham D_Info.TextSize=11 D_Info.TextColor3=Color3.fromRGB(200,190,255) D_Info.BackgroundTransparency=0

local D_RefBtn=Instance.new("TextButton",T3)
D_RefBtn.Size=UDim2.new(1,0,0,28) D_RefBtn.Position=UDim2.new(0,0,0,34)
D_RefBtn.Text="↺  Jetzt manuell scannen" D_RefBtn.Font=Enum.Font.GothamBold D_RefBtn.TextSize=12
D_RefBtn.TextColor3=Color3.fromRGB(255,255,255) D_RefBtn.BackgroundColor3=Color3.fromRGB(28,55,130)
D_RefBtn.BorderSizePixel=0 Instance.new("UICorner",D_RefBtn).CornerRadius=UDim.new(0,7)

local D_Filter=Instance.new("Frame",T3)
D_Filter.Size=UDim2.new(1,0,0,28) D_Filter.Position=UDim2.new(0,0,0,66)
D_Filter.BackgroundColor3=Color3.fromRGB(16,13,28) D_Filter.BorderSizePixel=0
Instance.new("UICorner",D_Filter).CornerRadius=UDim.new(0,7)
local D_FBox=Instance.new("TextBox",D_Filter)
D_FBox.Size=UDim2.new(1,-12,1,-6) D_FBox.Position=UDim2.new(0,8,0,3)
D_FBox.PlaceholderText="Filter..." D_FBox.Text=""
D_FBox.Font=Enum.Font.Gotham D_FBox.TextSize=12 D_FBox.TextColor3=Color3.fromRGB(220,210,255)
D_FBox.PlaceholderColor3=Color3.fromRGB(80,75,120) D_FBox.BackgroundTransparency=1 D_FBox.ClearTextOnFocus=false

local DSc=Instance.new("ScrollingFrame",T3)
DSc.Size=UDim2.new(1,0,1,-100) DSc.Position=UDim2.new(0,0,0,98)
DSc.BackgroundColor3=Color3.fromRGB(12,10,22) DSc.BorderSizePixel=0
DSc.ScrollBarThickness=4 DSc.ScrollBarImageColor3=Color3.fromRGB(70,55,130)
DSc.AutomaticCanvasSize=Enum.AutomaticSize.Y DSc.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",DSc).CornerRadius=UDim.new(0,9)
local dLL=Instance.new("UIListLayout",DSc) dLL.Padding=UDim.new(0,2)
local dLP=Instance.new("UIPadding",DSc) dLP.PaddingAll=UDim.new(0,4)

local allDebugModels={}

local function BuildDebug(filter)
    for _,c in ipairs(DSc:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local n=0
    for _,entry in ipairs(allDebugModels) do
        local name=entry.rawName
        if filter=="" or name:lower():find(filter:lower(),1,true) then
            n=n+1 if n>150 then break end
            local isMatched=entry.dbEntry~=nil
            local col=isMatched and Color3.fromRGB(80,230,100) or Color3.fromRGB(180,140,60)
            local row=Instance.new("Frame",DSc) row.LayoutOrder=n
            row.Size=UDim2.new(1,-8,0,26) row.BackgroundColor3=Color3.fromRGB(14,12,24) row.BorderSizePixel=0
            Instance.new("UICorner",row).CornerRadius=UDim.new(0,5)
            local nL=Instance.new("TextLabel",row) nL.Size=UDim2.new(0.65,0,1,0) nL.Position=UDim2.new(0,8,0,0)
            nL.Text=(isMatched and "✓ " or "? ") .. name
            nL.Font=Enum.Font.Gotham nL.TextSize=12 nL.TextColor3=col nL.BackgroundTransparency=1 nL.TextXAlignment=Enum.TextXAlignment.Left
            nL.TextTruncate=Enum.TextTruncate.AtEnd
            local tpB=Instance.new("TextButton",row) tpB.Size=UDim2.new(0,38,0,20) tpB.Position=UDim2.new(1,-44,0.5,-10)
            tpB.Text="TP" tpB.Font=Enum.Font.GothamBold tpB.TextSize=11 tpB.TextColor3=Color3.fromRGB(255,255,255)
            tpB.BackgroundColor3=Color3.fromRGB(32,65,140) tpB.BorderSizePixel=0
            Instance.new("UICorner",tpB).CornerRadius=UDim.new(0,4)
            local capCF=entry.cf
            tpB.MouseButton1Click:Connect(function() TP(capCF) end)
        end
    end
end

local function RunDebugScan(filter)
    allDebugModels={}
    local seen={}
    for _,obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj~=LP.Character and not seen[obj] then
            seen[obj]=true
            local root=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if root and obj.Name~="" and obj.Name~="Workspace" then
                local dbE=matchDB(obj.Name)
                table.insert(allDebugModels,{rawName=obj.Name, dbEntry=dbE, cf=root.CFrame})
            end
        end
    end
    -- Sort: Gematchte zuerst
    table.sort(allDebugModels,function(a,b)
        local am=a.dbEntry~=nil local bm=b.dbEntry~=nil
        if am~=bm then return am end
        return a.rawName<b.rawName
    end)
    BuildDebug(filter or "")
    D_RefBtn.Text="↺  "..#allDebugModels.." Models gefunden — erneut scannen"
end

D_RefBtn.MouseButton1Click:Connect(function() RunDebugScan(D_FBox.Text) end)
D_FBox:GetPropertyChangedSignal("Text"):Connect(function() BuildDebug(D_FBox.Text) end)

-- ================================================================
--  TAB SWITCHING
-- ================================================================
local function SetTab(n)
    T1.Visible=(n==1) T2.Visible=(n==2) T3.Visible=(n==3)
    local tabs={TB1,TB2,TB3}
    for i,btn in ipairs(tabs) do
        btn.BackgroundColor3=(i==n) and Color3.fromRGB(36,50,140) or Color3.fromRGB(20,18,34)
        btn.TextColor3=(i==n) and Color3.fromRGB(220,210,255) or Color3.fromRGB(140,130,180)
    end
end
TB1.MouseButton1Click:Connect(function() SetTab(1) end)
TB2.MouseButton1Click:Connect(function() SetTab(2) end)
TB3.MouseButton1Click:Connect(function() SetTab(3) end)
SetTab(1)

-- ================================================================
--  MAIN LOOP
-- ================================================================
local SCAN_IV   = 1.0   -- Scan-Interval (Sekunden)
local SNIPE_IV  = 0.8
local CD_IV     = 0.4
local lastScan  = 0
local lastSnipe = 0
local lastCD    = 0
local maxCDVal  = 0

RunService.Heartbeat:Connect(function()
    local now=tick()

    -- ── Countdown ──────────────────────────────────────────────
    if now-lastCD>=CD_IV then
        lastCD=now
        local ok,lbl,sec=pcall(FindCountdown)
        if ok and lbl and sec and sec>0 then
            if sec>maxCDVal then maxCDVal=sec end
            local pct=maxCDVal>0 and (sec/maxCDVal) or 1
            PBar.Size=UDim2.new(math.max(0,math.min(1,pct)),0,1,0)
            local cs=string.format("%ds",sec)
            CDLbl.Text="⏱ "..cs
            SpawnLbl.Text="⏱ Wiederbeleben in "..cs
            if sec<=10 then
                PBar.BackgroundColor3=Color3.fromRGB(255,60,60)
                SpawnLbl.TextColor3=Color3.fromRGB(255,100,100)
                CDLbl.TextColor3=Color3.fromRGB(255,100,100)
            elseif sec<=20 then
                PBar.BackgroundColor3=Color3.fromRGB(255,160,40)
                SpawnLbl.TextColor3=Color3.fromRGB(255,200,60)
                CDLbl.TextColor3=Color3.fromRGB(255,200,60)
            else
                PBar.BackgroundColor3=Color3.fromRGB(80,220,100)
                SpawnLbl.TextColor3=Color3.fromRGB(255,200,60)
                CDLbl.TextColor3=Color3.fromRGB(255,200,60)
            end
        else
            CDLbl.Text="⏱ --s"
            SpawnLbl.Text="⏱ Countdown nicht gefunden"
        end
    end

    -- ── Scanner ────────────────────────────────────────────────
    if now-lastScan>=SCAN_IV then
        lastScan=now
        local ok,matched,unmatched=pcall(ScanAll)
        if ok then
            cachedMatch=matched cachedUnmatch=unmatched
            local hash=""
            for _,e in ipairs(matched) do hash=hash..e.rawName end
            if hash~=lastHash then
                lastHash=hash
                RefreshT1(matched)
            end
            StatLbl.Text="● Aktiv  "..os.date("%H:%M:%S")
        else
            StatLbl.Text="● Err: "..(tostring(matched):sub(1,25))
        end
    end

    -- ── Sniper ─────────────────────────────────────────────────
    if sniperActive and now-lastSnipe>=SNIPE_IV then
        lastSnipe=now
        if #watchList>0 and #cachedMatch>0 then
            local best=nil
            for _,entry in ipairs(cachedMatch) do
                for _,wn in ipairs(watchList) do
                    if entry.data.name:lower()==wn:lower() then
                        if not best or entry.data.rarity>best.data.rarity then best=entry end
                        break
                    end
                end
            end
            if best and now-lastTpTime>3 then
                lastTpTime=now PlayAlert() TP(best.cf)
            end
        end
    end
end)

-- Initial Debug-Scan beim Laden
task.delay(2, function() RunDebugScan("") end)

print("[FIU v4] ✓ Geladen — Tab 3 (Debug) zeigt alle Models im Workspace!")
print("[FIU v4] Tipp: Gehe in den Junkyard und öffne Tab 3 um Auto-Namen zu sehen.")
