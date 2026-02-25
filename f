local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

-- ERWEITERTE DATENBANK (image_a819be.png)
local CarDatabase = {
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Merquis SLX"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Chule Curgete"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Auidy RF3 Limousine"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi V8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K5 e60"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local TrackedObjects = {}

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! Elite Hybrid",
   LoadingTitle = "Initialisiere High-Speed Scan...",
})

local RadarTab = Window:CreateTab("Radar & ESP", 4483362458)
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)

AutoBuyTab:CreateToggle({Name = "MASTER AUTO-BUY", CurrentValue = false, Callback = function(v) AutoBuyActive = v end})

for name, _ in pairs(CarDatabase) do
    AutoBuyTab:CreateToggle({Name = name, CurrentValue = false, Callback = function(v) SelectedForAutoBuy[name] = v end})
end

-- Funktion zum Erstellen eines Info-Schilds (aus deinem Beispiel-Script)
local function createInfoTag(car, name, color)
    if car:FindFirstChild("Body") and not car.Body:FindFirstChild("EliteTag") then
        local bbg = Instance.new("BillboardGui", car.Body)
        bbg.Name = "EliteTag"
        bbg.AlwaysOnTop = true
        bbg.Size = UDim2.new(0, 200, 0, 50)
        bbg.StudsOffset = Vector3.new(0, 3, 0)
        
        local label = Instance.new("TextLabel", bbg)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "★ " .. name .. " ★"
        label.TextColor3 = color
        label.TextSize = 18
        label.Font = Enum.Font.GothamBold
    end
end

-- Deep-Identification (Kombiniert deinen Explorer mit dem neuen Beispiel)
local function getRealName(model)
    local values = model:FindFirstChild("Values")
    if not values then return nil end
    
    -- Wir prüfen den Cache-Ordner vom Screenshot
    local cache = values:FindFirstChild("Cache")
    local checkFolder = cache or values
    
    for _, item in pairs(checkFolder:GetChildren()) do
        if item:IsA("StringValue") then
            for dbName, _ in pairs(CarDatabase) do
                if string.find(item.Value, dbName) or string.find(item.Name, dbName) then
                    return dbName
                end
            end
        end
    end
    -- Fallback: Check Modell-Name (falls das Spiel ihn doch dort speichert)
    for dbName, _ in pairs(CarDatabase) do
        if string.find(model.Name, dbName) then return dbName end
    end
    return nil
end

local function ProcessVehicle(obj)
    if not obj:IsA("Model") or TrackedObjects[obj] then return end
    
    task.wait(0.5) -- Kurz warten, bis die 'Values' vom Server gesendet wurden
    local name = getRealName(obj)
    
    if name then
        local data = CarDatabase[name]
        TrackedObjects[obj] = true
        
        -- 1. Visuelles ESP & Highlight
        local hl = Instance.new("Highlight", obj)
        hl.FillColor = data.Color
        hl.OutlineColor = Color3.new(1, 1, 1)
        createInfoTag(obj, name, data.Color)
        
        -- 2. Radar Button
        RadarTab:CreateButton({
           Name = "TELEPORT: " .. name,
           Callback = function() 
               game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0)
           end,
        })
        
        -- 3. Auto-Buy
        if AutoBuyActive and SelectedForAutoBuy[name] then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0)
            -- Hier könnte man ein Event feuern, falls wir das exakte CarPurchase Event kennen
        end
    end
end

-- Starten der Überwachung im Vehicles-Ordner
local vFolder = workspace:FindFirstChild("Vehicles")
if vFolder then
    vFolder.ChildAdded:Connect(ProcessVehicle)
    for _, c in pairs(vFolder:GetChildren()) do ProcessVehicle(c) end
end
