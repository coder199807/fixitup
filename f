local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

-- DATENBANK DER NAMEN (Zum Abgleichen der IDs)
local CarNames = {
    "BNV K3 F", "Skami Truk", "BNV K8", "Merquis SLX", "Chule Curgete", 
    "Fia-Te 10026p", "Auidy RF3 Limousine", "Audi V8", "BNV K5 e60", 
    "Audi RF3", "Chule Camarao", "Four Rex", "BNV K5 e39", "Peujo 400e6",
    "Vovo Sr60", "Lokswag Passar", "Sacode Oitava"
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local TrackedObjects = {}

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! ULTIMATE HYBRID",
   LoadingTitle = "Lerne Fahrzeug-IDs...",
})

local RadarTab = Window:CreateTab("Live-Radar", 4483362458)
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)

AutoBuyTab:CreateToggle({
   Name = "MASTER AUTO-BUY AKTIVIEREN",
   CurrentValue = false,
   Callback = function(Value) AutoBuyActive = Value end,
})

-- Erstelle Toggles für alle Autos in der Liste
for _, carName in pairs(CarNames) do
    AutoBuyTab:CreateToggle({
       Name = carName,
       CurrentValue = false,
       Callback = function(Value) SelectedForAutoBuy[carName] = Value end,
    })
end

-- FUNKTION: FINDET DEN ECHTEN NAMEN (Lernt aus dem Cache)
local function GetCarIdentity(model)
    local valuesFolder = model:FindFirstChild("Values")
    if not valuesFolder then return nil end

    -- Wir durchsuchen ALLES im Values-Ordner und im Cache-Unterordner
    -- Das ist die Lösung für die GUID-Namen (232c9107...)
    local allValues = valuesFolder:GetDescendants()
    for _, val in pairs(allValues) do
        if val:IsA("StringValue") then
            local text = val.Value
            for _, knownName in pairs(CarNames) do
                if string.find(string.lower(text), string.lower(knownName)) then
                    return knownName
                end
            end
        end
    end
    return nil
end

-- FUNKTION: ESP ERSTELLEN (Wie in deinem Beispiel-Script)
local function createESP(car, displayName)
    if car:FindFirstChild("Body") and not car.Body:FindFirstChild("CarESP") then
        local bbg = Instance.new("BillboardGui", car.Body)
        bbg.Name = "CarESP"
        bbg.AlwaysOnTop = true
        bbg.Size = UDim2.new(0, 150, 0, 50)
        bbg.StudsOffset = Vector3.new(0, 3, 0)
        
        local label = Instance.new("TextLabel", bbg)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "★ " .. displayName .. " ★"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 16
        label.Font = Enum.Font.GothamBold
        
        local highlight = Instance.new("Highlight", car)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    end
end

-- HAUPTLOGIK: VERARBEITUNG
local function ProcessVehicle(obj)
    if not obj:IsA("Model") or TrackedObjects[obj] then return end
    
    -- Warte kurz, bis die 'Values' vom Server repliziert wurden
    task.wait(0.8)
    
    local realName = GetCarIdentity(obj)
    
    -- Wenn wir den Namen gefunden haben, fügen wir ihn dem Radar hinzu
    if realName then
        TrackedObjects[obj] = true
        
        -- Radar Button
        RadarTab:CreateButton({
           Name = "GEFUNDEN: " .. realName,
           Callback = function() 
               if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                   game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0)
               end
           end,
        })
        
        -- ESP erzeugen
        createESP(obj, realName)
        
        -- Auto-Buy Teleport
        if AutoBuyActive and SelectedForAutoBuy[realName] then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0)
        end
    end
end

-- MONITOR: Überwache den Vehicles Ordner (Aus deinem Explorer-Pfad)
local vehiclesFolder = workspace:FindFirstChild("Vehicles")

if vehiclesFolder then
    -- Logik für neue Autos (wenn der Junkyard-Timer abläuft oder jemand kauft)
    vehiclesFolder.ChildAdded:Connect(function(child)
        ProcessVehicle(child)
    end)

    -- Scan für Autos, die bereits da sind
    for _, child in pairs(vehiclesFolder:GetChildren()) do
        task.spawn(function() ProcessVehicle(child) end)
    end
else
    Rayfield:Notify({
       Title = "Fehler",
       Content = "Ordner 'Workspace.Vehicles' nicht gefunden!",
       Duration = 10,
    })
end

Rayfield:Notify({
   Title = "Scanner Bereit",
   Content = "Warte auf Junkyard-Spawn...",
   Duration = 5,
})
