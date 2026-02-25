-- Sicherheits-Check für die Library
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Rayfield konnte nicht geladen werden! Überprüfe deine Internetverbindung oder den Link.")
    return
end

-- Datenbank (Beispiel-Auszug, bitte mit deiner Liste ergänzen)
local CarDatabase = {
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    -- ... hier die restlichen Autos einfügen
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! Premium Hub",
   LoadingTitle = "XENO Executor stabilisiert...",
   ConfigurationSaving = { Enabled = false } -- Deaktiviert für schnellere Ladezeit
})

-- TAB 1: LIVE RADAR
local RadarTab = Window:CreateTab("Live-Radar", 4483362458)
local RadarSection = RadarTab:CreateSection("Gespawnte Autos")

-- TAB 2: AUTO-BUY
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)
AutoBuyTab:CreateToggle({
   Name = "MASTER AUTO-BUY AKTIVIEREN",
   CurrentValue = false,
   Callback = function(Value) AutoBuyActive = Value end,
})

-- Hilfsfunktion für Teleport
local function SafeTeleport(model)
    local p = game.Players.LocalPlayer
    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local cf = model:GetModelCFrame()
        p.Character.HumanoidRootPart.CFrame = cf + Vector3.new(0, 5, 0)
    end
end

-- Erstellung der Auswahl-Liste
for carName, _ in pairs(CarDatabase) do
    AutoBuyTab:CreateToggle({
       Name = carName,
       CurrentValue = false,
       Callback = function(Value) SelectedForAutoBuy[carName] = Value end,
    })
end

-- ECHTZEIT LOGIK
task.spawn(function()
    while task.wait(0.5) do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and CarDatabase[obj.Name] then
                
                -- Highlighting
                if not obj:FindFirstChild("Highlight") then
                    local hl = Instance.new("Highlight", obj)
                    hl.OutlineColor = CarDatabase[obj.Name].Color
                    hl.FillTransparency = 0.8
                end

                -- Auto-Buy Check
                if AutoBuyActive and SelectedForAutoBuy[obj.Name] then
                    SafeTeleport(obj)
                    task.wait(1)
                end
            end
        end
    end
end)
