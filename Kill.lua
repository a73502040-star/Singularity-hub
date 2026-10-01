-- ============================================================
-- Kill.lua - Kill系 + Loop Kill + Blobman Kill + Loop Blob KickSpam
-- ============================================================
local S = _G.Singularity
if not S or not S.Library then
    warn("[Singularity] Shared.lua not loaded")
    return
end

local Library = S.Library
local Tabs = S.Tabs
local Players = S.Players
local Workspace = S.Workspace
local RS = S.RS
local RunService = S.RunService
local LocalPlayer = S.LocalPlayer
local Notify = S.Notify
local reg = S.reg
local MyHRP = S.MyHRP
local MyHum = S.MyHum
local PPHRP = S.PPHRP

local SetNet = S.SetNet
local CGL = S.CGL
local DGL = S.DGL
local SpawnToy = S.SpawnToy
local DestroyToy = S.DestroyToy

-- ============================================================
-- Loop Blob KickSpam（Kick.lua からも参照される）
-- ============================================================
local function LoopBlobKickSpam()
    local REMOTE_DELAY = 0.002
    local lastRemote, savedPos = 0, nil
    while _G.loopBlobKickSpamActive do
        local tg = Players:FindFirstChild(_G.loopBlobKickSpamTargetName)
        if not tg or not tg.Character or not tg.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.3)
            continue
        end
        local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local h = c:WaitForChild("Humanoid")
        local s = h.SeatPart
        if not s or s.Parent.Name ~= "CreatureBlobman" then
            Notify("Error","Please sit on a Blobman",5)
            if S.Toggles.BlobSpamKickToggle then
                S.Toggles.BlobSpamKickToggle:SetValue(false)
            end
            return
        end
        local blob = s.Parent
        local br = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        local so = blob:WaitForChild("BlobmanSeatAndOwnerScript")
        local CG = so:WaitForChild("CreatureGrab")
        local CD = so:WaitForChild("CreatureDrop")
        local RD = blob:WaitForChild("RightDetector")
        savedPos = br.CFrame
        local drag, gs = false, 0
        while _G.loopBlobKickSpamActive do
            local ct = Players:FindFirstChild(_G.loopBlobKickSpamTargetName)
            if not ct then break end
            c = LocalPlayer.Character
            h = c and c:FindFirstChild("Humanoid")
            s = h and h.SeatPart
            if not s or s.Parent.Name ~= "CreatureBlobman" then break end
            br = s.Parent:FindFirstChild("HumanoidRootPart") or s.Parent.PrimaryPart
            local tc = ct.Character
            local tr = tc and tc:FindFirstChild("HumanoidRootPart")
            local th = tc and tc:FindFirstChild("Humanoid")
            if tr and th and th.Health > 0 and br then
                tr.Velocity = Vector3.zero
                if not drag then
                    br.CFrame = tr.CFrame; br.Velocity = Vector3.zero
                    if tick() - lastRemote >= REMOTE_DELAY then
                        lastRemote = tick()
                        pcall(function()
                            th.PlatformStand = true; th.Sit = true
                            S.SetNet:FireServer(tr, br.CFrame)
                            S.DGL:FireServer(tr)
                        end)
                    end
                    if gs == 0 then gs = tick() end
                    if tick() - gs > 0.35 then drag = true; gs = 0; br.CFrame = savedPos end
                else
                    br.CFrame = savedPos; br.Velocity = Vector3.zero
                    local lp = savedPos * CFrame.new(0, 23, 0)
                    tr.CFrame = lp; th.PlatformStand = true; th.Sit = true
                    if tick() - lastRemote >= REMOTE_DELAY then
                        lastRemote = tick()
                        pcall(function()
                            S.SetNet:FireServer(tr, lp)
                            S.DGL:FireServer(tr)
                            local w = RD:FindFirstChild("RightWeld") or RD:FindFirstChildWhichIsA("Weld")
                            if w then CD:FireServer(w); CG:FireServer(RD, tr, w) end
                        end)
                    end
                end
            else
                drag = false; gs = 0
            end
            RunService.Heartbeat:Wait()
        end
        if br then br.CFrame = savedPos end
    end
end

S.LoopBlobKickSpam = LoopBlobKickSpam

-- ============================================================
-- Loop Kill 1 / 2
-- ============================================================
local function LoopKill1()
    while _G.loopKill1Active do
        local t = Players:FindFirstChild(_G.loopKill1TargetName)
        if t and t.Character then
            local tr = t.Character:FindFirstChild("HumanoidRootPart")
            local th = t.Character:FindFirstChild("Humanoid")
            if tr and th and th.Health > 0 then
                local c = LocalPlayer.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if r then
                    local orig = r.CFrame
                    local s = tick()
                    while tick() - s < 0.35 and _G.loopKill1Active do
                        if not tr.Parent then break end
                        r.CFrame = tr.CFrame * CFrame.new(0, 0, 2); r.Velocity = Vector3.zero
                        pcall(function()
                            S.RS.GrabEvents.SetNetworkOwner:FireServer(tr, r.CFrame)
                            th.BreakJointsOnDeath = false
                            th:ChangeState(Enum.HumanoidStateType.Dead)
                            S.RS.GrabEvents.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false)
                            S.RS.GrabEvents.DestroyGrabLine:FireServer(tr)
                        end)
                        RunService.Heartbeat:Wait()
                    end
                    if r then r.CFrame = orig; r.Velocity = Vector3.zero end
                end
            end
        end
        task.wait(0.05)
    end
end

local function LoopKill2()
    while _G.loopKill2Active do
        local t = Players:FindFirstChild(_G.loopKill2TargetName)
        if t and t.Character then
            local tr = t.Character:FindFirstChild("HumanoidRootPart")
            local th = t.Character:FindFirstChildOfClass("Humanoid")
            if tr and th and th.Health > 0 then
                local c = LocalPlayer.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if r then
                    local orig = r.CFrame
                    local fc = 0
                    while fc < 18 and th and th.Health > 0 and _G.loopKill2Active do
                        fc = fc + 1
                        r.CFrame = tr.CFrame * CFrame.new(0, 0, 2.5)
                        r.Velocity = Vector3.zero
                        r.RotVelocity = Vector3.zero
                        pcall(function()
                            S.RS.GrabEvents.SetNetworkOwner:FireServer(tr, r.CFrame)
                            th.BreakJointsOnDeath = false
                            th:ChangeState(Enum.HumanoidStateType.Dead)
                            S.RS.GrabEvents.CreateGrabLine:FireServer(tr, Vector3.new(0,-200,0), tr.Position, true)
                            S.RS.GrabEvents.DestroyGrabLine:FireServer(tr)
                        end)
                        RunService.Heartbeat:Wait()
                    end
                    if r then r.CFrame = orig end
                end
            end
        end
        task.wait(0.05)
    end
end

-- ============================================================
-- Snowball Ragdoll
-- ============================================================
local function SnowballRag()
    while _G.snowballRagdollActive do
        local t = Players:FindFirstChild(_G.snowballRagdollTargetName)
        if not t or not t.Character then task.wait(0.5); continue end
        local tc = t.Character
        local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
        if not torso then task.wait(); continue end
        pcall(function()
            local o = Vector3.new(math.random(-30,30)/100, math.random(-30,30)/100, math.random(-30,30)/100)
            SpawnToy:InvokeServer("BallSnowball", torso.CFrame * CFrame.new(o), Vector3.zero)
        end)
        local f = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
        if f then
            for _, sb in pairs(f:GetChildren()) do
                if sb.Name == "BallSnowball" and sb.Parent then
                    local p = sb.PrimaryPart or sb:FindFirstChildWhichIsA("BasePart")
                    if p then
                        local o = Vector3.new(math.random(-30,30)/100, math.random(-30,30)/100, math.random(-30,30)/100)
                        p.CFrame = torso.CFrame * CFrame.new(o)
                        p.AssemblyLinearVelocity = Vector3.zero
                        p.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        end
        task.wait()
    end
end

-- ============================================================
-- Blobman Kill (BK)
-- ============================================================
local BK = {
    isRunning = false, isKillAura = false, isSelectedKill = false,
    selectedPlayer = nil, currentBlobman = nil,
    killAuraConnection = nil, selectedKillConn = nil
}
S.BK = BK

local TP_WAIT, GRAB_WAIT, RETRY_WAIT, MAX_RETRIES, MAX_DIST = 0.02, 0.01, 0.01, 5, 500

local function GetSeatedBlob()
    local c = LocalPlayer.Character; if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid"); if not h then return nil end
    local s = h.SeatPart
    if not s or not s:IsA("VehicleSeat") then return nil end
    local o = s
    while o do
        if o:IsA("Model") and o.Name == "CreatureBlobman" then return o end
        o = o.Parent
    end
end

local function SpawnBlobman()
    local sb = GetSeatedBlob()
    if sb then BK.currentBlobman = sb; return sb end
    if BK.currentBlobman and BK.currentBlobman.Parent then
        local bp
        if BK.currentBlobman.PrimaryPart then
            bp = BK.currentBlobman.PrimaryPart.Position
        else
            local p = BK.currentBlobman:FindFirstChildWhichIsA("BasePart")
            if p then bp = p.Position end
        end
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        local lp = r and r.Position
        if bp and lp and (bp - lp).Magnitude < MAX_DIST then
            local s = BK.currentBlobman:FindFirstChild("VehicleSeat")
            if s then
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h then s:Sit(h); task.wait(0.08) end
            end
            return BK.currentBlobman
        else
            pcall(function() BK.currentBlobman:Destroy() end)
            BK.currentBlobman = nil
        end
    end
    local c = LocalPlayer.Character; if not c then return nil end
    local r = c:FindFirstChild("HumanoidRootPart"); if not r then return nil end
    local ok = pcall(function()
        SpawnToy:InvokeServer("CreatureBlobman", r.CFrame * CFrame.new(0,0,-5), Vector3.new(0, 127, 0))
    end)
    if not ok then return nil end
    local fn = LocalPlayer.Name.."SpawnedInToys"
    local b, t0 = nil, tick()
    repeat
        local tf = workspace:FindFirstChild(fn)
        if tf then b = tf:FindFirstChild("CreatureBlobman") end
        if b then break end
        task.wait()
    until tick() - t0 > 2
    if not b then return nil end
    BK.currentBlobman = b
    local s = b:FindFirstChild("VehicleSeat")
    if s then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then s:Sit(h) end
    end
    task.wait(0.08)
    return b
end

local function KillPlayer(p)
    if not p or not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid"); if not h then return false end
    for _ = 1, MAX_RETRIES do
        local ok = pcall(function()
            h.BreakJointsOnDeath = false
            h:ChangeState(Enum.HumanoidStateType.Dead)
        end)
        if ok and h.Health <= 0 then return true end
        task.wait(RETRY_WAIT)
    end
    return false
end

local function GrabRelease(blob, tr)
    if not blob or not tr then return end
    pcall(function()
        local s = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        if s then
            s.CreatureGrab:FireServer(blob.LeftDetector, tr, blob.LeftDetector.LeftWeld)
            s.CreatureRelease:FireServer(blob.LeftDetector.LeftWeld)
        end
    end)
end

local function ProcessPlayer(p)
    if not p or not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    local tr = p.Character:FindFirstChild("HumanoidRootPart"); if not tr then return false end
    local b = SpawnBlobman(); if not b then return false end
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        c.HumanoidRootPart.CFrame = tr.CFrame
        task.wait(TP_WAIT)
    end
    KillPlayer(p)
    for _ = 1, 3 do GrabRelease(b, tr); task.wait(GRAB_WAIT) end
    return true
end

local function ProcessAll()
    local c = LocalPlayer.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local r = c.HumanoidRootPart
    local b = SpawnBlobman(); if not b then return end
    local tgts = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character
        and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(tgts, p)
        end
    end
    for _, p in ipairs(tgts) do
        if not BK.isRunning then break end
        local tc = p.Character; if not tc then continue end
        local h = tc:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then continue end
        local tr = tc:FindFirstChild("HumanoidRootPart"); if not tr then continue end
        r.CFrame = tr.CFrame
        task.wait(TP_WAIT)
        KillPlayer(p)
        for _ = 1, 2 do GrabRelease(b, tr); task.wait(GRAB_WAIT) end
    end
end

local function StartSelLoop()
    if BK.selectedKillConn then pcall(task.cancel, BK.selectedKillConn); BK.selectedKillConn = nil end
    if not BK.selectedPlayer then return end
    BK.selectedKillConn = task.spawn(function()
        while BK.isSelectedKill and BK.selectedPlayer and BK.selectedPlayer.Parent do
            if BK.selectedPlayer.Character
            and BK.selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(ProcessPlayer, BK.selectedPlayer)
            end
            task.wait(0.5)
        end
    end)
end

local function SetupAura()
    if BK.killAuraConnection then BK.killAuraConnection:Disconnect(); BK.killAuraConnection = nil end
    BK.killAuraConnection = RunService.Heartbeat:Connect(function()
        if not (BK.isKillAura or BK.isRunning) then return end
        local c = LocalPlayer.Character
        if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        local r = c.HumanoidRootPart
        if not BK.currentBlobman or not BK.currentBlobman.Parent then
            BK.currentBlobman = SpawnBlobman()
            if not BK.currentBlobman then return end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character
            and p.Character:FindFirstChild("HumanoidRootPart") then
                local tr = p.Character.HumanoidRootPart
                if (r.Position - tr.Position).Magnitude <= 40 then
                    KillPlayer(p)
                    GrabRelease(BK.currentBlobman, tr)
                end
            end
        end
    end)
end

local function UpdateAura()
    local sr = BK.isKillAura or BK.isRunning
    if sr then
        if not BK.killAuraConnection then SetupAura() end
    else
        if BK.killAuraConnection then BK.killAuraConnection:Disconnect(); BK.killAuraConnection = nil end
    end
end

S.KillProcessAll = ProcessAll

-- ============================================================
-- UI 構築（Kill タブ）
-- ============================================================
local KillTab = Tabs.Kill
local KillL = KillTab:AddLeftGroupbox("Blobman Kill", "skull")

KillL:AddToggle("BlobmanKillAllToggle", {
    Text = "Kill All", Default = false,
    Callback = function(v)
        BK.isRunning = v
        if v then
            if S.Toggles.BlobmanKillAuraToggle then
                S.Toggles.BlobmanKillAuraToggle:SetValue(false)
            end
            UpdateAura()
            task.spawn(function()
                while BK.isRunning do ProcessAll(); task.wait() end
            end)
            Notify("Start","Kill All",2)
        else
            UpdateAura()
            Notify("Stop","Kill All",2)
        end
    end
})
KillL:AddToggle("BlobmanKillAuraToggle", {
    Text = "Kill Aura", Default = false,
    Callback = function(v)
        BK.isKillAura = v
        if v then
            if S.Toggles.BlobmanKillAllToggle then
                S.Toggles.BlobmanKillAllToggle:SetValue(false)
            end
            SpawnBlobman()
            Notify("Start","Kill Aura",2)
        else
            Notify("Stop","Kill Aura",2)
        end
        UpdateAura()
    end
})
KillL:AddToggle("BlobmanSelectedKillToggle", {
    Text = "Selected Kill", Default = false,
    Callback = function(v)
        BK.isSelectedKill = v
        if v then
            BK.selectedPlayer = S.selectedTargetName and Players:FindFirstChild(S.selectedTargetName)
            if not BK.selectedPlayer then
                Notify("Error","No target selected",2)
                S.Toggles.BlobmanSelectedKillToggle:SetValue(false)
                return
            end
            StartSelLoop()
            Notify("Start","Selected Kill",2)
        else
            if BK.selectedKillConn then pcall(task.cancel, BK.selectedKillConn); BK.selectedKillConn = nil end
            Notify("Stop","Selected Kill",2)
        end
    end
})

local KillR = KillTab:AddRightGroupbox("Loop Kill", "skull")
KillR:AddToggle("LoopKillToggle", {
    Text = "Loop kill", Default = false,
    Callback = function(v)
        _G.loopKill1Active = v
        if v then
            _G.loopKill1TargetName = S.selectedTargetName
            if not _G.loopKill1TargetName then
                Notify("Error","No target selected",3)
                S.Toggles.LoopKillToggle:SetValue(false)
                return
            end
            task.spawn(LoopKill1)
            Notify("Start","Loop kill",2)
        else
            Notify("Stop","Loop kill",2)
        end
    end
})
KillR:AddToggle("LoopKill2Toggle", {
    Text = "Loop kill (Anti Pierce)", Default = false,
    Callback = function(v)
        _G.loopKill2Active = v
        if v then
            _G.loopKill2TargetName = S.selectedTargetName
            if not _G.loopKill2TargetName then
                Notify("Error","No target selected",3)
                S.Toggles.LoopKill2Toggle:SetValue(false)
                return
            end
            task.spawn(LoopKill2)
            Notify("Start","Loop kill(anti)",2)
        else
            Notify("Stop","Loop kill(anti)",2)
        end
    end
})

-- ============================================================
-- Lag & Ragdoll タブ：Ragdoll グループ
-- ============================================================
local LagRagTab = Tabs.LagRag
local RagL = LagRagTab:AddLeftGroupbox("Ragdoll", "activity")

RagL:AddToggle("SnowballRagdollToggle", {
    Text = "Snowball Ragdoll", Default = false,
    Callback = function(v)
        _G.snowballRagdollActive = v
        if v then
            _G.snowballRagdollTargetName = S.selectedTargetName
            if not _G.snowballRagdollTargetName then
                Notify("Error","No target selected",3)
                S.Toggles.SnowballRagdollToggle:SetValue(false)
                return
            end
            _G.snowballRagdollTask = task.spawn(SnowballRag)
            Notify("Start","Snowball Ragdoll",2)
        else
            if _G.snowballRagdollTask then
                task.cancel(_G.snowballRagdollTask)
                _G.snowballRagdollTask = nil
            end
            Notify("Stop","Snowball Ragdoll",2)
        end
    end
})

Notify("Kill", "Loaded", 2)
