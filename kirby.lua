-- ============================================================
-- Singularity hub
-- ============================================================
print("[Singularity hub] 読み込み開始...")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 10)
local SetNetworkOwnerEvent = GrabEvents and GrabEvents:WaitForChild("SetNetworkOwner", 5)
local CreateGrabLine = GrabEvents and GrabEvents:WaitForChild("CreateGrabLine", 5)
local DestroyGrabLine = GrabEvents and GrabEvents:WaitForChild("DestroyGrabLine", 5)

local MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 10)
local SpawnToyRemoteFunction = MenuToys and MenuToys:WaitForChild("SpawnToyRemoteFunction", 5)
local DestroyToy = MenuToys and MenuToys:WaitForChild("DestroyToy", 5)

local PlayerEvents = ReplicatedStorage:WaitForChild("PlayerEvents", 10)
local StickyEvent = PlayerEvents and PlayerEvents:WaitForChild("StickyPartEvent", 5)

local selectedTargetName = nil

local function Notify(title, desc, time)
    Library:Notify({Title = title, Description = desc, Time = time or 3})
end

local function GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    return list
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
    local plotItems = Workspace:FindFirstChild("PlotItems")
    if plotItems then
        for _, plot in ipairs(plotItems:GetChildren()) do
            if plot:IsA("Folder") then
                local pip = plot:FindFirstChild("PlayersInPlots")
                if pip and pip:FindFirstChild(player.Name) then
                    for _, child in ipairs(plot:GetDescendants()) do
                        if child:IsA("Model") and child.Name == player.Name then
                            local hrp = child:FindFirstChild("HumanoidRootPart")
                            if hrp then return hrp end
                        end
                    end
                end
            end
        end
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

local function GetMag(a, b)
    return (a.Position - b.Position).Magnitude
end

local function sno(part)
    if part then
        pcall(function()
            SetNetworkOwnerEvent:FireServer(part, part.CFrame)
        end)
    end
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
            or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        if sp then
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
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then AllkickStop() return end
        local list = {}
        local pi = Workspace:FindFirstChild("PlotItems")
        local pip = pi and pi:FindFirstChild("PlayersInPlots")
        local set = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then set[p.Name] = p end
        end
        if pip then
            for _, o in ipairs(pip:GetChildren()) do
                local p = Players:FindFirstChild(o.Name)
                if p and p ~= LocalPlayer then set[p.Name] = p end
            end
        end
        for _, p in pairs(set) do
            local hrp = GetPlayerHRP(p)
            if hrp then table.insert(list, hrp) end
        end
        if #list == 0 then task.wait(10) AllkickStop() return end
        Notify("Kick", "全員 (" .. #list .. "人) kick", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or Workspace:FindFirstChild("SpawnLocation1")
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
-- Noblobkick
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
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        if sp then
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
    if not selectedTargetName then
        Notify("Error", "ターゲット未選択", 3) return
    end
    local tp = Players:FindFirstChild(selectedTargetName)
    if not tp then
        Notify("Error", "プレイヤーなし", 3) return
    end
    TlagRunning = true
    TlagTask = task.spawn(function()
        TlagStartLag()
        local height = 35
        task.wait(1)
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then TlagStop() return end
        local tHrp = GetPlayerHRP(tp)
        if not tHrp then TlagStopLag() TlagRunning = false return end
        Notify("Kick", tp.DisplayName .. " kick", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or Workspace:FindFirstChild("SpawnLocation1")
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
        TlagStopLag()
        TlagRunning = false
    end)
end

-- ============================================================
-- Blobkick
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
    if not selectedTargetName then
        Notify("Error", "ターゲット未選択", 3) return
    end
    local tp = Players:FindFirstChild(selectedTargetName)
    if not tp or not tp.Character then return end
    local tHrp = tp.Character:FindFirstChild("HumanoidRootPart")
    local tHum = tp.Character:FindFirstChildWhichIsA("Humanoid")
    if not tHrp or not tHum then return end
    GrabKickExec = true
    task.spawn(function()
        local blob = GrabKickGetBlob()
        if not blob then
            Notify("Error", "ブロブマンに乗ってください", 3)
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
        Notify("Kick", tp.DisplayName .. " kick", 3)
        GrabKickExec = false
    end)
end

-- ============================================================
-- Lagkick (Select)
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
        Notify("Kick", tp.DisplayName .. " kick", 3)
        LagkExec = false
    end)
end

-- ============================================================
-- Lag Kick All
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
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        if sp then
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
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then LKA_Stop() return end
        local set = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then set[p.Name] = p end
        end
        local pi = Workspace:FindFirstChild("PlotItems")
        local pip = pi and pi:FindFirstChild("PlayersInPlots")
        if pip then
            for _, o in ipairs(pip:GetChildren()) do
                local p = Players:FindFirstChild(o.Name)
                if p and p ~= LocalPlayer then set[p.Name] = p end
            end
        end
        local list = {}
        for _, p in pairs(set) do
            local hrp = GetPlayerHRP(p)
            if hrp then table.insert(list, hrp) end
        end
        if #list == 0 then task.wait(5) LKA_Stop() return end
        Notify("Kick", "全員 (" .. #list .. "人) kick", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or Workspace:FindFirstChild("SpawnLocation1")
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

-- ============================================================
-- Lag Kick Select
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
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        if sp then
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
    if not selectedTargetName then
        Notify("Error", "ターゲット未選択", 3) return
    end
    local targetPlayer = Players:FindFirstChild(selectedTargetName)
    if not targetPlayer then
        Notify("Error", "プレイヤーなし", 3) return
    end
    LKS_Running = true
    LKS_Task = task.spawn(function()
        LKS_StartLag()
        local height = 35
        task.wait(0.5)
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then LKS_Stop() return end
        local tHrp = GetPlayerHRP(targetPlayer)
        if not tHrp then LKS_StopLag() LKS_Running = false return end
        Notify("Kick", targetPlayer.DisplayName .. " kick", 3)
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or Workspace:FindFirstChild("SpawnLocation1")
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
-- 強力固定ヘルパー
-- ============================================================
local activeEnclosures = {}

local function getEnclosureStore(key)
    if not activeEnclosures[key] then
        activeEnclosures[key] = {}
    end
    return activeEnclosures[key]
end

local function disableAntiKickFor(target)
    if not target then return end
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder.Name:find("SpawnedInToys") then
            for _, toy in ipairs(folder:GetChildren()) do
                if toy.Name == "NinjaShuriken" or toy.Name == "NinjaKunai"
                    or toy.Name == "AntiKick" or toy.Name:lower():find("kunai")
                    or toy.Name:lower():find("antikick") then
                    local destroyed = false
                    local soundPart = toy:FindFirstChild("SoundPart")
                    if soundPart and soundPart:FindFirstChild("PartOwner") then
                        if soundPart.PartOwner.Value == target.Name then
                            if DestroyToy then pcall(function() DestroyToy:FireServer(toy) end) end
                            pcall(function() toy:Destroy() end)
                            destroyed = true
                        end
                    end
                    if not destroyed and target.Character then
                        local char = target.Character
                        for _, bp in ipairs(toy:GetDescendants()) do
                            if bp:IsA("BasePart") then
                                for _, tp in ipairs(char:GetDescendants()) do
                                    if tp:IsA("BasePart") and (bp.Position - tp.Position).Magnitude < 15 then
                                        if DestroyToy then pcall(function() DestroyToy:FireServer(toy) end) end
                                        pcall(function() toy:Destroy() end)
                                        destroyed = true
                                        break
                                    end
                                end
                            end
                            if destroyed then break end
                        end
                    end
                end
            end
        end
    end
    if target.Character then
        for _, obj in ipairs(target.Character:GetDescendants()) do
            if obj.Name:lower():find("antikick")
                or obj.Name:lower():find("kunai")
                or obj.Name == "NinjaShuriken"
                or obj.Name == "NinjaKunai"
                or obj.Name == "AntiKick" then
                pcall(function() obj:Destroy() end)
            end
        end
    end
    if target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp and SetNetworkOwnerEvent then
            pcall(function() SetNetworkOwnerEvent:FireServer(hrp, hrp.CFrame) end)
        end
    end
end

local function destroyEnclosure(key, player)
    local store = activeEnclosures[key]
    if not store then return end
    local data = store[player]
    if not data then return end
    if data.conn then data.conn:Disconnect() end
    if data.charConn then data.charConn:Disconnect() end
    for _, p in ipairs(data.parts) do pcall(function() p:Destroy() end) end
    if data.bp and data.bp.Parent then pcall(function() data.bp:Destroy() end) end
    if data.bg and data.bg.Parent then pcall(function() data.bg:Destroy() end) end
    if data.ap and data.ap.Parent then pcall(function() data.ap:Destroy() end) end
    if data.ao and data.ao.Parent then pcall(function() data.ao:Destroy() end) end
    if data.alignAtt and data.alignAtt.Parent then pcall(function() data.alignAtt:Destroy() end) end
    if data.anchorBase and data.anchorBase.Parent then pcall(function() data.anchorBase:Destroy() end) end
    store[player] = nil
end

local function cleanupEnclosures(key)
    local store = activeEnclosures[key]
    if not store then return end
    for player, _ in pairs(store) do
        destroyEnclosure(key, player)
    end
    activeEnclosures[key] = {}
end

local function cleanupAllEnclosures()
    for key, _ in pairs(activeEnclosures) do
        cleanupEnclosures(key)
    end
end

local function buildEnclosureParts(centerCFrame, size)
    local parts = {}
    local thickness = 1
    local height = size
    local function makeWall(offset, rotY)
        local p = Instance.new("Part")
        p.Anchored = true; p.CanCollide = true
        p.Transparency = 1; p.CanQuery = false; p.CanTouch = true
        p.Size = Vector3.new(size, height, thickness)
        p.CFrame = centerCFrame * CFrame.new(offset) * CFrame.Angles(0, rotY, 0)
        p.Parent = Workspace; p.Name = "LagKickEnclosure"
        table.insert(parts, p)
    end
    makeWall(Vector3.new(0, 0, -size/2), 0)
    makeWall(Vector3.new(0, 0,  size/2), math.rad(180))
    makeWall(Vector3.new(-size/2, 0, 0), math.rad(90))
    makeWall(Vector3.new( size/2, 0, 0), math.rad(-90))
    local ceiling = Instance.new("Part")
    ceiling.Anchored = true; ceiling.CanCollide = true
    ceiling.Transparency = 1; ceiling.CanQuery = false; ceiling.CanTouch = true
    ceiling.Size = Vector3.new(size, thickness, size)
    ceiling.CFrame = centerCFrame * CFrame.new(0, height/2, 0)
    ceiling.Parent = Workspace; ceiling.Name = "LagKickEnclosure"
    table.insert(parts, ceiling)
    local floor = Instance.new("Part")
    floor.Anchored = true; floor.CanCollide = true
    floor.Transparency = 1; floor.CanQuery = false; floor.CanTouch = true
    floor.Size = Vector3.new(size, thickness, size)
    floor.CFrame = centerCFrame * CFrame.new(0, -height/2, 0)
    floor.Parent = Workspace; floor.Name = "LagKickEnclosure"
    table.insert(parts, floor)
    return parts
end

local function lockPlayerWithEnclosure(key, player, lockedCFrame, size, duration)
    if not player then return end
    destroyEnclosure(key, player)
    local hrp = GetPlayerHRP(player)
    if not hrp then return end
    local parts = buildEnclosureParts(lockedCFrame, size)

    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 1e13; bp.D = 2000
    bp.Position = lockedCFrame.Position
    bp.Name = "LagKickBP"; bp.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 1e13; bg.D = 2000
    bg.CFrame = lockedCFrame
    bg.Name = "LagKickBG"; bg.Parent = hrp

    local ap = Instance.new("AlignPosition")
    ap.Mode = Enum.PositionAlignmentMode.OneAttachment
    ap.MaxForce = math.huge
    ap.Responsiveness = 200
    ap.Position = lockedCFrame.Position
    ap.Name = "LagKickAP"

    local alignAtt = Instance.new("Attachment")
    alignAtt.Name = "LagKickAlignAtt"
    alignAtt.Parent = hrp
    ap.Attachment0 = alignAtt
    ap.Parent = hrp

    local ao = Instance.new("AlignOrientation")
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.MaxTorque = math.huge
    ao.Responsiveness = 200
    ao.CFrame = lockedCFrame
    ao.Attachment0 = alignAtt
    ao.Name = "LagKickAO"; ao.Parent = hrp

    local anchorBase = Instance.new("Part")
    anchorBase.Name = "LagKickAnchorBase"
    anchorBase.Anchored = true
    anchorBase.CanCollide = false
    anchorBase.CanQuery = false
    anchorBase.CanTouch = false
    anchorBase.Transparency = 1
    anchorBase.Size = Vector3.new(1, 1, 1)
    anchorBase.CFrame = lockedCFrame
    anchorBase.Parent = Workspace

    local endTime = tick() + (duration or 30)
    local data = {
        parts = parts, bp = bp, bg = bg, ap = ap, ao = ao,
        alignAtt = alignAtt, anchorBase = anchorBase,
        conn = nil, charConn = nil, lockedCFrame = lockedCFrame, hrp = hrp,
    }

    data.conn = RunService.Heartbeat:Connect(function()
        if bp and bp.Parent then pcall(function() bp.Position = lockedCFrame.Position end) end
        if bg and bg.Parent then pcall(function() bg.CFrame = lockedCFrame end) end
        if ap and ap.Parent then pcall(function() ap.Position = lockedCFrame.Position end) end
        if ao and ao.Parent then pcall(function() ao.CFrame = lockedCFrame end) end
        for _, p in ipairs(parts) do
            if p and p.Parent then pcall(function() p.Anchored = true end) end
        end
        if hrp and hrp.Parent then
            local current = hrp.Position
            local target = lockedCFrame.Position
            if (current - target).Magnitude > 2 then
                pcall(function()
                    hrp.CFrame = lockedCFrame
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
            if SetNetworkOwnerEvent then
                pcall(function() SetNetworkOwnerEvent:FireServer(hrp, lockedCFrame) end)
            end
        end
        if tick() >= endTime then destroyEnclosure(key, player) end
    end)

    data.charConn = player.CharacterAdded:Connect(function(newChar)
        local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
        if newHrp and activeEnclosures[key] and activeEnclosures[key][player] then
            local newBp = Instance.new("BodyPosition")
            newBp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            newBp.P = 1e13; newBp.D = 2000
            newBp.Position = lockedCFrame.Position
            newBp.Name = "LagKickBP"; newBp.Parent = newHrp
            local newBg = Instance.new("BodyGyro")
            newBg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            newBg.P = 1e13; newBg.D = 2000
            newBg.CFrame = lockedCFrame
            newBg.Name = "LagKickBG"; newBg.Parent = newHrp
            data.bp = newBp; data.bg = newBg; data.hrp = newHrp
        end
    end)

    getEnclosureStore(key)[player] = data
end

-- ============================================================
-- Lag Kick All（強力固定）
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
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        if sp then
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
    cleanupEnclosures("LKA2")
end

local function LKA2_Execute()
    if LKA2_Running then return end
    LKA2_Running = true
    LKA2_Task = task.spawn(function()
        LKA2_StartLag()
        local height = 35
        task.wait(0.5)
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then LKA2_Stop() return end

        local set = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then set[p.Name] = p end
        end
        local pi = Workspace:FindFirstChild("PlotItems")
        local pip = pi and pi:FindFirstChild("PlayersInPlots")
        if pip then
            for _, o in ipairs(pip:GetChildren()) do
                local p = Players:FindFirstChild(o.Name)
                if p and p ~= LocalPlayer then set[p.Name] = p end
            end
        end

        local list, listPlayers = {}, {}
        for _, p in pairs(set) do
            local hrp = GetPlayerHRP(p)
            if hrp then
                table.insert(list, hrp)
                table.insert(listPlayers, p)
            end
        end
        if #list == 0 then task.wait(5) LKA2_Stop() return end

        for _, p in ipairs(listPlayers) do
            pcall(function() disableAntiKickFor(p) end)
        end
        Notify("Kick", "全員 (" .. #list .. "人) kick (強力固定)", 3)

        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or Workspace:FindFirstChild("SpawnLocation1")
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

            if listPlayers[i] then
                local lockedCFrame = CFrame.new(cx + x, height, cz + z)
                lockPlayerWithEnclosure("LKA2", listPlayers[i], lockedCFrame, 10, 30)
            end
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
-- Lag Kick Select（anti貫通）
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
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        if sp then
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
    cleanupEnclosures("LKS2")
end

local function LKS2_Execute()
    if LKS2_Running then return end
    if not selectedTargetName then
        Notify("Error", "ターゲット未選択", 3) return
    end
    local targetPlayer = Players:FindFirstChild(selectedTargetName)
    if not targetPlayer then
        Notify("Error", "プレイヤーなし", 3) return
    end

    LKS2_Running = true
    LKS2_Task = task.spawn(function()
        LKS2_StartLag()
        local height = 35
        task.wait(0.5)

        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then LKS2_Stop() return end
        local tHrp = GetPlayerHRP(targetPlayer)
        if not tHrp then LKS2_StopLag() LKS2_Running = false return end

        pcall(function() disableAntiKickFor(targetPlayer) end)
        Notify("Kick", targetPlayer.DisplayName .. " kick (anti貫通)", 3)

        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or Workspace:FindFirstChild("SpawnLocation1")
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

        local lockedCFrame = CFrame.new(cx, height, cz + 5)
        lockPlayerWithEnclosure("LKS2", targetPlayer, lockedCFrame, 10, 30)

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
-- Grab Kick All（視点貫通）
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
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        if sp then
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
    cleanupEnclosures("LKA3")
end

local function LKA3_Execute()
    if LKA3_Running then return end
    LKA3_Running = true
    LKA3_Task = task.spawn(function()
        LKA3_StartLag()
        local height = 35
        task.wait(0.5)
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then LKA3_Stop() return end

        local set = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then set[p.Name] = p end
        end
        local pi = Workspace:FindFirstChild("PlotItems")
        local pip = pi and pi:FindFirstChild("PlayersInPlots")
        if pip then
            for _, o in ipairs(pip:GetChildren()) do
                local p = Players:FindFirstChild(o.Name)
                if p and p ~= LocalPlayer then set[p.Name] = p end
            end
        end

        local list, listPlayers = {}, {}
        for _, p in pairs(set) do
            local hrp = GetPlayerHRP(p)
            if hrp then
                table.insert(list, hrp)
                table.insert(listPlayers, p)
            end
        end
        if #list == 0 then task.wait(5) LKA3_Stop() return end

        for _, p in ipairs(listPlayers) do
            pcall(function() disableAntiKickFor(p) end)
        end
        Notify("Kick", "全員 (" .. #list .. "人) kick (視点貫通)", 3)

        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or Workspace:FindFirstChild("SpawnLocation1")
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

            if listPlayers[i] then
                local lockedCFrame = CFrame.new(cx + x, height, cz + z)
                lockPlayerWithEnclosure("LKA3", listPlayers[i], lockedCFrame, 10, 30)
            end
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
-- Grab Kick Select（ビジュアル貫通）
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
        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        if sp then
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
    cleanupEnclosures("LKS3")
end

local function LKS3_Execute()
    if LKS3_Running then return end
    if not selectedTargetName then
        Notify("Error", "ターゲット未選択", 3) return
    end
    local targetPlayer = Players:FindFirstChild(selectedTargetName)
    if not targetPlayer then
        Notify("Error", "プレイヤーなし", 3) return
    end

    LKS3_Running = true
    LKS3_Task = task.spawn(function()
        LKS3_StartLag()
        local height = 35
        task.wait(0.5)

        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then LKS3_Stop() return end
        local tHrp = GetPlayerHRP(targetPlayer)
        if not tHrp then LKS3_StopLag() LKS3_Running = false return end

        pcall(function() disableAntiKickFor(targetPlayer) end)
        Notify("Kick", targetPlayer.DisplayName .. " kick (ビジュアル貫通)", 3)

        local sp = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
            or Workspace:FindFirstChild("SpawnLocation1")
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

        local lockedCFrame = CFrame.new(cx, height, cz + 5)
        lockPlayerWithEnclosure("LKS3", targetPlayer, lockedCFrame, 10, 30)

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
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
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
    Notify("Kick", targetName .. " kick", 3)

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
        Notify("Error", "ターゲット未選択", 2)
        DriftActive = false return
    end
    local target = Players:FindFirstChild(selectedTargetName)
    if not target or not target.Character then
        Notify("Error", "無効なターゲット", 3)
        DriftActive = false return
    end
    Notify("Kick", target.DisplayName .. " kick", 3)
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

-- ============================================================
-- バリア破壊
-- ============================================================
local BarrierAutoRunning = false
local BarrierAutoToggle = nil

local function BarrierExecute()
    local pn = LocalPlayer.Name
    local pi = Workspace:FindFirstChild("PlotItems")
    if pi then
        local pip = pi:FindFirstChild("PlayersInPlots")
        if pip and pip:FindFirstChild(pn) then
            Notify("Error", "家の外で実行してください", 3)
            return false
        end
    end
    BarrierAutoRunning = true
    local ok, result = pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return false end
        local ow = hum.WalkSpeed
        local op = char.HumanoidRootPart.CFrame
        hum.WalkSpeed = 0
        if not ReplicatedStorage:FindFirstChild("MenuToys") then hum.WalkSpeed = ow return false end
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("InstrumentWoodwindOcarina",
            CFrame.new(184.148834, -5.54824972, 498.136749, 0.829037189, -0.214714944, 0.516328275, 0, 0.923344612, 0.383972496, -0.559193552, -0.318327487, 0.765486956),
            Vector3.new(0, 34, 0))
        wait(0.4)
        local tf = Workspace:FindFirstChild(pn .. "SpawnedInToys")
        if not tf or not tf:FindFirstChild("InstrumentWoodwindOcarina") then hum.WalkSpeed = ow return false end
        local oc = tf:FindFirstChild("InstrumentWoodwindOcarina")
        if not oc or not oc:FindFirstChild("HoldPart") then hum.WalkSpeed = ow return false end
        oc.HoldPart.HoldItemRemoteFunction:InvokeServer(oc, Workspace[pn])
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(304.06, 25.77, 488.54)
        end
        wait(0.21)
        if tf and tf:FindFirstChild("InstrumentWoodwindOcarina") then
            ReplicatedStorage.MenuToys.DestroyToy:FireServer(tf.InstrumentWoodwindOcarina)
        end
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = op
        end
        wait(0.7)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("Campfire",
            CFrame.new(257.638672, -5.57392979, 450.103638, -0.950906992, -0.171067372, 0.257899135, 0, 0.833338678, 0.552762806, -0.309477001, 0.525626004, -0.79242748),
            Vector3.new(0, 161.9720001220703, 0))
        wait(0.7)
        local cp = Vector3.new(257.638672, -5.57392979, 450.103638)
        local tf2 = Workspace:FindFirstChild(pn .. "SpawnedInToys")
        if tf2 and tf2:FindFirstChild("Campfire") then
            local cf = tf2:FindFirstChild("Campfire")
            local pp = cf.PrimaryPart or cf:FindFirstChildWhichIsA("BasePart")
            if pp then
                local d = (pp.Position - cp).Magnitude
                if d < 10 then
                    wait(1)
                    hum.WalkSpeed = ow
                    Notify("プロット破壊成功", "Barrier破壊完了", 5)
                    return true
                end
            end
        end
        hum.WalkSpeed = ow
        return false
    end)
    if not ok then
        local char = LocalPlayer.Character
        if char then
            local h = char:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
        end
    end
    BarrierAutoRunning = false
    return result
end

-- ============================================================
-- Anti 設定
-- ============================================================
local AntiConfig = {
    AntiGrab = false, AntiVoid = false, AntiRagdoll = false,
    AntiExplode = false, AntiExplodeV2 = false, AntiGucci = false,
    AntiSpamKick = false, AntiLag = false, AntiKick = false,
    AntiKill = false, KickGrab = false
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
        if ReplicatedStorage.CharacterEvents and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle") then
            ReplicatedStorage.CharacterEvents.Struggle:FireServer(LocalPlayer)
        end
        if ReplicatedStorage.GameCorrectionEvents and ReplicatedStorage.GameCorrectionEvents:FindFirstChild("StopAllVelocity") then
            ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
        end
    end)
end

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

local charEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 10)
local ragdollRemote = charEvents and charEvents:WaitForChild("RagdollRemote", 5)

local toysFolder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
if not toysFolder then toysFolder = Workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys", 5) end
if not toysFolder then
    toysFolder = Instance.new("Folder")
    toysFolder.Name = LocalPlayer.Name .. "SpawnedInToys"
    toysFolder.Parent = Workspace
end

local antiGucciRunning = false
local antiGucciToyName = "CreatureBlobman"
local antiGucciInstance = nil
local antiGucciConn = nil
local antiGucciOriginalPos = nil
local ANTI_DURATION = 0.5
local SPAWN_POS = Vector3.new(0, 999999999999999, 0)

local function clearAntiGucciRagdoll()
    local hrp, hum = GetMyHRP(), GetMyHum()
    if hrp and hum and ragdollRemote then
        pcall(function()
            ragdollRemote:FireServer(hrp, 0)
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
            if ragdollRemote then
                pcall(function()
                    ragdollRemote:FireServer(hrp, 0)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
            RunService.Heartbeat:Wait()
        end
        local primary = child.PrimaryPart or child:FindFirstChild("HumanoidRootPart", true) or child:FindFirstChild("Part", true)
        if primary and antiGucciRunning then
            pcall(function()
                if primary.SetNetworkOwner then primary:SetNetworkOwner(LocalPlayer) end
                sethiddenproperty(primary, "NetworkIsSleeping", false)
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
        Notify("Anti Gucci", "有効化", 3)
    else
        if antiGucciConn then antiGucciConn:Disconnect() antiGucciConn = nil end
        clearAntiGucciRagdoll()
        antiGucciInstance = nil
        antiGucciOriginalPos = nil
        Notify("Anti Gucci", "無効化", 2)
    end
end

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
                    pcall(function() ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(target, target.CFrame) end)
                    pcall(function()
                        local bp = Instance.new("BodyPosition")
                        bp.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                        bp.Position = Vector3.new(25e25, 25e25, 25e25)
                        bp.Parent = target
                        task.wait(0.5)
                        bp:Destroy()
                    end)
                    pcall(function() ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(target) end)
                end
            end)
        end
    end
end)

-- ============================================================
-- Anti-Piercing Kick
-- ============================================================
local kickRunning = false
local kickTask = nil

local function FindKunaiStuckTo(target)
    if not target or not target.Character then return {} end
    local targetParts = {}
    for _, p in ipairs(target.Character:GetDescendants()) do
        if p:IsA("BasePart") then targetParts[p] = true end
    end
    local found = {}
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder.Name:find("SpawnedInToys") then
            for _, toy in ipairs(folder:GetChildren()) do
                if toy.Name == "NinjaShuriken" or toy.Name == "NinjaKunai" or toy.Name == "AntiKick" then
                    local stuck = false
                    local soundPart = toy:FindFirstChild("SoundPart")
                    local stickyPart = toy:FindFirstChild("StickyPart")
                    if soundPart and soundPart:FindFirstChild("PartOwner") then
                        if soundPart.PartOwner.Value == target.Name then stuck = true end
                    end
                    if not stuck and stickyPart then
                        local weld = stickyPart:FindFirstChild("StickyWeld")
                        if weld and weld:IsA("Weld") and weld.Part1 and targetParts[weld.Part1] then
                            stuck = true
                        end
                    end
                    if not stuck then
                        for _, basePart in ipairs(toy:GetDescendants()) do
                            if basePart:IsA("BasePart") then
                                for targetPart, _ in pairs(targetParts) do
                                    if (basePart.Position - targetPart.Position).Magnitude < 15 then
                                        stuck = true; break
                                    end
                                end
                            end
                            if stuck then break end
                        end
                    end
                    if stuck then table.insert(found, toy) end
                end
            end
        end
    end
    for _, p in ipairs(target.Character:GetDescendants()) do
        if p.Name == "NinjaShuriken" or p.Name == "NinjaKunai" or p.Name == "AntiKick" then
            table.insert(found, p)
        end
    end
    return found
end

local function RemoveKunai(toy)
    if not toy or not toy.Parent then return false end
    local sp = toy:FindFirstChild("SoundPart") or toy:FindFirstChildWhichIsA("BasePart", true)
    if not sp then
        pcall(function() toy:Destroy() end)
        return true
    end
    pcall(function()
        if SetNetworkOwnerEvent then SetNetworkOwnerEvent:FireServer(sp, sp.CFrame) end
    end)
    task.wait(0.02)
    pcall(function() sp.CFrame = CFrame.new(0, 5000, 0) end)
    task.wait(0.02)
    pcall(function()
        if DestroyToy then DestroyToy:FireServer(toy) end
    end)
    pcall(function() toy:Destroy() end)
    return true
end

local function RemoveTargetAntiKick(target)
    if not target then return false end
    local kunaiList = FindKunaiStuckTo(target)
    if #kunaiList == 0 then return false end
    for _, k in ipairs(kunaiList) do RemoveKunai(k) end
    return true
end

local function ExecutePiercingKick(target)
    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local seat = myHum and myHum.SeatPart
    if not seat or seat.Parent.Name ~= "CreatureBlobman" then
        return false, "Blobmanに乗ってください"
    end
    local blob = seat.Parent
    local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
    local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
    if not (blobRoot and scriptObj) then return false, "Blobmanパーツ不足" end
    local CG = scriptObj:FindFirstChild("CreatureGrab")
    local CD = scriptObj:FindFirstChild("CreatureDrop")
    local R_Det = blob:FindFirstChild("RightDetector")
    local L_Det = blob:FindFirstChild("LeftDetector")
    local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
    local L_Weld = L_Det and (L_Det:FindFirstChild("LeftWeld") or L_Det:FindFirstChildWhichIsA("Weld"))
    if not (CG and R_Det and R_Weld) then return false, "Blobmanスクリプト不足" end
    RemoveTargetAntiKick(target)
    task.wait(0.1)
    local tRoot = GetHRP(target)
    if not tRoot then return false, "ターゲットなし" end
    local savedPos = blobRoot.CFrame
    for _ = 1, 10 do
        if not tRoot.Parent then break end
        blobRoot.CFrame = tRoot.CFrame
        blobRoot.Velocity = Vector3.zero
        pcall(function()
            CG:FireServer(R_Det, tRoot, R_Weld)
            if SetNetworkOwnerEvent then SetNetworkOwnerEvent:FireServer(tRoot, blobRoot.CFrame) end
        end)
        RunService.Heartbeat:Wait()
    end
    blobRoot.CFrame = savedPos
    blobRoot.Velocity = Vector3.zero
    task.wait(0.05)
    local lockPos = savedPos * CFrame.new(0, 20, 0)
    for _ = 1, 30 do
        if not tRoot or not tRoot.Parent then break end
        local tHum = target.Character and target.Character:FindFirstChild("Humanoid")
        tRoot.CFrame = lockPos
        tRoot.Velocity = Vector3.zero
        tRoot.RotVelocity = Vector3.zero
        if tHum then
            tHum.PlatformStand = true
            tHum.Sit = true
        end
        pcall(function()
            if SetNetworkOwnerEvent then SetNetworkOwnerEvent:FireServer(tRoot, lockPos) end
            if DestroyGrabLine then DestroyGrabLine:FireServer(tRoot) end
            if R_Det and R_Weld then CG:FireServer(R_Det, tRoot, R_Weld) end
            if L_Det and L_Weld then CG:FireServer(L_Det, tRoot, L_Weld) end
            if CreateGrabLine then CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false) end
        end)
        RunService.Heartbeat:Wait()
    end
    pcall(function()
        if R_Det then
            local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
            if weld and CD then CD:FireServer(weld) end
        end
        if L_Det then
            local weld = L_Det:FindFirstChild("LeftWeld") or L_Det:FindFirstChildWhichIsA("Weld")
            if weld and CD then CD:FireServer(weld) end
        end
        if DestroyGrabLine then DestroyGrabLine:FireServer(tRoot) end
    end)
    pcall(function()
        if tRoot then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            bv.Velocity = Vector3.new(
                math.random(-200, 200),
                math.random(200, 500),
                math.random(-200, 200)
            )
            bv.Parent = tRoot
            task.delay(0.5, function() pcall(function() bv:Destroy() end) end)
        end
    end)
    return true, "キック成功"
end

local function StartKickLoop(targetName)
    if kickRunning then return end
    kickRunning = true
    kickTask = task.spawn(function()
        while kickRunning do
            local target = Players:FindFirstChild(targetName)
            if not target or not target.Character then
                task.wait(0.5)
            else
                local ok, msg = ExecutePiercingKick(target)
                if ok then
                    Notify("Kick", target.DisplayName .. " kick", 3)
                    task.wait(0.5)
                elseif msg == "Blobmanに乗ってください" then
                    task.wait(1)
                else
                    task.wait(0.05)
                end
            end
        end
    end)
end

local function StopKickLoop()
    kickRunning = false
    if kickTask then
        pcall(task.cancel, kickTask)
        kickTask = nil
    end
end

local DisableAKActive = false
local DisableAKTask = nil

local function DisableAKStart(targetName)
    if DisableAKTask then return end
    DisableAKActive = true
    DisableAKTask = task.spawn(function()
        while DisableAKActive do
            local target = Players:FindFirstChild(targetName)
            if target and target.Character then
                local kunaiList = FindKunaiStuckTo(target)
                for _, k in ipairs(kunaiList) do RemoveKunai(k) end
            end
            task.wait(0.03)
        end
        DisableAKTask = nil
    end)
end

local function DisableAKStop()
    DisableAKActive = false
    if DisableAKTask then
        pcall(task.cancel, DisableAKTask)
        DisableAKTask = nil
    end
end

_G.LoopDisableActive = false
_G.LoopDisableTask = nil

local function LoopDisableExecute()
    if _G.LoopDisableTask then return end
    _G.LoopDisableActive = true
    _G.LoopDisableTask = task.spawn(function()
        while _G.LoopDisableActive do
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local kunaiList = FindKunaiStuckTo(plr)
                    for _, k in ipairs(kunaiList) do RemoveKunai(k) end
                end
            end
            task.wait(0.03)
        end
        _G.LoopDisableTask = nil
    end)
end

local function LoopDisableStop()
    _G.LoopDisableActive = false
    if _G.LoopDisableTask then
        pcall(task.cancel, _G.LoopDisableTask)
        _G.LoopDisableTask = nil
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if not _G.LoopDisableActive and not DisableAKActive then return end
    if obj.Name == "NinjaShuriken" or obj.Name == "NinjaKunai" or obj.Name == "AntiKick" then
        task.wait(0.15)
        if DisableAKActive and selectedTargetName then
            local target = Players:FindFirstChild(selectedTargetName)
            if target then
                local list = FindKunaiStuckTo(target)
                for _, k in ipairs(list) do RemoveKunai(k) end
            end
        end
        if _G.LoopDisableActive then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local list = FindKunaiStuckTo(plr)
                    for _, k in ipairs(list) do RemoveKunai(k) end
                end
            end
        end
    end
end)

-- ============================================================
-- Tsunami
-- ============================================================
local tsunamiRunning = false
local spawnedShurikens = {}
local anchorConnection = nil
local currentTarget = nil

local function getTargetObject()
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end
    local alwaysHere = map:FindFirstChild("AlwaysHereTweenedObjects")
    if not alwaysHere then return nil end
    local ocean = alwaysHere:FindFirstChild("Ocean")
    if not ocean then return nil end
    local object = ocean:FindFirstChild("Object")
    if not object then return nil end
    local objectModel = object:FindFirstChild("ObjectModel")
    if not objectModel then return nil end
    local children = objectModel:GetChildren()
    local index = 17
    if index <= #children then
        local target = children[index]
        if target and target:IsA("BasePart") then return target, ocean end
    end
    return nil
end

local function SpawnToy(ToyName)
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Root = Character:WaitForChild("HumanoidRootPart")
    local InPlot = LocalPlayer:FindFirstChild("InPlot")
    local InOwnedPlot = LocalPlayer:FindFirstChild("InOwnedPlot")
    local CanSpawnToy = LocalPlayer:FindFirstChild("CanSpawnToy")
    if InPlot and InPlot.Value and InOwnedPlot and not InOwnedPlot.Value then
        InPlot:GetPropertyChangedSignal("Value"):Wait()
    end
    if CanSpawnToy and not CanSpawnToy.Value then
        CanSpawnToy:GetPropertyChangedSignal("Value"):Wait()
    end
    local MyPCLD = nil
    for _, v in pairs(Workspace:GetChildren()) do
        if v.Name == "PlayerCharacterLocationDetector" and GetMag(v, Root) <= 2 then
            MyPCLD = v; break
        end
    end
    local SpawnCF = (MyPCLD or Root).CFrame * CFrame.new(0, 14, 20)
    local Container = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if not Container then return nil end
    local spawnedObject = nil
    local conn
    conn = Container.ChildAdded:Connect(function(child)
        if child.Name == ToyName then
            spawnedObject = child
            conn:Disconnect()
        end
    end)
    task.spawn(function()
        pcall(function()
            SpawnToyRemoteFunction:InvokeServer(ToyName, SpawnCF, Vector3.new(0, 0, 0))
        end)
    end)
    local start = tick()
    repeat task.wait(0.05) until spawnedObject or (tick() - start) > 3
    if conn then pcall(function() conn:Disconnect() end) end
    return spawnedObject
end

local function disableOceanCollision(oceanObject)
    if not oceanObject then return end
    pcall(function() oceanObject.Collision = false end)
end

local function keepUnanchored(target)
    if not target then return end
    if anchorConnection then anchorConnection:Disconnect() anchorConnection = nil end
    currentTarget = target
    anchorConnection = target:GetPropertyChangedSignal("Anchored"):Connect(function()
        if currentTarget and currentTarget.Anchored then
            pcall(function() currentTarget.Anchored = false end)
        end
    end)
    pcall(function() target.Anchored = false end)
end

local function runTsunami()
    if tsunamiRunning then return end
    local targetObject, oceanObject = getTargetObject()
    if not targetObject then
        Notify("Error", "津波オブジェクトが見つかりません", 3)
        return
    end
    tsunamiRunning = true
    keepUnanchored(targetObject)
    for i = 1, 12 do
        if not tsunamiRunning then break end
        local shuriken = SpawnToy("NinjaShuriken")
        if shuriken then
            local SP = FWD(shuriken, "StickyPart")
            if SP then
                sno(SP)
                local BP = Instance.new("BodyPosition")
                BP.Position = Vector3.new(math.random(-100, 100), 1e3, math.random(-100, 100))
                BP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                BP.Parent = SP
                table.insert(spawnedShurikens, shuriken)
            end
        end
        task.wait(0.15)
    end
    local toysFolderLocal = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if toysFolderLocal then
        local crazyCFrame = CFrame.new(0, -2.14748365e+09, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        for _, toy in ipairs(toysFolderLocal:GetChildren()) do
            if toy.Name == "NinjaShuriken" and toy:FindFirstChild("StickyPart") then
                pcall(function()
                    sno(toy.StickyPart)
                    StickyEvent:FireServer(toy.StickyPart, targetObject, crazyCFrame)
                end)
                task.wait(0.05)
            end
        end
    end
    task.wait(0.5)
    if oceanObject then disableOceanCollision(oceanObject) end
    Notify("津波", "津波発生完了", 3)
    tsunamiRunning = false
end

local function tsunamiCleanup()
    tsunamiRunning = false
    if anchorConnection then
        anchorConnection:Disconnect()
        anchorConnection = nil
    end
    currentTarget = nil
    for _, toy in ipairs(spawnedShurikens) do
        if toy and toy.Parent then
            pcall(function()
                local destroyRem = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
                if destroyRem then destroyRem:FireServer(toy) end
            end)
        end
    end
    spawnedShurikens = {}
end

-- ============================================================
-- UI
-- ============================================================
local Window = Library:CreateWindow({
    Title = "Singularity hub",
    Footer = "Kick + Plot + Anti + Tsunami",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("メイン", "user"),
    Kick = Window:AddTab("キック", "swords"),
    Plot = Window:AddTab("プロット破壊", "hammer"),
    Anti = Window:AddTab("Anti", "shield"),
    Tsunami = Window:AddTab("津波", "waves"),
}

local TargetGroup = Tabs.Main:AddLeftGroupbox("ターゲット", "target")
TargetGroup:AddDropdown("TargetDropdown", {
    Values = GetPlayerList(),
    Default = "",
    Text = "ターゲットを選択",
    Searchable = true,
    Callback = function(selected)
        if selected and selected ~= "" then
            local un = selected:match("%@(.-)%)")
            if un then
                selectedTargetName = un
                Notify("ターゲット設定", un, 2)
            end
        end
    end,
})
TargetGroup:AddButton({
    Text = "プレイヤーリスト更新",
    Func = function() Options.TargetDropdown:SetValues(GetPlayerList()) end,
})

local KickLeft = Tabs.Kick:AddLeftGroupbox("キック / ラグ", "swords")
local KickRight = Tabs.Kick:AddRightGroupbox("Anti-Piercing Kick", "target")

KickLeft:AddToggle("AllkickToggle", {
    Text = "Allkick", Default = false,
    Callback = function(value)
        if value then
            AllkickExecute()
            Notify("開始", "Allkick 開始", 2)
        else
            AllkickStop()
            Notify("停止", "Allkick 停止", 2)
        end
    end,
})

KickLeft:AddToggle("NoblobkickToggle", {
    Text = "Noblobkick", Default = false,
    Callback = function(value)
        if value then
            TlagExecute()
            Notify("開始", "Noblobkick 開始", 2)
        else
            TlagStop()
            Notify("停止", "Noblobkick 停止", 2)
        end
    end,
})

KickLeft:AddButton({
    Text = "Blobkick",
    Func = function() GrabKickExecute() end,
})

KickLeft:AddButton({
    Text = "Lagkick",
    Func = function() LagkExecute() end,
})

KickLeft:AddToggle("LKA_Toggle", {
    Text = "lag kick all", Default = false,
    Callback = function(value)
        if value then
            LKA_Execute()
            Notify("開始", "lag kick all 開始", 2)
        else
            LKA_Stop()
            Notify("停止", "lag kick all 停止", 2)
        end
    end,
})

KickLeft:AddToggle("LKS_Toggle", {
    Text = "lag kick select", Default = false,
    Callback = function(value)
        if value then
            LKS_Execute()
            Notify("開始", "lag kick select 開始", 2)
        else
            LKS_Stop()
            Notify("停止", "lag kick select 停止", 2)
        end
    end,
})

KickLeft:AddToggle("LKA2_Toggle", {
    Text = "lag kick all(強力固定)", Default = false,
    Callback = function(value)
        if value then
            LKA2_Execute()
            Notify("開始", "lag kick all(強力固定) 開始", 2)
        else
            LKA2_Stop()
            Notify("停止", "lag kick all(強力固定) 停止", 2)
        end
    end,
})

KickLeft:AddToggle("LKS2_Toggle", {
    Text = "lag kick select(anti貫通)", Default = false,
    Callback = function(value)
        if value then
            LKS2_Execute()
            Notify("開始", "lag kick select(anti貫通) 開始", 2)
        else
            LKS2_Stop()
            Notify("停止", "lag kick select(anti貫通) 停止", 2)
        end
    end,
})

KickLeft:AddToggle("LKA3_Toggle", {
    Text = "grab kick all(視点貫通)", Default = false,
    Callback = function(value)
        if value then
            LKA3_Execute()
            Notify("開始", "grab kick all(視点貫通) 開始", 2)
        else
            LKA3_Stop()
            Notify("停止", "grab kick all(視点貫通) 停止", 2)
        end
    end,
})

KickLeft:AddToggle("LKS3_Toggle", {
    Text = "grab kick select(ビジュアル貫通)", Default = false,
    Callback = function(value)
        if value then
            LKS3_Execute()
            Notify("開始", "grab kick select(ビジュアル貫通) 開始", 2)
        else
            LKS3_Stop()
            Notify("停止", "grab kick select(ビジュアル貫通) 停止", 2)
        end
    end,
})

KickLeft:AddToggle("SpamKToggle", {
    Text = "Spam Kick", Default = false,
    Callback = function(value)
        if value then
            if not selectedTargetName then
                Notify("Error", "ターゲット未選択", 3)
                Toggles.SpamKToggle:SetValue(false)
                return
            end
            SpamKStart(selectedTargetName)
            Notify("開始", "Spam Kick 開始", 2)
        else
            SpamKStop()
            Notify("停止", "Spam Kick 停止", 2)
        end
    end,
})

KickLeft:AddToggle("DriftKToggle", {
    Text = "Drift Kick", Default = false,
    Callback = function(value)
        if value then
            DriftStart()
            Notify("開始", "Drift Kick 開始", 2)
        else
            DriftStop()
            Notify("停止", "Drift Kick 停止", 2)
        end
    end,
})

KickLeft:AddDivider()
KickLeft:AddLabel("Drift Kick 設定")

KickLeft:AddSlider("DriftRadiusSlider", {
    Text = "Orbit半径",
    Min = 5, Max = 50, Default = 19, Rounding = 0,
    Suffix = " studs",
    Callback = function(v) DriftRadius = v end,
})

KickLeft:AddSlider("DriftSpeedSlider", {
    Text = "Orbit速度",
    Min = 1, Max = 20, Default = 8.5, Rounding = 1,
    Callback = function(v) DriftSpeed = v end,
})

KickLeft:AddSlider("DriftHeightSlider", {
    Text = "高度オフセット",
    Min = -10, Max = 10, Default = 0, Rounding = 0,
    Suffix = " studs",
    Callback = function(v) DriftHeight = v end,
})

KickRight:AddToggle("APKToggle", {
    Text = "Anti-Piercing Kick", Default = false,
    Callback = function(value)
        if value then
            if not selectedTargetName then
                Notify("Error", "ターゲット未選択", 3)
                Toggles.APKToggle:SetValue(false)
                return
            end
            local myChar = LocalPlayer.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local seat = myHum and myHum.SeatPart
            if not seat or seat.Parent.Name ~= "CreatureBlobman" then
                Notify("Error", "Blobmanに乗ってください", 3)
                Toggles.APKToggle:SetValue(false)
                return
            end
            StartKickLoop(selectedTargetName)
            Notify("開始", "Anti-Piercing Kick 開始", 2)
        else
            StopKickLoop()
            Notify("停止", "Anti-Piercing Kick 停止", 2)
        end
    end,
})

KickRight:AddDivider()

KickRight:AddButton({
    Text = "強制停止（キック全停止）",
    Func = function()
        AllkickStop()
        TlagStop()
        SpamKStop()
        DriftStop()
        LKA_Stop()
        LKS_Stop()
        LKA2_Stop()
        LKS2_Stop()
        LKA3_Stop()
        LKS3_Stop()
        StopKickLoop()
        cleanupAllEnclosures()
        Notify("停止", "キック全停止", 2)
    end,
})

local PlotGroup = Tabs.Plot:AddLeftGroupbox("バリア破壊", "hammer")

PlotGroup:AddButton({
    Text = "Break Barrier（1回実行）",
    Func = function() BarrierExecute() end,
})

PlotGroup:AddDivider()
PlotGroup:AddLabel("自動実行機能")

BarrierAutoToggle = PlotGroup:AddToggle("BarrierAutoToggle", {
    Text = "Auto Barrier破壊", Default = false,
    Callback = function(Value)
        BarrierAutoRunning = Value
        if Value then
            task.spawn(function()
                while BarrierAutoRunning do
                    local result = BarrierExecute()
                    if result then
                        if BarrierAutoToggle then BarrierAutoToggle:SetValue(false) end
                        break
                    end
                    wait(1)
                end
            end)
        end
    end,
})

local AntiGroupL = Tabs.Anti:AddLeftGroupbox("Anti 機能", "shield")
local AntiGroupR = Tabs.Anti:AddRightGroupbox("Anti-Kick 対策 / グラブ", "zap")

AntiGroupL:AddToggle("AntiGrabToggle", {
    Text = "Anti Grab", Default = false,
    Callback = function(v) AntiConfig.AntiGrab = v end,
})
AntiGroupL:AddToggle("AntiVoidToggle", {
    Text = "Anti Void", Default = false,
    Callback = function(v) AntiConfig.AntiVoid = v end,
})
AntiGroupL:AddToggle("AntiRagdollToggle", {
    Text = "Anti Ragdoll", Default = false,
    Callback = function(v) AntiConfig.AntiRagdoll = v end,
})
AntiGroupL:AddToggle("AntiExplodeToggle", {
    Text = "Anti Explode", Default = false,
    Callback = function(v) AntiConfig.AntiExplode = v; SetupAntiExplode() end,
})
AntiGroupL:AddToggle("AntiExplodeV2Toggle", {
    Text = "Anti Explode V2", Default = false,
    Callback = function(v)
        AntiConfig.AntiExplodeV2 = v
        local h = LocalPlayer.PlayerScripts:FindFirstChild("ClientExoplosionHandler")
        if h then h.Enabled = not v end
    end,
})
AntiGroupL:AddToggle("AntiGucciToggle", {
    Text = "Anti Gucci", Default = false,
    Callback = function(v) toggleAntiGucci(v) end,
})
AntiGroupL:AddToggle("AntiSpamKickToggle", {
    Text = "Anti Spam Kick", Default = false,
    Callback = function(v) AntiConfig.AntiSpamKick = v end,
})
AntiGroupL:AddToggle("AntiLagToggle", {
    Text = "Anti Lag Kick", Default = false,
    Callback = function(v)
        AntiConfig.AntiLag = v
        local gf = ReplicatedStorage:FindFirstChild("GrabEvents")
        if v then
            if gf then
                local c = gf:FindFirstChild("CreateGrabLine")
                local e = gf:FindFirstChild("ExtendGrabLine")
                if c and c:IsA("RemoteEvent") then c:Destroy() end
                if e and e:IsA("RemoteEvent") then e:Destroy() end
            end
            for _, o in ipairs(Workspace:GetDescendants()) do
                if o:IsA("Beam") or (o.Name and string.lower(o.Name):find("line")) then
                    pcall(function() o:Destroy() end)
                end
            end
        else
            if gf then
                if createGrabLineCopy and not gf:FindFirstChild("CreateGrabLine") then
                    createGrabLineCopy:Clone().Parent = gf
                end
                if extendGrabLineCopy and not gf:FindFirstChild("ExtendGrabLine") then
                    extendGrabLineCopy:Clone().Parent = gf
                end
            end
        end
    end,
})

AntiGroupR:AddToggle("AntiKickToggle", {
    Text = "Anti Kick", Default = false, Risky = true,
    Callback = function(v) AntiConfig.AntiKick = v; setupAntiKick(v) end,
})
AntiGroupR:AddToggle("AntiKillToggle", {
    Text = "Anti Kill", Default = false, Risky = true,
    Callback = function(v) AntiConfig.AntiKill = v; setupAntiKill(v) end,
})
AntiGroupR:AddDivider()
AntiGroupR:AddToggle("KickGrabToggle", {
    Text = "Kick Grab", Default = false,
    Callback = function(v) AntiConfig.KickGrab = v end,
})
AntiGroupR:AddDivider()

AntiGroupR:AddButton({
    Text = "ターゲットのAnti-Kick除去",
    Func = function()
        if not selectedTargetName then
            Notify("Error", "ターゲット未選択", 3)
            return
        end
        local target = Players:FindFirstChild(selectedTargetName)
        if target then
            local ok = RemoveTargetAntiKick(target)
            if ok then
                Notify("成功", target.Name .. " のAnti-Kickを除去", 2)
            else
                Notify("情報", "除去対象は見つかりませんでした", 2)
            end
        end
    end,
})

AntiGroupR:AddToggle("DisableAKToggle", {
    Text = "Target Anti-Kick ループ無効化", Default = false,
    Callback = function(v)
        if v then
            if not selectedTargetName then
                Notify("Error", "ターゲット未選択", 3)
                Toggles.DisableAKToggle:SetValue(false)
                return
            end
            DisableAKStart(selectedTargetName)
            Notify("開始", "ターゲットAnti-Kickループ除去 開始", 2)
        else
            DisableAKStop()
            Notify("停止", "ターゲットAnti-Kickループ除去 停止", 2)
        end
    end,
})

AntiGroupR:AddToggle("LoopDisableAKToggle", {
    Text = "全員 Anti-Kick ループ無効化", Default = false,
    Callback = function(v)
        if v then
            LoopDisableExecute()
            Notify("開始", "全員Anti-Kick自動除去 開始", 2)
        else
            LoopDisableStop()
            Notify("停止", "全員Anti-Kick自動除去 停止", 2)
        end
    end,
})

local TsunamiGroup = Tabs.Tsunami:AddLeftGroupbox("津波コントロール", "waves")

TsunamiGroup:AddButton({
    Text = "Tsunami 実行",
    Func = function() task.spawn(runTsunami) end,
})

TsunamiGroup:AddButton({
    Text = "Tsunami クリーンアップ",
    Func = function()
        tsunamiCleanup()
        Notify("津波", "クリーンアップ完了", 2)
    end,
})

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if Options.TargetDropdown then Options.TargetDropdown:SetValues(GetPlayerList()) end
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    if Options.TargetDropdown then Options.TargetDropdown:SetValues(GetPlayerList()) end
end)

-- ============================================================
-- チャットに "Singularity hub" を表示（読み込み時のみ）
-- ============================================================
task.spawn(function()
    local TextChatService = game:GetService("TextChatService")
    local sent = false
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channels = TextChatService:FindFirstChild("TextChannels")
            local general = channels and channels:FindFirstChild("RBXGeneral")
            if general then
                general:SendAsync("Singularity hub")
                sent = true
            end
        end
    end)
    if not sent then
        pcall(function()
            local StarterGui = game:GetService("StarterGui")
            StarterGui:SetCore("ChatSendMessage", { Text = "Singularity hub" })
        end)
    end
end)

Notify("Singularity hub", "読み込み完了", 3)

Library:OnUnload(function()
    AllkickStop()
    TlagStop()
    SpamKStop()
    DriftStop()
    LKA_Stop()
    LKS_Stop()
    LKA2_Stop()
    LKS2_Stop()
    LKA3_Stop()
    LKS3_Stop()
    StopKickLoop()
    DisableAKStop()
    LoopDisableStop()
    tsunamiCleanup()
    cleanupAllEnclosures()
    print("[Singularity hub] Unloaded!")
end)
