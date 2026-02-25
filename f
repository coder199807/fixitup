-- ================================================================
--  Fix It Up — DIAGNOSE SCRIPT
--  Führe dieses Script aus WÄHREND Autos gespawnt sind!
--  Es zeigt dir GENAU was im Workspace ist und wie alles heißt.
-- ================================================================

local Players  = game:GetService("Players")
local WS       = game:GetService("Workspace")
local LP       = Players.LocalPlayer

-- GUI aufbauen
pcall(function()
    for _, g in ipairs(LP.PlayerGui:GetChildren()) do
        if g.Name == "FIU_DIAG" then g:Destroy() end
    end
end)

local GUI = Instance.new("ScreenGui")
GUI.Name = "FIU_DIAG"
GUI.ResetOnSpawn = false
GUI.Parent = LP.PlayerGui

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 600, 0, 700)
Main.Position = UDim2.new(0, 10, 0, 10)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 36)
Title.Text = "🔍 FIU DIAGNOSE — Drücke SCAN um alle Objekte zu sehen"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextColor3 = Color3.fromRGB(255, 220, 80)
Title.BackgroundColor3 = Color3.fromRGB(16, 14, 28)
Title.BorderSizePixel = 0
Title.BackgroundTransparency = 0
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local ScanBtn = Instance.new("TextButton", Main)
ScanBtn.Size = UDim2.new(0.48, 0, 0, 32)
ScanBtn.Position = UDim2.new(0, 8, 0, 40)
ScanBtn.Text = "▶ ALLES SCANNEN"
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.TextSize = 13
ScanBtn.TextColor3 = Color3.fromRGB(255,255,255)
ScanBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 200)
ScanBtn.BorderSizePixel = 0
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 7)

local CDBtn = Instance.new("TextButton", Main)
CDBtn.Size = UDim2.new(0.48, 0, 0, 32)
CDBtn.Position = UDim2.new(0.52, -8, 0, 40)
CDBtn.Text = "⏱ COUNTDOWN SUCHEN"
CDBtn.Font = Enum.Font.GothamBold
CDBtn.TextSize = 12
CDBtn.TextColor3 = Color3.fromRGB(255,255,255)
CDBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
CDBtn.BorderSizePixel = 0
Instance.new("UICorner", CDBtn).CornerRadius = UDim.new(0, 7)

local FilterBg = Instance.new("Frame", Main)
FilterBg.Size = UDim2.new(1, -16, 0, 28)
FilterBg.Position = UDim2.new(0, 8, 0, 76)
FilterBg.BackgroundColor3 = Color3.fromRGB(18, 16, 30)
FilterBg.BorderSizePixel = 0
Instance.new("UICorner", FilterBg).CornerRadius = UDim.new(0, 6)

local FilterBox = Instance.new("TextBox", FilterBg)
FilterBox.Size = UDim2.new(1,-10,1,-6)
FilterBox.Position = UDim2.new(0,6,0,3)
FilterBox.PlaceholderText = "Filter (z.B. 'Car', 'Vehicle', 'Model'...)"
FilterBox.Text = ""
FilterBox.Font = Enum.Font.Gotham
FilterBox.TextSize = 12
FilterBox.TextColor3 = Color3.fromRGB(220,210,255)
FilterBox.PlaceholderColor3 = Color3.fromRGB(90,85,130)
FilterBox.BackgroundTransparency = 1
FilterBox.ClearTextOnFocus = false

local InfoLbl = Instance.new("TextLabel", Main)
InfoLbl.Size = UDim2.new(1,-16, 0, 24)
InfoLbl.Position = UDim2.new(0, 8, 0, 108)
InfoLbl.Text = "Noch nicht gescannt. Drücke ALLES SCANNEN."
InfoLbl.Font = Enum.Font.Gotham
InfoLbl.TextSize = 11
InfoLbl.TextColor3 = Color3.fromRGB(160, 150, 200)
InfoLbl.BackgroundTransparency = 1
InfoLbl.TextXAlignment = Enum.TextXAlignment.Left

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1,-16, 1, -140)
Scroll.Position = UDim2.new(0, 8, 0, 136)
Scroll.BackgroundColor3 = Color3.fromRGB(12,10,20)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 5
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80,70,140)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 8)
local LL = Instance.new("UIListLayout", Scroll)
LL.Padding = UDim.new(0,2)
LL.SortOrder = Enum.SortOrder.LayoutOrder
local LP2 = Instance.new("UIPadding", Scroll)
LP2.PaddingAll = UDim.new(0, 4)

-- Alle gefundenen Objekte zwischenspeichern
local allEntries = {}

local function makeEntry(parent, text, col, idx, cf, tpable)
    local row = Instance.new("Frame", parent)
    row.LayoutOrder = idx
    row.Size = UDim2.new(1,-8, 0, 24)
    row.BackgroundColor3 = Color3.fromRGB(15,12,24)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,4)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = tpable and UDim2.new(1,-50,1,0) or UDim2.new(1,-8,1,0)
    lbl.Position = UDim2.new(0,6,0,0)
    lbl.Text = text
    lbl.Font = Enum.Font.Code  -- Monospace für bessere Lesbarkeit
    lbl.TextSize = 11
    lbl.TextColor3 = col
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd

    if tpable and cf then
        local tp = Instance.new("TextButton", row)
        tp.Size = UDim2.new(0,40,0,18)
        tp.Position = UDim2.new(1,-44,0.5,-9)
        tp.Text = "TP"
        tp.Font = Enum.Font.GothamBold
        tp.TextSize = 10
        tp.TextColor3 = Color3.fromRGB(255,255,255)
        tp.BackgroundColor3 = Color3.fromRGB(30,60,140)
        tp.BorderSizePixel = 0
        Instance.new("UICorner",tp).CornerRadius = UDim.new(0,4)
        local capCF = cf
        tp.MouseButton1Click:Connect(function()
            local ch = LP.Character
            if ch and ch:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    ch.HumanoidRootPart.CFrame = capCF + Vector3.new(0,5,0)
                end)
            end
        end)
    end
    return row
end

local function header(parent, txt, idx, bgcol)
    local row = Instance.new("Frame", parent)
    row.LayoutOrder = idx
    row.Size = UDim2.new(1,-8,0,22)
    row.BackgroundColor3 = bgcol or Color3.fromRGB(25,20,45)
    row.BorderSizePixel = 0
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,4)
    local l = Instance.new("TextLabel",row)
    l.Size = UDim2.new(1,-8,1,0) l.Position = UDim2.new(0,6,0,0)
    l.Text = txt l.Font = Enum.Font.GothamBold l.TextSize = 11
    l.TextColor3 = Color3.fromRGB(255,220,80) l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function rebuildDisplay(filter)
    for _, c in ipairs(Scroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local n = 0
    local shown = 0
    for _, e in ipairs(allEntries) do
        n = n + 1
        local show = filter == "" or e.text:lower():find(filter:lower(), 1, true)
        if show then
            shown = shown + 1
            if shown <= 300 then
                makeEntry(Scroll, e.text, e.col, shown, e.cf, e.tpable)
            end
        end
    end
    InfoLbl.Text = string.format("Gesamt: %d Einträge | Angezeigt: %d (Filter: '%s')", n, math.min(shown,300), filter)
end

FilterBox:GetPropertyChangedSignal("Text"):Connect(function()
    rebuildDisplay(FilterBox.Text)
end)

-- ================================================================
--  HAUPTSCAN
-- ================================================================
ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "⏳ Scannt..."
    allEntries = {}
    local idx = 0

    -- ── 1. Workspace-Struktur (direkte Kinder) ──
    idx = idx + 1
    table.insert(allEntries, {
        text = "══ WORKSPACE DIREKTE KINDER ══",
        col  = Color3.fromRGB(255,220,80),
        tpable = false
    })

    local directChildren = WS:GetChildren()
    table.sort(directChildren, function(a,b) return a.ClassName < b.ClassName end)

    for _, obj in ipairs(directChildren) do
        idx = idx + 1
        local root = nil
        if obj:IsA("Model") then
            root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        elseif obj:IsA("BasePart") then
            root = obj
        end
        local pos = root and string.format(" @ (%.0f, %.0f, %.0f)", root.Position.X, root.Position.Y, root.Position.Z) or ""
        local childCount = #obj:GetChildren()
        local text = string.format("[%s] \"%s\"%s  [%d Kinder]", obj.ClassName, obj.Name, pos, childCount)
        local col = obj:IsA("Model") and Color3.fromRGB(100,200,255) or Color3.fromRGB(160,160,180)
        table.insert(allEntries, {text=text, col=col, cf=root and root.CFrame or nil, tpable=root~=nil})
    end

    -- ── 2. Alle Models 2 Ebenen tief ──
    idx = idx + 1
    table.insert(allEntries, {
        text = "══ ALLE MODELS (2 EBENEN TIEF) ══",
        col  = Color3.fromRGB(255,160,80),
        tpable = false
    })

    local modelCount = 0
    for _, child in ipairs(WS:GetChildren()) do
        -- Direkte Model-Kinder des Workspace
        if child:IsA("Model") and child ~= LP.Character then
            local root = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
            local pos = root and string.format(" @ (%.0f,%.0f,%.0f)", root.Position.X, root.Position.Y, root.Position.Z) or " @ ?"
            modelCount = modelCount + 1
            table.insert(allEntries, {
                text = string.format("  MODEL: \"%s\"%s", child.Name, pos),
                col  = Color3.fromRGB(80,220,120),
                cf   = root and root.CFrame or nil,
                tpable = root ~= nil
            })
            -- Kinder dieses Models
            for _, grandchild in ipairs(child:GetChildren()) do
                if grandchild:IsA("Model") then
                    local r2 = grandchild.PrimaryPart or grandchild:FindFirstChildWhichIsA("BasePart")
                    local p2 = r2 and string.format(" @ (%.0f,%.0f,%.0f)", r2.Position.X, r2.Position.Y, r2.Position.Z) or " @ ?"
                    modelCount = modelCount + 1
                    table.insert(allEntries, {
                        text = string.format("    └ MODEL: \"%s\"%s", grandchild.Name, p2),
                        col  = Color3.fromRGB(60,180,100),
                        cf   = r2 and r2.CFrame or nil,
                        tpable = r2 ~= nil
                    })
                end
            end
        end
        -- Folder mit Models darin
        if child:IsA("Folder") then
            local fmodels = 0
            for _, fm in ipairs(child:GetChildren()) do
                if fm:IsA("Model") and fm ~= LP.Character then
                    local root = fm.PrimaryPart or fm:FindFirstChildWhichIsA("BasePart")
                    local pos = root and string.format(" @ (%.0f,%.0f,%.0f)", root.Position.X, root.Position.Y, root.Position.Z) or " @ ?"
                    fmodels = fmodels + 1
                    modelCount = modelCount + 1
                    table.insert(allEntries, {
                        text = string.format("  [Folder:%s] MODEL: \"%s\"%s", child.Name, fm.Name, pos),
                        col  = Color3.fromRGB(180,220,80),
                        cf   = root and root.CFrame or nil,
                        tpable = root ~= nil
                    })
                end
            end
        end
    end

    -- ── 3. StringValues / IntValues die Fahrzeugnamen enthalten könnten ──
    table.insert(allEntries, {
        text = "══ STRING/INT VALUES MIT 'CAR'/'VEHICLE'/'AUTO' ══",
        col  = Color3.fromRGB(200,120,255),
        tpable = false
    })
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("ObjectValue") then
            local v = tostring(obj.Value or "")
            local n = obj.Name:lower()
            if n:find("car") or n:find("vehicle") or n:find("auto") or n:find("spawn") or n:find("model") then
                table.insert(allEntries, {
                    text = string.format("  [%s] Name:\"%s\" Value:\"%s\"  (in: %s)", obj.ClassName, obj.Name, v:sub(1,40), obj.Parent and obj.Parent.Name or "?"),
                    col  = Color3.fromRGB(200,150,255),
                    tpable = false
                })
            end
        end
    end

    -- ── 4. Countdown-Texte ──
    table.insert(allEntries, {
        text = "══ ALLE TEXTE MIT ZAHLEN (potenzielle Countdowns) ══",
        col  = Color3.fromRGB(255,200,60),
        tpable = false
    })
    local cdFound = 0
    -- In Workspace (SurfaceGui, BillboardGui)
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local t = obj.Text or ""
            if t:match("%d") and t ~= "" and #t < 80 then
                cdFound = cdFound + 1
                local parent = obj.Parent
                local pname = parent and parent.Name or "?"
                local ppname = (parent and parent.Parent) and parent.Parent.Name or "?"
                table.insert(allEntries, {
                    text = string.format("  [WS] \"%s\"  (in: %s > %s)", t:gsub("\n"," "), pname, ppname),
                    col  = Color3.fromRGB(255,220,80),
                    tpable = false
                })
            end
        end
    end
    -- In PlayerGui
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local t = obj.Text or ""
                if t:match("%d") and t ~= "" and #t < 80 and not t:match("^%s*$") then
                    cdFound = cdFound + 1
                    local parent = obj.Parent
                    local pname = parent and parent.Name or "?"
                    table.insert(allEntries, {
                        text = string.format("  [GUI] \"%s\"  (in: %s)", t:gsub("\n"," "), pname),
                        col  = Color3.fromRGB(255,200,100),
                        tpable = false
                    })
                end
            end
        end
    end

    -- ── 5. RemoteEvents/Functions (für Auto-Kauf) ──
    table.insert(allEntries, {
        text = "══ REMOTEEVENTS & REMOTEFUNCTIONS ══",
        col  = Color3.fromRGB(255,100,100),
        tpable = false
    })
    local RE = game:GetService("ReplicatedStorage")
    local function scanRemotes(container, prefix)
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                table.insert(allEntries, {
                    text = string.format("  [%s] %s/%s", obj.ClassName, prefix, obj.Name),
                    col  = Color3.fromRGB(255,120,120),
                    tpable = false
                })
            end
        end
    end
    pcall(scanRemotes, RE, "ReplicatedStorage")
    pcall(scanRemotes, WS, "Workspace")

    ScanBtn.Text = "▶ ERNEUT SCANNEN (" .. #allEntries .. " Einträge)"
    rebuildDisplay(FilterBox.Text)
end)

-- ================================================================
--  COUNTDOWN-SUCHE (detailliert)
-- ================================================================
CDBtn.MouseButton1Click:Connect(function()
    allEntries = {}

    table.insert(allEntries, {text="══ COUNTDOWN VOLLSUCHE ══", col=Color3.fromRGB(255,200,60), tpable=false})

    local patterns = {
        "SEKUNDEN", "sekunden", "Sekunden",
        "SECS", "secs",
        "SECONDS", "seconds",
        "Timer", "TIMER", "timer",
        "Countdown", "COUNTDOWN",
        "Spawn", "SPAWN",
        "Respawn", "RESPAWN",
        "WIEDERBELEBEN", "wiederbeleben",
    }

    local function checkAndAdd(obj, source)
        if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
        local t = obj.Text or ""
        if t == "" then return end
        local relevant = false
        for _, p in ipairs(patterns) do
            if t:find(p, 1, true) then relevant = true break end
        end
        if t:match("%d+") and #t < 100 then relevant = true end
        if relevant then
            local parent = obj.Parent
            local pname = parent and parent.Name or "?"
            local ppname = (parent and parent.Parent) and parent.Parent.Name or "?"
            table.insert(allEntries, {
                text = string.format("[%s] Text:\"%s\"  Obj:\"%s\"  Parent:\"%s\"  GParent:\"%s\"",
                    source, t:sub(1,50):gsub("\n"," "), obj.Name, pname, ppname),
                col = Color3.fromRGB(255,220,80),
                tpable = false
            })
        end
    end

    -- Workspace tief
    for _, obj in ipairs(WS:GetDescendants()) do
        pcall(checkAndAdd, obj, "WS")
    end

    -- PlayerGui
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetDescendants()) do
            pcall(checkAndAdd, obj, "GUI")
        end
    end

    -- StarterGui (falls vorhanden)
    pcall(function()
        local sg = game:GetService("StarterGui")
        for _, obj in ipairs(sg:GetDescendants()) do
            pcall(checkAndAdd, obj, "StarterGui")
        end
    end)

    rebuildDisplay("")
    InfoLbl.Text = "Countdown-Suche: " .. (#allEntries-1) .. " potenzielle Treffer"
end)

print("[FIU Diagnose] Bereit! Klicke 'ALLES SCANNEN' in der GUI.")
print("[FIU Diagnose] Tipp: Führe den Scan durch wenn Autos im Junkyard sind!")
