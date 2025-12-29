-- [[ GGPVP MOBILE SUPREME V4 | TOTALMENTE REFORMULADO ]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🎯 GGPVP MOBILE", "Midnight")

--// REFERÊNCIA DA GUI
local KavoGui = game:GetService("CoreGui"):FindFirstChild("🎯 GGPVP MOBILE")

--// SERVIÇOS
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

--// CONFIGS INICIAIS
_G.Aimbot = false
_G.FovRadius = 100
_G.FovVisible = true
_G.Smoothness = 0.1 -- Valor baixo para ser "Legit"
_G.WallCheck = true -- Se falso, gruda através da parede
_G.TargetPart = "Head"

_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 50

_G.ESP_Box = false
_G.ESP_Name = false

----------------------------------------------------
-- BOTÃO FLUTUANTE DE MINIMIZAR
----------------------------------------------------
local MobileBtn = Instance.new("ScreenGui", game:GetService("CoreGui"))
local ToggleBtn = Instance.new("TextButton", MobileBtn)
local UICorner = Instance.new("UICorner", ToggleBtn)

ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Text = "MENU"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Draggable = true
UICorner.CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    if KavoGui then
        KavoGui.Enabled = not KavoGui.Enabled
    end
end)

----------------------------------------------------
-- FOV CIRCLE (APENAS LINHA)
----------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

----------------------------------------------------
-- LÓGICA DE COMBATE & WALLCHECK
----------------------------------------------------
local function IsVisible(part)
    if not _G.WallCheck then return true end
    local cast = Camera:GetPartsObscuringTarget({part.Position}, {LP.Character, part.Parent})
    return #cast == 0
end

local function GetClosestTarget()
    local target = nil
    local shortest = _G.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = p.Character[_G.TargetPart]
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
    return target
end

----------------------------------------------------
-- INTERFACE (TABS)
----------------------------------------------------

-- ABA 1: COMBATE
local Combat = Window:NewTab("Combate")
local AimSect = Combat:NewSection("Aimbot Settings")

AimSect:NewToggle("Ativar Aimbot", "Puxa e Mira", function(v) _G.Aimbot = v end)
AimSect:NewToggle("Wall Check", "Se OFF, gruda na parede", function(v) _G.WallCheck = v end)
AimSect:NewToggle("Mostrar Círculo FOV", "", function(v) _G.FovVisible = v end)
AimSect:NewSlider("Raio do FOV", "", 500, 50, function(v) _G.FovRadius = v end)
AimSect:NewSlider("Suavidade (Smooth)", "Legit: 0.1 a 0.3", 100, 1, function(v) _G.Smoothness = v/100 end)

-- ABA 2: ESP (SEPARADA)
local Visuals = Window:NewTab("ESP")
local EspSect = Visuals:NewSection("Visualização")

EspSect:NewToggle("ESP Box", "Quadrados nos inimigos", function(v) _G.ESP_Box = v end)
EspSect:NewToggle("ESP Names", "Nome dos inimigos", function(v) _G.ESP_Name = v end)

-- ABA 3: MOVIMENTO
local Move = Window:NewTab("Movimento")
local MoveSect = Move:NewSection("Speed & Fly")

-- NOVO SISTEMA DE SPEED: Digite o valor para travar
MoveSect:NewTextBox("Velocidade (1 a 50)", "Digite e aperte Enter", function(txt)
    local num = tonumber(txt)
    if num then _G.Speed = num end
end)

MoveSect:NewToggle("Ativar Fly", "Voo Mobile", function(v) _G.Fly = v end)
MoveSect:NewSlider("Fly Speed", "", 300, 20, function(v) _G.FlySpeed = v end)

----------------------------------------------------
-- SISTEMA DE ESP (BOX & NAME)
----------------------------------------------------
local function CreateESP(plr)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Thickness = 1
    Box.Filled = false

    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Color = Color3.fromRGB(255, 255, 255)
    Name.Size = 14
    Name.Center = true
    Name.Outline = true

    RunService.RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local rppos, onscreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            
            if onscreen and ( _G.ESP_Box or _G.ESP_Name ) then
                local head = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                local size = (Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)).Y - head.Y)
                
                if _G.ESP_Box then
                    Box.Visible = true
                    Box.Size = Vector2.new(size * 1.5, size * 1.8)
                    Box.Position = Vector2.new(rppos.X - Box.Size.X / 2, rppos.Y - Box.Size.Y / 2)
                else Box.Visible = false end

                if _G.ESP_Name then
                    Name.Visible = true
                    Name.Text = plr.Name
                    Name.Position = Vector2.new(rppos.X, rppos.Y - (Box.Size.Y / 2) - 15)
                else Name.Visible = false end
            else
                Box.Visible = false
                Name.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
        end
    end)
end

-- Inicia ESP para quem entrar
for _, p in pairs(Players:GetPlayers()) do if p ~= LP then CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LP then CreateESP(p) end end)

----------------------------------------------------
-- LOOPS FINAIS
----------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- Update FOV
    FOVCircle.Visible = _G.FovVisible
    FOVCircle.Radius = _G.FovRadius
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Aimbot Smooth
    if _G.Aimbot then
        local target = GetClosestTarget()
        if target then
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.Smoothness)
        end
    end
end)

-- Trava de WalkSpeed (Heartbeat é mais forte que o reset do jogo)
RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        
        -- Fly
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if _G.Fly and root then
            if not root:FindFirstChild("FlyForce") then
                local bv = Instance.new("BodyVelocity", root)
                bv.Name = "FlyForce"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            root.FlyForce.Velocity = Camera.CFrame.LookVector * _G.FlySpeed
        elseif root and root:FindFirstChild("FlyForce") then
            root.FlyForce:Destroy()
        end
    end
end)
