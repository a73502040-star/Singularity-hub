-- ============================================================
-- Kick.lua - Kick系全部（Lag Kick / Spam / Drift / Blob Kick）
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
local EGL = S.EGL
local SpawnToy = S.SpawnToy
local DestroyToy = S.DestroyToy

local makeLag = S.makeLag

-- ============================================================
-- Kick 本体
-- ============================================================
local function makeKick(rate)
    local startLag, stopLag = makeLag(rate)()
    local running, task_ = false, nil
    local function stop()
        running = false
        if task_ then pcall(task.cancel, task_); task_ = nil end
        stopLag()
    end
    local function exec(single)
        if running then return end
        running = true
        task_ = reg(task.spawn(function()
            startLag()
            local H = 35
            task.wait(single and 1 or 0.5)
            local my = MyHRP(); if not my then stop(); return end
            local list = {}
            if single then
                if not S.selectedTargetName then stop(); return end
                local tp = Players:FindFirstChild(S.selectedTargetName)
                local h = tp and PPHRP(tp)
                if h then table.insert(list, h) end
            else
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer then
                        local h = PPHRP(p)
                        if h then table.insert(list, h) end
                    end
                end
            end
            if #list == 0 then task.wait(5); stop(); return end
            Notify("Kick", (single and "Target" or ("All ("..#list..")")).." kicked", 3)

            local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
            local cx = sp and sp.Position.X or 0
            local cz = sp and sp.Position.Z or 0

            pcall(function() my.CFrame = CFrame.new(cx, H, cz); my.AssemblyLinearVelocity = Vector3.zero end)
            for _, h in ipairs(list) do
                pcall(function() my.CFrame = h.CFrame * CFrame.new(0,5,5); my.AssemblyLinearVelocity = Vector3.zero end)
                task.wait(0.2)
                if SetNet then pcall(function() SetNet:FireServer(h, h.CFrame) end) end
            end

            local R = single and 10 or 80
            local step = (math.pi*2)/math.max(#list, 1)
            for i, h in ipairs(list) do
                local a = (i-1)*step
                local x, z = math.cos(a)*R, math.sin(a)*R
                if single and not (i == 1) then break end
                pcall(function() h.CFrame = CFrame.new(cx+x, H, cz+z); h.AssemblyLinearVelocity = Vector3.zero end)
                local bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(9e9,9e9,9e9); bp.P = 1e5
                bp.Position = Vector3.new(cx+x, H, cz+z); bp.Parent = h
                task.delay(2, function() pcall(function() bp:Destroy() end) end)
                task.wait()
            end

            pcall(function() my.CFrame = CFrame.new(cx, H, cz); my.AssemblyLinearVelocity = Vector3.zero end)
            for _ = 1, 80 do
                for _, h in ipairs(list) do
                    task.spawn(function()
                        if CGL and DGL then
                            pcall(function()
                                CGL:FireServer(h, CFrame.new(0, 1e9, 0))
                                DGL:FireServer(h)
                            end)
                        end
                    end)
                end
                task.wait(0.03)
            end
            task.wait(6)
            stop()
        end))
    end
    return exec, stop
end

local AllkickExec, AllkickStop = makeKick(85)
local TlagExec, TlagStop = makeKick(85)
S.AllkickStop = AllkickStop
S.TlagStop = TlagStop

-- ============================================================
-- GrabKick
-- ============================================================
local GrabKickChar = LocalPlayer.Character
LocalPlayer.CharacterAdded:Connect(function(c) GrabKickChar = c end)

local function GKGetBlob()
    if not GrabKickChar then return nil end
    local f = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
    if f then
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("Model") and c.Name:find("CreatureBlobman") then return c end
        end
    end
    for _, d in ipairs(GrabKickChar:GetDescendants()) do
        if d:IsA("Model") and d.Name:find("CreatureBlobman") then return d end
    end
end
local function GKWeld(det)
    if not det then return end
    for _, c in ipairs(det:GetChildren()) do
        if c:IsA("Weld") or c:IsA("ManualWeld") then c:Destroy() end
    end
end

local GKRunning = false
local function GrabKickExecute()
    if GKRunning then return end
    if not S.selectedTargetName then Notify("Error","No target selected",3); return end
    local tp = Players:FindFirstChild(S.selectedTargetName)
    if not tp or not tp.Character then return end
    local th = tp.Character:FindFirstChild("HumanoidRootPart")
    if not th then return end
    GKRunning = true
    task.spawn(function()
        local blob = GKGetBlob()
        if not blob then Notify("Error","Please sit on a Blobman",3); GKRunning = false; return end
        local bs = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        if not bs then GKRunning = false; return end
        local gr, rr, dr = bs:FindFirstChild("CreatureGrab"), bs:FindFirstChild("CreatureRelease"), bs:FindFirstChild("CreatureDrop")
        local rd = blob:FindFirstChild("RightDetector")
        local rw = rd and rd:FindFirstChild("RightWeld")
        if not gr or not rd then GKRunning = false; return end
        pcall(function() th:SetNetworkOwner(LocalPlayer) end)
        for _ = 1, 6 do
            if not th.Parent then break end
            pcall(function()
                th.AssemblyLinearVelocity = Vector3.zero
                th.AssemblyAngularVelocity = Vector3.zero
                GKWeld(rd)
                local ao = blob:GetPivot():Inverse()*rd.CFrame
                blob:PivotTo(th.CFrame*ao:Inverse())
                for _ = 1, 6 do gr:FireServer(rd, th, rw) task.wait(0.001) end
                task.wait(0.01)
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                bv.Velocity = Vector3.new(math.random(-10,10), math.random(8,18), math.random(-10,10)).Unit
                bv.Parent = th
                task.delay(0.05, function() pcall(function() bv:Destroy() end) end)
                if rr then pcall(function() rr:FireServer() end) end
                if dr then pcall(function() dr:FireServer() end) end
                GKWeld(rd)
            end)
            task.wait(0.001)
        end
        pcall(function() th:SetNetworkOwner(nil) end)
        Notify("Kick", tp.DisplayName.." kicked", 3)
        GKRunning = false
    end)
end

-- ============================================================
-- Lagkick
-- ============================================================
local LagkRunning = false
local function LagkExecute()
    if LagkRunning then return end
    if not S.selectedTargetName then return end
    local tp = Players:FindFirstChild(S.selectedTargetName)
    if not tp or not tp.Character then return end
    local tr = tp.Character:FindFirstChild("HumanoidRootPart")
    if not tr then return end
    LagkRunning = true
    task.spawn(function()
        local myChar = LocalPlayer.Character
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local inv = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
        local blob = inv and inv:FindFirstChild("CreatureBlobman")
        if not blob and SpawnToy then
            local mr = myChar and myChar:FindFirstChild("HumanoidRootPart")
            pcall(function() SpawnToy:InvokeServer("CreatureBlobman", mr and mr.CFrame or CFrame.new(0,50,0), Vector3.zero) end)
            task.wait(1)
            inv = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
            blob = inv and inv:FindFirstChild("CreatureBlobman")
        end
        if not blob then LagkRunning = false; return end
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
                pcall(function() gr:FireServer(ld, mr, lw) end); task.wait(0.08)
                if SetNet then pcall(function() SetNet:FireServer(tr, tr.CFrame) end) end; task.wait(0.08)
                pcall(function() tr.CFrame = tr.CFrame + Vector3.new(0,16,0) end); task.wait(0.08)
                if DGL then pcall(function() DGL:FireServer(tr) end) end; task.wait(0.08)
                pcall(function() gr:FireServer(ld, tr, lw) end); task.wait(0.08)
                if dr then pcall(function() dr:FireServer(ld, tr) end) end; task.wait(0.08)
                if DGL then pcall(function() DGL:FireServer(tr) end) end
            end
        end
        if DestroyToy then pcall(function() DestroyToy:FireServer(blob) end) end
        Notify("Kick", tp.DisplayName.." kicked", 3)
        LagkRunning = false
    end)
end

-- ============================================================
-- Lag Kick All / Select
-- ============================================================
local function makeLKA(radius, mult)
    local running, task_
    local startLag, stopLag = makeLag(1000)()
    local function stop()
        running = false
        if task_ then pcall(task.cancel, task_); task_ = nil end
        stopLag()
    end
    local function exec()
        if running then return end
        running = true
        task_ = reg(task.spawn(function()
            startLag()
            local H = 35
            task.wait(0.5)
            local my = MyHRP(); if not my then stop(); return end
            local list = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local h = PPHRP(p)
                    if h then table.insert(list, h) end
                end
            end
            if #list == 0 then task.wait(5); stop(); return end
            Notify("Kick", "All ("..#list..") kicked", 3)
            local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
            local cx = sp and sp.Position.X or 0
            local cz = sp and sp.Position.Z or 0
            pcall(function() my.CFrame = CFrame.new(cx, H, cz); my.AssemblyLinearVelocity = Vector3.zero end)
            for _, h in ipairs(list) do
                pcall(function() my.CFrame = h.CFrame * CFrame.new(0,5,5); my.AssemblyLinearVelocity = Vector3.zero end)
                task.wait(0.2)
                if SetNet then
                    for _ = 1, mult do
                        pcall(function() SetNet:FireServer(h, h.CFrame) end)
                    end
                end
            end
            local step = (math.pi*2)/math.max(#list, 1)
            for i, h in ipairs(list) do
                local a = (i-1)*step
                local x, z = math.cos(a)*radius, math.sin(a)*radius
                pcall(function() h.CFrame = CFrame.new(cx+x, H, cz+z); h.AssemblyLinearVelocity = Vector3.zero end)
                local bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(9e9,9e9,9e9); bp.P = 1e5
                bp.Position = Vector3.new(cx+x, H, cz+z); bp.Parent = h
                task.delay(2, function() pcall(function() bp:Destroy() end) end)
                task.wait()
            end
            pcall(function() my.CFrame = CFrame.new(cx, H, cz); my.AssemblyLinearVelocity = Vector3.zero end)
            for _ = 1, 80 do
                for _, h in ipairs(list) do
                    task.spawn(function()
                        if CGL and DGL then
                            pcall(function()
                                CGL:FireServer(h, CFrame.new(0,1e9,0))
                                DGL:FireServer(h)
                            end)
                        end
                    end)
                end
                task.wait(0.03)
            end
            task.wait(6)
            stop()
        end))
    end
    return exec, stop
end

local function makeLKS(radius, mult)
    local running, task_
    local startLag, stopLag = makeLag(1000)()
    local function stop()
        running = false
        if task_ then pcall(task.cancel, task_); task_ = nil end
        stopLag()
    end
    local function exec()
        if running then return end
        if not S.selectedTargetName then Notify("Error","No target selected",3); return end
        local tp = Players:FindFirstChild(S.selectedTargetName)
        if not tp then Notify("Error","Player not found",3); return end
        running = true
        task_ = reg(task.spawn(function()
            startLag()
            local H = 35
            task.wait(0.5)
            local my = MyHRP(); if not my then stop(); return end
            local th = PPHRP(tp); if not th then stop(); return end
            Notify("Kick", tp.DisplayName.." kicked", 3)
            local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
            local cx = sp and sp.Position.X or 0
            local cz = sp and sp.Position.Z or 0
            pcall(function() my.CFrame = CFrame.new(cx, H, cz); my.AssemblyLinearVelocity = Vector3.zero end)
            pcall(function() my.CFrame = th.CFrame * CFrame.new(0,5,5); my.AssemblyLinearVelocity = Vector3.zero end)
            task.wait(0.2)
            if SetNet then
                for _ = 1, mult do
                    pcall(function() SetNet:FireServer(th, th.CFrame) end)
                end
            end
            pcall(function() th.CFrame = CFrame.new(cx, H, cz+5); th.AssemblyLinearVelocity = Vector3.zero end)
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(9e9,9e9,9e9); bp.P = 1e5
            bp.Position = Vector3.new(cx, H, cz+5); bp.Parent = th
            task.delay(2, function() pcall(function() bp:Destroy() end) end)
            pcall(function() my.CFrame = CFrame.new(cx, H, cz); my.AssemblyLinearVelocity = Vector3.zero end)
            for _ = 1, 80 do
                task.spawn(function()
                    if CGL and DGL then
                        pcall(function()
                            CGL:FireServer(th, CFrame.new(0,1e9,0))
                            DGL:FireServer(th)
                        end)
                    end
                end)
                task.wait(0.03)
            end
            task.wait(6)
            stop()
        end))
    end
    return exec, stop
end

local LKAExec, LKAStop = makeLKA(10, 2)
local LKSExec, LKSStop = makeLKS(10, 3)
local LKA2Exec, LKA2Stop = makeLKA(10, 2)
local LKS2Exec, LKS2Stop = makeLKS(10, 2)
local LKA3Exec, LKA3Stop = makeLKA(10, 2)
local LKS3Exec, LKS3Stop = makeLKS(10, 2)

S.LKAStop = LKAStop
S.LKSStop = LKSStop
S.LKA2Stop = LKA2Stop
S.LKS2Stop = LKS2Stop
S.LKA3Stop = LKA3Stop
S.LKS3Stop = LKS3Stop

-- ============================================================
-- Spam Kick
-- ============================================================
local SpamKActive, SpamKTask = false, nil
local SpamKLagRunning, SpamKRagdollRunning = false, false
local SpamKSelectedName

local function SpamKTele(target, myRoot)
    if not target.Character then return end
    local th = target.Character:FindFirstChild("HumanoidRootPart")
    if not th or not myRoot then return end
    local s = myRoot.CFrame
    myRoot.CFrame = th.CFrame * CFrame.new(0,0,2)
    for _ = 1, 15 do
        if SetNet then SetNet:FireServer(th, th.CFrame) end
        task.wait()
    end
    myRoot.CFrame = s
end

local function SpawnToy_(name)
    local ch = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = ch:WaitForChild("HumanoidRootPart")
    local folder = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys") or Workspace
    local res
    local conn = folder.ChildAdded:Connect(function(c) if c.Name == name then res = c end end)
    task.spawn(function()
        pcall(function()
            if SpawnToy then SpawnToy:InvokeServer(name, root.CFrame*CFrame.new(0,14,20), Vector3.zero) end
        end)
    end)
    local t = tick()
    repeat task.wait(0.05) until res or tick()-t > 5
    conn:Disconnect()
    return res
end

local function SpawnRag()
    if SpamKRagdollRunning then return nil end
    SpamKRagdollRunning = true
    local toy = SpawnToy_("PalletLightBrown")
    if not toy then SpamKRagdollRunning = false; return nil end
    local sp = toy:FindFirstChild("SoundPart") or toy:WaitForChild("SoundPart", 3)
    if not sp then toy:Destroy(); SpamKRagdollRunning = false; return nil end
    local n = 0
    while n < 10 do
        if not SpamKActive then toy:Destroy(); SpamKRagdollRunning = false; return nil end
        if SetNet then SetNet:FireServer(sp, sp.CFrame) end
        task.wait()
        if sp:FindFirstChild("PartOwner") then break end
        n = n + 1
    end
    if not sp:FindFirstChild("PartOwner") then toy:Destroy(); SpamKRagdollRunning = false; return nil end
    for _, d in pairs(toy:GetDescendants()) do
        if d:IsA("BasePart") then d.CanCollide = false; d.Transparency = 0.8 end
    end
    toy.Name = "RagdollPalete"
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Velocity = Vector3.new(0, 900, 0)
    bv.Parent = sp
    SpamKRagdollRunning = false
    return toy
end

local function SpamKStop()
    SpamKActive = false
    if SpamKTask then pcall(task.cancel, SpamKTask); SpamKTask = nil end
    SpamKLagRunning = false
    local t = SpamKSelectedName and Players:FindFirstChild(SpamKSelectedName)
    if t and t.Character then
        local r = t.Character:FindFirstChild("HumanoidRootPart")
        if r and r:FindFirstChild("ControlBP") then r.ControlBP:Destroy() end
    end
end

local function SpamKStart(name)
    if SpamKActive then return end
    SpamKSelectedName = name
    SpamKActive = true
    SpamKLagRunning = true
    task.spawn(function()
        while SpamKLagRunning do
            local sp = Workspace:FindFirstChild("SpawnLocation")
                    or Workspace:FindFirstChild("Spawn")
                    or MyHRP()
            if sp and CGL then
                CGL:FireServer(sp, CFrame.new(
                    math.random(-2010000000, 2000200000), 0,
                    math.random(-2008100000, 2000200000)))
            end
            task.wait()
        end
    end)
    Notify("Kick", name.." kicked", 3)
    SpamKTask = task.spawn(function()
        local rag = nil
        local folder = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
        while SpamKActive do
            local t = Players:FindFirstChild(name)
            local my = MyHRP()
            if t and my then
                local tc = t.Character
                local th = tc and tc:FindFirstChild("HumanoidRootPart")
                local th_h = tc and tc:FindFirstChild("Humanoid")
                if th and th_h then
                    if (my.Position - th.Position).Magnitude > 15 then SpamKTele(t, my) end
                    if SetNet then SetNet:FireServer(th, th.CFrame) end
                    if DGL then DGL:FireServer(th) end
                    th.AssemblyLinearVelocity = Vector3.zero
                    th.AssemblyAngularVelocity = Vector3.zero
                    local bp = th:FindFirstChild("ControlBP")
                    if not bp then
                        bp = Instance.new("BodyPosition")
                        bp.Name = "ControlBP"
                        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bp.P = 800000
                        bp.Parent = th
                    end
                    bp.Position = my.Position + Vector3.new(5, 10, 5)
                    if rag and rag:IsDescendantOf(Workspace) then
                        local sp = rag:FindFirstChild("SoundPart")
                        if sp then
                            if not sp:FindFirstChild("PartOwner") then rag:Destroy(); rag = nil end
                        else
                            rag:Destroy(); rag = nil
                        end
                    end
                    if not SpamKRagdollRunning and (not rag or not rag:IsDescendantOf(Workspace)) then
                        rag = folder and folder:FindFirstChild("RagdollPalete") or SpawnRag()
                    end
                    if rag and rag:FindFirstChild("SoundPart") then
                        local r = th_h:FindFirstChild("Ragdolled")
                        if r and not r.Value then rag.SoundPart.Position = th.Position end
                    end
                end
            end
            task.wait()
        end
    end)
end

S.SpamKStop = SpamKStop

-- ============================================================
-- Drift Kick
-- ============================================================
local DriftActive, DriftRadius, DriftSpeed, DriftHeight, DriftAngle, DriftLoopId = false, 19, 8.5, 0, 0, 0
local function DriftStop() DriftActive = false; DriftLoopId = DriftLoopId + 1 end
local function DriftStart()
    DriftActive = true
    DriftLoopId = DriftLoopId + 1
    local myLoop = DriftLoopId
    if not S.selectedTargetName then Notify("Error","No target selected",2); DriftActive = false; return end
    local t = Players:FindFirstChild(S.selectedTargetName)
    if not t or not t.Character then DriftActive = false; return end
    Notify("Kick", t.DisplayName.." kicked", 3)
    task.spawn(function()
        local inv = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
        local blob = inv and inv:FindFirstChild("CreatureBlobman")
        if not blob and SpawnToy then
            local mr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            pcall(function() SpawnToy:InvokeServer("CreatureBlobman", mr and mr.CFrame or CFrame.new(0,50,0), Vector3.zero) end)
            task.wait(1)
            inv = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
            blob = inv and inv:FindFirstChild("CreatureBlobman")
        end
        if not blob then DriftActive = false; return end
        local seat = blob:FindFirstChild("VehicleSeat")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if seat and hum and not hum.Sit then
            pcall(function() seat:Sit(hum) end)
            task.wait(0.6)
        end
        local br = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        if not br then DriftActive = false; return end
        local saved, last = nil, tick()
        while DriftActive and myLoop == DriftLoopId and blob.Parent do
            local tg = Players:FindFirstChild(t.Name)
            if not tg or not tg.Character then break end
            local tr = tg.Character:FindFirstChild("HumanoidRootPart")
            local th = tg.Character:FindFirstChild("Humanoid")
            if not tr or not th or th.Health <= 0 then break end
            if not saved then saved = tr.CFrame end
            local center = saved + Vector3.new(0, 30, 0)
            local now = tick(); local dt = now - last; last = now
            DriftAngle = DriftAngle + DriftSpeed * dt
            local bp = center.Position + Vector3.new(math.cos(DriftAngle)*DriftRadius, DriftHeight, math.sin(DriftAngle)*DriftRadius)
            pcall(function()
                br.CFrame = CFrame.new(bp, center.Position)
                br.AssemblyLinearVelocity = Vector3.zero
                br.AssemblyAngularVelocity = Vector3.zero
                tr.CFrame = center
                tr.AssemblyLinearVelocity = Vector3.zero
                tr.AssemblyAngularVelocity = Vector3.zero
                th.PlatformStand = true
                th.Sit = true
                if SetNet then SetNet:FireServer(tr, center) end
            end)
            RunService.Heartbeat:Wait()
        end
        if br and saved then
            pcall(function()
                br.CFrame = saved
                br.AssemblyLinearVelocity = Vector3.zero
            end)
        end
    end)
end

S.DriftStop = DriftStop

-- ============================================================
-- UI 構築（Kickタブ）
-- ============================================================
local KickTab = Tabs.Kick
local KL = KickTab:AddLeftGroupbox("Kick", "swords")

KL:AddToggle("AllkickToggle", {
    Text = "Allkick", Default = false,
    Callback = function(v)
        if v then AllkickExec(false); Notify("Start","Allkick",2)
        else AllkickStop(); Notify("Stop","Allkick",2) end
    end
})
KL:AddToggle("NoblobkickToggle", {
    Text = "Noblobkick", Default = false,
    Callback = function(v)
        if v then TlagExec(true); Notify("Start","Noblobkick",2)
        else TlagStop(); Notify("Stop","Noblobkick",2) end
    end
})
KL:AddButton({ Text = "Blobkick", Func = GrabKickExecute })
KL:AddButton({ Text = "Lagkick", Func = LagkExecute })

local function mKick(name, text, ex, st)
    KL:AddToggle(name, {
        Text = text, Default = false,
        Callback = function(v)
            if v then ex(); Notify("Start", text, 2)
            else st(); Notify("Stop", text, 2) end
        end
    })
end
mKick("LKA_Toggle", "Lag Kick All", LKAExec, LKAStop)
mKick("LKS_Toggle", "Lag Kick Select", LKSExec, LKSStop)
mKick("LKA2_Toggle", "Lag Kick All (Strong)", LKA2Exec, LKA2Stop)
mKick("LKS2_Toggle", "Lag Kick Select (Anti Pierce)", LKS2Exec, LKS2Stop)
mKick("LKA3_Toggle", "Grab Kick All (Vision Pierce)", LKA3Exec, LKA3Stop)
mKick("LKS3_Toggle", "Grab Kick Select (Visual Pierce)", LKS3Exec, LKS3Stop)

KL:AddToggle("SpamKToggle", {
    Text = "Spam Kick", Default = false,
    Callback = function(v)
        if v then
            if not S.selectedTargetName then
                Notify("Error","No target selected",3)
                Toggles.SpamKToggle:SetValue(false)
                return
            end
            SpamKStart(S.selectedTargetName); Notify("Start","Spam Kick",2)
        else
            SpamKStop(); Notify("Stop","Spam Kick",2)
        end
    end
})
KL:AddToggle("DriftKToggle", {
    Text = "Drift Kick", Default = false,
    Callback = function(v)
        if v then DriftStart(); Notify("Start","Drift Kick",2)
        else DriftStop(); Notify("Stop","Drift Kick",2) end
    end
})

-- ---------- Kick All Options ----------
local KAK = {mode = "circle", r = 10, iR = 5, oR = 15, sS = 5, sE = 15, py = 100, sy = 100, wl = {}}
local KAKT = nil
local function KAAll()
    if KAKT then
        pcall(task.cancel, KAKT); KAKT = nil
        Notify("KickAll","Stopped",2)
        return
    end
    KAKT = reg(task.spawn(function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and not KAK.wl[p.Name] and p.Character
            and p.Character:FindFirstChild("HumanoidRootPart") then
                list[#list+1] = p
            end
        end
        if #list == 0 then Notify("KickAll","No targets",2); KAKT = nil; return end
        Notify("KickAll","Kicking "..#list.." players",2)
        local r = MyHRP(); if not r then KAKT = nil; return end
        local inv = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
        local b = inv and inv:FindFirstChild("CreatureBlobman")
        if not b and SpawnToy then
            SpawnToy:InvokeServer("CreatureBlobman", r.CFrame * CFrame.new(0,0,-8), Vector3.new(0, 27.4, 0))
            task.wait(1)
            inv = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
            b = inv and inv:FindFirstChild("CreatureBlobman")
        end
        if not b then Notify("KickAll","Blob fail",3); KAKT = nil; return end
        local s = b:FindFirstChild("VehicleSeat")
        local h = MyHum()
        if s and h and not h.Sit then pcall(function() s:Sit(h) end); task.wait(.6) end
        for _, p in ipairs(list) do
            local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                r.CFrame = tr.CFrame; task.wait(.02)
                if SetNet then SetNet:FireServer(tr, tr.CFrame) end
            end
        end
        r.CFrame = CFrame.new(0, KAK.sy, 0); task.wait(.1)
        for _, pp in ipairs(b:GetDescendants()) do
            if pp:IsA("BasePart") then pcall(function() pp.Anchored = true end) end
        end
        task.wait(.1)
        local n = #list
        for i, p in ipairs(list) do
            local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local ang = (i-1) * (math.pi*2) / n
                local x, z = 0, 0
                if KAK.mode == "circle" then
                    x, z = math.cos(ang)*KAK.r, math.sin(ang)*KAK.r                elseif KAK.mode == "double" then
                    if i <= n/2 then
                        x, z = math.cos(ang)*KAK.iR, math.sin(ang)*KAK.iR
                    else
                        x, z = math.cos(ang)*KAK.oR, math.sin(ang)*KAK.oR
                    end
                elseif KAK.mode == "spiral" then
                    local t = (i-1) / math.max(n-1, 1)
                    local rr = KAK.sS + (KAK.sE - KAK.sS) * t
                    x, z = math.cos(ang*3)*rr, math.sin(ang*3)*rr
                end
                tr.CFrame = CFrame.new(x, KAK.py, z)
                local bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(9e9,9e9,9e9); bp.P = 1e5
                bp.Position = Vector3.new(x, KAK.py, z); bp.Parent = tr
                task.delay(2, function() pcall(function() bp:Destroy() end) end)
            end
            task.wait()
        end
        for _ = 1, 5 do
            for _, p in ipairs(list) do
                local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if tr and CGL and DGL then
                    pcall(function()
                        CGL:FireServer(tr, CFrame.new(0,1e9,0))
                        DGL:FireServer(tr)
                    end)
                end
            end
            task.wait(.3)
        end
        for _, pp in ipairs(b:GetDescendants()) do
            if pp:IsA("BasePart") then pcall(function() pp.Anchored = false end) end
        end
        Notify("KickAll","Done",2)
        KAKT = nil
    end))
end
S.KAKT = function() if KAKT then pcall(task.cancel, KAKT); KAKT = nil end end

local KR = KickTab:AddRightGroupbox("Exploits", "zap")
KR:AddToggle("BlobSpamKickToggle", {
    Text = "Blob spam kick", Default = false,
    Callback = function(v)
        _G.loopBlobKickSpamActive = v
        if v then
            _G.loopBlobKickSpamTargetName = S.selectedTargetName
            if not _G.loopBlobKickSpamTargetName then
                Notify("Error","No target selected",3)
                Toggles.BlobSpamKickToggle:SetValue(false)
                return
            end
            _G.loopBlobKickSpamTask = task.spawn(S.LoopBlobKickSpam)
            Notify("Start","Blob spam kick",2)
        else
            if _G.loopBlobKickSpamTask then task.cancel(_G.loopBlobKickSpamTask); _G.loopBlobKickSpamTask = nil end
            Notify("Stop","Blob spam kick",2)
        end
    end
})
KR:AddToggle("SpamKickGrabToggle", {
    Text = "Spam kick(grab)", Default = false,
    Callback = function(on)
        _G.kickLoopEnabled = on
        if on then
            if not S.selectedTargetName then
                Notify("Error","No target selected",3)
                Toggles.SpamKickGrabToggle:SetValue(false)
                return
            end
            _G.loopBlobKickSpamTargetName = S.selectedTargetName
            task.spawn(function()
                local c, r, saved = LocalPlayer.Character, nil, nil
                r = c and c:FindFirstChild("HumanoidRootPart")
                if r then saved = r.CFrame end
                local drag, gs = false, 0
                while _G.kickLoopEnabled do
                    local t = Players:FindFirstChild(_G.loopBlobKickSpamTargetName)
                    if not t or not t.Parent then _G.kickLoopEnabled = false; break end
                    local tc = t.Character
                    local tr = tc and tc:FindFirstChild("HumanoidRootPart")
                    local th = tc and tc:FindFirstChild("Humanoid")
                    c = LocalPlayer.Character
                    r = c and c:FindFirstChild("HumanoidRootPart")
                    if tr and th and th.Health > 0 and r then
                        tr.Velocity = Vector3.zero
                        if not drag then
                            r.CFrame = tr.CFrame
                            pcall(function()
                                th.PlatformStand = true; th.Sit = true
                                SetNet:FireServer(tr, r.CFrame)
                                CGL:FireServer(tr, Vector3.zero, tr.Position, false)
                            end)
                            if gs == 0 then gs = tick() end
                            if tick() - gs > 0.35 then drag = true; gs = 0 end
                        else
                            r.CFrame = saved
                            local lp = saved * CFrame.new(0,17,0)
                            tr.CFrame = lp; th.PlatformStand = true; th.Sit = false
                            pcall(function()
                                SetNet:FireServer(tr, lp)
                                CGL:FireServer(tr, Vector3.zero, tr.Position, false)
                                DGL:FireServer(tr)
                                CGL:FireServer(tr, Vector3.zero, tr.Position, false)
                            end)
                        end
                    else
                        drag = false; gs = 0
                        if r then r.CFrame = saved end
                    end
                    RunService.Heartbeat:Wait()
                end
                if r then r.CFrame = saved end
            end)
            Notify("Start","Spam kick(grab)",2)
        else
            Notify("Stop","Spam kick(grab)",2)
        end
    end
})
KR:AddDivider()
KR:AddButton({
    Text = "Stop All Kick",
    Func = function()
        AllkickStop(); TlagStop(); LKAStop(); LKSStop(); LKA2Stop(); LKS2Stop(); LKA3Stop(); LKS3Stop()
        SpamKStop(); DriftStop()
        _G.kickLoopEnabled = false
        if _G.loopBlobKickSpamTask then task.cancel(_G.loopBlobKickSpamTask); _G.loopBlobKickSpamTask = nil end
        Notify("Stop","All kicks stopped",2)
    end
})

local KAO = KickTab:AddRightGroupbox("Kick All Options", "zap")
KAO:AddDropdown("KAMode", {Text="Mode", Values={"circle","double","spiral"}, Default="circle", Callback=function(v) KAK.mode = v end})
KAO:AddSlider("KARadius", {Text="Radius", Default=10, Min=5, Max=100, Rounding=0, Callback=function(v) KAK.r = v end})
KAO:AddSlider("KAInner", {Text="Inner", Default=5, Min=5, Max=50, Rounding=0, Callback=function(v) KAK.iR = v end})
KAO:AddSlider("KAOuter", {Text="Outer", Default=15, Min=10, Max=100, Rounding=0, Callback=function(v) KAK.oR = v end})
KAO:AddSlider("KAPlayerY", {Text="Player Y", Default=100, Min=10, Max=500, Rounding=0, Callback=function(v) KAK.py = v end})
KAO:AddButton({Text="Execute Kick All", Func=KAAll})

Notify("Kick", "Loaded", 2)
