local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Datenbank (Hier alle Namen EXAKT wie im Spiel eintragen)
local CarDatabase = {
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    -- ... (füge hier die anderen ein)
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local TrackedObjects = {}

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! Smooth Hub",
   LoadingTitle = "Optimierung aktiv...",
})

local RadarTab = Window:CreateTab("Live-Radar", 4483362458)
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)

AutoBuyTab:CreateToggle({
   Name = "MASTER AUTO-BUY",
   CurrentValue = false,
   Callback = function(Value) AutoBuyActive = Value end,
})

-- Auswahl-Liste
for carName, _ in pairs(CarDatabase) do
    AutoBuyTab:CreateToggle({
       Name = carName,
       CurrentValue = false,
       Callback = function(Value) SelectedForAutoBuy[carName] = Value end,
    })
end

-- OPTIMIERTE SCAN-LOGIK
task.spawn(function()
    while task.wait(1.5) do -- Höheres Intervall reduziert Lag massiv
        -- Wir suchen gezielt in 'workspace', aber weniger tief
        for _, obj in pairs(workspace:GetChildren()) do 
            -- Falls die Autos in einem Ordner wie 'Vehicles' sind, 
            -- änder 'workspace' oben zu 'workspace.Vehicles'
            
            if obj:IsA("Model") and CarDatabase[obj.Name] then
                
                -- Highlight nur einmal setzen
                if not obj:FindFirstChild("EliteHighlight") then
                    local hl = Instance.new("Highlight", obj)
                    hl.Name = "EliteHighlight"
                    hl.OutlineColor = CarDatabase[obj.Name].Color
                    hl.FillTransparency = 0.7
                end

                -- Radar Button erstellen (nur falls noch nicht da)
                if not TrackedObjects[obj] then
                    RadarTab:CreateButton({
                       Name = "ZU: " .. obj.Name,
                       Callback = function() 
                           game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0,5,0)
                       end,
                    })
                    TrackedObjects[obj] = true
                end

                -- Auto-Buy Teleport
                if AutoBuyActive and SelectedForAutoBuy[obj.Name] then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0,5,0)
                    task.wait(3) -- Sicherheits-Pause
                end
            end
        end
    end
end)
