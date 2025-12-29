-- [[ GGPVP MOBILE SUPREME V4 | BOTÃO FLUTUANTE & OTIMIZADO ]]
-- Versão para Delta, KRNL, Arceus X

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🎯 GGPVP MOBILE", "Midnight")

--// SERVIÇOS E VARIÁVEIS
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

_G.Aimbot = false
_G.TargetPart = "Head"
_G.FovRadius = 100
_G.FovVisible = true
_G.Smoothness = 0.2
_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 50
_G.ESP = false

--// CRIAÇÃO DO BOTÃO FLUTUANTE (PARA MINIMIZAR)
local OpenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local ImageButton = Instance.new("ImageButton")

OpenGui.Name = "OpenGui"
OpenGui.Parent = game:GetService("CoreGui")
OpenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = OpenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.12, 0, 0.15, 0)
Frame.Size = UDim2.new(0, 50, 0, 50)
Frame.Active = true
Frame.Draggable = true -- Você pode arrastar a bolinha pela tela

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Frame

ImageButton.Parent = Frame
ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageButton.BackgroundTransparency = 1.0
ImageButton.Size = UDim2.new(1, 0, 1, 0)
ImageButton.Image = "rbxassetid://6031068433" -- Ícone de alvo

-- Função para Abrir/Fechar
ImageButton.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
end)

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.6
FOVCircle.Color = Color3.fromRGB(0, 255, 255)

----------------------------------------------------
-- LÓGICA DE TARGET & ESP
----------------------------------------------------
local function GetClosestTarget()
    local target = nil
    local shortest = _G.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
            if p.Character.Humanoid.Health > 0 then
                local part = p.Character[_G.TargetPart]
                local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
                if onscreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortest then
                        shortest = dist
                        target = part
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
local Combat = Window:NewTab("Combate")
local AimSect = Combat:NewSection("Aimbot & Visuals")

AimSect:NewToggle("Ativar Aimbot", "Mira no alvo", function(v) _G.Aimbot = v end)
AimSect:NewToggle("Ver FOV", "Círculo da mira", function(v) _G.FovVisible = v end)
AimSect:NewSlider("Tamanho FOV", "Raio", 500, 50, function(v) _G.FovRadius = v end)
AimSect:NewToggle("Ativar ESP", "Ver Jogadores", function(v) _G.ESP = v end)

local Move = Window:NewTab("Movimento")
local MoveSect = Move:NewSection("Speed & Fly")

MoveSect:NewSlider("Velocidade", "WalkSpeed", 250, 16, function(v) _G.Speed = v end)
MoveSect:NewToggle("Ativar Fly", "Voar (Direção da Câmera)", function(v) _G.Fly = v end)
MoveSect:NewSlider("Velocidade Voo", "Fly Speed", 300, 20, function(v) _G.FlySpeed = v end)

----------------------------------------------------
-- LOOPS (MOBILE STABLE)
----------------------------------------------------

-- Loop Visual e Mira
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.FovVisible
    FOVCircle.Radius = _G.FovRadius
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if _G.Aimbot then
        local target = GetClosestTarget()
        if target then
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.Smoothness)
        end
    end
end)

-- Loop Movimento e ESP Simples
local Highlights = {}
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
            root.FlyForce.Velocity = Camera.CFrame.LookVector * _G.FlySpeed
        elseif root and root:FindFirstChild("FlyForce") then
            root.FlyForce:Destroy()
        end
    end

    -- Lógica de ESP Leve (Highlight)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            if _G.ESP and p.Character.Humanoid.Health > 0 then
                if not p.Character:FindFirstChild("GGPVP_ESP") then
                    local h = Instance.new("Highlight")
                    h.Name = "GGPVP_ESP"
                    h.Parent = p.Character
                    h.FillTransparency = 0.5
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if p.Character:FindFirstChild("GGPVP_ESP") then
                    p.Character:FindFirstChild("GGPVP_ESP"):Destroy()
                end
            end
        end
    end
end)
