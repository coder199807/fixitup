-- ================================================================
--  Fix It Up — KONSOLEN DIAGNOSE (kein GUI nötig)
--  Output erscheint in der Xeno Konsole / Developer Console (F9)
--  Einfach ausführen und Konsole aufmachen!
-- ================================================================

local WS      = game:GetService("Workspace")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

print("===========================================")
print("  FIU DIAGNOSE START")
print("===========================================")
print("PlaceId: " .. tostring(game.PlaceId))
print("GameId:  " .. tostring(game.GameId))
print("")

-- ── 1. Alle direkten Workspace-Kinder ───────────────────────
print("--- WORKSPACE DIREKTE KINDER ---")
for _, obj in ipairs(WS:GetChildren()) do
    local info = "[" .. obj.ClassName .. "] \"" .. obj.Name .. "\""
    if obj:IsA("Model") or obj:IsA("BasePart") then
        local root = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
        if root then
            info = info .. string.format("  pos=(%.0f,%.0f,%.0f)", root.Position.X, root.Position.Y, root.Position.Z)
        end
        info = info .. "  children=" .. #obj:GetChildren()
    end
    print(info)
end
print("")

-- ── 2. Folder-Inhalte (Autos sind oft in Folders) ───────────
print("--- FOLDER INHALTE ---")
for _, obj in ipairs(WS:GetChildren()) do
    if obj:IsA("Folder") then
        print("  FOLDER: \"" .. obj.Name .. "\" hat " .. #obj:GetChildren() .. " Kinder")
        for i, child in ipairs(obj:GetChildren()) do
            if i > 20 then print("    ... (mehr als 20, abgekürzt)") break end
            local root = child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")) or nil
            local pos = root and string.format(" pos=(%.0f,%.0f,%.0f)", root.Position.X, root.Position.Y, root.Position.Z) or ""
            print("    [" .. child.ClassName .. "] \"" .. child.Name .. "\"" .. pos)
        end
    end
end
print("")

-- ── 3. Models in Models (verschachtelt) ─────────────────────
print("--- MODELS IN MODELS (verschachtelt) ---")
for _, obj in ipairs(WS:GetChildren()) do
    if obj:IsA("Model") and obj ~= LP.Character then
        local subModels = 0
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Model") then subModels = subModels + 1 end
        end
        if subModels > 0 then
            print("  MODEL \"" .. obj.Name .. "\" enthält " .. subModels .. " Sub-Models:")
            for i, child in ipairs(obj:GetChildren()) do
                if child:IsA("Model") then
                    local root = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                    local pos = root and string.format(" pos=(%.0f,%.0f,%.0f)", root.Position.X, root.Position.Y, root.Position.Z) or ""
                    print("    └ [Model] \"" .. child.Name .. "\"" .. pos)
                end
            end
        end
    end
end
print("")

-- ── 4. Alle TextLabels mit Zahlen (Countdown) ───────────────
print("--- TEXTLABELS MIT ZAHLEN (Countdowns) ---")
local cdCount = 0
for _, obj in ipairs(WS:GetDescendants()) do
    if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text ~= "" then
        local t = obj.Text:gsub("\n", " ")
        if t:match("%d") then
            cdCount = cdCount + 1
            local p1 = obj.Parent and obj.Parent.Name or "?"
            local p2 = (obj.Parent and obj.Parent.Parent) and obj.Parent.Parent.Name or "?"
            print(string.format("  [WS-Text] \"%s\"  (in: %s > %s)", t:sub(1,60), p1, p2))
            if cdCount >= 30 then print("  ... (max 30 gezeigt)") break end
        end
    end
end

-- PlayerGui Texte
local pg = LP:FindFirstChildOfClass("PlayerGui")
if pg then
    for _, obj in ipairs(pg:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text ~= "" then
            local t = obj.Text:gsub("\n"," ")
            if t:match("%d") and #t < 100 then
                cdCount = cdCount + 1
                print(string.format("  [GUI-Text] \"%s\"  (in: %s)", t:sub(1,60), obj.Parent and obj.Parent.Name or "?"))
                if cdCount >= 60 then break end
            end
        end
    end
end
print("  Total Texte mit Zahlen: " .. cdCount)
print("")

-- ── 5. ReplicatedStorage ────────────────────────────────────
print("--- REPLICATED STORAGE ---")
local ok, RS = pcall(function() return game:GetService("ReplicatedStorage") end)
if ok then
    for _, obj in ipairs(RS:GetChildren()) do
        print("  [" .. obj.ClassName .. "] \"" .. obj.Name .. "\"  children=" .. #obj:GetChildren())
    end
    print("  -- RemoteEvents/Functions:")
    for _, obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
            local path = obj.Name
            local p = obj.Parent
            while p and p ~= RS do
                path = p.Name .. "/" .. path
                p = p.Parent
            end
            print("  [" .. obj.ClassName .. "] " .. path)
        end
    end
end
print("")

-- ── 6. Player Character Info ────────────────────────────────
print("--- PLAYER INFO ---")
local char = LP.Character
if char then
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        print(string.format("  Spieler Position: (%.1f, %.1f, %.1f)", hrp.Position.X, hrp.Position.Y, hrp.Position.Z))
    end
end
print("  LocalPlayer Name: " .. LP.Name)

-- ── 7. Alle Models im gesamten Workspace (GetDescendants) ───
print("")
print("--- ALLE MODELS IM WORKSPACE (GetDescendants, max 80) ---")
local modelList = {}
for _, obj in ipairs(WS:GetDescendants()) do
    if obj:IsA("Model") and obj ~= LP.Character and obj.Name ~= "Workspace" then
        local root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if root then
            table.insert(modelList, {
                name = obj.Name,
                pos  = root.Position,
                path = obj:GetFullName()
            })
        end
    end
end
table.sort(modelList, function(a,b) return a.name < b.name end)
for i, m in ipairs(modelList) do
    if i > 80 then print("  ... und " .. (#modelList-80) .. " weitere") break end
    print(string.format("  [Model] \"%s\"  pos=(%.0f,%.0f,%.0f)  path=%s",
        m.name, m.pos.X, m.pos.Y, m.pos.Z, m.path))
end
print("")

-- ── 8. Parts mit 'ClickDetector' (Kauf-Mechanismus) ─────────
print("--- CLICKDETECTORS (Kauf-Mechanismus) ---")
local clickCount = 0
for _, obj in ipairs(WS:GetDescendants()) do
    if obj:IsA("ClickDetector") then
        clickCount = clickCount + 1
        local p = obj.Parent
        local pp = p and p.Parent
        print(string.format("  ClickDetector in: \"%s\" > \"%s\" > \"%s\"",
            obj.Name,
            p and p.Name or "?",
            pp and pp.Name or "?"))
        if clickCount >= 20 then print("  ... (max 20)") break end
    end
end
if clickCount == 0 then print("  Keine ClickDetectors gefunden") end
print("")

-- ── 9. ProximityPrompts (neuerer Kauf-Mechanismus) ──────────
print("--- PROXIMITYPROMPTS ---")
local ppCount = 0
for _, obj in ipairs(WS:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        ppCount = ppCount + 1
        local p = obj.Parent
        local pp = p and p.Parent
        print(string.format("  ProximityPrompt \"%s\" ActionText:\"%s\"  in: \"%s\" > \"%s\"",
            obj.Name, obj.ActionText or "",
            p and p.Name or "?",
            pp and pp.Name or "?"))
        if ppCount >= 20 then print("  ... (max 20)") break end
    end
end
if ppCount == 0 then print("  Keine ProximityPrompts gefunden") end

print("")
print("===========================================")
print("  DIAGNOSE FERTIG")
print("  Öffne die Developer Console (F9 im Spiel)")
print("  oder schau in die Xeno Konsole!")
print("===========================================")
