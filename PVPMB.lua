-- [[ GGPVP SUPREME V4 - MOBILE ULTIMATE ]]
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("🎯 GGPVP MOBILE", "Midnight")

--// VARIÁVEIS DE CONTROLE
_G.Aimbot = false
_G.FovRadius = 100
_G.FovVisible = true
_G.Smoothness = 0.1
_G.WallCheck = true
_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 50
_G.ESP_Box = false
_G.ESP_Name = false

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

----------------------------------------------------
-- BOTÃO FLUTUANTE (CORRIGIDO)
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", ScreenGui)
local UICorner = Instance.new("UICorner", OpenBtn)

OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
OpenBtn.Text = "GGPVP"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 12
OpenBtn.Draggable = true
UICorner.CornerRadius = UDim.new(1, 0)

-- Função para mostrar/esconder o menu
OpenBtn.MouseButton1Click:Connect(function()
    local targetGui = game:GetService("CoreGui"):FindFirstChild("🎯 GGPVP MOBILE")
    if targetGui then
        targetGui.Enabled = not targetGui.Enabled
    end
end)

----------------------------------------------------
-- FOV CIRCLE (SÓ O CONTORNO)
----------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

----------------------------------------------------
-- ABAS E FUNÇÕES
----------------------------------------------------
local Combat = Window:NewTab("Combate")
local AimSect = Combat:NewSection("Mira e FOV")

AimSect:NewToggle("Ativar Aimbot", "Gruda no inimigo", function(v) _G.Aimbot = v end)
AimSect:NewToggle("Wall Check", "Verifica se há parede", function(v) _G.WallCheck = v end)
AimSect:NewToggle("Ver Círculo", "Mostra o FOV", function(v) _G.FovVisible = v end)

AimSect:NewSlider("Tamanho FOV", "Área de alcance", 500, 50, function(v) 
    _G.FovRadius = v 
end)

AimSect:NewSlider("Suavidade (Smooth)", "Legit Aim", 100, 1, function(v) 
    _G.Smoothness = v / 100 
end)

local Visuals = Window:NewTab("ESP")
local EspSect = Visuals:NewSection("Wallhack")
EspSect:NewToggle("ESP Box", "Caixas", function(v) _G.ESP_Box = v end)
EspSect:NewToggle("ESP Name", "Nomes", function(v) _G.ESP_Name = v end)

local Move = Window:NewTab("Movimento")
local MoveSect = Move:NewSection("Velocidade e Voo")

MoveSect:NewTextBox("Velocidade (1-50)", "Digite e dê Enter", function(txt)
    local n = tonumber(txt)
    if n and n <= 100 then _G.Speed = n end
end)

MoveSect:NewToggle("Ativar Fly", "Voar", function(v) _G.Fly = v end)
MoveSect:NewSlider("Velocidade Voo", "", 300, 20, function(v) _G.FlySpeed = v end)

----------------------------------------------------
-- LÓGICA DE ESP (CAIXA E NOME)
----------------------------------------------------
local function AddESP(plr)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(0, 255, 255)
    Box.Thickness = 1
    
    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Color = Color3.fromRGB(255, 255, 255)
    Name.Size = 13
    Name.Center = true
    Name.Outline = true

    RunService.RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 then
            local pos, on = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if on and (_G.ESP_Box or _G.ESP_Name) then
                local head = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                local dist = math.abs(head.Y - pos.Y)
                
                if _G.ESP_Box then
                    Box.Visible = true
                    Box.Size = Vector2.new(dist * 2, dist * 2.5)
                    Box.Position = Vector2.new(pos.X - Box.Size.X/2, pos.Y - Box.Size.Y/2)
                else Box.Visible = false end

                if _G.ESP_Name then
                    Name.Visible = true
                    Name.Text = plr.Name
                    Name.Position = Vector2.new(pos.X, pos.Y - dist - 20)
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

for _, p in pairs(Players:GetPlayers()) do if p ~= LP then AddESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LP then AddESP(p) end end)

----------------------------------------------------
-- LOOPS PRINCIPAIS
----------------------------------------------------
local function GetClosest()
    local target, shortest = nil, _G.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local part = p.Character.Head
            if _G.WallCheck then
                local cast = Camera:GetPartsObscuringTarget({part.Position}, {LP.Character, p.Character})
                if #cast > 0 then continue end
            end
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
    return target
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.FovVisible
    FOVCircle.Radius = _G.FovRadius
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    if _G.Aimbot then
        local t = GetClosest()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), _G.Smoothness)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if _G.Fly and root then
            if not root:FindFirstChild("FlyV") then
                local bv = Instance.new("BodyVelocity", root)
                bv.Name = "FlyV"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            root.FlyV.Velocity = Camera.CFrame.LookVector * _G.FlySpeed
        elseif root and root:FindFirstChild("FlyV") then
            root.FlyV:Destroy()
        end
    end
end)
