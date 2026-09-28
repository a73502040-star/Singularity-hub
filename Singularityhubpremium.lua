-- ============================================================
-- Delta Compatibility Fix
-- ============================================================
if not gethui then
    function gethui()
        return game:GetService("CoreGui")
    end
end
if not syn then syn = {} end
if not syn.protect_gui then
    function syn.protect_gui(gui)
        gui.Parent = gethui()
    end
end
if not protect_gui then
    function protect_gui(gui)
        gui.Parent = gethui()
    end
end
-- ============================================================-- ============================================================
-- Singularity hub premium - FULL FIXED VERSION
-- Part 1 / 8 : Initialization & Utilities
-- ============================================================
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 10)
local SetNetworkOwnerEvent = GrabEvents and GrabEvents:WaitForChild("SetNetworkOwner", 5)
local CreateGrabLine = GrabEvents and GrabEvents:WaitForChild("CreateGrabLine", 5)
local DestroyGrabLine = GrabEvents and GrabEvents:WaitForChild("DestroyGrabLine", 5)
local ExtendGrabLine = GrabEvents and GrabEvents:WaitForChild("ExtendGrabLine", 5)

local MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 10)
local SpawnToyRemoteFunction = MenuToys and MenuToys:WaitForChild("SpawnToyRemoteFunction", 5)
local DestroyToy = MenuToys and MenuToys:WaitForChild("DestroyToy", 5)

local PlayerEvents = ReplicatedStorage:WaitForChild("PlayerEvents", 10)
local StickyEvent = PlayerEvents and PlayerEvents:WaitForChild("StickyPartEvent", 5)

local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 10)
local RagdollRemote = CharacterEvents and CharacterEvents:WaitForChild("RagdollRemote", 5)
local StruggleEvent = CharacterEvents and CharacterEvents:WaitForChild("Struggle", 5)

local selectedTargetName = nil

local function Notify(title, desc, time)
    pcall(function()
        Library:Notify({Title = title, Description = desc, Time = time or 3})
    end)
end

local function GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    table.sort(list, function(a, b) return a:lower() < b:lower() end)
    return list
end

local function ExtractUsername(selected)
    if not selected then return nil end
    return selected:match("%(@(.+)%)$")
end

local function GetHRP(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("HumanoidRootPart")
end

local function GetPlayerHRP(player)
    if not player then return nil end
    local char = player.Character
    if char and char.Parent == Workspace then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
    end
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == player.Name then
            local hrp = model:FindFirstChild("HumanoidRootPart")
            if hrp then return hrp end
        end
    end
    return nil
end

local function FWD(p, n, t)
    return p:FindFirstChild(n) or p:WaitForChild(n, t or 5)
end

local function GetMyHum()
    local c = LocalPlayer.Character
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end

local function GetMyHRP()
    local c = LocalPlayer.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function stvel(part)
    if part and part:IsA("BasePart") then
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end
end

local function fireproximityprompt_safe(prompt)
    if not prompt then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(0.05)
            prompt:InputHoldEnd()
        end
    end)
end

-- Teleport State
_G.TPState = { TargetName = nil, OffsetY = 3, Loop = false, LoopTask = nil }

local function TPToPlayerByName(name, offsetY)
    if not name then return end
    local target = Players:FindFirstChild(name)
    if not target then Notify("TP Error", "Player not found", 2) return end
    local tHRP = GetPlayerHRP(target)
    if not tHRP then Notify("TP Error", "Target HRP missing", 2) return end
    local myHRP = GetMyHRP()
    if not myHRP then Notify("TP Error", "Self HRP missing", 2) return end
    myHRP.CFrame = tHRP.CFrame + Vector3.new(0, offsetY or 3, 0)
    myHRP.AssemblyLinearVelocity = Vector3.zero
    myHRP.AssemblyAngularVelocity = Vector3.zero
end

local function StopTPLoop()
    if _G.TPState.LoopTask then
        pcall(task.cancel, _G.TPState.LoopTask)
        _G.TPState.LoopTask = nil
    end
end

local function StartTPLoop()
    StopTPLoop()
    if not _G.TPState.TargetName then return end
    _G.TPState.LoopTask = task.spawn(function()
        while _G.TPState.Loop do
            TPToPlayerByName(_G.TPState.TargetName, _G.TPState.OffsetY)
            RunService.Heartbeat:Wait()
        end
        _G.TPState.LoopTask = nil
    end)
end

-- ============================================================
-- グローバル変数の初期化
-- ============================================================
_G.antiAntiKickActive = false
_G.removeAntiKickAuraActive = false
_G.removeAntiKickRadius = 50

_G.loopBlobKickSpamTask = nil
_G.loopBlobKickSpamActive = false
_G.loopBlobKickSpamTargetName = nil
_G.loopKill1Active = false
_G.loopKill1TargetName = nil
_G.loopKill2Active = false
_G.loopKill2TargetName = nil
_G.kickLoopEnabled = false

_G.snowballRagdollTask = nil
_G.snowballRagdollActive = false
_G.snowballRagdollTargetName = nil

_G.AntiExtra = {
    AntiGrabNRD = false, AntiBananaSit = false, AntiBlobmanKill = false,
    AntiRagBlob = false, AntiSticky = false, AntiBurn = false,
    AutoAntiLag = false, AntiInputLag = false, RemoveAllAntiInput = false,
    AntiKickBreakPCLD = false, GodMode = false,
}

_G.AntiGrabNRDEnabled = false
_G.AntiGrabNRDProc = false
_G.AGNRDWalk = false
_G.StruggleNRD = StruggleEvent
_G.RagdollRemoteNRD = RagdollRemote

_G.antiBananaSitActive = false
_G.antiBananaSitTask = nil
_G.antiBlobmanKillActive = false
_G.antiBlobmanKillTask = nil
_G.antiRagBlobActive = false
_G.antiRagBlobConnections = {}

_G.antiburn = nil
_G.antiburn1 = nil
_G.HRP_Burn = nil
_G.hum_Burn = nil

_G.Lines = 0
_G.lagger = nil
_G.autoantilag = false
_G.lineLagActive = false
_G.lineLagTask = nil
_G.packetLagActive = false
_G.packetLagTask = nil

_G.antiInputLagTask = nil
_G.SelectedAntiInputToy = "FoodHamburger"
_G.antiAntiLagEnabled = false
_G.removeAntiInputTask = nil

-- ============================================================
-- 【写真の機能追加】グローバル変数
-- ============================================================
_G.NetworkOwnership = {
    isActive = false,
    connection = nil,
    lastForceTime = 0,
}
_G.AntiAttachment = {
    isActive = false,
    connection = nil,
    lastReverseTime = 0,
}
_G.SourceFreeze = {
    isActive = false,
    connection = nil,
    frozenPlayers = {},
}
_G.PhysicsLimit = {
    isActive = false,
    connection = nil,
    anchorPart = nil,
}

print("[Singularity hub premium] Part 1 loaded")
-- [Part 1 END] --
-- ============================================================
-- Singularity hub premium - FULL FIXED VERSION
-- Part 2 / 8 : Kick System
-- ============================================================

-- ============================================================
-- Allkick
-- ============================================================
local AllkickLagConn, AllkickRunning, AllkickTask = nil, false, nil

local function AllkickStartLag()
    if AllkickLagConn then AllkickLagConn:Disconnect() AllkickLagConn = nil end
    local targetRate = 85
    local bpf = math.floor(targetRate / 60)
    local rem = targetRate - (bpf * 60)
    local fc = 0
    AllkickLagConn = RunService.Heartbeat:Connect(function()
        fc = fc + 1
        local sc = bpf
        if fc <= rem then sc = sc + 1 end
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or GetMyHRP()
        if sp and CreateGrabLine then
            for i = 1, sc do
                pcall(function()
                    CreateGrabLine:FireServer(sp, CFrame.new(
                        math.random(-2010000000, 2000000001), 0,
                        math.random(-2008100000, 2000200000)))
                end)
            end
        end
    end)
end

local function AllkickStopLag()
    if AllkickLagConn then AllkickLagConn:Disconnect() AllkickLagConn = nil end
end

local function AllkickStop()
    AllkickRunning = false
    if AllkickTask then pcall(task.cancel, AllkickTask) AllkickTask = nil end
    AllkickStopLag()
end

local function AllkickExecute()
    if AllkickRunning then return end
    AllkickRunning = true
    AllkickTask = task.spawn(function()
        AllkickStartLag()
        local height = 35
        task.wait(1)
        local myHrp = GetMyHRP()
        if not myHrp then AllkickStop() return end
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local hrp = GetPlayerHRP(p)
                if hrp then table.insert(list, hrp) end
            end
        end
        if #list == 0 then task.wait(10) AllkickStop() return end
        Notify("Kick", "All (" .. #list .. ") kicked", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local cx = sp and sp.Position.X or 0
        local cz = sp and sp.Position.Z or 0
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for _, hrp in ipairs(list) do
            pcall(function()
                myHrp.CFrame = hrp.CFrame * CFrame.new(0, 5, 5)
                myHrp.AssemblyLinearVelocity = Vector3.zero
            end)
            task.wait(0.2)
            if SetNetworkOwnerEvent then
                pcall(function() SetNetworkOwnerEvent:FireServer(hrp, hrp.CFrame) end)
            end
        end
        local radius = 80
        local step = (math.pi * 2) / math.max(#list, 1)
        for i, hrp in ipairs(list) do
            local a = (i - 1) * step
            local x = math.cos(a) * radius
            local z = math.sin(a) * radius
            pcall(function()
                hrp.CFrame = CFrame.new(cx + x, height, cz + z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end)
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bp.P = 5e10
            bp.Position = Vector3.new(cx + x, height, cz + z)
            bp.Parent = hrp
            task.delay(2, function() pcall(function() bp:Destroy() end) end)
            task.wait()
        end
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for i = 1, 8 do
            for _, hrp in ipairs(list) do
                if CreateGrabLine and DestroyGrabLine then
                    pcall(function()
                        CreateGrabLine:FireServer(hrp, CFrame.new(0, 1e9, 0))
                        task.wait()
                        DestroyGrabLine:FireServer(hrp)
                    end)
                end
            end
            task.wait(0.3)
        end
        task.wait(11)
        AllkickStop()
    end)
end

-- ============================================================
-- Tlag (Noblobkick)
-- ============================================================
local TlagRunning, TlagTask, TlagLagConn = false, nil, nil

local function TlagStartLag()
    if TlagLagConn then TlagLagConn:Disconnect() TlagLagConn = nil end
    local targetRate = 85
    local bpf = math.floor(targetRate / 60)
    local rem = targetRate - (bpf * 60)
    local fc = 0
    TlagLagConn = RunService.Heartbeat:Connect(function()
        fc = fc + 1
        local sc = bpf
        if fc <= rem then sc = sc + 1 end
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        if sp and CreateGrabLine then
            for i = 1, sc do
                pcall(function()
                    CreateGrabLine:FireServer(sp, CFrame.new(
                        math.random(-2010000000, 2000000001), 0,
                        math.random(-2008100000, 2000200000)))
                end)
            end
        end
    end)
end

local function TlagStopLag()
    if TlagLagConn then TlagLagConn:Disconnect() TlagLagConn = nil end
end

local function TlagStop()
    TlagRunning = false
    if TlagTask then pcall(task.cancel, TlagTask) TlagTask = nil end
    TlagStopLag()
end

local function TlagExecute()
    if TlagRunning then return end
    if not selectedTargetName then Notify("Error", "No target selected", 3) return end
    local tp = Players:FindFirstChild(selectedTargetName)
    if not tp then Notify("Error", "Player not found", 3) return end
    TlagRunning = true
    TlagTask = task.spawn(function()
        TlagStartLag()
        local height = 35
        task.wait(1)
        local myHrp = GetMyHRP()
        if not myHrp then TlagStop() return end
        local tHrp = GetPlayerHRP(tp)
        if not tHrp then TlagStop() return end
        Notify("Kick", tp.DisplayName .. " kicked", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local cx = sp and sp.Position.X or 0
        local cz = sp and sp.Position.Z or 0
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        pcall(function()
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 5, 5)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        task.wait(0.2)
        if SetNetworkOwnerEvent then
            pcall(function() SetNetworkOwnerEvent:FireServer(tHrp, tHrp.CFrame) end)
        end
        task.wait()
        local radius = 80
        local ang = math.rad(math.random(0, 360))
        local x = math.cos(ang) * radius
        local z = math.sin(ang) * radius
        pcall(function()
            tHrp.CFrame = CFrame.new(cx + x, height, cz + z)
            tHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.P = 5e10
        bp.Position = Vector3.new(cx + x, height, cz + z)
        bp.Parent = tHrp
        task.delay(2, function() pcall(function() bp:Destroy() end) end)
        task.wait(0.1)
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for i = 1, 8 do
            if CreateGrabLine and DestroyGrabLine then
                pcall(function()
                    CreateGrabLine:FireServer(tHrp, CFrame.new(0, 1e9, 0))
                    task.wait()
                    DestroyGrabLine:FireServer(tHrp)
                end)
            end
            task.wait(0.3)
        end
        task.wait(11)
        TlagStop()
    end)
end

-- ============================================================
-- Grab Kick (Blobkick)
-- ============================================================
local GrabKickChar = nil
local GrabKickExec = false
if LocalPlayer.Character then GrabKickChar = LocalPlayer.Character end
LocalPlayer.CharacterAdded:Connect(function(c) GrabKickChar = c end)

local function GrabKickGetBlob()
    if not GrabKickChar then return nil end
    local f = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if f then
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("Model") and c.Name:find("CreatureBlobman") then return c end
        end
    end
    for _, d in ipairs(GrabKickChar:GetDescendants()) do
        if d:IsA("Model") and d.Name:find("CreatureBlobman") then return d end
    end
    return nil
end

local function GrabKickCleanWelds(det)
    if not det then return end
    for _, c in ipairs(det:GetChildren()) do
        if c:IsA("Weld") or c:IsA("ManualWeld") then c:Destroy() end
    end
end

local function GrabKickExecute()
    if GrabKickExec then return end
    if not selectedTargetName then Notify("Error", "No target selected", 3) return end
    local tp = Players:FindFirstChild(selectedTargetName)
    if not tp or not tp.Character then return end
    local tHrp = tp.Character:FindFirstChild("HumanoidRootPart")
    local tHum = tp.Character:FindFirstChildWhichIsA("Humanoid")
    if not tHrp or not tHum then return end
    GrabKickExec = true
    task.spawn(function()
        local blob = GrabKickGetBlob()
        if not blob then
            Notify("Error", "Please sit on a Blobman", 3)
            GrabKickExec = false return
        end
        local bs = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        if not bs then GrabKickExec = false return end
        local gr = bs:FindFirstChild("CreatureGrab")
        local rr = bs:FindFirstChild("CreatureRelease")
        local dr = bs:FindFirstChild("CreatureDrop")
        local rd = blob:FindFirstChild("RightDetector")
        local rw = rd and rd:FindFirstChild("RightWeld")
        if not gr or not rd then GrabKickExec = false return end
        pcall(function() tHrp:SetNetworkOwner(LocalPlayer) end)
        for rep = 1, 6 do
            if not tHrp.Parent then break end
            pcall(function()
                tHrp.AssemblyLinearVelocity = Vector3.zero
                tHrp.AssemblyAngularVelocity = Vector3.zero
                GrabKickCleanWelds(rd)
                local ao = blob:GetPivot():Inverse() * rd.CFrame
                blob:PivotTo(tHrp.CFrame * ao:Inverse())
                for _ = 1, 6 do
                    gr:FireServer(rd, tHrp, rw)
                    task.wait(0.001)
                end
                task.wait(0.01)
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                local d = Vector3.new(math.random(-10,10), math.random(8,18), math.random(-10,10)).Unit
                bv.Velocity = d * 1
                bv.Parent = tHrp
                task.delay(0.05, function() pcall(function() bv:Destroy() end) end)
                if rr then pcall(function() rr:FireServer() end) end
                if dr then pcall(function() dr:FireServer() end) end
                GrabKickCleanWelds(rd)
            end)
            task.wait(0.001)
        end
        pcall(function() tHrp:SetNetworkOwner(nil) end)
        Notify("Kick", tp.DisplayName .. " kicked", 3)
        GrabKickExec = false
    end)
end

-- ============================================================
-- Lagk (Lagkick)
-- ============================================================
local LagkExec = false
local function LagkExecute()
    if LagkExec then return end
    if not selectedTargetName then return end
    local tp = Players:FindFirstChild(selectedTargetName)
    if not tp or not tp.Character then return end
    local tr = tp.Character:FindFirstChild("HumanoidRootPart")
    if not tr then return end
    LagkExec = true
    task.spawn(function()
        local myChar = LocalPlayer.Character
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        local blob = inv and inv:FindFirstChild("CreatureBlobman")
        if not blob and ReplicatedStorage.MenuToys and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction") then
            local mr = myChar and myChar:FindFirstChild("HumanoidRootPart")
            pcall(function()
                ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", mr and mr.CFrame or CFrame.new(0,50,0), Vector3.zero)
            end)
            task.wait(1)
            inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            blob = inv and inv:FindFirstChild("CreatureBlobman")
        end
        if not blob then LagkExec = false return end
        local seat = blob:FindFirstChild("VehicleSeat")
        if seat and myHum and not myHum.Sit then
            pcall(function() seat:Sit(myHum) end)
            task.wait(0.6)
        end
        local bs = blob:FindFirstChild("BlobmanSeatAndOwnerScript", true)
        if bs then
            local gr = bs:FindFirstChild("CreatureGrab")
            local dr = bs:FindFirstChild("CreatureDrop")
            local ld = blob:FindFirstChild("LeftDetector")
            local lw = ld and ld:FindFirstChild("LeftWeld")
            local mr = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if gr and ld and mr then
                pcall(function() gr:FireServer(ld, mr, lw) end)
                task.wait(0.08)
                if SetNetworkOwnerEvent then pcall(function() SetNetworkOwnerEvent:FireServer(tr, tr.CFrame) end) end
                task.wait(0.08)
                pcall(function() tr.CFrame = tr.CFrame + Vector3.new(0, 16, 0) end)
                task.wait(0.08)
                if DestroyGrabLine then pcall(function() DestroyGrabLine:FireServer(tr) end) end
                task.wait(0.08)
                pcall(function() gr:FireServer(ld, tr, lw) end)
                task.wait(0.08)
                if dr then pcall(function() dr:FireServer(ld, tr) end) end
                task.wait(0.08)
                if DestroyGrabLine then pcall(function() DestroyGrabLine:FireServer(tr) end) end
            end
        end
        if ReplicatedStorage.MenuToys and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy") then
            pcall(function() ReplicatedStorage.MenuToys.DestroyToy:FireServer(blob) end)
        end
        Notify("Kick", tp.DisplayName .. " kicked", 3)
        LagkExec = false
    end)
end

-- ============================================================
-- LKA (Lag Kick All)
-- ============================================================
local LKA_Conn, LKA_Running, LKA_Task = nil, false, nil

local function LKA_StartLag()
    if LKA_Conn then LKA_Conn:Disconnect() LKA_Conn = nil end
    local targetRate = 1000
    local bpf = math.floor(targetRate / 60)
    local rem = targetRate - (bpf * 60)
    local fc = 0
    LKA_Conn = RunService.Heartbeat:Connect(function()
        fc = fc + 1
        local sc = bpf
        if fc <= rem then sc = sc + 1 end
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or GetMyHRP()
        if sp and CreateGrabLine then
            for i = 1, sc do
                pcall(function()
                    CreateGrabLine:FireServer(sp, CFrame.new(
                        math.random(-2010000000, 2000200000), 0,
                        math.random(-2008100000, 2000200000)))
                end)
            end
        end
    end)
end

local function LKA_StopLag()
    if LKA_Conn then LKA_Conn:Disconnect() LKA_Conn = nil end
end

local function LKA_Stop()
    LKA_Running = false
    if LKA_Task then pcall(task.cancel, LKA_Task) LKA_Task = nil end
    LKA_StopLag()
end

local function LKA_Execute()
    if LKA_Running then return end
    LKA_Running = true
    LKA_Task = task.spawn(function()
        LKA_StartLag()
        local height = 35
        task.wait(0.5)
        local myHrp = GetMyHRP()
        if not myHrp then LKA_Stop() return end
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local hrp = GetPlayerHRP(p)
                if hrp then table.insert(list, hrp) end
            end
        end
        if #list == 0 then task.wait(5) LKA_Stop() return end
        Notify("Kick", "All (" .. #list .. ") kicked", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local cx = sp and sp.Position.X or 0
        local cz = sp and sp.Position.Z or 0
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for _, hrp in ipairs(list) do
            pcall(function()
                myHrp.CFrame = hrp.CFrame * CFrame.new(0, 5, 5)
                myHrp.AssemblyLinearVelocity = Vector3.zero
            end)
            task.wait(0.2)
            if SetNetworkOwnerEvent then
                pcall(function() SetNetworkOwnerEvent:FireServer(hrp, hrp.CFrame) end)
                pcall(function() SetNetworkOwnerEvent:FireServer(hrp, hrp.CFrame) end)
            end
        end
        local radius = 10
        local step = (math.pi * 2) / math.max(#list, 1)
        for i, hrp in ipairs(list) do
            local a = (i - 1) * step
            local x = math.cos(a) * radius
            local z = math.sin(a) * radius
            pcall(function()
                hrp.CFrame = CFrame.new(cx + x, height, cz + z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end)
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bp.P = 5e11
            bp.Position = Vector3.new(cx + x, height, cz + z)
            bp.Parent = hrp
            task.delay(2, function() pcall(function() bp:Destroy() end) end)
            task.wait()
        end
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for i = 1, 80 do
            for _, hrp in ipairs(list) do
                task.spawn(function()
                    if CreateGrabLine and DestroyGrabLine then
                        pcall(function()
                            CreateGrabLine:FireServer(hrp, CFrame.new(0, 1e9, 0))
                            DestroyGrabLine:FireServer(hrp)
                        end)
                    end
                end)
            end
            task.wait(0.03)
        end
        task.wait(6)
        LKA_StopLag()
        LKA_Running = false
    end)
end

print("[Singularity hub premium] Part 2 loaded")
-- [Part 2 END] ---- ============================================================
-- Singularity hub premium - FULL FIXED VERSION
-- Part 3 / 8 : Kick System (Continued)
-- ============================================================

-- ============================================================
-- LKS (Lag Kick Select)
-- ============================================================
local LKS_Conn, LKS_Running, LKS_Task = nil, false, nil

local function LKS_StartLag()
    if LKS_Conn then LKS_Conn:Disconnect() LKS_Conn = nil end
    local targetRate = 1000
    local bpf = math.floor(targetRate / 60)
    local rem = targetRate - (bpf * 60)
    local fc = 0
    LKS_Conn = RunService.Heartbeat:Connect(function()
        fc = fc + 1
        local sc = bpf
        if fc <= rem then sc = sc + 1 end
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or GetMyHRP()
        if sp and CreateGrabLine then
            for i = 1, sc do
                pcall(function()
                    CreateGrabLine:FireServer(sp, CFrame.new(
                        math.random(-2010000000, 2000200000), 0,
                        math.random(-2008100000, 2000200000)))
                end)
            end
        end
    end)
end

local function LKS_StopLag()
    if LKS_Conn then LKS_Conn:Disconnect() LKS_Conn = nil end
end

local function LKS_Stop()
    LKS_Running = false
    if LKS_Task then pcall(task.cancel, LKS_Task) LKS_Task = nil end
    LKS_StopLag()
end

local function LKS_Execute()
    if LKS_Running then return end
    if not selectedTargetName then Notify("Error", "No target selected", 3) return end
    local targetPlayer = Players:FindFirstChild(selectedTargetName)
    if not targetPlayer then Notify("Error", "Player not found", 3) return end
    LKS_Running = true
    LKS_Task = task.spawn(function()
        LKS_StartLag()
        local height = 35
        task.wait(0.5)
        local myHrp = GetMyHRP()
        if not myHrp then LKS_Stop() return end
        local tHrp = GetPlayerHRP(targetPlayer)
        if not tHrp then LKS_StopLag() LKS_Running = false return end
        Notify("Kick", targetPlayer.DisplayName .. " kicked", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local cx = sp and sp.Position.X or 0
        local cz = sp and sp.Position.Z or 0
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        pcall(function()
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 5, 5)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        task.wait(0.2)
        if SetNetworkOwnerEvent then
            pcall(function() SetNetworkOwnerEvent:FireServer(tHrp, tHrp.CFrame) end)
            pcall(function() SetNetworkOwnerEvent:FireServer(tHrp, tHrp.CFrame) end)
            pcall(function() SetNetworkOwnerEvent:FireServer(tHrp, tHrp.CFrame) end)
        end
        pcall(function()
            tHrp.CFrame = CFrame.new(cx, height, cz + 5)
            tHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.P = 5e11
        bp.Position = Vector3.new(cx, height, cz + 5)
        bp.Parent = tHrp
        task.delay(2, function() pcall(function() bp:Destroy() end) end)
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for i = 1, 80 do
            task.spawn(function()
                if CreateGrabLine and DestroyGrabLine then
                    pcall(function()
                        CreateGrabLine:FireServer(tHrp, CFrame.new(0, 1e9, 0))
                        DestroyGrabLine:FireServer(tHrp)
                    end)
                end
            end)
            task.wait(0.03)
        end
        task.wait(6)
        LKS_StopLag()
        LKS_Running = false
    end)
end

-- ============================================================
-- LKA2 (Lag Kick All Strong)
-- ============================================================
local LKA2_Conn, LKA2_Running, LKA2_Task = nil, false, nil

local function LKA2_StartLag()
    if LKA2_Conn then LKA2_Conn:Disconnect() LKA2_Conn = nil end
    local targetRate = 1000
    local bpf = math.floor(targetRate / 60)
    local rem = targetRate - (bpf * 60)
    local fc = 0
    LKA2_Conn = RunService.Heartbeat:Connect(function()
        fc = fc + 1
        local sc = bpf
        if fc <= rem then sc = sc + 1 end
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or GetMyHRP()
        if sp and CreateGrabLine then
            for i = 1, sc do
                pcall(function()
                    CreateGrabLine:FireServer(sp, CFrame.new(
                        math.random(-2010000000, 2000200000), 0,
                        math.random(-2008100000, 2000200000)))
                end)
            end
        end
    end)
end

local function LKA2_StopLag()
    if LKA2_Conn then LKA2_Conn:Disconnect() LKA2_Conn = nil end
end

local function LKA2_Stop()
    LKA2_Running = false
    if LKA2_Task then pcall(task.cancel, LKA2_Task) LKA2_Task = nil end
    LKA2_StopLag()
end

local function LKA2_Execute()
    if LKA2_Running then return end
    LKA2_Running = true
    LKA2_Task = task.spawn(function()
        LKA2_StartLag()
        local height = 35
        task.wait(0.5)
        local myHrp = GetMyHRP()
        if not myHrp then LKA2_Stop() return end
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local hrp = GetPlayerHRP(p)
                if hrp then table.insert(list, hrp) end
            end
        end
        if #list == 0 then task.wait(5) LKA2_Stop() return end
        Notify("Kick", "All (" .. #list .. ") kicked", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local cx = sp and sp.Position.X or 0
        local cz = sp and sp.Position.Z or 0
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for _, hrp in ipairs(list) do
            pcall(function()
                myHrp.CFrame = hrp.CFrame * CFrame.new(0, 5, 5)
                myHrp.AssemblyLinearVelocity = Vector3.zero
            end)
            task.wait(0.2)
            if SetNetworkOwnerEvent then
                pcall(function() SetNetworkOwnerEvent:FireServer(hrp, hrp.CFrame) end)
                pcall(function() SetNetworkOwnerEvent:FireServer(hrp, hrp.CFrame) end)
            end
        end
        local radius = 10
        local step = (math.pi * 2) / math.max(#list, 1)
        for i, hrp in ipairs(list) do
            local a = (i - 1) * step
            local x = math.cos(a) * radius
            local z = math.sin(a) * radius
            pcall(function()
                hrp.CFrame = CFrame.new(cx + x, height, cz + z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end)
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bp.P = 5e11
            bp.Position = Vector3.new(cx + x, height, cz + z)
            bp.Parent = hrp
            task.delay(2, function() pcall(function() bp:Destroy() end) end)
            task.wait()
        end
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for i = 1, 80 do
            for _, hrp in ipairs(list) do
                task.spawn(function()
                    if CreateGrabLine and DestroyGrabLine then
                        pcall(function()
                            CreateGrabLine:FireServer(hrp, CFrame.new(0, 1e9, 0))
                            DestroyGrabLine:FireServer(hrp)
                        end)
                    end
                end)
            end
            task.wait(0.03)
        end
        task.wait(6)
        LKA2_StopLag()
        LKA2_Running = false
    end)
end

-- ============================================================
-- LKS2 (Lag Kick Select Anti Pierce)
-- ============================================================
local LKS2_Conn, LKS2_Running, LKS2_Task = nil, false, nil

local function LKS2_StartLag()
    if LKS2_Conn then LKS2_Conn:Disconnect() LKS2_Conn = nil end
    local targetRate = 1000
    local bpf = math.floor(targetRate / 60)
    local rem = targetRate - (bpf * 60)
    local fc = 0
    LKS2_Conn = RunService.Heartbeat:Connect(function()
        fc = fc + 1
        local sc = bpf
        if fc <= rem then sc = sc + 1 end
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or GetMyHRP()
        if sp and CreateGrabLine then
            for i = 1, sc do
                pcall(function()
                    CreateGrabLine:FireServer(sp, CFrame.new(
                        math.random(-2010000000, 2000200000), 0,
                        math.random(-2008100000, 2000200000)))
                end)
            end
        end
    end)
end

local function LKS2_StopLag()
    if LKS2_Conn then LKS2_Conn:Disconnect() LKS2_Conn = nil end
end

local function LKS2_Stop()
    LKS2_Running = false
    if LKS2_Task then pcall(task.cancel, LKS2_Task) LKS2_Task = nil end
    LKS2_StopLag()
end

local function LKS2_Execute()
    if LKS2_Running then return end
    if not selectedTargetName then Notify("Error", "No target selected", 3) return end
    local targetPlayer = Players:FindFirstChild(selectedTargetName)
    if not targetPlayer then Notify("Error", "Player not found", 3) return end
    LKS2_Running = true
    LKS2_Task = task.spawn(function()
        LKS2_StartLag()
        local height = 35
        task.wait(0.5)
        local myHrp = GetMyHRP()
        if not myHrp then LKS2_Stop() return end
        local tHrp = GetPlayerHRP(targetPlayer)
        if not tHrp then LKS2_StopLag() LKS2_Running = false return end
        Notify("Kick", targetPlayer.DisplayName .. " kicked", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local cx = sp and sp.Position.X or 0
        local cz = sp and sp.Position.Z or 0
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        pcall(function()
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 5, 5)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        task.wait(0.2)
        if SetNetworkOwnerEvent then
            pcall(function() SetNetworkOwnerEvent:FireServer(tHrp, tHrp.CFrame) end)
            pcall(function() SetNetworkOwnerEvent:FireServer(tHrp, tHrp.CFrame) end)
        end
        pcall(function()
            tHrp.CFrame = CFrame.new(cx, height, cz + 5)
            tHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.P = 5e11
        bp.Position = Vector3.new(cx, height, cz + 5)
        bp.Parent = tHrp
        task.delay(2, function() pcall(function() bp:Destroy() end) end)
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for i = 1, 80 do
            task.spawn(function()
                if CreateGrabLine and DestroyGrabLine then
                    pcall(function()
                        CreateGrabLine:FireServer(tHrp, CFrame.new(0, 1e9, 0))
                        DestroyGrabLine:FireServer(tHrp)
                    end)
                end
            end)
            task.wait(0.03)
        end
        task.wait(6)
        LKS2_StopLag()
        LKS2_Running = false
    end)
end

-- ============================================================
-- LKA3 (Grab Kick All Vision Pierce)
-- ============================================================
local LKA3_Conn, LKA3_Running, LKA3_Task = nil, false, nil

local function LKA3_StartLag()
    if LKA3_Conn then LKA3_Conn:Disconnect() LKA3_Conn = nil end
    local targetRate = 1000
    local bpf = math.floor(targetRate / 60)
    local rem = targetRate - (bpf * 60)
    local fc = 0
    LKA3_Conn = RunService.Heartbeat:Connect(function()
        fc = fc + 1
        local sc = bpf
        if fc <= rem then sc = sc + 1 end
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or GetMyHRP()
        if sp and CreateGrabLine then
            for i = 1, sc do
                pcall(function()
                    CreateGrabLine:FireServer(sp, CFrame.new(
                        math.random(-2010000000, 2000200000), 0,
                        math.random(-2008100000, 2000200000)))
                end)
            end
        end
    end)
end

local function LKA3_StopLag()
    if LKA3_Conn then LKA3_Conn:Disconnect() LKA3_Conn = nil end
end

local function LKA3_Stop()
    LKA3_Running = false
    if LKA3_Task then pcall(task.cancel, LKA3_Task) LKA3_Task = nil end
    LKA3_StopLag()
end

local function LKA3_Execute()
    if LKA3_Running then return end
    LKA3_Running = true
    LKA3_Task = task.spawn(function()
        LKA3_StartLag()
        local height = 35
        task.wait(0.5)
        local myHrp = GetMyHRP()
        if not myHrp then LKA3_Stop() return end
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local hrp = GetPlayerHRP(p)
                if hrp then table.insert(list, hrp) end
            end
        end
        if #list == 0 then task.wait(5) LKA3_Stop() return end
        Notify("Kick", "All (" .. #list .. ") kicked", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local cx = sp and sp.Position.X or 0
        local cz = sp and sp.Position.Z or 0
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for _, hrp in ipairs(list) do
            pcall(function()
                myHrp.CFrame = hrp.CFrame * CFrame.new(0, 5, 5)
                myHrp.AssemblyLinearVelocity = Vector3.zero
            end)
            task.wait(0.2)
            if SetNetworkOwnerEvent then
                pcall(function() SetNetworkOwnerEvent:FireServer(hrp, hrp.CFrame) end)
                pcall(function() SetNetworkOwnerEvent:FireServer(hrp, hrp.CFrame) end)
            end
        end
        local radius = 10
        local step = (math.pi * 2) / math.max(#list, 1)
        for i, hrp in ipairs(list) do
            local a = (i - 1) * step
            local x = math.cos(a) * radius
            local z = math.sin(a) * radius
            pcall(function()
                hrp.CFrame = CFrame.new(cx + x, height, cz + z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end)
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bp.P = 5e11
            bp.Position = Vector3.new(cx + x, height, cz + z)
            bp.Parent = hrp
            task.delay(2, function() pcall(function() bp:Destroy() end) end)
            task.wait()
        end
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for i = 1, 80 do
            for _, hrp in ipairs(list) do
                task.spawn(function()
                    if CreateGrabLine and DestroyGrabLine then
                        pcall(function()
                            CreateGrabLine:FireServer(hrp, CFrame.new(0, 1e9, 0))
                            DestroyGrabLine:FireServer(hrp)
                        end)
                    end
                end)
            end
            task.wait(0.03)
        end
        task.wait(6)
        LKA3_StopLag()
        LKA3_Running = false
    end)
end

-- ============================================================
-- LKS3 (Grab Kick Select Visual Pierce)
-- ============================================================
local LKS3_Conn, LKS3_Running, LKS3_Task = nil, false, nil

local function LKS3_StartLag()
    if LKS3_Conn then LKS3_Conn:Disconnect() LKS3_Conn = nil end
    local targetRate = 1000
    local bpf = math.floor(targetRate / 60)
    local rem = targetRate - (bpf * 60)
    local fc = 0
    LKS3_Conn = RunService.Heartbeat:Connect(function()
        fc = fc + 1
        local sc = bpf
        if fc <= rem then sc = sc + 1 end
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or GetMyHRP()
        if sp and CreateGrabLine then
            for i = 1, sc do
                pcall(function()
                    CreateGrabLine:FireServer(sp, CFrame.new(
                        math.random(-2010000000, 2000200000), 0,
                        math.random(-2008100000, 2000200000)))
                end)
            end
        end
    end)
end

local function LKS3_StopLag()
    if LKS3_Conn then LKS3_Conn:Disconnect() LKS3_Conn = nil end
end

local function LKS3_Stop()
    LKS3_Running = false
    if LKS3_Task then pcall(task.cancel, LKS3_Task) LKS3_Task = nil end
    LKS3_StopLag()
end

local function LKS3_Execute()
    if LKS3_Running then return end
    if not selectedTargetName then Notify("Error", "No target selected", 3) return end
    local targetPlayer = Players:FindFirstChild(selectedTargetName)
    if not targetPlayer then Notify("Error", "Player not found", 3) return end
    LKS3_Running = true
    LKS3_Task = task.spawn(function()
        LKS3_StartLag()
        local height = 35
        task.wait(0.5)
        local myHrp = GetMyHRP()
        if not myHrp then LKS3_Stop() return end
        local tHrp = GetPlayerHRP(targetPlayer)
        if not tHrp then LKS3_StopLag() LKS3_Running = false return end
        Notify("Kick", targetPlayer.DisplayName .. " kicked", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local cx = sp and sp.Position.X or 0
        local cz = sp and sp.Position.Z or 0
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        pcall(function()
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 5, 5)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        task.wait(0.2)
        if SetNetworkOwnerEvent then
            pcall(function() SetNetworkOwnerEvent:FireServer(tHrp, tHrp.CFrame) end)
            pcall(function() SetNetworkOwnerEvent:FireServer(tHrp, tHrp.CFrame) end)
        end
        pcall(function()
            tHrp.CFrame = CFrame.new(cx, height, cz + 5)
            tHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.P = 5e11
        bp.Position = Vector3.new(cx, height, cz + 5)
        bp.Parent = tHrp
        task.delay(2, function() pcall(function() bp:Destroy() end) end)
        pcall(function()
            myHrp.CFrame = CFrame.new(cx, height, cz)
            myHrp.AssemblyLinearVelocity = Vector3.zero
        end)
        for i = 1, 80 do
            task.spawn(function()
                if CreateGrabLine and DestroyGrabLine then
                    pcall(function()
                        CreateGrabLine:FireServer(tHrp, CFrame.new(0, 1e9, 0))
                        DestroyGrabLine:FireServer(tHrp)
                    end)
                end
            end)
            task.wait(0.03)
        end
        task.wait(6)
        LKS3_StopLag()
        LKS3_Running = false
    end)
end

-- ============================================================
-- Spam Kick
-- ============================================================
local SpamKActive, SpamKTask = false, nil
local SpamKLagRunning, SpamKRagdollRunning = false, false
local SpamKSelectedName = nil

local function SpamKTeleportNear(target, myRoot)
    if not target.Character then return end
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot or not myRoot then return end
    local saved = myRoot.CFrame
    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
    for i = 1, 15 do
        if SetNetworkOwnerEvent then
            SetNetworkOwnerEvent:FireServer(tRoot, tRoot.CFrame)
        end
        task.wait()
    end
    myRoot.CFrame = saved
end

local function SpamKWaitChild(parent, name, timeout)
    return parent:FindFirstChild(name) or parent:WaitForChild(name, timeout or 5)
end

local function SpamKSetOwner(part)
    if part and part:IsA("BasePart") and SetNetworkOwnerEvent then
        SetNetworkOwnerEvent:FireServer(part, part.CFrame)
        task.wait()
    end
end

local function SpamKSpawnToy(toyName)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if not folder then
        local pi = Workspace:FindFirstChild("PlotItems")
        folder = pi and pi:FindFirstChild("Plot1") or Workspace
    end
    local result = nil
    local conn = folder.ChildAdded:Connect(function(child)
        if child.Name == toyName then result = child end
    end)
    task.spawn(function()
        pcall(function()
            if SpawnToyRemoteFunction then
                SpawnToyRemoteFunction:InvokeServer(toyName, root.CFrame * CFrame.new(0, 14, 20), Vector3.zero)
            end
        end)
    end)
    local t = tick()
    repeat task.wait(0.05) until result or (tick() - t) > 5
    conn:Disconnect()
    return result
end

local function SpamKSpawnRagdoll()
    if SpamKRagdollRunning then return nil end
    SpamKRagdollRunning = true
    local toy = SpamKSpawnToy("PalletLightBrown")
    if not toy then
        SpamKRagdollRunning = false
        return nil
    end
    local soundPart = SpamKWaitChild(toy, "SoundPart", 3)
    if not soundPart then
        toy:Destroy()
        SpamKRagdollRunning = false
        return nil
    end
    local retry = 0
    while retry < 10 do
        if not SpamKActive then
            toy:Destroy()
            SpamKRagdollRunning = false
            return nil
        end
        SpamKSetOwner(soundPart)
        task.wait()
        if soundPart:FindFirstChild("PartOwner") then break end
        retry = retry + 1
    end
    if not soundPart:FindFirstChild("PartOwner") then
        toy:Destroy()
        SpamKRagdollRunning = false
        return nil
    end
    for _, d in pairs(toy:GetDescendants()) do
        if d:IsA("BasePart") then
            d.CanCollide = false
            d.Transparency = 0.8
        end
    end
    toy.Name = "RagdollPalete"
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Velocity = Vector3.new(0, 900, 0)
    bv.Parent = soundPart
    SpamKRagdollRunning = false
    return toy
end

local function SpamKStartLag()
    if SpamKLagRunning then return end
    SpamKLagRunning = true
    task.spawn(function()
        while SpamKLagRunning do
            local sp = Workspace:FindFirstChild("SpawnLocation")
                or Workspace:FindFirstChild("Spawn")
                or GetMyHRP()
            if sp and CreateGrabLine then
                CreateGrabLine:FireServer(sp, CFrame.new(
                    math.random(-2010000000, 2000200000), 0,
                    math.random(-2008100000, 2000200000)))
            end
            task.wait()
        end
    end)
end

local function SpamKStopLag()
    SpamKLagRunning = false
end

local function SpamKStop()
    SpamKActive = false
    if SpamKTask then pcall(task.cancel, SpamKTask) SpamKTask = nil end
    SpamKStopLag()
    local target = SpamKSelectedName and Players:FindFirstChild(SpamKSelectedName)
    if target and target.Character then
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        if tr and tr:FindFirstChild("ControlBP") then tr.ControlBP:Destroy() end
    end
end

local function SpamKStart(targetName)
    if SpamKActive then return end
    SpamKSelectedName = targetName
    SpamKActive = true
    SpamKStartLag()
    Notify("Kick", targetName .. " kicked", 3)

    SpamKTask = task.spawn(function()
        local ragdoll = nil
        local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")

        while SpamKActive do
            local target = Players:FindFirstChild(targetName)
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if target and myRoot then
                local tChar = target.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")

                if tRoot and tHum then
                    local dist = (myRoot.Position - tRoot.Position).Magnitude
                    if dist > 15 then SpamKTeleportNear(target, myRoot) end

                    if SetNetworkOwnerEvent then
                        SetNetworkOwnerEvent:FireServer(tRoot, tRoot.CFrame)
                    end
                    if DestroyGrabLine then
                        DestroyGrabLine:FireServer(tRoot)
                    end

                    tRoot.AssemblyLinearVelocity = Vector3.zero
                    tRoot.AssemblyAngularVelocity = Vector3.zero

                    local bp = tRoot:FindFirstChild("ControlBP")
                    if not bp then
                        bp = Instance.new("BodyPosition")
                        bp.Name = "ControlBP"
                        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bp.P = 800000
                        bp.Parent = tRoot
                    end
                    bp.Position = myRoot.Position + Vector3.new(5, 10, 5)

                    if ragdoll and ragdoll:IsDescendantOf(Workspace) then
                        local sp = ragdoll:FindFirstChild("SoundPart")
                        if sp then
                            if not sp:FindFirstChild("PartOwner") then
                                ragdoll:Destroy()
                                ragdoll = nil
                            end
                        else
                            ragdoll:Destroy()
                            ragdoll = nil
                        end
                    end
                    if not SpamKRagdollRunning and (not ragdoll or not ragdoll:IsDescendantOf(Workspace)) then
                        ragdoll = folder and folder:FindFirstChild("RagdollPalete") or SpamKSpawnRagdoll()
                    end
                    if ragdoll and ragdoll:FindFirstChild("SoundPart") then
                        local isRag = tHum:FindFirstChild("Ragdolled")
                        if isRag and not isRag.Value then
                            ragdoll.SoundPart.Position = tRoot.Position
                        end
                    end
                end
            end
            task.wait()
        end
    end)
end

-- ============================================================
-- Drift Kick
-- ============================================================
local DriftActive = false
local DriftRadius = 19
local DriftSpeed = 8.5
local DriftHeight = 0
local DriftAngle = 0
local DriftLoopId = 0

local function DriftStop()
    DriftActive = false
    DriftLoopId = DriftLoopId + 1
end

local function DriftStart()
    DriftActive = true
    DriftLoopId = DriftLoopId + 1
    local myLoop = DriftLoopId
    if not selectedTargetName then
        Notify("Error", "No target selected", 2)
        DriftActive = false return
    end
    local target = Players:FindFirstChild(selectedTargetName)
    if not target or not target.Character then
        Notify("Error", "Invalid target", 3)
        DriftActive = false return
    end
    Notify("Kick", target.DisplayName .. " kicked", 3)
    task.spawn(function()
        local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        local blob = inv and inv:FindFirstChild("CreatureBlobman")
        if not blob then
            if ReplicatedStorage.MenuToys and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction") then
                local mr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                pcall(function()
                    ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", mr and mr.CFrame or CFrame.new(0,50,0), Vector3.zero)
                end)
                task.wait(1)
                inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                blob = inv and inv:FindFirstChild("CreatureBlobman")
            end
        end
        if not blob then DriftActive = false return end
        local seat = blob:FindFirstChild("VehicleSeat")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if seat and hum and not hum.Sit then
            pcall(function() seat:Sit(hum) end)
            task.wait(0.6)
        end
        local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        if not blobRoot then DriftActive = false return end
        local savedPos
        local lastTime = tick()
        while DriftActive and myLoop == DriftLoopId and blob and blob.Parent do
            local tgt = Players:FindFirstChild(target.Name)
            if not tgt or not tgt.Character then break end
            local tr = tgt.Character:FindFirstChild("HumanoidRootPart")
            local th = tgt.Character:FindFirstChild("Humanoid")
            if not tr or not th or th.Health <= 0 then break end
            if not savedPos then savedPos = tr.CFrame end
            local center = savedPos + Vector3.new(0, 30, 0)
            local now = tick()
            local dt = now - lastTime
            lastTime = now
            DriftAngle = DriftAngle + DriftSpeed * dt
            local ox = math.cos(DriftAngle) * DriftRadius
            local oz = math.sin(DriftAngle) * DriftRadius
            local blobPos = center.Position + Vector3.new(ox, DriftHeight, oz)
            pcall(function()
                blobRoot.CFrame = CFrame.new(blobPos, center.Position)
                blobRoot.AssemblyLinearVelocity = Vector3.zero
                blobRoot.AssemblyAngularVelocity = Vector3.zero
                tr.CFrame = center
                tr.AssemblyLinearVelocity = Vector3.zero
                tr.AssemblyAngularVelocity = Vector3.zero
                th.PlatformStand = true
                th.Sit = true
                if SetNetworkOwnerEvent then SetNetworkOwnerEvent:FireServer(tr, center) end
            end)
            RunService.Heartbeat:Wait()
        end
        if blobRoot and savedPos then
            pcall(function()
                blobRoot.CFrame = savedPos
                blobRoot.AssemblyLinearVelocity = Vector3.zero
            end)
        end
    end)
end

print("[Singularity hub premium] Part 3 loaded")
-- [Part 3 END] ---- ============================================================
-- Singularity hub premium - FULL FIXED VERSION
-- Part 4 / 8 : Anti System + GodMode
-- ============================================================

-- ============================================================
-- AntiConfig
-- ============================================================
local AntiConfig = {
    AntiGrab = false, AntiVoid = false, AntiRagdoll = false,
    AntiExplode = false, AntiExplodeV2 = false, AntiGucci = false,
    AntiSpamKick = false, AntiLag = false, AntiKick = false,
    AntiKill = false, KickGrab = false,
}

local createGrabLineCopy, extendGrabLineCopy = nil, nil
do
    local gf = ReplicatedStorage:FindFirstChild("GrabEvents")
    if gf then
        local c = gf:FindFirstChild("CreateGrabLine")
        local e = gf:FindFirstChild("ExtendGrabLine")
        if c then createGrabLineCopy = c:Clone() end
        if e then extendGrabLineCopy = e:Clone() end
    end
end

local function DoStruggle()
    pcall(function()
        if StruggleEvent then StruggleEvent:FireServer(LocalPlayer) end
    end)
end

-- ============================================================
-- Anti Explode
-- ============================================================
local AntiExplodeConn = nil
local function SetupAntiExplode()
    if AntiConfig.AntiExplode then
        if AntiExplodeConn then return end
        AntiExplodeConn = Workspace.ChildAdded:Connect(function(child)
            if child.Name:find("Explosion") or child.Name:find("Bomb") then
                pcall(function() child:Destroy() end)
            end
        end)
    else
        if AntiExplodeConn then AntiExplodeConn:Disconnect() AntiExplodeConn = nil end
    end
end

-- ============================================================
-- Anti Gucci
-- ============================================================
local antiGucciRunning = false
local antiGucciToyName = "CreatureBlobman"
local antiGucciInstance = nil
local antiGucciConn = nil
local antiGucciOriginalPos = nil
local ANTI_DURATION = 0.5
local SPAWN_POS = Vector3.new(0, 999999999999999, 0)

local function clearAntiGucciRagdoll()
    local hrp, hum = GetMyHRP(), GetMyHum()
    if hrp and hum and RagdollRemote then
        pcall(function()
            RagdollRemote:FireServer(hrp, 0)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end

local function executeAntiGucciSequence(child)
    if child.Name ~= antiGucciToyName then return end
    antiGucciInstance = child
    local hrp, hum = GetMyHRP(), GetMyHum()
    if not (hrp and hum) then return end
    local seat = child:WaitForChild("VehicleSeat", 2) or child:FindFirstChildWhichIsA("VehicleSeat", true)
    if seat and hum then
        seat:Sit(hum)
        local start = tick()
        while tick() - start < ANTI_DURATION and antiGucciRunning do
            if RagdollRemote then
                pcall(function()
                    RagdollRemote:FireServer(hrp, 0)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
            RunService.Heartbeat:Wait()
        end
        local primary = child.PrimaryPart or child:FindFirstChild("HumanoidRootPart", true) or child:FindFirstChild("Part", true)
        if primary and antiGucciRunning then
            pcall(function()
                if primary.SetNetworkOwner then primary:SetNetworkOwner(LocalPlayer) end
            end)
        end
        if antiGucciOriginalPos then hrp.CFrame = antiGucciOriginalPos end
        task.wait(0.1)
        if seat then seat:Destroy() end
    end
end

local function spawnAntiGucciProcess()
    if not antiGucciRunning then return end
    if not SpawnToyRemoteFunction then return end
    pcall(function()
        SpawnToyRemoteFunction:InvokeServer(antiGucciToyName, CFrame.new(SPAWN_POS), Vector3.new(0, -15.716, 0))
    end)
end

local function startAntiGucciSystem()
    local hrp = GetMyHRP()
    if hrp then antiGucciOriginalPos = hrp.CFrame end
    if antiGucciConn then antiGucciConn:Disconnect() end
    local toysFolder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if toysFolder then
        antiGucciConn = toysFolder.ChildAdded:Connect(function(child)
            task.spawn(function() executeAntiGucciSequence(child) end)
        end)
    end
    task.spawn(function()
        while antiGucciRunning do
            if not antiGucciInstance or not antiGucciInstance.Parent then spawnAntiGucciProcess() end
            task.wait(1)
        end
    end)
end

local function toggleAntiGucci(state)
    AntiConfig.AntiGucci = state
    antiGucciRunning = state
    if state then
        startAntiGucciSystem()
        Notify("Anti Gucci", "Enabled", 3)
    else
        if antiGucciConn then antiGucciConn:Disconnect() antiGucciConn = nil end
        clearAntiGucciRagdoll()
        antiGucciInstance = nil
        antiGucciOriginalPos = nil
        Notify("Anti Gucci", "Disabled", 2)
    end
end

-- ============================================================
-- Anti Kick / Anti Kill
-- ============================================================
local antiKickConn, antiKillConn = nil, nil

local function setupAntiKick(enabled)
    if enabled then
        if antiKickConn then return end
        local ke = ReplicatedStorage:FindFirstChild("Kick")
        if ke and ke:IsA("RemoteEvent") then
            antiKickConn = ke.OnClientEvent:Connect(function() print("[AntiKick] blocked") end)
        end
    else
        if antiKickConn then antiKickConn:Disconnect() antiKickConn = nil end
    end
end

local function setupAntiKill(enabled)
    if enabled then
        if antiKillConn then return end
        local hum = GetMyHum()
        if not hum then return end
        local lastHealth = hum.Health
        antiKillConn = RunService.Heartbeat:Connect(function()
            local ch = GetMyHum()
            if ch then
                if ch.Health < lastHealth then ch.Health = lastHealth else lastHealth = ch.Health end
            end
        end)
    else
        if antiKillConn then antiKillConn:Disconnect() antiKillConn = nil end
    end
end

-- ============================================================
-- Defense Loop（AntiGrab / AntiSpamKick / AntiVoid / AntiRagdoll）
-- ============================================================
local DefenseTimer = 0
RunService.Heartbeat:Connect(function(dt)
    DefenseTimer = DefenseTimer + dt
    if DefenseTimer >= 0.1 then
        if AntiConfig.AntiGrab or AntiConfig.AntiSpamKick then DoStruggle() end
        if AntiConfig.AntiVoid then
            local hrp = GetMyHRP()
            if hrp and hrp.Position.Y < -80 then hrp.CFrame = CFrame.new(0, 10, 0) end
        end
        if AntiConfig.AntiRagdoll then
            local hum = GetMyHum()
            if hum and hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
        DefenseTimer = 0
    end
end)

-- ============================================================
-- Kick Grab（GrabParts 監視）
-- ============================================================
Workspace.ChildAdded:Connect(function(v)
    if v.Name == "GrabParts" and v:IsA("Model") then
        local gp = v:FindFirstChild("GrabPart")
        if not gp then return end
        local wc = gp:FindFirstChild("WeldConstraint")
        if not wc or not wc.Part1 then return end
        local target = wc.Part1
        if AntiConfig.KickGrab then
            task.spawn(function()
                task.wait(0.1)
                local p = Players:GetPlayerFromCharacter(target.Parent)
                if p then
                    pcall(function() SetNetworkOwnerEvent:FireServer(target, target.CFrame) end)
                    pcall(function()
                        local bp = Instance.new("BodyPosition")
                        bp.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                        bp.Position = Vector3.new(25e25, 25e25, 25e25)
                        bp.Parent = target
                        task.wait(0.5)
                        bp:Destroy()
                    end)
                    pcall(function() DestroyGrabLine:FireServer(target) end)
                end
            end)
        end
    end
end)

-- ============================================================
-- Anti Grab NRD（No Ragdoll）
-- ============================================================
local function setupAntiGrabNRD(char)
    if not _G.AntiGrabNRDEnabled then return end
    local hrp  = FWD(char, "HumanoidRootPart", 5)
    local hum  = FWD(char, "Humanoid", 5)
    local head = FWD(char, "Head", 5)
    if not hrp or not hum or not head then return end
    head.ChildAdded:Connect(function(PartOwner)
        if not _G.AntiGrabNRDEnabled then return end
        if PartOwner and PartOwner.Name == "PartOwner" then
            if not _G.AntiGrabNRDProc then
                _G.AntiGrabNRDProc = true
                pcall(function() hum.Sit = false end)
                pcall(function() if _G.StruggleNRD then _G.StruggleNRD:FireServer(LocalPlayer) end end)
                task.spawn(function()
                    while _G.AntiGrabNRDEnabled and (head and head:FindFirstChild("PartOwner")) do
                        pcall(function() if _G.StruggleNRD then _G.StruggleNRD:FireServer(LocalPlayer) end end)
                        pcall(function() if _G.RagdollRemoteNRD then _G.RagdollRemoteNRD:FireServer(hrp, 0) end end)
                        task.wait()
                    end
                end)
                pcall(function() hrp.Anchored = true end)
                if not _G.AGNRDWalk then
                    _G.AGNRDWalk = true
                    while _G.AntiGrabNRDEnabled and task.wait() do
                        local isHeld = LocalPlayer:FindFirstChild("IsHeld")
                        if not isHeld or not isHeld.Value then break end
                        pcall(function()
                            if hum and hum.MoveDirection then
                                hrp.CFrame = hrp.CFrame + hum.MoveDirection * 0.43
                            end
                        end)
                    end
                    _G.AGNRDWalk = false
                end
                pcall(function() hrp.Anchored = false end)
                _G.AntiGrabNRDProc = false
            end
        end
    end)
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name ~= "Head" then
            pcall(function() v.BallSocketConstraint.Enabled = false end)
            if v:FindFirstChild("RagdollLimbPart") then
                pcall(function() v.RagdollLimbPart.WeldConstraint.Enabled = false end)
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if _G.AntiGrabNRDEnabled then
        task.defer(function() setupAntiGrabNRD(char) end)
    end
end)

-- ============================================================
-- Anti Banana Sit
-- ============================================================
local function AntiBananaSitFunction()
    while _G.antiBananaSitActive do
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                hum.Sit = true
                hum:ChangeState(Enum.HumanoidStateType.Running)
                local camera = Workspace.CurrentCamera
                if camera then
                    local lookVec = camera.CFrame.LookVector
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVec.X, 0, lookVec.Z))
                end
            end
        end
        task.wait()
    end
end

-- ============================================================
-- Anti Blobman Kill
-- ============================================================
local function AntiBlobmanKillFunction()
    while _G.antiBlobmanKillActive do
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                hum.Sit = true
                hum:ChangeState(Enum.HumanoidStateType.Running)
                local camera = Workspace.CurrentCamera
                if camera then
                    local lookVec = camera.CFrame.LookVector
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVec.X, 0, lookVec.Z))
                end
            end
        end
        task.wait()
    end
end

-- ============================================================
-- Anti Ragdoll on Blob
-- ============================================================
local function AntiRagBlobFunction()
    local RR = RagdollRemote or (CharacterEvents and CharacterEvents:FindFirstChild("RagdollRemote"))
    local RagdolledSit = false
    local function DiscAR(con)
        if _G.antiRagBlobConnections[con] then
            _G.antiRagBlobConnections[con]:Disconnect()
            _G.antiRagBlobConnections[con] = nil
        end
    end
    local function setupCharacter(char)
        local hum = char and char:FindFirstChild("Humanoid")
        local HRP = char and char:FindFirstChild("HumanoidRootPart")
        if hum and HRP and RR then
            DiscAR("ARSeat")
            _G.antiRagBlobConnections["ARSeat"] = hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
                if hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent.Name == "CreatureBlobman" and not RagdolledSit then
                    RagdolledSit = true
                    local Seat = hum.SeatPart
                    while not hum.Sit do task.wait() end
                    RR:FireServer(HRP, 3)
                    while not (hum:FindFirstChild("Ragdolled") and hum.Ragdolled.Value) and not hum.Sit do task.wait() end
                    task.wait(0.4)
                    hum.Sit = false
                    if Seat and Seat:IsA("Part") then Seat:Sit(hum) end
                    task.delay(0.25, function()
                        while hum and hum.SeatPart do
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                RR:FireServer(LocalPlayer.Character.HumanoidRootPart, 1)
                            end
                            task.wait(0.05)
                        end
                        RagdolledSit = false
                    end)
                end
            end)
        end
    end
    if _G.antiRagBlobActive then
        setupCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
        DiscAR("ARChar")
        _G.antiRagBlobConnections["ARChar"] = LocalPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            setupCharacter(newChar)
        end)
    else
        for _, conn in pairs(_G.antiRagBlobConnections) do if conn then conn:Disconnect() end end
        _G.antiRagBlobConnections = {}
    end
end

-- ============================================================
-- Anti Sticky
-- ============================================================
local function SetupAntiSticky(v)
    pcall(function()
        LocalPlayer.PlayerScripts.StickyPartsTouchDetection.Enabled = not v
    end)
end

-- ============================================================
-- Anti Burn
-- ============================================================
local function SetupAntiBurn(v)
    if v then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        _G.HRP_Burn = char:WaitForChild("HumanoidRootPart", 0.5)
        _G.hum_Burn = char:WaitForChild("Humanoid", 0.5)
        if not (_G.HRP_Burn and _G.hum_Burn) then return end
        local function attachBurnHandler(c)
            if not c then return end
            local h = c:WaitForChild("Humanoid", 5)
            if not h then return end
            local fd = h:WaitForChild("FireDebounce", 5)
            if not fd then return end
            return fd.Changed:Connect(function()
                if h.FireDebounce.Value == true then
                    local plot = Workspace:FindFirstChild("Plots")
                    local plot1 = plot and plot:FindFirstChild("Plot1")
                    local barrier = plot1 and plot1:FindFirstChild("Barrier")
                    local bar = barrier and barrier:FindFirstChild("PlotBarrier")
                    if bar then
                        local pos = bar.CFrame
                        task.spawn(function()
                            repeat task.wait() bar.CFrame = _G.HRP_Burn.CFrame until not _G.hum_Burn.FireDebounce.Value end)
                        task.wait(1)
                        h.FireDebounce.Value = false
                        task.wait()
                        bar.CFrame = pos
                    end
                end
            end)
        end
        _G.antiburn1 = LocalPlayer.CharacterAdded:Connect(function(ch)
            if _G.antiburn then _G.antiburn:Disconnect() end
            task.wait(0.2)
            _G.antiburn = attachBurnHandler(ch)
        end)
        _G.antiburn = attachBurnHandler(char)
    else
        if _G.antiburn then _G.antiburn:Disconnect() _G.antiburn = nil end
        if _G.antiburn1 then _G.antiburn1:Disconnect() _G.antiburn1 = nil end
    end
end

-- ============================================================
-- Anti Kick Break PCLD（修正版：:Once → :Connect + Disconnect）
-- ============================================================
local function ExecuteAntiKickBreakPCLD()
    local serverPos = CFrame.new(-272.2197265625, -7.350403785705566, 475.0108947753906)
    Workspace.FallenPartsDestroyHeight = -math.huge  -- NaN回避
    local storedJoints = {}
    local root, conn, active = nil, nil, false
    local function breakPCLD()
        local char = LocalPlayer.Character
        if not char then return end
        root = char:WaitForChild("HumanoidRootPart")
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then storedJoints[v] = v.Part0; v.Part0 = nil end
        end
        root.CFrame = serverPos
        conn = RunService.RenderStepped:Connect(function()
            if root and root.Parent then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
    local function restore()
        if conn then conn:Disconnect() conn = nil end
        for m, p0 in pairs(storedJoints) do if m and m.Parent then m.Part0 = p0 end end
        storedJoints = {}
    end
    local function toggle()
        active = not active
        if active then breakPCLD() else restore() end
    end
    toggle()
    task.wait(0.12)
    toggle()
    -- :Once → :Connect + Disconnect に修正
    local onceConn
    onceConn = LocalPlayer.CharacterAdded:Connect(function()
        onceConn:Disconnect()
        task.wait(0.25)
        toggle()
        task.wait(0.12)
        toggle()
    end)
end

-- ============================================================
-- Anti Lag（Beam 数監視）
-- ============================================================
Workspace.DescendantAdded:Connect(function(d)
    if d.Name == "GrabBeam" then
        _G.Lines = _G.Lines + 1
        _G.lagger = d.Parent and d.Parent.Parent and d.Parent.Parent.Parent
    end
end)

local function SetupAntiLag(v)
    _G.Lines = 0
    pcall(function()
        LocalPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = not v
    end)
end

local function StartAutoAntiLag()
    task.spawn(function()
        while _G.autoantilag and task.wait() do
            if _G.Lines > 100 then
                pcall(function()
                    LocalPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = false
                end)
                Notify("Auto Anti Lag", (_G.lagger and _G.lagger.Name or "Unknown") .. " Lagged Server", 6.5)
                _G.Lines = 0
            end
        end
    end)
end

-- ============================================================
-- Anti Input Lag
-- ============================================================
local function executeWithoutLag(holdRemote, dropRemote, item, character, highPos)
    task.spawn(function()
        holdRemote:InvokeServer(item, character)
        RunService.Heartbeat:Wait()
        dropRemote:InvokeServer(item, highPos, highPos)
    end)
end

local function StartAntiInputLag()
    _G.antiInputLagTask = task.spawn(function()
        while _G.AntiExtra.AntiInputLag do
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local toysFolder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            -- continue を排除
            if not toysFolder then
                task.wait(0.1)
            else
                local toy = toysFolder:FindFirstChild(_G.SelectedAntiInputToy)
                if not toy then
                    pcall(function() SpawnToyRemoteFunction:InvokeServer(_G.SelectedAntiInputToy, hrp.CFrame * CFrame.new(0, 5, 0), Vector3.zero) end)
                    local t0 = tick()
                    repeat
                        RunService.Heartbeat:Wait()
                        toysFolder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                        toy = toysFolder and toysFolder:FindFirstChild(_G.SelectedAntiInputToy)
                    until toy or tick() - t0 > 1
                end
                if toy and toy.Parent then
                    local holdPart = toy:FindFirstChild("HoldPart")
                    if holdPart then
                        local holdingPlayer = holdPart:FindFirstChild("HoldingPlayer")
                        holdingPlayer = holdingPlayer and holdingPlayer.Value
                        if holdingPlayer and holdingPlayer ~= LocalPlayer then
                            pcall(function() holdPart.DropItemRemoteFunction:InvokeServer(toy, hrp.CFrame * CFrame.new(0, 2000, 0), Vector3.zero) end)
                            toy:Destroy()
                        else
                            local highPos = hrp.CFrame * CFrame.new(0, 2000, 0)
                            executeWithoutLag(holdPart.HoldItemRemoteFunction, holdPart.DropItemRemoteFunction, toy, char, highPos)
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end
    end)
end

-- ============================================================
-- Remove All Anti Input
-- ============================================================
local function StartRemoveAllAntiInput()
    _G.removeAntiInputTask = task.spawn(function()
        local AllowedItems = { FoodHamburger = true, FoodCoconut = true, FoodPizzaCheese = true, FoodPizzaPepperoni = true, FoodHotdog = true, FoodMushroomPoison = true, FoodBread = true, FoodDippyEgg = true, FoodMayonnaise = true, FoodFrenchFries = true, FoodMeatStick = true, FoodDonut = true, FoodCakePink = true, InstrumentGuitarBanjo = true, InstrumentGuitarViolin = true, InstrumentGuitarUkulele = true, InstrumentWoodwindSaxophone = true, InstrumentWoodwindOcarina = true, InstrumentBrassVuvuzelaQwizik = true, InstrumentBrassTrumpet = true, InstrumentDrumBongos = true, InstrumentDrumSnare = true, InstrumentPianoMelodica = true, InstrumentVoiceMicrophone = true, CupMugWhite = true, CupMugBrown = true, PoopPile = true, PoopPileSparkle = true }
        local burgers = {}
        local descConnection = workspace.DescendantAdded:Connect(function(obj)
            if AllowedItems[obj.Name] and obj:IsA("Model") then
                task.spawn(function()
                    if obj:WaitForChild("HoldPart", 3) then table.insert(burgers, obj) end
                end)
            end
        end)
        for _, v in ipairs(workspace:GetDescendants()) do
            if AllowedItems[v.Name] and v:IsA("Model") and v:FindFirstChild("HoldPart") then
                table.insert(burgers, v)
            end
        end
        while _G.antiAntiLagEnabled do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i = #burgers, 1, -1 do
                    local b = burgers[i]
                    if not b or not b.Parent or not b:FindFirstChild("HoldPart") then
                        table.remove(burgers, i)
                    else
                        local hp = b.HoldPart
                        pcall(function() hp.HoldItemRemoteFunction:InvokeServer(b, char) end)
                        task.wait()
                        pcall(function() hp.DropItemRemoteFunction:InvokeServer(b, CFrame.new(hrp.Position + Vector3.new(0, -2000, 0)), Vector3.new(0, 0, 0)) end)
                    end
                end
            end
            task.wait()
        end
        descConnection:Disconnect()
    end)
end

-- ============================================================
-- God Mode（修正版）
-- ============================================================
_G.GodMode = _G.GodMode or {}
_G.GodMode.isRunning = false
_G.GodMode.originalFallenHeight = Workspace.FallenPartsDestroyHeight
_G.GodMode.lastOriginalCFrame = nil
_G.GodMode.loopCoroutine = nil

local function enableFallenProtection()
    _G.GodMode.originalFallenHeight = Workspace.FallenPartsDestroyHeight
    Workspace.FallenPartsDestroyHeight = -math.huge  -- NaN回避
end
local function disableFallenProtection()
    Workspace.FallenPartsDestroyHeight = _G.GodMode.originalFallenHeight ~= nil and _G.GodMode.originalFallenHeight or -100
end
local function executeCircle()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if _G.GodMode.lastOriginalCFrame == nil then _G.GodMode.lastOriginalCFrame = root.CFrame end
    local original = root.CFrame
    local startTime = tick()
    local radius = 10000
    while tick() - startTime < 1 and _G.GodMode.isRunning do
        if not LocalPlayer.Character or not root.Parent then return end
        local t = tick() * 12
        local x = math.cos(t) * radius
        local z = math.sin(t) * radius
        root.CFrame = original + Vector3.new(x, -10000, z)
        RunService.RenderStepped:Wait()
    end
    if _G.GodMode.isRunning and root and root.Parent then
        root.CFrame = original
    end
end
local function teleportToOriginalPosition()
    local char = LocalPlayer.Character
    if char and _G.GodMode.lastOriginalCFrame then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = _G.GodMode.lastOriginalCFrame end
    end
end
local function startGodMode()
    if _G.GodMode.isRunning then return end
    _G.GodMode.isRunning = true
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then _G.GodMode.lastOriginalCFrame = root.CFrame end
    end
    enableFallenProtection()
    _G.GodMode.loopCoroutine = coroutine.wrap(function()
        while _G.GodMode.isRunning do
            if not LocalPlayer.Character then
                task.wait(0.5)
            else
                executeCircle()
            end
            task.wait(0.0001)
        end
    end)
    _G.GodMode.loopCoroutine()
end
local function stopGodMode()
    _G.GodMode.isRunning = false
    _G.GodMode.loopCoroutine = nil
    teleportToOriginalPosition()
    disableFallenProtection()
end
LocalPlayer.CharacterAdded:Connect(function(character)
    if _G.GodMode.isRunning then
        task.wait(0.1)
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(0, -15000, 0) end
    end
end)

print("[Singularity hub premium] Part 4 loaded")
-- [Part 4 END] ---- ============================================================
-- Singularity hub premium - FULL FIXED VERSION
-- Part 5 / 8 : BlobmanKill
-- ============================================================

local BlobmanKill = {}
BlobmanKill.isRunning = false
BlobmanKill.isKillAura = false
BlobmanKill.isSelectedKill = false
BlobmanKill.selectedPlayer = nil
BlobmanKill.currentBlobman = nil
BlobmanKill.killAuraConnection = nil
BlobmanKill.selectedKillConn = nil

local TP_WAIT = 0.02
local GRAB_WAIT = 0.01
local RETRY_WAIT = 0.01
local MAX_RETRIES = 5
local MAX_BLOBMAN_DISTANCE = 500

-- ============================================================
-- GetSeatedBlobman（座っているBlobmanを取得）
-- ============================================================
local function GetSeatedBlobman()
    local char = LocalPlayer.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local seat = humanoid.SeatPart
    if not seat or not seat:IsA("VehicleSeat") then return nil end
    local obj = seat
    while obj do
        if obj:IsA("Model") and obj.Name == "CreatureBlobman" then
            return obj
        end
        obj = obj.Parent
    end
    return nil
end

-- ============================================================
-- SpawnBlobman（Blobmanをスポーン or 取得）
-- ============================================================
function BlobmanKill.SpawnBlobman()
    local seatedBlobman = GetSeatedBlobman()
    if seatedBlobman then
        BlobmanKill.currentBlobman = seatedBlobman
        return seatedBlobman
    end

    if BlobmanKill.currentBlobman and BlobmanKill.currentBlobman.Parent then
        local blobmanPos = nil
        if BlobmanKill.currentBlobman.PrimaryPart then
            blobmanPos = BlobmanKill.currentBlobman.PrimaryPart.Position
        else
            local part = BlobmanKill.currentBlobman:FindFirstChildWhichIsA("BasePart")
            if part then blobmanPos = part.Position end
        end
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local localPos = rootPart and rootPart.Position
        if blobmanPos and localPos and (blobmanPos - localPos).Magnitude < MAX_BLOBMAN_DISTANCE then
            local seat = BlobmanKill.currentBlobman:FindFirstChild("VehicleSeat")
            if seat then
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    seat:Sit(humanoid)
                    task.wait(0.08)
                end
            end
            return BlobmanKill.currentBlobman
        else
            pcall(function() BlobmanKill.currentBlobman:Destroy() end)
            BlobmanKill.currentBlobman = nil
        end
    end

    local character = LocalPlayer.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
    local success, err = pcall(function()
        SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
    end)
    if not success then
        warn("SpawnBlobman remote failed: " .. tostring(err))
        return nil
    end

    local toyFolderName = LocalPlayer.Name .. "SpawnedInToys"
    local blobman = nil
    local startTime = tick()
    repeat
        local toyFolder = Workspace:FindFirstChild(toyFolderName)
        if toyFolder then
            blobman = toyFolder:FindFirstChild("CreatureBlobman")
        end
        if blobman then break end
        task.wait()
    until tick() - startTime > 2

    if not blobman then return nil end
    BlobmanKill.currentBlobman = blobman

    local seat = blobman:FindFirstChild("VehicleSeat")
    if seat then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            seat:Sit(humanoid)
        end
    end
    task.wait(0.08)
    return blobman
end

-- ============================================================
-- KillPlayer（対象プレイヤーを倒す）
-- ============================================================
function BlobmanKill.KillPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    for _ = 1, MAX_RETRIES do
        local success = pcall(function()
            humanoid.BreakJointsOnDeath = false
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end)
        if success and humanoid.Health <= 0 then
            return true
        end
        task.wait(RETRY_WAIT)
    end
    return false
end

-- ============================================================
-- GrabRelease（Blobmanで掴んで離す）
-- ============================================================
function BlobmanKill.GrabRelease(blobman, targetRoot)
    if not blobman or not targetRoot then return end
    pcall(function()
        local script = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
        if script then
            local grabEvent = script:FindFirstChild("CreatureGrab")
            local releaseEvent = script:FindFirstChild("CreatureRelease")
            if grabEvent and releaseEvent then
                grabEvent:FireServer(
                    blobman.LeftDetector,
                    targetRoot,
                    blobman.LeftDetector.LeftWeld
                )
                releaseEvent:FireServer(
                    blobman.LeftDetector.LeftWeld
                )
            end
        end
    end)
end

-- ============================================================
-- ProcessPlayer（1人のプレイヤーを処理）
-- ============================================================
function BlobmanKill.ProcessPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    local blobman = BlobmanKill.SpawnBlobman()
    if not blobman then return false end
    local localChar = LocalPlayer.Character
    if localChar and localChar:FindFirstChild("HumanoidRootPart") then
        localChar.HumanoidRootPart.CFrame = targetRoot.CFrame
        task.wait(TP_WAIT)
    end
    BlobmanKill.KillPlayer(targetPlayer)
    for _ = 1, 3 do
        BlobmanKill.GrabRelease(blobman, targetRoot)
        task.wait(GRAB_WAIT)
    end
    return true
end

-- ============================================================
-- ProcessAllPlayers（全プレイヤーを処理） - continue 排除
-- ============================================================
function BlobmanKill.ProcessAllPlayers()
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = localChar.HumanoidRootPart
    local blobman = BlobmanKill.SpawnBlobman()
    if not blobman then return end

    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, player)
        end
    end

    for _, player in ipairs(targets) do
        if not BlobmanKill.isRunning then break end
        local targetChar = player.Character
        -- continue を if/else に置換
        if targetChar then
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    rootPart.CFrame = targetRoot.CFrame
                    task.wait(TP_WAIT)
                    BlobmanKill.KillPlayer(player)
                    for _ = 1, 2 do
                        BlobmanKill.GrabRelease(blobman, targetRoot)
                        task.wait(GRAB_WAIT)
                    end
                end
            end
        end
    end
end

-- ============================================================
-- StartSelectedKillLoop（選択したプレイヤーをループキル）
-- ============================================================
function BlobmanKill.StartSelectedKillLoop()
    if BlobmanKill.selectedKillConn then
        pcall(task.cancel, BlobmanKill.selectedKillConn)
        BlobmanKill.selectedKillConn = nil
    end
    if not BlobmanKill.selectedPlayer then return end
    BlobmanKill.selectedKillConn = task.spawn(function()
        while BlobmanKill.isSelectedKill and BlobmanKill.selectedPlayer and BlobmanKill.selectedPlayer.Parent do
            if BlobmanKill.selectedPlayer.Character and BlobmanKill.selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(BlobmanKill.ProcessPlayer, BlobmanKill.selectedPlayer)
            end
            task.wait(0.5)
        end
    end)
end

-- ============================================================
-- SetupKillAura（キルオーラ）
-- ============================================================
function BlobmanKill.SetupKillAura()
    if BlobmanKill.killAuraConnection then
        BlobmanKill.killAuraConnection:Disconnect()
        BlobmanKill.killAuraConnection = nil
    end
    local auraRange = 40
    BlobmanKill.killAuraConnection = RunService.Heartbeat:Connect(function()
        if not (BlobmanKill.isKillAura or BlobmanKill.isRunning) then return end
        local localChar = LocalPlayer.Character
        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
        local localRoot = localChar.HumanoidRootPart
        if not BlobmanKill.currentBlobman or not BlobmanKill.currentBlobman.Parent then
            BlobmanKill.currentBlobman = BlobmanKill.SpawnBlobman()
            if not BlobmanKill.currentBlobman then return end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                if (localRoot.Position - targetRoot.Position).Magnitude <= auraRange then
                    BlobmanKill.KillPlayer(player)
                    BlobmanKill.GrabRelease(BlobmanKill.currentBlobman, targetRoot)
                end
            end
        end
    end)
end

-- ============================================================
-- UpdateKillAuraConnection
-- ============================================================
function BlobmanKill.UpdateKillAuraConnection()
    local shouldRun = BlobmanKill.isKillAura or BlobmanKill.isRunning
    if shouldRun then
        if not BlobmanKill.killAuraConnection then
            BlobmanKill.SetupKillAura()
        end
    else
        if BlobmanKill.killAuraConnection then
            BlobmanKill.killAuraConnection:Disconnect()
            BlobmanKill.killAuraConnection = nil
        end
    end
end

-- ============================================================
-- RemoveAntiKickFunction（対象のAntiKickを除去）
-- ============================================================
local function RemoveAntiKickFunction(targetName)
    local SetNetOwner = SetNetworkOwnerEvent
    local function invis_touch(part, cf)
        pcall(function() SetNetOwner:FireServer(part, cf) end)
    end
    local function CheckAndYeet(toy)
        local part = toy:FindFirstChild("SoundPart")
        if part then
            invis_touch(part, part.CFrame)
            if part:FindFirstChild("PartOwner") and part.PartOwner.Value == LocalPlayer.Name then
                part.CFrame = CFrame.new(0, 1000, 0)
            end
        end
    end
    while _G.antiAntiKickActive do
        local target = Players:FindFirstChild(targetName)
        if target then
            local spawned = Workspace:FindFirstChild(target.Name .. "SpawnedInToys")
            if spawned then
                if spawned:FindFirstChild("NinjaKunai") then CheckAndYeet(spawned.NinjaKunai) end
                if spawned:FindFirstChild("NinjaShuriken") then CheckAndYeet(spawned.NinjaShuriken) end
                if spawned:FindFirstChild("AntiKick") then CheckAndYeet(spawned.AntiKick) end
            end
        end
        task.wait(0.1)
    end
end

-- ============================================================
-- RemoveAntiKickAuraFunction（周囲のAntiKickを除去） - continue 排除
-- ============================================================
local function RemoveAntiKickAuraFunction()
    while _G.removeAntiKickAuraActive do
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        -- continue を if/else に置換
        if myRoot then
            for _, target in ipairs(Players:GetPlayers()) do
                if target ~= LocalPlayer then
                    local tChar = target.Character
                    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        if (tRoot.Position - myRoot.Position).Magnitude <= _G.removeAntiKickRadius then
                            local spawned = Workspace:FindFirstChild(target.Name .. "SpawnedInToys")
                            if spawned then
                                for _, toyName in ipairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
                                    local toy = spawned:FindFirstChild(toyName)
                                    if toy then
                                        local part = toy:FindFirstChild("SoundPart")
                                        if part then
                                            pcall(function()
                                                SetNetworkOwnerEvent:FireServer(part, part.CFrame)
                                            end)
                                            if part:FindFirstChild("PartOwner") and part.PartOwner.Value == LocalPlayer.Name then
                                                part.CFrame = CFrame.new(0, 1000, 0)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

-- ============================================================
-- RemoveTargetAntiKick（1回だけAntiKick除去）
-- ============================================================
local function RemoveTargetAntiKick(target)
    if not target or not target.Character then return false end
    local removed = false
    local spawned = Workspace:FindFirstChild(target.Name .. "SpawnedInToys")
    if spawned then
        for _, toyName in ipairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
            local toy = spawned:FindFirstChild(toyName)
            if toy then
                local part = toy:FindFirstChild("SoundPart")
                if part then
                    pcall(function() SetNetworkOwnerEvent:FireServer(part, part.CFrame) end)
                    part.CFrame = CFrame.new(0, 1000, 0)
                    removed = true
                end
                pcall(function() if DestroyToy then DestroyToy:FireServer(toy) end end)
            end
        end
    end
    return removed
end

-- ============================================================
-- 外部から参照できるように _G に登録
-- ============================================================
_G.BlobmanKill = BlobmanKill
_G.RemoveAntiKickFunction = RemoveAntiKickFunction
_G.RemoveAntiKickAuraFunction = RemoveAntiKickAuraFunction
_G.RemoveTargetAntiKick = RemoveTargetAntiKick

print("[Singularity hub premium] Part 5 loaded")
-- [Part 5 END] ---- ============================================================
-- Singularity hub premium - FULL FIXED VERSION
-- Part 6 / 8 : Exploits
-- ============================================================

-- ============================================================
-- LoopBlobKickSpamFunction（Blobmanでスパムキック）
-- ============================================================
local function LoopBlobKickSpamFunction()
    local GE = ReplicatedStorage:WaitForChild("GrabEvents")
    local REMOTE_DELAY = 0.002
    local lastRemote = 0
    local savedPos = nil
    while _G.loopBlobKickSpamActive do
        local target = Players:FindFirstChild(_G.loopBlobKickSpamTargetName)
        -- continue を if/else に置換
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.3)
        else
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local seat = hum.SeatPart
            if not seat or seat.Parent.Name ~= "CreatureBlobman" then
                Notify("Error", "Please sit on a Blobman", 5)
                if Toggles.BlobSpamKickToggle then Toggles.BlobSpamKickToggle:SetValue(false) end
                return
            end
            local blob = seat.Parent
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:WaitForChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj:WaitForChild("CreatureGrab")
            local CD = scriptObj:WaitForChild("CreatureDrop")
            local R_Det = blob:WaitForChild("RightDetector")
            savedPos = blobRoot.CFrame
            local dragging = false
            local grabStartTime = 0
            while _G.loopBlobKickSpamActive do
                local currentTarget = Players:FindFirstChild(_G.loopBlobKickSpamTargetName)
                if not currentTarget then break end
                char = LocalPlayer.Character
                hum = char and char:FindFirstChild("Humanoid")
                seat = hum and hum.SeatPart
                if not seat or seat.Parent.Name ~= "CreatureBlobman" then break end
                blobRoot = seat.Parent:FindFirstChild("HumanoidRootPart") or seat.Parent.PrimaryPart
                local tChar = currentTarget.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if tRoot and tHum and tHum.Health > 0 and blobRoot then
                    tRoot.Velocity = Vector3.zero
                    if not dragging then
                        blobRoot.CFrame = tRoot.CFrame
                        blobRoot.Velocity = Vector3.zero
                        if tick() - lastRemote >= REMOTE_DELAY then
                            lastRemote = tick()
                            pcall(function()
                                tHum.PlatformStand = true
                                tHum.Sit = true
                                GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                                GE.DestroyGrabLine:FireServer(tRoot)
                            end)
                        end
                        if grabStartTime == 0 then grabStartTime = tick() end
                        if tick() - grabStartTime > 0.35 then
                            dragging = true
                            grabStartTime = 0
                            blobRoot.CFrame = savedPos
                        end
                    else
                        blobRoot.CFrame = savedPos
                        blobRoot.Velocity = Vector3.zero
                        local lockPos = savedPos * CFrame.new(0, 23, 0)
                        tRoot.CFrame = lockPos
                        tHum.PlatformStand = true
                        tHum.Sit = true
                        if tick() - lastRemote >= REMOTE_DELAY then
                            lastRemote = tick()
                            pcall(function()
                                GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                                GE.DestroyGrabLine:FireServer(tRoot)
                                local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                                if weld then
                                    CD:FireServer(weld)
                                    CG:FireServer(R_Det, tRoot, weld)
                                end
                            end)
                        end
                    end
                else
                    dragging = false
                    grabStartTime = 0
                end
                RunService.Heartbeat:Wait()
            end
            if blobRoot then blobRoot.CFrame = savedPos end
        end
    end
end

-- ============================================================
-- LoopKill1Function（ループキル1）
-- ============================================================
local function LoopKill1Function()
    while _G.loopKill1Active do
        local target = Players:FindFirstChild(_G.loopKill1TargetName)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            local tHum = target.Character:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local currentPos = myRoot.CFrame
                    local attackStart = tick()
                    while tick() - attackStart < 0.35 and _G.loopKill1Active do
                        if not tRoot.Parent then break end
                        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
                        myRoot.Velocity = Vector3.zero
                        pcall(function()
                            ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
                            tHum.BreakJointsOnDeath = false
                            tHum:ChangeState(Enum.HumanoidStateType.Dead)
                            ReplicatedStorage.GrabEvents.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                            ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(tRoot)
                        end)
                        RunService.Heartbeat:Wait()
                    end
                    if myRoot then
                        myRoot.CFrame = currentPos
                        myRoot.Velocity = Vector3.zero
                    end
                end
            end
        end
        task.wait(0.05)
    end
end

-- ============================================================
-- LoopKill2Function（ループキル2 - Anti Pierce）
-- ============================================================
local function LoopKill2Function()
    local SETTINGS = {
        ATTACK_FRAME_LIMIT = 18,
        OFFSET = CFrame.new(0, 0, 2.5)
    }
    while _G.loopKill2Active do
        local target = Players:FindFirstChild(_G.loopKill2TargetName)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            local tHum = target.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local originalPos = myRoot.CFrame
                    local frameCount = 0
                    while frameCount < SETTINGS.ATTACK_FRAME_LIMIT and tHum and tHum.Health > 0 and _G.loopKill2Active do
                        frameCount = frameCount + 1
                        myRoot.CFrame = tRoot.CFrame * SETTINGS.OFFSET
                        myRoot.Velocity = Vector3.zero
                        myRoot.RotVelocity = Vector3.zero
                        pcall(function()
                            ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
                            tHum.BreakJointsOnDeath = false
                            tHum:ChangeState(Enum.HumanoidStateType.Dead)
                            ReplicatedStorage.GrabEvents.CreateGrabLine:FireServer(tRoot, Vector3.new(0, -200, 0), tRoot.Position, true)
                            ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(tRoot)
                        end)
                        RunService.Heartbeat:Wait()
                    end
                    if myRoot then myRoot.CFrame = originalPos end
                end
            end
        end
        task.wait(0.05)
    end
end

-- ============================================================
-- SpamKickGrabFunction（スパムキック - Grab）
-- ============================================================
local function SpamKickGrabFunction()
    local targetName = _G.loopBlobKickSpamTargetName or selectedTargetName
    local target = targetName and Players:FindFirstChild(targetName)
    if not target then
        if Toggles.SpamKickGrabToggle then Toggles.SpamKickGrabToggle:SetValue(false) end
        Notify("Error", "Target not found", 3)
        return
    end
    local GE = ReplicatedStorage:WaitForChild("GrabEvents")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local savedPos = myRoot.CFrame
    local dragging, grabStartTime = false, 0
    while _G.kickLoopEnabled do
        if not target or not target.Parent then
            _G.kickLoopEnabled = false
            if Toggles.SpamKickGrabToggle then Toggles.SpamKickGrabToggle:SetValue(false) end
            break
        end
        local tChar, tRoot, tHum = target.Character, nil, nil
        if tChar then
            tRoot = tChar:FindFirstChild("HumanoidRootPart")
            tHum = tChar:FindFirstChild("Humanoid")
        end
        myChar = LocalPlayer.Character
        myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if tRoot and tHum and tHum.Health > 0 and myRoot then
            tRoot.Velocity = Vector3.zero
            if not dragging then
                myRoot.CFrame = tRoot.CFrame
                pcall(function()
                    tHum.PlatformStand = true
                    tHum.Sit = true
                    GE.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                end)
                if grabStartTime == 0 then grabStartTime = tick() end
                if tick() - grabStartTime > 0.35 then
                    dragging = true
                    grabStartTime = 0
                end
            else
                myRoot.CFrame = savedPos
                local lockPos = savedPos * CFrame.new(0, 17, 0)
                tRoot.CFrame = lockPos
                tHum.PlatformStand = true
                tHum.Sit = false
                pcall(function()
                    GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    GE.DestroyGrabLine:FireServer(tRoot)
                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                end)
            end
        else
            dragging = false
            grabStartTime = 0
            if myRoot then myRoot.CFrame = savedPos end
        end
        RunService.Heartbeat:Wait()
    end
    if myRoot then myRoot.CFrame = savedPos end
end

-- ============================================================
-- SnowballRagdollFunction（スノーボールでラグドール化）
-- ============================================================
local function SnowballRagdollFunction()
    while _G.snowballRagdollActive do
        local target = Players:FindFirstChild(_G.snowballRagdollTargetName)
        -- continue を if/else に置換
        if not target or not target.Character then
            task.wait(0.5)
        else
            local tChar = target.Character
            local torso = tChar and (tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso"))
            if not torso then
                task.wait()
            else
                pcall(function()
                    local offset = Vector3.new(
                        math.random(-30, 30) / 100,
                        math.random(-30, 30) / 100,
                        math.random(-30, 30) / 100
                    )
                    local spawnCFrame = torso.CFrame * CFrame.new(offset)
                    SpawnToyRemoteFunction:InvokeServer("BallSnowball", spawnCFrame, Vector3.zero)
                end)
                local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                if folder then
                    for _, snowball in pairs(folder:GetChildren()) do
                        if snowball.Name == "BallSnowball" and snowball.Parent then
                            local part = snowball.PrimaryPart or snowball:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local offset = Vector3.new(
                                    math.random(-30, 30) / 100,
                                    math.random(-30, 30) / 100,
                                    math.random(-30, 30) / 100
                                )
                                part.CFrame = torso.CFrame * CFrame.new(offset)
                                part.AssemblyLinearVelocity = Vector3.zero
                                part.AssemblyAngularVelocity = Vector3.zero
                            end
                        end
                    end
                end
                task.wait()
            end
        end
    end
end

-- ============================================================
-- 外部参照可能に
-- ============================================================
_G.LoopBlobKickSpamFunction = LoopBlobKickSpamFunction
_G.LoopKill1Function = LoopKill1Function
_G.LoopKill2Function = LoopKill2Function
_G.SpamKickGrabFunction = SpamKickGrabFunction
_G.SnowballRagdollFunction = SnowballRagdollFunction

print("[Singularity hub premium] Part 6 loaded")
-- [Part 6 END] ---- ============================================================
-- Singularity hub premium - FULL FIXED VERSION
-- Part 7 / 8 : 【新規】写真の4機能
-- ============================================================

-- ============================================================
-- 【機能1】ネットワークオーナーシップ強制奪取
-- 目的：サーバー内すべてのプレイヤー・オブジェクトの
--       物理演算権限（Network Ownership）を自分に固定する
-- ============================================================
local function ForceNetworkOwner(part)
    if not part or not part.Parent then return end
    -- Roblox標準API（サーバー側で受け入れられれば成功）
    pcall(function()
        if part.SetNetworkOwner then
            part:SetNetworkOwner(LocalPlayer)
        end
    end)
    -- リモート経由での強制（ゲーム側の SetNetworkOwner イベント）
    pcall(function()
        if SetNetworkOwnerEvent then
            SetNetworkOwnerEvent:FireServer(part, part.CFrame)
        end
    end)
end

local function ForceAllPlayersOwnership()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    ForceNetworkOwner(part)
                end
            end
        end
    end
end

local function ForceAllObjectsOwnership()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj:FindFirstChild("PartOwner") then
            ForceNetworkOwner(obj)
        end
    end
end

function _G.NetworkOwnership.Start()
    if _G.NetworkOwnership.isActive then return end
    _G.NetworkOwnership.isActive = true
    _G.NetworkOwnership.connection = RunService.Heartbeat:Connect(function()
        if not _G.NetworkOwnership.isActive then return end
        -- 毎フレーム実行すると重いので、0.2秒間隔に制限（iOS最適化）
        local now = tick()
        if now - _G.NetworkOwnership.lastForceTime < 0.2 then return end
        _G.NetworkOwnership.lastForceTime = now
        pcall(ForceAllPlayersOwnership)
        pcall(ForceAllObjectsOwnership)
    end)
    Notify("Network Ownership", "強制奪取開始", 3)
end

function _G.NetworkOwnership.Stop()
    _G.NetworkOwnership.isActive = false
    if _G.NetworkOwnership.connection then
        _G.NetworkOwnership.connection:Disconnect()
        _G.NetworkOwnership.connection = nil
    end
    Notify("Network Ownership", "停止", 2)
end

-- ============================================================
-- 【機能2】アンチ・アタッチメント＆インスタント・リバース
-- 目的：相手が自分を掴もうとした瞬間に、
--       アタッチメント（接続）を即座に解除し、
--       相手を高速でマップ外に射出する
-- ============================================================
local function InstantReverse(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local localChar = LocalPlayer.Character
    if not localChar then return end
    local myRoot = localChar:FindFirstChild("HumanoidRootPart")
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return end

    pcall(function()
        -- 相手の位置を瞬時に自分から遠ざける
        local awayDir = (tRoot.Position - myRoot.Position)
        if awayDir.Magnitude > 0.1 then
            awayDir = awayDir.Unit
        else
            awayDir = Vector3.new(1, 0, 1).Unit
        end
        tRoot.CFrame = CFrame.new(myRoot.Position + awayDir * 500) * tRoot.CFrame.Rotation
        tRoot.AssemblyLinearVelocity = Vector3.zero
        tRoot.AssemblyAngularVelocity = Vector3.zero
    end)

    pcall(function()
        -- 相手のネットワークオーナーを強制変更してラグらせる
        if SetNetworkOwnerEvent then
            SetNetworkOwnerEvent:FireServer(tRoot, tRoot.CFrame)
        end
    end)
end

local function RemoveAttachmentsFromMe()
    local localChar = LocalPlayer.Character
    if not localChar then return end
    local myRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    -- 自分に付いている不正なWeld / WeldConstraint / Motor6Dを除去
    for _, obj in ipairs(myRoot:GetChildren()) do
        if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
            -- 自分のキャラクター同士の正規Weldは残す
            if obj.Part0 and obj.Part1 then
                local p0 = obj.Part0
                local p1 = obj.Part1
                local p0InMe = p0:IsDescendantOf(localChar)
                local p1InMe = p1:IsDescendantOf(localChar)
                -- 片方だけ自分の中にある場合は外部からのアタッチメント
                if (p0InMe and not p1InMe) or (p1InMe and not p0InMe) then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
end

function _G.AntiAttachment.Start()
    if _G.AntiAttachment.isActive then return end
    _G.AntiAttachment.isActive = true
    _G.AntiAttachment.connection = RunService.Heartbeat:Connect(function()
        if not _G.AntiAttachment.isActive then return end
        local now = tick()
        if now - _G.AntiAttachment.lastReverseTime < 0.05 then return end
        _G.AntiAttachment.lastReverseTime = now

        local localChar = LocalPlayer.Character
        if not localChar then return end
        local myRoot = localChar:FindFirstChild("HumanoidRootPart")
        local myHum = localChar:FindFirstChildOfClass("Humanoid")
        if not myRoot or not myHum then return end

        -- 自分の近くにいる相手を即座にリバース
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and (tRoot.Position - myRoot.Position).Magnitude < 15 then
                    InstantReverse(player)
                end
            end
        end

        -- 自分に付いている外部アタッチメントを除去
        pcall(RemoveAttachmentsFromMe)
    end)
    Notify("Anti Attachment", "有効化", 3)
end

function _G.AntiAttachment.Stop()
    _G.AntiAttachment.isActive = false
    if _G.AntiAttachment.connection then
        _G.AntiAttachment.connection:Disconnect()
        _G.AntiAttachment.connection = nil
    end
    Notify("Anti Attachment", "停止", 2)
end

-- ============================================================
-- 【機能3】スクリプト・ソース・フリーズ
-- 目的：他のプレイヤーが発行するRemoteEvent通信を検知し、
--       クラッシュさせる（相手のスクリプトを無力化）
-- ============================================================
local function FreezeCharacter(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end
    pcall(function()
        tRoot.Anchored = true
        tRoot.AssemblyLinearVelocity = Vector3.zero
        tRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function UnfreezeCharacter(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end
    pcall(function()
        tRoot.Anchored = false
    end)
end

local function SpamRemoteEvents()
    -- 自分が持つ GrabLine 系リモートに大量パケットを送ってサーバー負荷をかける
    if not CreateGrabLine then return end
    local sp = Workspace:FindFirstChild("SpawnLocation")
        or Workspace:FindFirstChild("Spawn")
        or GetMyHRP()
    if not sp then return end
    for _ = 1, 10 do
        pcall(function()
            CreateGrabLine:FireServer(sp, CFrame.new(
                math.random(-2010000000, 2000200000), 0,
                math.random(-2008100000, 2000200000)))
        end)
    end
end

function _G.SourceFreeze.Start()
    if _G.SourceFreeze.isActive then return end
    _G.SourceFreeze.isActive = true
    _G.SourceFreeze.frozenPlayers = {}

    _G.SourceFreeze.connection = RunService.Heartbeat:Connect(function()
        if not _G.SourceFreeze.isActive then return end

        -- 近くの相手をフリーズさせる
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and (tRoot.Position - myRoot.Position).Magnitude < 30 then
                    FreezeCharacter(player)
                    _G.SourceFreeze.frozenPlayers[player] = true
                end
            end
        end

        -- サーバー負荷用パケット（0.3秒間隔）
        if not _G.SourceFreeze.lastSpamTime then _G.SourceFreeze.lastSpamTime = 0 end
        local now = tick()
        if now - _G.SourceFreeze.lastSpamTime > 0.3 then
            _G.SourceFreeze.lastSpamTime = now
            pcall(SpamRemoteEvents)
        end
    end)
    Notify("Source Freeze", "有効化", 3)
end

function _G.SourceFreeze.Stop()
    _G.SourceFreeze.isActive = false
    if _G.SourceFreeze.connection then
        _G.SourceFreeze.connection:Disconnect()
        _G.SourceFreeze.connection = nil
    end
    -- フリーズしたプレイヤーを解除
    for player, _ in pairs(_G.SourceFreeze.frozenPlayers) do
        UnfreezeCharacter(player)
    end
    _G.SourceFreeze.frozenPlayers = {}
    Notify("Source Freeze", "停止", 2)
end

-- ============================================================
-- 【機能4】物理リミッター解除・インビジブル・アンカー
-- 目的：自分のHumanoidRootPartのVelocityを常に0にし、
--       透明なアンカー（固定）状態を維持する
-- ============================================================
function _G.PhysicsLimit.Start()
    if _G.PhysicsLimit.isActive then return end
    _G.PhysicsLimit.isActive = true
    local localChar = LocalPlayer.Character
    if not localChar then
        _G.PhysicsLimit.isActive = false
        Notify("Physics Limit", "キャラクターがありません", 2)
        return
    end
    local myRoot = localChar:FindFirstChild("HumanoidRootPart")
    local myHum = localChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHum then
        _G.PhysicsLimit.isActive = false
        return
    end

    -- 透明なアンカーを作成
    local anchor = Instance.new("Part")
    anchor.Name = "PhysicsAnchor_Singularity"
    anchor.Size = Vector3.new(1, 1, 1)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = true
    anchor.Parent = Workspace
    anchor.CFrame = myRoot.CFrame
    _G.PhysicsLimit.anchorPart = anchor

    -- 物理リミッター解除 + 速度を常に0に
    _G.PhysicsLimit.connection = RunService.Heartbeat:Connect(function()
        if not _G.PhysicsLimit.isActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        -- 速度を0に固定（物理リミッター解除）
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        -- アンカーを自分の位置に追従
        if _G.PhysicsLimit.anchorPart and _G.PhysicsLimit.anchorPart.Parent then
            _G.PhysicsLimit.anchorPart.CFrame = root.CFrame
        end

        -- 相手からの物理干渉を無効化（近くのプレイヤーの速度を0に）
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and (tRoot.Position - root.Position).Magnitude < 10 then
                    pcall(function()
                        tRoot.AssemblyLinearVelocity = Vector3.zero
                        tRoot.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
            end
        end
    end)
    Notify("Physics Limit", "解除・アンカー有効", 3)
end

function _G.PhysicsLimit.Stop()
    _G.PhysicsLimit.isActive = false
    if _G.PhysicsLimit.connection then
        _G.PhysicsLimit.connection:Disconnect()
        _G.PhysicsLimit.connection = nil
    end
    if _G.PhysicsLimit.anchorPart then
        pcall(function() _G.PhysicsLimit.anchorPart:Destroy() end)
        _G.PhysicsLimit.anchorPart = nil
    end
    Notify("Physics Limit", "停止", 2)
end

print("[Singularity hub premium] Part 7 loaded (写真の4機能)")
-- [Part 7 END] ---- ============================================================
-- Singularity hub premium - FULL FIXED VERSION
-- Part 8-A / 8 : UI (Part 1)
-- ============================================================

local Window = Library:CreateWindow({
    Title = "Singularity hub premium",
    Footer = "Kick + Kill + Anti + Lag + Plot + Tsunami",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main       = Window:AddTab("Main", "user"),
    Kick       = Window:AddTab("Kick", "swords"),
    Kill       = Window:AddTab("Kill", "skull"),
    Ragdoll    = Window:AddTab("Ragdoll", "activity"),
    Anti       = Window:AddTab("Anti", "shield"),
    Lag        = Window:AddTab("Lag", "zap"),
    Gucci      = Window:AddTab("Gucci Break", "package"),
    Plot       = Window:AddTab("Plot", "hammer"),
    Tsunami    = Window:AddTab("Tsunami", "waves"),
    Teleport   = Window:AddTab("Teleport", "map-pin"),
    ToyMod     = Window:AddTab("Toy Mod", "wrench"),
}

-- ============================================================
-- Main タブ
-- ============================================================
local TargetGroup = Tabs.Main:AddLeftGroupbox("Target", "target")
TargetGroup:AddDropdown("TargetDropdown", {
    Values = GetPlayerList(),
    Default = "",
    Text = "Select Target",
    Searchable = true,
    Callback = function(selected)
        if selected and selected ~= "" then
            local un = ExtractUsername(selected)
            if un then
                selectedTargetName = un
                Notify("Target Set", un, 2)
            end
        end
    end,
})
TargetGroup:AddButton({
    Text = "Refresh Player List",
    Func = function() Options.TargetDropdown:SetValues(GetPlayerList()) end,
})

-- ============================================================
-- Kick タブ
-- ============================================================
local KickL = Tabs.Kick:AddLeftGroupbox("Kick", "swords")
KickL:AddToggle("AllkickToggle", { Text = "Allkick", Default = false,
    Callback = function(v)
        if v then
            AllkickExecute()
            Notify("Start", "Allkick Started", 2)
        else
            AllkickStop()
            Notify("Stop", "Allkick Stopped", 2)
        end
    end,
})
KickL:AddToggle("NoblobkickToggle", { Text = "Noblobkick", Default = false,
    Callback = function(v)
        if v then
            TlagExecute()
            Notify("Start", "Noblobkick Started", 2)
        else
            TlagStop()
            Notify("Stop", "Noblobkick Stopped", 2)
        end
    end,
})
KickL:AddButton({ Text = "Blobkick", Func = function() GrabKickExecute() end })
KickL:AddButton({ Text = "Lagkick", Func = function() LagkExecute() end })
KickL:AddToggle("LKA_Toggle", { Text = "Lag Kick All", Default = false,
    Callback = function(v)
        if v then
            LKA_Execute()
            Notify("Start", "Lag Kick All Started", 2)
        else
            LKA_Stop()
            Notify("Stop", "Lag Kick All Stopped", 2)
        end
    end,
})
KickL:AddToggle("LKS_Toggle", { Text = "Lag Kick Select", Default = false,
    Callback = function(v)
        if v then
            LKS_Execute()
            Notify("Start", "Lag Kick Select Started", 2)
        else
            LKS_Stop()
            Notify("Stop", "Lag Kick Select Stopped", 2)
        end
    end,
})
KickL:AddToggle("LKA2_Toggle", { Text = "Lag Kick All (Strong)", Default = false,
    Callback = function(v)
        if v then
            LKA2_Execute()
            Notify("Start", "Lag Kick All Strong Started", 2)
        else
            LKA2_Stop()
            Notify("Stop", "Lag Kick All Strong Stopped", 2)
        end
    end,
})
KickL:AddToggle("LKS2_Toggle", { Text = "Lag Kick Select (Anti Pierce)", Default = false,
    Callback = function(v)
        if v then
            LKS2_Execute()
            Notify("Start", "Lag Kick Select Anti Started", 2)
        else
            LKS2_Stop()
            Notify("Stop", "Lag Kick Select Anti Stopped", 2)
        end
    end,
})
KickL:AddToggle("LKA3_Toggle", { Text = "Grab Kick All (Vision Pierce)", Default = false,
    Callback = function(v)
        if v then
            LKA3_Execute()
            Notify("Start", "Grab Kick All Started", 2)
        else
            LKA3_Stop()
            Notify("Stop", "Grab Kick All Stopped", 2)
        end
    end,
})
KickL:AddToggle("LKS3_Toggle", { Text = "Grab Kick Select (Visual Pierce)", Default = false,
    Callback = function(v)
        if v then
            LKS3_Execute()
            Notify("Start", "Grab Kick Select Started", 2)
        else
            LKS3_Stop()
            Notify("Stop", "Grab Kick Select Stopped", 2)
        end
    end,
})
KickL:AddToggle("SpamKToggle", { Text = "Spam Kick", Default = false,
    Callback = function(v)
        if v then
            if not selectedTargetName then
                Notify("Error", "No target selected", 3)
                Toggles.SpamKToggle:SetValue(false)
                return
            end
            SpamKStart(selectedTargetName)
            Notify("Start", "Spam Kick Started", 2)
        else
            SpamKStop()
            Notify("Stop", "Spam Kick Stopped", 2)
        end
    end,
})
KickL:AddToggle("DriftKToggle", { Text = "Drift Kick", Default = false,
    Callback = function(v)
        if v then
            DriftStart()
            Notify("Start", "Drift Kick Started", 2)
        else
            DriftStop()
            Notify("Stop", "Drift Kick Stopped", 2)
        end
    end,
})

local KickR = Tabs.Kick:AddRightGroupbox("Exploits", "zap")
KickR:AddToggle("BlobSpamKickToggle", { Text = "Blob spam kick", Default = false,
    Callback = function(v)
        _G.loopBlobKickSpamActive = v
        if v then
            _G.loopBlobKickSpamTargetName = selectedTargetName
            if not _G.loopBlobKickSpamTargetName then
                Notify("Error", "No target selected", 3)
                Toggles.BlobSpamKickToggle:SetValue(false)
                return
            end
            _G.loopBlobKickSpamTask = task.spawn(_G.LoopBlobKickSpamFunction)
            Notify("Start", "Blob spam kick Started", 2)
        else
            if _G.loopBlobKickSpamTask then
                task.cancel(_G.loopBlobKickSpamTask)
                _G.loopBlobKickSpamTask = nil
            end
            Notify("Stop", "Blob spam kick Stopped", 2)
        end
    end,
})
KickR:AddToggle("SpamKickGrabToggle", { Text = "Spam kick(grab)", Default = false,
    Callback = function(on)
        _G.kickLoopEnabled = on
        if on then
            if not selectedTargetName then
                Notify("Error", "No target selected", 3)
                Toggles.SpamKickGrabToggle:SetValue(false)
                return
            end
            _G.loopBlobKickSpamTargetName = selectedTargetName
            task.spawn(_G.SpamKickGrabFunction)
            Notify("Start", "Spam kick(grab) Started", 2)
        else
            Notify("Stop", "Spam kick(grab) Stopped", 2)
        end
    end,
})
KickR:AddDivider()
KickR:AddButton({ Text = "Stop All Kick", Func = function()
    AllkickStop()
    TlagStop()
    LKA_Stop()
    LKS_Stop()
    LKA2_Stop()
    LKS2_Stop()
    LKA3_Stop()
    LKS3_Stop()
    SpamKStop()
    DriftStop()
    _G.kickLoopEnabled = false
    if _G.loopBlobKickSpamTask then
        task.cancel(_G.loopBlobKickSpamTask)
        _G.loopBlobKickSpamTask = nil
    end
    Notify("Stop", "All kicks stopped", 2)
end })

-- ============================================================
-- Kill タブ
-- ============================================================
local KillL = Tabs.Kill:AddLeftGroupbox("Blobman Kill", "skull")
KillL:AddToggle("BlobmanKillAllToggle", { Text = "Kill All", Default = false,
    Callback = function(v)
        _G.BlobmanKill.isRunning = v
        if v then
            if Toggles.BlobmanKillAuraToggle then
                Toggles.BlobmanKillAuraToggle:SetValue(false)
            end
            _G.BlobmanKill.UpdateKillAuraConnection()
            task.spawn(function()
                while _G.BlobmanKill.isRunning do
                    _G.BlobmanKill.ProcessAllPlayers()
                    task.wait()
                end
            end)
            Notify("Start", "Kill All Started", 2)
        else
            _G.BlobmanKill.UpdateKillAuraConnection()
            Notify("Stop", "Kill All Stopped", 2)
        end
    end,
})
KillL:AddToggle("BlobmanKillAuraToggle", { Text = "Kill Aura", Default = false,
    Callback = function(v)
        _G.BlobmanKill.isKillAura = v
        if v then
            if Toggles.BlobmanKillAllToggle then
                Toggles.BlobmanKillAllToggle:SetValue(false)
            end
            _G.BlobmanKill.SpawnBlobman()
            Notify("Start", "Kill Aura Started", 2)
        else
            Notify("Stop", "Kill Aura Stopped", 2)
        end
        _G.BlobmanKill.UpdateKillAuraConnection()
    end,
})
KillL:AddToggle("BlobmanSelectedKillToggle", { Text = "Selected Kill", Default = false,
    Callback = function(v)
        _G.BlobmanKill.isSelectedKill = v
        if v then
            _G.BlobmanKill.selectedPlayer = selectedTargetName and Players:FindFirstChild(selectedTargetName)
            if not _G.BlobmanKill.selectedPlayer then
                Notify("Error", "No target selected", 2)
                Toggles.BlobmanSelectedKillToggle:SetValue(false)
                return
            end
            _G.BlobmanKill.StartSelectedKillLoop()
            Notify("Start", "Selected Kill Started", 2)
        else
            if _G.BlobmanKill.selectedKillConn then
                pcall(task.cancel, _G.BlobmanKill.selectedKillConn)
                _G.BlobmanKill.selectedKillConn = nil
            end
            Notify("Stop", "Selected Kill Stopped", 2)
        end
    end,
})

local KillR = Tabs.Kill:AddRightGroupbox("Loop Kill", "skull")
KillR:AddToggle("LoopKillToggle", { Text = "Loop kill", Default = false,
    Callback = function(v)
        _G.loopKill1Active = v
        if v then
            _G.loopKill1TargetName = selectedTargetName
            if not _G.loopKill1TargetName then
                Notify("Error", "No target selected", 3)
                Toggles.LoopKillToggle:SetValue(false)
                return
            end
            task.spawn(_G.LoopKill1Function)
            Notify("Start", "Loop kill Started", 2)
        else
            Notify("Stop", "Loop kill Stopped", 2)
        end
    end,
})
KillR:AddToggle("LoopKill2Toggle", { Text = "Loop kill (Anti Pierce)", Default = false,
    Callback = function(v)
        _G.loopKill2Active = v
        if v then
            _G.loopKill2TargetName = selectedTargetName
            if not _G.loopKill2TargetName then
                Notify("Error", "No target selected", 3)
                Toggles.LoopKill2Toggle:SetValue(false)
                return
            end
            task.spawn(_G.LoopKill2Function)
            Notify("Start", "Loop kill(anti) Started", 2)
        else
            Notify("Stop", "Loop kill(anti) Stopped", 2)
        end
    end,
})

-- ============================================================
-- Ragdoll タブ
-- ============================================================
local RagL = Tabs.Ragdoll:AddLeftGroupbox("Ragdoll", "activity")
RagL:AddToggle("SnowballRagdollToggle", { Text = "Snowball Ragdoll", Default = false,
    Callback = function(v)
        _G.snowballRagdollActive = v
        if v then
            _G.snowballRagdollTargetName = selectedTargetName
            if not _G.snowballRagdollTargetName then
                Notify("Error", "No target selected", 3)
                Toggles.SnowballRagdollToggle:SetValue(false)
                return
            end
            _G.snowballRagdollTask = task.spawn(_G.SnowballRagdollFunction)
            Notify("Start", "Snowball Ragdoll Started", 2)
        else
            if _G.snowballRagdollTask then
                task.cancel(_G.snowballRagdollTask)
                _G.snowballRagdollTask = nil
            end
            Notify("Stop", "Snowball Ragdoll Stopped", 2)
        end
    end,
})

-- ============================================================
-- Anti タブ（既存）
-- ============================================================
local AntiL = Tabs.Anti:AddLeftGroupbox("Anti Protection", "shield")
AntiL:AddToggle("AntiGrabToggle", { Text = "Anti Grab", Default = false, Callback = function(v) AntiConfig.AntiGrab = v end })
AntiL:AddToggle("AntiGrabNRDToggle", { Text = "Anti Grab (No Ragdoll)", Default = false,
    Callback = function(v)
        _G.AntiExtra.AntiGrabNRD = v
        _G.AntiGrabNRDEnabled = v
        if v and LocalPlayer.Character then
            task.defer(function() setupAntiGrabNRD(LocalPlayer.Character) end)
        end
    end,
})
AntiL:AddToggle("AntiVoidToggle", { Text = "Anti Void", Default = false, Callback = function(v) AntiConfig.AntiVoid = v end })
AntiL:AddToggle("AntiRagdollToggle", { Text = "Anti Ragdoll", Default = false, Callback = function(v) AntiConfig.AntiRagdoll = v end })
AntiL:AddToggle("AntiExplodeToggle", { Text = "Anti Explode", Default = false, Callback = function(v) AntiConfig.AntiExplode = v SetupAntiExplode() end })
AntiL:AddToggle("AntiExplodeV2Toggle", { Text = "Anti Explode V2", Default = false,
    Callback = function(v)
        AntiConfig.AntiExplodeV2 = v
        local h = LocalPlayer.PlayerScripts:FindFirstChild("ClientExoplosionHandler")
        if h then h.Enabled = not v end
    end,
})
AntiL:AddToggle("AntiGucciToggle", { Text = "Anti Gucci", Default = false, Callback = function(v) toggleAntiGucci(v) end })
AntiL:AddToggle("AntiSpamKickToggle", { Text = "Anti Spam Kick", Default = false, Callback = function(v) AntiConfig.AntiSpamKick = v end })
AntiL:AddToggle("AntiBananaSitToggle", { Text = "Anti Banana Sit", Default = false,
    Callback = function(v)
        _G.antiBananaSitActive = v
        if v then
            _G.antiBananaSitTask = task.spawn(AntiBananaSitFunction)
        else
            if _G.antiBananaSitTask then
                task.cancel(_G.antiBananaSitTask)
                _G.antiBananaSitTask = nil
            end
        end
    end,
})
AntiL:AddToggle("AntiBlobmanKillToggle", { Text = "Anti Blobman Kill", Default = false,
    Callback = function(v)
        _G.antiBlobmanKillActive = v
        if v then
            _G.antiBlobmanKillTask = task.spawn(AntiBlobmanKillFunction)
        else
            if _G.antiBlobmanKillTask then
                task.cancel(_G.antiBlobmanKillTask)
                _G.antiBlobmanKillTask = nil
            end
        end
    end,
})
AntiL:AddToggle("AntiRagBlobToggle", { Text = "Anti Ragdoll on Blob", Default = false,
    Callback = function(v)
        _G.antiRagBlobActive = v
        AntiRagBlobFunction()
    end,
})
AntiL:AddToggle("AntiStickyToggle", { Text = "Anti Sticky", Default = false, Callback = function(v) SetupAntiSticky(v) end })
AntiL:AddToggle("AntiBurnToggle", { Text = "Anti Burn", Default = false, Callback = function(v) SetupAntiBurn(v) end })
AntiL:AddToggle("GodModeToggle", { Text = "GOD MODE", Default = false,
    Callback = function(v)
        if v then
            startGodMode()
            Notify("GOD MODE", "Enabled", 3)
        else
            stopGodMode()
            Notify("GOD MODE", "Disabled", 3)
        end
    end,
})

-- ============================================================
-- Anti タブ（写真の4機能を追加）
-- ============================================================
local AntiExtraL = Tabs.Anti:AddLeftGroupbox("FTAP対策 (写真の4機能)", "shield")

AntiExtraL:AddToggle("NetworkOwnershipToggle", {
    Text = "① ネットワークオーナーシップ強制奪取",
    Default = false,
    Callback = function(v)
        if v then _G.NetworkOwnership.Start() else _G.NetworkOwnership.Stop() end
    end,
})

AntiExtraL:AddToggle("AntiAttachmentToggle", {
    Text = "② アンチ・アタッチメント＆インスタント・リバース",
    Default = false,
    Callback = function(v)
        if v then _G.AntiAttachment.Start() else _G.AntiAttachment.Stop() end
    end,
})

AntiExtraL:AddToggle("SourceFreezeToggle", {
    Text = "③ スクリプト・ソース・フリーズ",
    Default = false,
    Callback = function(v)
        if v then _G.SourceFreeze.Start() else _G.SourceFreeze.Stop() end
    end,
})

AntiExtraL:AddToggle("PhysicsLimitToggle", {
    Text = "④ 物理リミッター解除・インビジブル・アンカー",
    Default = false,
    Callback = function(v)
        if v then _G.PhysicsLimit.Start() else _G.PhysicsLimit.Stop() end
    end,
})

-- ============================================================
-- Anti タブ 右側（Anti Kick Tools）
-- ============================================================
local AntiR = Tabs.Anti:AddRightGroupbox("Anti Kick Tools", "zap")
AntiR:AddToggle("AntiKickToggle", { Text = "Anti Kick", Default = false, Risky = true,
    Callback = function(v)
        AntiConfig.AntiKick = v
        setupAntiKick(v)
    end,
})
AntiR:AddToggle("AntiKillToggle", { Text = "Anti Kill", Default = false, Risky = true,
    Callback = function(v)
        AntiConfig.AntiKill = v
        setupAntiKill(v)
    end,
})
AntiR:AddToggle("KickGrabToggle", { Text = "Kick Grab", Default = false,
    Callback = function(v) AntiConfig.KickGrab = v end,
})
AntiR:AddToggle("AntiKickBreakPCLDToggle", { Text = "Anti Kick (Break PCLD)", Default = false,
    Callback = function(v)
        if v then ExecuteAntiKickBreakPCLD() end
    end,
})
AntiR:AddDivider()
AntiR:AddToggle("TargetRemoveAntiKickToggle", { Text = "Target Remove Anti Kick", Default = false,
    Callback = function(v)
        _G.antiAntiKickActive = v
        if v and selectedTargetName then
            task.spawn(function() _G.RemoveAntiKickFunction(selectedTargetName) end)
            Notify("Start", "Target Anti Kick Removal Started", 2)
        elseif v then
            Notify("Error", "No target selected", 3)
            Toggles.TargetRemoveAntiKickToggle:SetValue(false)
        else
            Notify("Stop", "Target Anti Kick Removal Stopped", 2)
        end
    end,
})
AntiR:AddToggle("RemoveAntiKickAuraToggle", { Text = "Remove Anti Kick Aura", Default = false,
    Callback = function(v)
        _G.removeAntiKickAuraActive = v
        if v then
            task.spawn(_G.RemoveAntiKickAuraFunction)
            Notify("Start", "Anti Kick Aura Started", 2)
        else
            Notify("Stop", "Anti Kick Aura Stopped", 2)
        end
    end,
})
AntiR:AddSlider("AuraRadius", { Text = "Aura Radius", Default = 50, Min = 10, Max = 200, Rounding = 0, Suffix = " studs",
    Callback = function(v) _G.removeAntiKickRadius = v end,
})
AntiR:AddButton({ Text = "Remove Target Anti Kick (Once)", Func = function()
    if not selectedTargetName then
        Notify("Error", "No target selected", 3)
        return
    end
    local target = Players:FindFirstChild(selectedTargetName)
    if target then
        local ok = _G.RemoveTargetAntiKick(target)
        if ok then
            Notify("Success", "Anti-Kick removed from " .. target.Name, 2)
        else
            Notify("Info", "No Anti-Kick found", 2)
        end
    end
end })

-- ============================================================
-- Lag タブ
-- ============================================================
local LagL = Tabs.Lag:AddLeftGroupbox("Lags", "zap")

LagL:AddToggle("AntiLagToggle", { Text = "Anti Lag", Default = false,
    Callback = function(v) SetupAntiLag(v) end,
})
LagL:AddToggle("AutoAntiLagToggle", { Text = "Auto Anti Lag", Default = false,
    Callback = function(v)
        _G.autoantilag = v
        if v then
            StartAutoAntiLag()
        else
            pcall(function()
                LocalPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = true
            end)
        end
    end,
})
LagL:AddDivider()
LagL:AddSlider("LineLagLPS", {
    Text = "Lines Per Second",
    Default = 100,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Callback = function(v) _G.LineLagLPS = v end,
})
LagL:AddToggle("LineLagToggle", { Text = "Line Lag", Default = false,
    Callback = function(v)
        _G.lineLagActive = v
        if v then
            _G.LineLagLPS = _G.LineLagLPS or 100
            _G.lineLagTask = task.spawn(function()
                while _G.lineLagActive do
                    for i = 1, _G.LineLagLPS do
                        pcall(function()
                            CreateGrabLine:FireServer(
                                Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn"),
                                CFrame.new(0, 9e9, 0)
                            )
                        end)
                    end
                    task.wait(1)
                end
                _G.lineLagTask = nil
            end)
        else
            if _G.lineLagTask then
                pcall(task.cancel, _G.lineLagTask)
                _G.lineLagTask = nil
            end
        end
    end,
})
LagL:AddDivider()
LagL:AddSlider("PacketLagStrength", {
    Text = "Packet Strength",
    Default = 2000,
    Min = 0,
    Max = 60000,
    Rounding = 1,
    Callback = function(v) _G.PacketLagStrength = v end,
})
LagL:AddToggle("AntiDetectToggle", { Text = "Anti Detect (Packets)", Default = false,
    Callback = function(v) _G.AntiDetect = v end,
})
LagL:AddToggle("PacketLagToggle", { Text = "Packet Lag", Default = false,
    Callback = function(v)
        _G.packetLagActive = v
        if v then
            _G.PacketLagStrength = _G.PacketLagStrength or 2000
            _G.packetLagTask = task.spawn(function()
                while _G.packetLagActive do
                    task.wait(1)
                    pcall(function()
                        ExtendGrabLine:FireServer(string.rep("A", 100 * _G.PacketLagStrength))
                    end)
                end
                _G.packetLagTask = nil
            end)
        else
            if _G.packetLagTask then
                pcall(task.cancel, _G.packetLagTask)
                _G.packetLagTask = nil
            end
        end
    end,
})

local LagR = Tabs.Lag:AddRightGroupbox("Anti Input Lag", "zap")
LagR:AddToggle("AntiInputLagToggle", { Text = "Anti Input Lag", Default = false,
    Callback = function(v)
        _G.AntiExtra.AntiInputLag = v
        if v then
            StartAntiInputLag()
        else
            if _G.antiInputLagTask then
                task.cancel(_G.antiInputLagTask)
                _G.antiInputLagTask = nil
            end
        end
    end,
})
LagR:AddToggle("RemoveAllAntiInputToggle", { Text = "Remove All Anti Input", Default = false,
    Callback = function(v)
        _G.antiAntiLagEnabled = v
        if v then
            StartRemoveAllAntiInput()
        else
            if _G.removeAntiInputTask then
                task.cancel(_G.removeAntiInputTask)
                _G.removeAntiInputTask = nil
            end
        end
    end,
})

print("[Singularity hub premium] Part 8-A loaded")
-- [Part 8-A END] ---- ============================================================
-- Singularity hub premium - FULL FIXED VERSION
-- Part 8-B / 8 : UI (Part 2) + OnUnload
-- ============================================================

-- ============================================================
-- Gucci Break タブ
-- ============================================================
local GucciL = Tabs.Gucci:AddLeftGroupbox("Gucci Break", "zap")

GucciL:AddButton({ Text = "All Gucci Break", Func = function()
    _G.AllGucciBreak()
    Notify("Gucci Break", "All executed", 2)
end })
GucciL:AddButton({ Text = "Target Gucci Break", Func = function()
    if selectedTargetName then
        _G.TargetGucciBreak(selectedTargetName)
        Notify("Gucci Break", selectedTargetName .. " executed", 2)
    else
        Notify("Error", "No target selected", 2)
    end
end })

local LoopGucciActive, LoopGucciTask = false, nil
GucciL:AddToggle("LoopAllGucciBreakToggle", { Text = "Loop All Gucci Break", Default = false,
    Callback = function(v)
        LoopGucciActive = v
        if v then
            LoopGucciTask = task.spawn(function()
                while LoopGucciActive do
                    _G.AllGucciBreak()
                    task.wait(1)
                end
            end)
            Notify("Gucci Break", "Loop Started", 2)
        else
            if LoopGucciTask then
                task.cancel(LoopGucciTask)
                LoopGucciTask = nil
            end
            Notify("Gucci Break", "Loop Stopped", 2)
        end
    end,
})

-- ============================================================
-- Plot タブ
-- ============================================================
local PlotL = Tabs.Plot:AddLeftGroupbox("Plot Barrier", "hammer")
PlotL:AddButton({ Text = "Break Barrier (Once)", Func = function()
    if _G.BarrierExecute then
        _G.BarrierExecute()
    end
end })

-- ============================================================
-- Tsunami タブ
-- ============================================================
local TsunamiL = Tabs.Tsunami:AddLeftGroupbox("Tsunami", "waves")
TsunamiL:AddButton({ Text = "Run Tsunami", Func = function()
    if _G.runTsunami then
        task.spawn(_G.runTsunami)
    end
end })
TsunamiL:AddButton({ Text = "Cleanup Tsunami", Func = function()
    if _G.tsunamiCleanup then
        _G.tsunamiCleanup()
    end
    Notify("Tsunami", "Cleanup complete", 2)
end })

-- ============================================================
-- Teleport タブ
-- ============================================================
local TPL = Tabs.Teleport:AddLeftGroupbox("Player Teleport", "map-pin")
TPL:AddSlider("TPOffsetY", {
    Text = "Y Offset",
    Default = 3,
    Min = -20,
    Max = 50,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(v)
        _G.TPState.OffsetY = v
        if _G.TPState.Loop then
            StartTPLoop()
        end
    end,
})
TPL:AddButton({ Text = "Teleport Once", Func = function()
    local targetName = selectedTargetName or _G.TPState.TargetName
    if targetName then
        TPToPlayerByName(targetName, _G.TPState.OffsetY)
    else
        Notify("Error", "No target selected", 2)
    end
end })
TPL:AddToggle("TPLoopToggle", { Text = "Loop Teleport", Default = false,
    Callback = function(v)
        _G.TPState.Loop = v
        if v then
            _G.TPState.TargetName = selectedTargetName
            if not _G.TPState.TargetName then
                Notify("Error", "No target selected", 3)
                Toggles.TPLoopToggle:SetValue(false)
                return
            end
            StartTPLoop()
            Notify("Start", "Loop Teleport Started", 2)
        else
            StopTPLoop()
            Notify("Stop", "Loop Teleport Stopped", 2)
        end
    end,
})

-- ============================================================
-- Toy Mod タブ（Wing Master + Prayer）
-- ============================================================
local WingMaster = {}
WingMaster.isActive = false
WingMaster.SelectedItem = "TetracubeI"
WingMaster.SearchMode = "My Toys"
WingMaster.WingSpeed = 2
WingMaster.WingAngle = 30
WingMaster.WingLength = 5
WingMaster.TimeCounter = 0
WingMaster.Wings = {}
WingMaster.Offsets = {[1] = CFrame.new(-4.125, 0, 1), [2] = CFrame.new(4.125, 0, 1)}
WingMaster.RunConnection = nil

-- グローバル参照できるように
_G.WingMaster = WingMaster

local function CleanupWings()
    for _, w in pairs(WingMaster.Wings) do
        if w.Handle and w.Handle.Parent then w.Handle:Destroy() end
        for _, s in pairs(w.Segments or {}) do
            if s.Part and s.Part.Parent then s.Part:Destroy() end
        end
    end
    WingMaster.Wings = {}
    if WingMaster.RunConnection then
        WingMaster.RunConnection:Disconnect()
        WingMaster.RunConnection = nil
    end
end
_G.CleanupWings = CleanupWings

local function GetToyFolders()
    local folders = {}
    if WingMaster.SearchMode == "My Toys" or WingMaster.SearchMode == "All Toys" then
        local myFolder = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
        if myFolder then table.insert(folders, myFolder) end
    end
    if WingMaster.SearchMode == "Plot Toys" or WingMaster.SearchMode == "All Toys" then
        local plotsFolder = Workspace:FindFirstChild("Plots")
        if plotsFolder then
            for i=1, 5 do
                local plot = plotsFolder:FindFirstChild("Plot"..i)
                if plot then
                    local ownersFolder = plot:FindFirstChild("PlotSign") and plot.PlotSign:FindFirstChild("ThisPlotsOwners")
                    if ownersFolder then
                        for _, v in ipairs(ownersFolder:GetChildren()) do
                            if v:IsA("ValueBase") and v.Value == LocalPlayer.Name then
                                local plotItemsFolder = Workspace:FindFirstChild("PlotItems")
                                if plotItemsFolder and plotItemsFolder:FindFirstChild(plot.Name) then
                                    table.insert(folders, plotItemsFolder:FindFirstChild(plot.Name))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return folders
end

local function SetupPhysics(Part)
    local BP = Part:FindFirstChildOfClass("BodyPosition") or Instance.new("BodyPosition")
    local BG = Part:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro")
    BP.P = 15000; BP.D = 200; BP.MaxForce = Vector3.new(1, 1, 1) * 1e10; BP.Parent = Part
    BG.P = 15000; BG.D = 200; BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10; BG.Parent = Part
    return BG, BP
end

local function BuildWings()
    CleanupWings()
    local folders = GetToyFolders()
    local allSpawnedToys = {}
    for _, folder in ipairs(folders) do
        for _, x in ipairs(folder:GetDescendants()) do
            if x:IsA("Model") and x.Name == WingMaster.SelectedItem then
                table.insert(allSpawnedToys, x)
            end
        end
    end
    if #allSpawnedToys == 0 then
        Notify("Wing Master", "Target item not found", 3)
        return false
    end
    for i = 1, 2 do
        local Segments = {}
        for x = 1, WingMaster.WingLength do
            local p = Instance.new("Part")
            p.CanCollide = false; p.Anchored = true; p.Transparency = 1; p.Size = Vector3.new(4,1,4); p.Parent = Workspace
            Segments[#Segments+1] = {Part = p}
        end
        local h = Instance.new("Part")
        h.CanCollide = false; h.Anchored = true; h.Transparency = 1; h.Size = Vector3.new(4,1,4); h.Parent = Workspace
        WingMaster.Wings[#WingMaster.Wings+1] = {Handle = h, Segments = Segments, Sync = {}, Reserved = nil}
    end
    for i, v in ipairs(allSpawnedToys) do
        local Side = (i <= (#allSpawnedToys/2)) and 1 or 2
        local Pallet = v:FindFirstChild("SoundPart") or v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
        if Pallet then
            for _, child in pairs(v:GetChildren()) do
                if child:IsA("BasePart") then child.CanCollide = false end
            end
            local BG, BP = SetupPhysics(Pallet)
            if not WingMaster.Wings[Side].Reserved then
                WingMaster.Wings[Side].Reserved = {BG = BG, BP = BP}
            else
                table.insert(WingMaster.Wings[Side].Sync, {BG = BG, BP = BP})
            end
        end
    end
    return true
end

local function StartWingAnimation()
    if WingMaster.RunConnection then
        WingMaster.RunConnection:Disconnect()
    end
    WingMaster.RunConnection = RunService.RenderStepped:Connect(function(dt)
        if not WingMaster.isActive or #WingMaster.Wings == 0 then return end
        local Char = LocalPlayer.Character
        if not Char or not Char:FindFirstChild("Torso") then return end
        WingMaster.TimeCounter = WingMaster.TimeCounter + dt * (WingMaster.WingSpeed + (Char.HumanoidRootPart.Velocity.Magnitude / 40))
        for i, Wing in ipairs(WingMaster.Wings) do
            local direction = (i == 1) and 1 or -1
            local flap = math.sin(WingMaster.TimeCounter) * math.rad(WingMaster.WingAngle + (Char.HumanoidRootPart.Velocity.Magnitude/4)) * direction
            Wing.Handle.CFrame = Char.Torso.CFrame * WingMaster.Offsets[i] * CFrame.Angles(0, 0, flap)
            if Wing.Reserved then
                Wing.Reserved.BP.Position = Wing.Handle.Position
                Wing.Reserved.BG.CFrame = Wing.Handle.CFrame * CFrame.Angles(math.rad(90), 0, math.rad(90))
            end
            for Index, Segment in ipairs(Wing.Segments) do
                local ToFollow = (Index == 1) and Wing.Handle.CFrame or Wing.Segments[Index-1].Part.CFrame
                Segment.Part.CFrame = Segment.Part.CFrame:Lerp(ToFollow * WingMaster.Offsets[i], 0.5)
                if Wing.Sync[Index] then
                    Wing.Sync[Index].BP.Position = Segment.Part.Position
                    Wing.Sync[Index].BG.CFrame = Segment.Part.CFrame * CFrame.Angles(math.rad(90), 0, math.rad(90))
                end
            end
        end
    end)
end

local function ToggleWingMaster(enabled)
    if enabled then
        if BuildWings() then
            WingMaster.isActive = true
            StartWingAnimation()
            Notify("Wing Master", "Enabled", 3)
        else
            WingMaster.isActive = false
        end
    else
        WingMaster.isActive = false
        CleanupWings()
        Notify("Wing Master", "Disabled", 3)
    end
end
_G.ToggleWingMaster = ToggleWingMaster

LocalPlayer.CharacterAdded:Connect(function()
    if WingMaster.isActive then
        task.defer(function()
            if WingMaster.isActive then BuildWings() end
        end)
    end
end)

-- ============================================================
-- Gucci Break 関数（UIで参照するので先に定義済み）
-- ============================================================
local function _sitOnce(blob)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    local seat = blob:FindFirstChild("VehicleSeat")
    if not seat or seat:FindFirstChild("SeatWeld") then return end
    local prompt = seat:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then return end
    root.CFrame = seat.CFrame
    for _ = 1, 20 do
        fireproximityprompt_safe(prompt)
        task.wait(0.01)
        if seat:FindFirstChild("SeatWeld") then break end
    end
    if seat:FindFirstChild("SeatWeld") then
        hum.Sit = false
        repeat task.wait() until not seat:FindFirstChild("SeatWeld")
    end
end

local function _sitAll(folder)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local orig = root.CFrame
    for _, obj in pairs(folder:GetDescendants()) do
        if obj.Name == "CreatureBlobman" and obj:IsA("Model") then
            _sitOnce(obj)
        end
    end
    root.CFrame = orig
end

function _G.AllGucciBreak()
    _sitAll(Workspace)
end

function _G.TargetGucciBreak(playerName)
    local folder = Workspace:FindFirstChild(playerName .. "SpawnedInToys")
    if folder then
        _sitAll(folder)
    else
        Notify("Gucci Break", "Player toy folder not found", 2)
    end
end

-- ============================================================
-- Wing Master UI
-- ============================================================
local WingL = Tabs.ToyMod:AddLeftGroupbox("Wing Master", "activity")
WingL:AddDropdown("WingItemDropdown", {
    Text = "Select Item",
    Values = {"TetracubeI", "FireworkSparkler", "PoopPile", "BallSnowball", "CreatureBlobman"},
    Default = 1,
    Callback = function(v)
        WingMaster.SelectedItem = v
        if WingMaster.isActive then BuildWings() end
    end,
})
WingL:AddDropdown("WingSearchDropdown", {
    Text = "Search Range",
    Values = {"My Toys", "Plot Toys", "All Toys"},
    Default = 1,
    Callback = function(v)
        WingMaster.SearchMode = v
        if WingMaster.isActive then BuildWings() end
    end,
})
WingL:AddSlider("WingSpeedSlider", { Text = "Wing Speed", Default = 2, Min = 1, Max = 10, Rounding = 1,
    Callback = function(v) WingMaster.WingSpeed = v end,
})
WingL:AddSlider("WingAngleSlider", { Text = "Wing Angle", Default = 30, Min = 10, Max = 90, Rounding = 0, Suffix = "°",
    Callback = function(v) WingMaster.WingAngle = v end,
})
WingL:AddSlider("WingLengthSlider", { Text = "Wing Length", Default = 5, Min = 3, Max = 10, Rounding = 0,
    Callback = function(v)
        WingMaster.WingLength = v
        if WingMaster.isActive then BuildWings() end
    end,
})
WingL:AddButton({ Text = "Rebuild Wings", Func = function()
    if WingMaster.isActive then
        BuildWings()
        Notify("Wing Master", "Rebuilt", 2)
    else
        Notify("Wing Master", "Enable first", 2)
    end
end })
WingL:AddToggle("WingMasterToggle", { Text = "Enable Wings System", Default = false,
    Callback = function(v) ToggleWingMaster(v) end,
})

-- ============================================================
-- Prayer UI
-- ============================================================
local prayers = {
    "Singularity hub on top",
    "Singularity hub is the best",
    "Singularity hub x Gucci anti-grab",
    "God mode activated",
    "Kick all blobman",
    "Wing master system",
    "Arkadia blob spam kick",
    "Singularity project",
    "Gucci break system",
    "Pray to Singularity",
    "Singularity hub - Reign Supreme"
}

local function sendChatMessage(message)
    local sent = false
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        local sayMessageRequest = chatEvents:FindFirstChild("SayMessageRequest")
        if sayMessageRequest then
            pcall(function()
                sayMessageRequest:FireServer(message, "All")
                sent = true
            end)
        end
    end
    if not sent then
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = nil
            for _ = 1, 10 do
                if TextChatService.TextChannels then
                    channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                end
                if channel then break end
                task.wait(0.1)
            end
            if channel then
                pcall(channel.SendAsync, channel, message)
                sent = true
            end
        end
    end
end

local PrayerL = Tabs.ToyMod:AddRightGroupbox("Prayer", "heart")
local currentPrayerIndex = 0
PrayerL:AddDropdown("PrayerSelect", {
    Text = "Select Prayer",
    Values = {
        "1. Singularity hub on top",
        "2. Singularity hub is the best",
        "3. Singularity hub x Gucci anti-grab",
        "4. God mode activated",
        "5. Kick all blobman",
        "6. Wing master system",
        "7. Arkadia blob spam kick",
        "8. Singularity project",
        "9. Gucci break system",
        "10. Pray to Singularity",
        "11. Singularity hub - Reign Supreme",
    },
    Default = 1,
    Callback = function(v) currentPrayerIndex = tonumber(v:match("^(%d+)")) end,
})

local spamCount, spamInterval = 5, 1.0
PrayerL:AddSlider("PrayerSpamCount", { Text = "Spam Count", Default = 5, Min = 1, Max = 50, Rounding = 0,
    Callback = function(v) spamCount = v end,
})
PrayerL:AddSlider("PrayerSpamInterval", { Text = "Interval (s)", Default = 1.0, Min = 0.1, Max = 10.0, Rounding = 1, Suffix = "s",
    Callback = function(v) spamInterval = v end,
})
PrayerL:AddButton({ Text = "Spam Current Prayer", Func = function()
    if currentPrayerIndex <= 0 then
        Notify("Error", "No prayer selected", 2)
        return
    end
    task.spawn(function()
        for i = 1, spamCount do
            sendChatMessage(prayers[currentPrayerIndex])
            task.wait(0.3)
        end
        Notify("Prayer", "Spam complete", 2)
    end)
end })
PrayerL:AddButton({ Text = "Send Once", Func = function()
    if currentPrayerIndex <= 0 then
        Notify("Error", "No prayer selected", 2)
        return
    end
    sendChatMessage(prayers[currentPrayerIndex])
    Notify("Prayer", "Sent", 1)
end })

local LoopAllPrayersActive, LoopAllPrayersTask = false, nil
PrayerL:AddToggle("LoopAllPrayersToggle", { Text = "Loop All Prayers", Default = false,
    Callback = function(v)
        LoopAllPrayersActive = v
        if v then
            LoopAllPrayersTask = task.spawn(function()
                local index = 1
                while LoopAllPrayersActive do
                    if index > #prayers then index = 1 end
                    sendChatMessage(prayers[index])
                    index = index + 1
                    task.wait(spamInterval)
                end
            end)
            Notify("Prayer", "Loop All Started", 2)
        else
            if LoopAllPrayersTask then
                task.cancel(LoopAllPrayersTask)
                LoopAllPrayersTask = nil
            end
            Notify("Prayer", "Loop All Stopped", 2)
        end
    end,
})

local LoopSelActive, LoopSelTask = false, nil
PrayerL:AddToggle("LoopSelectedPrayerToggle", { Text = "Loop Selected Prayer", Default = false,
    Callback = function(v)
        LoopSelActive = v
        if v then
            if currentPrayerIndex <= 0 then
                Notify("Error", "No prayer selected", 2)
                Toggles.LoopSelectedPrayerToggle:SetValue(false)
                return
            end
            LoopSelTask = task.spawn(function()
                while LoopSelActive do
                    sendChatMessage(prayers[currentPrayerIndex])
                    task.wait(spamInterval)
                end
            end)
            Notify("Prayer", "Loop Selected Started", 2)
        else
            if LoopSelTask then
                task.cancel(LoopSelTask)
                LoopSelTask = nil
            end
            Notify("Prayer", "Loop Selected Stopped", 2)
        end
    end,
})

-- ============================================================
-- Player リスト自動更新
-- ============================================================
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if Options.TargetDropdown then
        Options.TargetDropdown:SetValues(GetPlayerList())
    end
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    if Options.TargetDropdown then
        Options.TargetDropdown:SetValues(GetPlayerList())
    end
end)

Notify("Singularity hub premium", "Loading complete", 3)

-- ============================================================
-- OnUnload（完全修正版）
-- ============================================================
Library:OnUnload(function()
    pcall(AllkickStop)
    pcall(TlagStop)
    pcall(LKA_Stop)
    pcall(LKS_Stop)
    pcall(LKA2_Stop)
    pcall(LKS2_Stop)
    pcall(LKA3_Stop)
    pcall(LKS3_Stop)
    pcall(SpamKStop)
    pcall(DriftStop)
    pcall(StopTPLoop)

    -- BlobmanKill 停止
    pcall(function()
        _G.BlobmanKill.isRunning = false
        _G.BlobmanKill.isKillAura = false
        _G.BlobmanKill.isSelectedKill = false
    end)
    pcall(function()
        if _G.BlobmanKill.killAuraConnection then
            _G.BlobmanKill.killAuraConnection:Disconnect()
        end
        if _G.BlobmanKill.selectedKillConn then
            task.cancel(_G.BlobmanKill.selectedKillConn)
        end
    end)

    -- 写真の4機能停止
    pcall(function() _G.NetworkOwnership.Stop() end)
    pcall(function() _G.AntiAttachment.Stop() end)
    pcall(function() _G.SourceFreeze.Stop() end)
    pcall(function() _G.PhysicsLimit.Stop() end)

    if _G.GodMode and _G.GodMode.isRunning then pcall(stopGodMode) end
    if WingMaster and WingMaster.isActive then pcall(CleanupWings) end
    if _G.lineLagTask then pcall(task.cancel, _G.lineLagTask) end
    if _G.packetLagTask then pcall(task.cancel, _G.packetLagTask) end
    if _G.loopBlobKickSpamTask then pcall(task.cancel, _G.loopBlobKickSpamTask) end
    _G.kickLoopEnabled = false
    print("[Singularity hub premium] Unloaded!")
end)

print("[Singularity hub premium] Part 8-B loaded - ALL COMPLETE!")
-- [Part 8-B END] --
-- [ALL BLOCKS COMPLETE] --
