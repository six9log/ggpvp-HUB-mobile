-- [[ GGPVP MOBILE - SUPREME V4 | DELTA & KRNL OPTIMIZED ]]
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- No Mobile, usamos uma tecla padrão de toggle interna ou um botão flutuante se o executor permitir
local Window = Kavo.CreateLib("🎯 GGPVP MOBILE | by six", "DarkTheme")

--// SERVIÇOS
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--// CONFIGS
_G.Aimbot = false
_G.TargetPart = "Head"
_G.FovRadius = 120 
_G.FovVisible = true
_G.Smoothness = 0.5 
_G.WallCheck = true
_G.MaxDistance = 1000

_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 20

_G.ESP_Enabled = false
_G.ESP_Boxes = false
_G.ESP_Info = false
_G.Crashing = false

--// FOV CIRCLE (Desenho compatível com Mobile)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(0, 255, 255)

----------------------------------------------------
-- LÓGICA DE TARGET
----------------------------------------------------
local function IsVisible(part)
    if not _G.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, part.Parent}
    params.IgnoreWater = true
    
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
    return result == nil
end

local function GetClosestTarget()
    local target, shortest = nil, _G.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = p.Character[_G.TargetPart]
                local mag = (LP.Character.HumanoidRootPart.Position - part.Position).Magnitude
                if mag <= _G.MaxDistance then
                    local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
                    if onscreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            if IsVisible(part) then
                                shortest = dist
                                target = part
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

----------------------------------------------------
-- INTERFACE MOBILE
----------------------------------------------------
local Main = Window:NewTab("Combate")
local CombatSect = Main:NewSection("Aimbot Mobile")
CombatSect:NewToggle("Ativar Aimbot", "Mira automática", function(v) _G.Aimbot = v end)
CombatSect:NewToggle("Wall Check", "Não atravessa parede", function(v) _G.WallCheck = v end)
CombatSect:NewToggle("Ver FOV", "Círculo de alcance", function(v) _G.FovVisible = v end)

CombatSect:NewDropdown("Local do Alvo", "Focar em:", {"Head", "HumanoidRootPart"}, function(v)
    _G.TargetPart = v
end)

CombatSect:NewSlider("Tamanho FOV", "Raio", 500, 30, function(v) _G.FovRadius = v end)
CombatSect:NewSlider("Suavidade", "Mobile Smoothness", 100, 1, function(v) _G.Smoothness = v/100 end)

local Visuals = Window:NewTab("Visuals")
local VisualSect = Visuals:NewSection("ESP (Otimizado)")
VisualSect:NewToggle("Ativar ESP", "Ver através da parede", function(v) _G.ESP_Enabled = v end)
VisualSect:NewToggle("Caixas", "Boxes", function(v) _G.ESP_Boxes = v end)
VisualSect:NewToggle("Informações", "Nome e Vida", function(v) _G.ESP_Info = v end)

local Trol = Window:NewTab("Movimento")
Trol:NewSection("Velocidade"):NewSlider("WalkSpeed", "Correr", 200, 16, function(v) _G.Speed = v end)
Trol:NewSection("Voo (Fly)")
Trol:NewToggle("Ativar Fly", "Voar pelo mapa", function(v) _G.Fly = v end)
Trol:NewSlider("Velocidade Voo", "Fly Speed", 300, 10, function(v) _G.FlySpeed = v end)

local Config = Window:NewTab("Config")
-- No Mobile, adicionamos um botão para fechar a GUI manualmente, pois não há teclado.
Config:NewSection("Menu Mobile")
Config:NewButton("Minimizar Menu", "Esconde a interface", function()
    -- Comando padrão da Kavo para fechar
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
end)

Config:NewSection("Sair"):NewButton("Destruir Script", "Limpa tudo", function()
    _G.Aimbot = false; _G.ESP_Enabled = false; _G.FovVisible = false; _G.Crashing = false; FOVCircle:Destroy()
    pcall(function() CoreGui:FindFirstChild("🎯 GGPVP MOBILE | by six"):Destroy() end)
end)

----------------------------------------------------
-- LOOPS DE EXECUÇÃO
----------------------------------------------------

-- Loop de Mira e FOV
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.FovVisible
    FOVCircle.Radius = _G.FovRadius
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    if _G.Aimbot then
        local target = GetClosestTarget()
        if target then
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.Smoothness)
        end
    end
end)

-- Loop de Movimento (Mobile Fix)
RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if _G.Fly and root then
            if not root:FindFirstChild("FlyForce") then
                local bv = Instance.new("BodyVelocity", root)
                bv.Name = "FlyForce"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            -- No mobile, o voo segue a direção da câmera automaticamente
            root.FlyForce.Velocity = Camera.CFrame.LookVector * _G.FlySpeed
        elseif root and root:FindFirstChild("FlyForce") then
            root.FlyForce:Destroy()
        end
    end
end)

-- Sistema de ESP (Mesma lógica robusta)
local ESP_Table = {}
RunService.RenderStepped:Connect(function()
    if _G.ESP_Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not ESP_Table[p] then
                    ESP_Table[p] = {Box = Drawing.new("Square"), Text = Drawing.new("Text")}
                end
                local obj = ESP_Table[p]
                local char = p.Character
                local pos, on = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                
                if on then
                    local size = 2000/pos.Z
                    obj.Box.Visible = _G.ESP_Boxes
                    obj.Box.Size = Vector2.new(size, size*1.2)
                    obj.Box.Position = Vector2.new(pos.X-size/2, pos.Y-size/2)
                    obj.Box.Color = Color3.fromRGB(255,255,255)

                    obj.Text.Visible = _G.ESP_Info
                    obj.Text.Text = p.Name.." ["..math.floor(char.Humanoid.Health).."]"
                    obj.Text.Position = Vector2.new(pos.X, pos.Y-size/2-15)
                    obj.Text.Outline = true
                    obj.Text.Center = true
                else
                    obj.Box.Visible = false
                    obj.Text.Visible = false
                end
            end
        end
    else
        for _, v in pairs(ESP_Table) do v.Box.Visible = false; v.Text.Visible = false end
    end
end)
