local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

-- NEUE DATENBANK BASIEREND AUF DEINER LISTE
local CarDatabase = {
    -- EPISCH (0,02% - 0,5%)
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Merquis SLX"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Fia-Te 10026p"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Toyoda AFF67"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Auidy RF3 Limousine"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Lokswag Brasiuiu"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi V8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K5 e60"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Ratos Rotos Esporte"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi RF3"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    
    -- SELTEN (1% - 3%)
    ["Chule Camarao"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Four Rex"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Audi V5"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Merquis Z73"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["BNV K3 e92"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Lokswag Golo GT"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Toyoda Yapp"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["BNV K5 e39"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    
    -- HÄUFIGER (6% - 15%)
    ["Four Traffic"] = {Rarity = "Ungewöhnlich", Color = Color3.fromRGB(0, 255, 0)},
    ["Merquis C203"] = {Rarity = "Ungewöhnlich", Color = Color3.fromRGB(0, 255, 0)},
    ["Toyoda Hellox"] = {Rarity = "Ungewöhnlich", Color = Color3.fromRGB(0, 255, 0)},
    ["Leskus not200"] = {Rarity = "Nutzfahrzeug", Color = Color3.fromRGB(255, 255, 255)},
    ["BNV K3"] = {Rarity = "Standard", Color = Color3.fromRGB(255, 255, 255)},
    ["Holde Ciwiq"] = {Rarity = "Standard", Color = Color3.fromRGB(255, 255, 255)},
    ["Audi V4"] = {Rarity = "Standard", Color = Color3.fromRGB(255, 255, 255)},
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local TrackedObjects = {}

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! Junk-Elite",
   LoadingTitle = "Lade neue Autoliste...",
})

local RadarTab = Window:CreateTab("Live-Radar", 4483362458)
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)

AutoBuyTab:CreateToggle({
   Name = "MASTER AUTO-BUY AKTIVIEREN",
   CurrentValue = false,
   Callback = function(Value) AutoBuyActive = Value end,
})

for carName, _ in pairs(CarDatabase) do
    AutoBuyTab:CreateToggle({
       Name = carName,
       CurrentValue = false,
       Callback = function(Value) SelectedForAutoBuy[carName] = Value end,
    })
end

local function CheckAndTrack(obj)
    if obj:IsA("Model") then
        for dbName, data in pairs(CarDatabase) do
            if string.find(obj.Name, dbName) then
                -- 1. Highlight
                if not obj:FindFirstChild("EliteHighlight") then
                    local hl = Instance.new("Highlight", obj)
                    hl.Name = "EliteHighlight"
                    hl.OutlineColor = data.Color
                    hl.FillTransparency = 0.8
                end
                
                -- 2. Radar Button
                if not TrackedObjects[obj] then
                    RadarTab:CreateButton({
                       Name = "ZU: " .. obj.Name .. " [" .. data.Rarity .. "]",
                       Callback = function() 
                           local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                           if hrp then hrp.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0) end
                       end,
                    })
                    TrackedObjects[obj] = true
                end

                -- 3. Auto-Buy
                if AutoBuyActive and SelectedForAutoBuy[dbName] then
                    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0) end
                end
            end
        end
    end
end

-- EFFIZIENTER SCANNER: Reagiert nur auf Änderungen im Workspace
workspace.ChildAdded:Connect(CheckAndTrack)

-- Initialer Scan beim Start (nur 1x)
for _, child in pairs(workspace:GetChildren()) do
    CheckAndTrack(child)
end

Rayfield:Notify({
   Title = "Scanner Bereit",
   Content = "Die neue Autoliste wurde geladen. Viel Erfolg im Junkyard!",
   Duration = 5,
})
