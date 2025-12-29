-- [[ GGPVP MOBILE SUPREME V4 | FINAL MOBILE FIX ]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🎯 GGPVP MOBILE", "Midnight")

--// REFERÊNCIA DIRETA PARA O BOTÃO FUNCIONAR
local MainGui = game:GetService("CoreGui"):WaitForChild("🎯 GGPVP MOBILE")
local MainFrame = MainGui:FindFirstChild("Main")

--// SERVIÇOS
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

--// CONFIGS (SEPARADAS PARA NÃO BUGAR)
_G.Aimbot = false
_G.FovRadius = 100
_G.FovVisible = true
_G.Smoothness = 0.1
_G.WallCheck = true
_G.TargetPart = "Head"

_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 50

_G.ESP_Box = false
_G.ESP_Name = false

----------------------------------------------------
-- BOTÃO FLUTUANTE (FIXADO)
----------------------------------------------------
local MobileBtn = Instance.new("ScreenGui", game:GetService("CoreGui"))
local ToggleBtn = Instance.new("TextButton", MobileBtn)
local UICorner = Instance.new("UICorner", ToggleBtn)

ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleBtn.Text = "MENU"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
ToggleBtn.Active = true
ToggleBtn.Draggable = true -- Podes arrastar com o dedo
UICorner.CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    if MainFrame then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

----------------------------------------------------
-- FOV (LINHA FINA)
----------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

----------------------------------------------------
-- LÓGICA DE TARGET
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
-- INTERFACE
----------------------------------------------------

-- ABA: COMBATE
local Combat = Window:NewTab("Combate")
local AimSect = Combat:NewSection("Aimbot")

AimSect:NewToggle("Ativar Aimbot", "", function(v) _G.Aimbot = v end)
AimSect:NewToggle("Wall Check", "Ignorar Paredes", function(v) _G.WallCheck = v end)
AimSect:NewToggle("Ver FOV", "", function(v) _G.FovVisible = v end)

AimSect:NewSlider("Raio do FOV", "Tamanho do Círculo", 500, 50, function(v) 
    _G.FovRadius = v 
end)

AimSect:NewSlider("Suavidade (Smooth)", "Legit", 100, 1, function(v) 
    _G.Smoothness = v / 100 
end)

-- ABA: ESP
local Visuals = Window:NewTab("ESP")
local EspSect = Visuals:NewSection("Visualização")
EspSect:NewToggle("ESP Box", "", function(v) _G.ESP_Box = v end)
EspSect:NewToggle("ESP Names", "", function(v) _G.ESP_Name = v end)

-- ABA: MOVIMENTO
local Move = Window:NewTab("Movimento")
local MoveSect = Move:NewSection("Configurações")

MoveSect:NewTextBox("Velocidade (1 a 200)", "Digita e dá Enter", function(txt)
    local n = tonumber(txt)
    if n then _G.Speed = n end
end)

MoveSect:NewToggle("Voo (Fly)", "", function(v) _G.Fly = v end)
MoveSect:NewSlider("Velocidade Fly", "", 300, 10, function(v) _G.FlySpeed = v end)

----------------------------------------------------
-- SISTEMA DE ESP (DESENHO 2D)
----------------------------------------------------
local function CreateESP(plr)
    local Box = Drawing.new("Square")
    Box.Thickness = 1
    Box.Filled = false
    Box.Color = Color3.fromRGB(0, 255, 255)
    
    local Name = Drawing.new("Text")
    Name.Size = 14
    Name.Center = true
    Name.Outline = true
    Name.Color = Color3.fromRGB(255, 255, 255)

    RunService.RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 then
            local pos, on = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if on and (_G.ESP_Box or _G.ESP_Name) then
                local head = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                local h = math.abs(head.Y - pos.Y) * 2
                local w = h * 0.6

                if _G.ESP_Box then
                    Box.Visible = true
                    Box.Size = Vector2.new(w, h)
                    Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                else Box.Visible = false end

                if _G.ESP_Name then
                    Name.Visible = true
                    Name.Text = plr.Name
                    Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15)
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

for _, p in pairs(Players:GetPlayers()) do if p ~= LP then CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LP then CreateESP(p) end end)

----------------------------------------------------
-- LOOPS DE CONTROLE
----------------------------------------------------
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

-- LOOP DE FORÇA (VELOCIDADE)
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
end)
