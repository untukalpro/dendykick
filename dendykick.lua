-- =====================================================================
-- BENJAMINDX SUPER FAST - PLACE & ROLLBACK DATA (SINGLE METHOD)
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TPService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isRunning = false
local giftDelay = 0.05 -- Jeda sangat singkat (detik) setelah menaruh item sebelum langsung Kick/Relog

-- [1] MATIKAN BGM GAME (BYPASS AUDIO)
task.spawn(function()
    local rf = ReplicatedStorage:WaitForChild("Functions", 5)
    local setSettingFunc = rf and rf:FindFirstChild("SetSettingFunc")

    if setSettingFunc then
        setSettingFunc:InvokeServer("BGM", "\255")
    end
end)

-- [2] PEMBUATAN GUI MENU (SEDERHANA)
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "BenJaMinX_SuperFast"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "BenJaMinX - Place Dupe"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -10, 0, 45)
toggle.Position = UDim2.new(0, 5, 1, -55)
toggle.Text = "START"
toggle.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
toggle.TextColor3 = Color3.new(1, 1, 1)

-- [3] FUNGSI REJOIN / KICK PAKSA (UNTUK ROLLBACK DATA)
-- local function Rejoin()
--     -- Memutus jaringan secara instan agar server tidak sempat menyimpan status inventaris yang berkurang
--     player:Kick("DC DULU BOS") 
    
--     task.wait(3)
--     TPService:Teleport(game.PlaceId, player)
-- end

local function Rejoin()
    player:Kick("DC DULU BOS") 
    
    task.wait(0.05)
    TPService:Teleport(game.PlaceId, player)
end

-- [4] TOMBOL START / STOP TOGGLE
toggle.MouseButton1Click:Connect(function()
    isRunning = not isRunning

    toggle.Text = isRunning and "STOP" or "START"
    toggle.BackgroundColor3 = isRunning 
        and Color3.fromRGB(180, 0, 0) 
        or Color3.fromRGB(0, 180, 0)

    if isRunning then
        print("[BenJaMinX] Sistem Pemantau Tombol E Aktif. Silakan taruh Brainrot Anda.")
    end
end)

-- [5] DETEKSI PENEKANAN TOMBOL E SECARA MANUAL / OTOMATIS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Jika script dalam posisi START dan kamu menekan tombol E
    if isRunning and input.KeyCode == Enum.KeyCode.E then
        print("[BenJaMinX] Tombol E Terdeteksi! Menunggu proses penempatan selesai...")
        
        -- Jeda sangat singkat untuk memastikan server menerima perintah 'Place' dari client
        task.wait(giftDelay)
        
        -- Langsung eksekusi pemutusan koneksi untuk memicu rollback data
        print("[BenJaMinX] Eksekusi Rollback!")
        Rejoin()
    end
end)

-- [6] LOOP OTOMATIS KLIK MENU KONFIRMASI (BILA ADA POPUP MUNCUL)
task.spawn(function()
    while true do
        if isRunning then
            local confirmGui = playerGui:FindFirstChild("Confirm")

            if confirmGui and confirmGui.Enabled then
                local btn = confirmGui:FindFirstChild("Main", true)
                    and confirmGui.Main:FindFirstChild("ConfirmFrame", true)
                    and confirmGui.Main.ConfirmFrame:FindFirstChild("Btn_Confirm")

                if btn then
                    GuiService.SelectedObject = btn

                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    task.wait()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

                    GuiService.SelectedObject = nil
                end
            end
        end
        task.wait()
    end
end)

-- [7] INSTANT PROXIMITY PROMPT (MEMBUAT PROSES TARUH/AMBIL JADI INSTAN)
local function setupPrompt(v)
    if v:IsA("ProximityPrompt") then
        v.HoldDuration = 0
    end
end

for _, v in ipairs(game:GetDescendants()) do
    setupPrompt(v)
end

game.DescendantAdded:Connect(setupPrompt)