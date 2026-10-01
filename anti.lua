-- ============================================================
-- Anti.lua - Anti系全部 + FTAP Defense + Defense系
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
local Cam = S.Cam
local Notify = S.Notify
local reg = S.reg
local MyHRP = S.MyHRP
local MyHum = S.MyHum
local FWD = S.FWD

local SetNet = S.SetNet
local CGL = S.CGL
local DGL = S.DGL
local EGL = S.EGL
local SpawnToy = S.SpawnToy
local DestroyToy = S.DestroyToy
local Ragdoll = S.Ragdoll
local Struggle = S.Struggle

-- ---------- Global states ----------
_G.antiAntiKickActive = false
_G.removeAntiKickAuraActive = false
_G.removeAntiKickRadius = 50
_G.AntiGrabNRDEnabled = false
_G.AntiGrabNRDProc = false
_G.AGNRDWalk = false
_G.StruggleNRD = Struggle
_G.RagdollRemoteNRD = Ragdoll
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
_G.antiInputLagTask = nil
_G.SelectedAntiInputToy = "FoodHamburger"
_G.antiAntiLagEnabled = false
_G.removeAntiInputTask = nil

-- ============================================================
-- Anti 基本設定
-- ============================================================
local AntiConfig = {
    AntiGrab = false, AntiVoid = false, AntiRagdoll = false,
    AntiExplode = false, AntiExplodeV2 = false, AntiGucci = false,
    AntiSpamKick = false, AntiLag = false, AntiKick = false,
    AntiKill = false, KickGrab = false
}

local function DoStruggle()
    pcall(function() if Struggle then Struggle:FireServer(LocalPlayer) end end)
end

-- Anti Explode
local AntiExplodeConn
local function SetupAntiExplode()
    if AntiConfig.AntiExplode then
        if AntiExplodeConn then return end
        AntiExplodeConn = Workspace.ChildAdded:Connect(function(c)
            if c.Name:find("Explosion") or c.Name:find("Bomb") then
                pcall(function() c:Destroy() end)
            end
        end)
    else
        if AntiExplodeConn then AntiExplodeConn:Disconnect(); AntiExplodeConn = nil end
    end
end

-- Anti Gucci
local aGRunning = false
local aGConn, aGInst, aGOrig
local function aGClear()
    local h, h2 = MyHRP(), MyHum()
    if h and h2 and Ragdoll then
        pcall(function()
            Ragdoll:FireServer(h, 0)
            h2:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end
local function aGSeq(c)
    if c.Name ~= "CreatureBlobman" then return end
    aGInst = c
    local h, h2 = MyHRP(), MyHum()
    if not (h and h2) then return end
    local seat = c:WaitForChild("VehicleSeat", 2) or c:FindFirstChildWhichIsA("VehicleSeat", true)
    if seat and h2 then
        seat:Sit(h2)
        local s = tick()
        while tick() - s < 0.5 and aGRunning do
            if Ragdoll then
                pcall(function()
                    Ragdoll:FireServer(h, 0)
                    h2:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
            RunService.Heartbeat:Wait()
        end
        local p = c.PrimaryPart or c:FindFirstChild("HumanoidRootPart", true) or c:FindFirstChild("Part", true)
        if p and aGRunning then
            pcall(function()
                if p.SetNetworkOwner then p:SetNetworkOwner(LocalPlayer) end
            end)
        end
        if aGOrig then h.CFrame = aGOrig end
        task.wait(0.1)
        if seat then seat:Destroy() end
    end
end
local function toggleAntiGucci(s)
    AntiConfig.AntiGucci = s
    aGRunning = s
    if s then
        local h = MyHRP(); if h then aGOrig = h.CFrame end
        if aGConn then aGConn:Disconnect() end
        local f = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        if f then
            aGConn = f.ChildAdded:Connect(function(c) task.spawn(function() aGSeq(c) end) end)
        end
        task.spawn(function()
            while aGRunning do
                if not aGInst or not aGInst.Parent then
                    if SpawnToy then
                        pcall(function()
                            SpawnToy:InvokeServer("CreatureBlobman", CFrame.new(0, 999999999999999, 0), Vector3.new(0, -15.716, 0))
                        end)
                    end
                end
                task.wait(1)
            end
        end)
        Notify("Anti Gucci", "Enabled", 3)
    else
        if aGConn then aGConn:Disconnect(); aGConn = nil end
        aGClear(); aGInst = nil; aGOrig = nil
        Notify("Anti Gucci", "Disabled", 2)
    end
end

-- Anti Kick / Anti Kill
local aKConn, aKCConn
local function setupAntiKick(v)
    if v then
        if aKConn then return end
        local k = RS:FindFirstChild("Kick")
        if k and k:IsA("RemoteEvent") then
            aKConn = k.OnClientEvent:Connect(function() print("[AntiKick] blocked") end)
        end
    else
        if aKConn then aKConn:Disconnect(); aKConn = nil end
    end
end
local function setupAntiKill(v)
    if v then
        if aKCConn then return end
        local h = MyHum(); if not h then return end
        local lh = h.Health
        aKCConn = RunService.Heartbeat:Connect(function()
            local c = MyHum()
            if c then
                if c.Health < lh then c.Health = lh else lh = c.Health end
            end
        end)
    else
        if aKCConn then aKCConn:Disconnect(); aKCConn = nil end
    end
end

-- メインループ（Anti Void / Anti Ragdoll / Anti Grab）
local dt_ = 0
RunService.Heartbeat:Connect(function(d)
    dt_ = dt_ + d
    if dt_ >= 0.1 then
        if AntiConfig.AntiGrab or AntiConfig.AntiSpamKick then DoStruggle() end
        if AntiConfig.AntiVoid then
            local h = MyHRP()
            if h and h.Position.Y < -80 then h.CFrame = CFrame.new(0, 10, 0) end
        end
        if AntiConfig.AntiRagdoll then
            local h = MyHum()
            if h and h:GetState() == Enum.HumanoidStateType.Ragdoll then
                h:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
        dt_ = 0
    end
end)

-- Kick Grab
Workspace.ChildAdded:Connect(function(v)
    if v.Name == "GrabParts" and v:IsA("Model") and AntiConfig.KickGrab then
        local gp = v:FindFirstChild("GrabPart"); if not gp then return end
        local wc = gp:FindFirstChild("WeldConstraint"); if not wc or not wc.Part1 then return end
        local t = wc.Part1
        task.spawn(function()
            task.wait(0.1)
            if Players:GetPlayerFromCharacter(t.Parent) then
                pcall(function() SetNet:FireServer(t, t.CFrame) end)
                pcall(function()
                    local bp = Instance.new("BodyPosition")
                    bp.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bp.Position = Vector3.new(25e25, 25e25, 25e25)
                    bp.Parent = t
                    task.wait(0.5)
                    bp:Destroy()
                end)
                pcall(function() DGL:FireServer(t) end)
            end
        end)
    end
end)

-- Anti Grab (No Ragdoll)
local function setupAntiGrabNRD(char)
    if not _G.AntiGrabNRDEnabled then return end
    local h, h2, hd = FWD(char, "HumanoidRootPart", 5), FWD(char, "Humanoid", 5), FWD(char, "Head", 5)
    if not (h and h2 and hd) then return end
    hd.ChildAdded:Connect(function(po)
        if not _G.AntiGrabNRDEnabled then return end
        if po and po.Name == "PartOwner" and not _G.AntiGrabNRDProc then
            _G.AntiGrabNRDProc = true
            pcall(function() h2.Sit = false end)
            pcall(function() if _G.StruggleNRD then _G.StruggleNRD:FireServer(LocalPlayer) end end)
            task.spawn(function()
                while _G.AntiGrabNRDEnabled and hd:FindFirstChild("PartOwner") do
                    pcall(function() if _G.StruggleNRD then _G.StruggleNRD:FireServer(LocalPlayer) end end)
                    pcall(function() if _G.RagdollRemoteNRD then _G.RagdollRemoteNRD:FireServer(h, 0) end end)
                    task.wait()
                end
            end)
            pcall(function() h.Anchored = true end)
            if not _G.AGNRDWalk then
                _G.AGNRDWalk = true
                while _G.AntiGrabNRDEnabled and task.wait() do
                    local ih = LocalPlayer:FindFirstChild("IsHeld")
                    if not ih or not ih.Value then break end
                    pcall(function()
                        if h2 and h2.MoveDirection then
                            h.CFrame = h.CFrame + h2.MoveDirection * 0.43
                        end
                    end)
                end
                _G.AGNRDWalk = false
            end
            pcall(function() h.Anchored = false end)
            _G.AntiGrabNRDProc = false
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
LocalPlayer.CharacterAdded:Connect(function(c)
    if _G.AntiGrabNRDEnabled then task.defer(function() setupAntiGrabNRD(c) end) end
end)

-- Anti Banana Sit
local function AntiBananaSit()
    while _G.antiBananaSitActive do
        local c = LocalPlayer.Character
        if c then
            local h, h2 = c:FindFirstChild("Humanoid"), c:FindFirstChild("HumanoidRootPart")
            if h and h2 and h.Health > 0 then
                h.Sit = true
                h:ChangeState(Enum.HumanoidStateType.Running)
                local cam = workspace.CurrentCamera
                if cam then
                    local lv = cam.CFrame.LookVector
                    h2.CFrame = CFrame.new(h2.Position, h2.Position + Vector3.new(lv.X, 0, lv.Z))
                end
            end
        end
        task.wait()
    end
end

-- Anti Blob Kill
local function AntiBlobKill()
    while _G.antiBlobmanKillActive do
        local c = LocalPlayer.Character
        if c then
            local h, h2 = c:FindFirstChild("Humanoid"), c:FindFirstChild("HumanoidRootPart")
            if h and h2 and h.Health > 0 then
                h.Sit = true
                h:ChangeState(Enum.HumanoidStateType.Running)
                local cam = workspace.CurrentCamera
                if cam then
                    local lv = cam.CFrame.LookVector
                    h2.CFrame = CFrame.new(h2.Position, h2.Position + Vector3.new(lv.X, 0, lv.Z))
                end
            end
        end
        task.wait()
    end
end

-- Anti Ragdoll on Blob
local function AntiRagBlob()
    local RR = Ragdoll
    local sit = false
    local function disc(n)
        if _G.antiRagBlobConnections[n] then
            _G.antiRagBlobConnections[n]:Disconnect()
            _G.antiRagBlobConnections[n] = nil
        end
    end
    local function setup(c)
        local h = c and c:FindFirstChild("Humanoid")
        local hp = c and c:FindFirstChild("HumanoidRootPart")
        if h and hp and RR then
            disc("ARSeat")
            _G.antiRagBlobConnections["ARSeat"] = h:GetPropertyChangedSignal("SeatPart"):Connect(function()
                if h.SeatPart and h.SeatPart.Parent
                and h.SeatPart.Parent.Name == "CreatureBlobman" and not sit then
                    sit = true
                    local S_ = h.SeatPart
                    while not h.Sit do task.wait() end
                    RR:FireServer(hp, 3)
                    while not (h:FindFirstChild("Ragdolled") and h.Ragdolled.Value)
                    and not h.Sit do task.wait() end
                    task.wait(0.4)
                    h.Sit = false
                    if S_ and S_:IsA("Part") then S_:Sit(h) end
                    task.delay(0.25, function()
                        while h and h.SeatPart do
                            if LocalPlayer.Character
                            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                RR:FireServer(LocalPlayer.Character.HumanoidRootPart, 1)
                            end
                            task.wait(0.05)
                        end
                        sit = false
                    end)
                end
            end)
        end
    end
    if _G.antiRagBlobActive then
        setup(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
        disc("ARChar")
        _G.antiRagBlobConnections["ARChar"] = LocalPlayer.CharacterAdded:Connect(function(nc)
            task.wait(0.5)
            setup(nc)
        end)
    else
        for _, c in pairs(_G.antiRagBlobConnections) do
            if c then c:Disconnect() end
        end
        _G.antiRagBlobConnections = {}
    end
end

-- Anti Sticky
local function SetupAntiSticky(v)
    pcall(function()
        LocalPlayer.PlayerScripts.StickyPartsTouchDetection.Enabled = not v
    end)
end

-- Anti Burn
local function SetupAntiBurn(v)
    if v then
        local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        _G.HRP_Burn = c:WaitForChild("HumanoidRootPart", 0.5)
        _G.hum_Burn = c:WaitForChild("Humanoid", 0.5)
        if not (_G.HRP_Burn and _G.hum_Burn) then return end
        local function h_(ch)
            if not ch then return end
            local h = ch:WaitForChild("Humanoid", 5); if not h then return end
            local fd = h:WaitForChild("FireDebounce", 5); if not fd then return end
            return fd.Changed:Connect(function()
                if h.FireDebounce.Value == true then
                    local p = Workspace:FindFirstChild("Plots")
                    local p1 = p and p:FindFirstChild("Plot1")
                    local b = p1 and p1:FindFirstChild("Barrier")
                    local bar = b and b:FindFirstChild("PlotBarrier")
                    if bar then
                        local pos = bar.CFrame
                        task.spawn(function()
                            repeat task.wait() bar.CFrame = _G.HRP_Burn.CFrame
                            until not _G.hum_Burn.FireDebounce.Value
                        end)
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
            _G.antiburn = h_(ch)
        end)
        _G.antiburn = h_(c)
    else
        if _G.antiburn then _G.antiburn:Disconnect(); _G.antiburn = nil end
        if _G.antiburn1 then _G.antiburn1:Disconnect(); _G.antiburn1 = nil end
    end
end

-- Anti Kick (Break PCLD)
local function ExecAntiKickPCLD()
    local sp = CFrame.new(-272.2197265625, -7.350403785705566, 475.0108947753906)
    Workspace.FallenPartsDestroyHeight = 0 / 0
    local stored, root, conn, act = {}, nil, nil, false
    local function brk()
        local c = LocalPlayer.Character; if not c then return end
        root = c:WaitForChild("HumanoidRootPart")
        for _, v in ipairs(c:GetDescendants()) do
            if v:IsA("Motor6D") then stored[v] = v.Part0; v.Part0 = nil end
        end
        root.CFrame = sp
        conn = RunService.RenderStepped:Connect(function()
            if root and root.Parent then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
    local function rst()
        if conn then conn:Disconnect(); conn = nil end
        for m, p in pairs(stored) do
            if m and m.Parent then m.Part0 = p end
        end
        stored = {}
    end
    local function tog() act = not act; if act then brk() else rst() end end
    tog(); task.wait(0.12); tog()
    LocalPlayer.CharacterAdded:Once(function()
        task.wait(0.25); tog(); task.wait(0.12); tog()
    end)
end

-- Auto Anti Lag
_G.Lines = 0
_G.lagger = nil
_G.autoantilag = false
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

-- Anti Input Lag
local function StartAntiInputLag()
    _G.antiInputLagTask = task.spawn(function()
        while S.AntiExtra and S.AntiExtra.AntiInputLag do
            local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hr = c:WaitForChild("HumanoidRootPart")
            local tf = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            if not tf then task.wait(0.1); continue end
            local t = tf:FindFirstChild(_G.SelectedAntiInputToy)
            if not t then
                pcall(function()
                    SpawnToy:InvokeServer(_G.SelectedAntiInputToy, hr.CFrame * CFrame.new(0, 5, 0), Vector3.zero)
                end)
                local t0 = tick()
                repeat
                    RunService.Heartbeat:Wait()
                    tf = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                    t = tf and tf:FindFirstChild(_G.SelectedAntiInputToy)
                until t or tick() - t0 > 1
            end
            if t and t.Parent then
                local hp = t:FindFirstChild("HoldPart")
                if hp then
                    local ho = hp:FindFirstChild("HoldingPlayer"); ho = ho and ho.Value
                    if ho and ho ~= LocalPlayer then
                        pcall(function()
                            hp.DropItemRemoteFunction:InvokeServer(t, hr.CFrame * CFrame.new(0, 2000, 0), Vector3.zero)
                        end)
                        t:Destroy()
                    else
                        local hi = hr.CFrame * CFrame.new(0, 2000, 0)
                        task.spawn(function()
                            hp.HoldItemRemoteFunction:InvokeServer(t, c)
                            RunService.Heartbeat:Wait()
                            hp.DropItemRemoteFunction:InvokeServer(t, hi, hi)
                        end)
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- Remove All Anti Input
local function StartRemoveAllAntiInput()
    _G.removeAntiInputTask = task.spawn(function()
        local allowed = {
            FoodHamburger=true, FoodCoconut=true, FoodPizzaCheese=true, FoodPizzaPepperoni=true,
            FoodHotdog=true, FoodMushroomPoison=true, FoodBread=true, FoodDippyEgg=true,
            FoodMayonnaise=true, FoodFrenchFries=true, FoodMeatStick=true, FoodDonut=true,
            FoodCakePink=true, InstrumentGuitarBanjo=true, InstrumentGuitarViolin=true,
            InstrumentGuitarUkulele=true, InstrumentWoodwindSaxophone=true, InstrumentWoodwindOcarina=true,
            InstrumentBrassVuvuzelaQwizik=true, InstrumentBrassTrumpet=true, InstrumentDrumBongos=true,
            InstrumentDrumSnare=true, InstrumentPianoMelodica=true, InstrumentVoiceMicrophone=true,
            CupMugWhite=true, CupMugBrown=true, PoopPile=true, PoopPileSparkle=true
        }
        local arr = {}
        local cc = workspace.DescendantAdded:Connect(function(o)
            if allowed[o.Name] and o:IsA("Model") then
                task.spawn(function()
                    if o:WaitForChild("HoldPart", 3) then table.insert(arr, o) end
                end)
            end
        end)
        for _, v in ipairs(workspace:GetDescendants()) do
            if allowed[v.Name] and v:IsA("Model") and v:FindFirstChild("HoldPart") then
                table.insert(arr, v)
            end
        end
        while _G.antiAntiLagEnabled do
            local c = LocalPlayer.Character
            local hr = c and c:FindFirstChild("HumanoidRootPart")
            if hr then
                for i = #arr, 1, -1 do
                    local b = arr[i]
                    if not b or not b.Parent or not b:FindFirstChild("HoldPart") then
                        table.remove(arr, i)
                    else
                        local hp = b.HoldPart
                        pcall(function() hp.HoldItemRemoteFunction:InvokeServer(b, c) end)
                        task.wait()
                        pcall(function()
                            hp.DropItemRemoteFunction:InvokeServer(b, CFrame.new(hr.Position + Vector3.new(0, -2000, 0)), Vector3.zero)
                        end)
                    end
                end
            end
            task.wait()
        end
        cc:Disconnect()
    end)
end

-- God Mode
_G.GodMode = _G.GodMode or {}
_G.GodMode.isRunning = false
_G.GodMode.originalFallenHeight = Workspace.FallenPartsDestroyHeight
_G.GodMode.lastOriginalCFrame = nil
_G.GodMode.loopCoroutine = nil
local function startGodMode()
    if _G.GodMode.isRunning then return end
    _G.GodMode.isRunning = true
    local c = LocalPlayer.Character
    if c then
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then _G.GodMode.lastOriginalCFrame = r.CFrame end
    end
    _G.GodMode.originalFallenHeight = Workspace.FallenPartsDestroyHeight
    Workspace.FallenPartsDestroyHeight = 0 / 0
    _G.GodMode.loopCoroutine = coroutine.wrap(function()
        while _G.GodMode.isRunning do
            local ch = LocalPlayer.Character
            if not ch then
                task.wait(0.5)
            else
                local r = ch:FindFirstChild("HumanoidRootPart")
                if r then
                    if _G.GodMode.lastOriginalCFrame == nil then
                        _G.GodMode.lastOriginalCFrame = r.CFrame
                    end
                    local o = r.CFrame
                    local s = tick()
                    while tick() - s < 1 and _G.GodMode.isRunning do
                        if not LocalPlayer.Character or not r.Parent then break end
                        local t = tick() * 12
                        r.CFrame = o + Vector3.new(math.cos(t) * 10000, -10000, math.sin(t) * 10000)
                        RunService.RenderStepped:Wait()
                    end
                    if _G.GodMode.isRunning and r.Parent then r.CFrame = o end
                end
            end
            task.wait(0.0001)
        end
    end)
    _G.GodMode.loopCoroutine()
end
local function stopGodMode()
    _G.GodMode.isRunning = false
    _G.GodMode.loopCoroutine = nil
    local c = LocalPlayer.Character
    if c and _G.GodMode.lastOriginalCFrame then
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame = _G.GodMode.lastOriginalCFrame end
    end
    Workspace.FallenPartsDestroyHeight = _G.GodMode.originalFallenHeight or -100
end
LocalPlayer.CharacterAdded:Connect(function(c)
    if _G.GodMode.isRunning then
        task.wait(0.1)
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame = CFrame.new(0, -15000, 0) end
    end
end)

-- Anti Kick Removal
local function RemoveAntiKick(name)
    while _G.antiAntiKickActive do
        local t = Players:FindFirstChild(name)
        if t then
            local s = workspace:FindFirstChild(t.Name .. "SpawnedInToys")
            if s then
                for _, n in ipairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
                    local ty = s:FindFirstChild(n)
                    if ty then
                        local p = ty:FindFirstChild("SoundPart")
                        if p then
                            pcall(function() SetNet:FireServer(p, p.CFrame) end)
                            if p:FindFirstChild("PartOwner") and p.PartOwner.Value == LocalPlayer.Name then
                                p.CFrame = CFrame.new(0, 1000, 0)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

local function RemoveAntiKickAura()
    while _G.removeAntiKickAuraActive do
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then task.wait(0.1); continue end
        for _, t in ipairs(Players:GetPlayers()) do
            if t ~= LocalPlayer then
                local tc = t.Character
                local tr = tc and tc:FindFirstChild("HumanoidRootPart")
                if tr and (tr.Position - r.Position).Magnitude <= _G.removeAntiKickRadius then
                    local s = workspace:FindFirstChild(t.Name .. "SpawnedInToys")
                    if s then
                        for _, n in ipairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
                            local ty = s:FindFirstChild(n)
                            if ty then
                                local p = ty:FindFirstChild("SoundPart")
                                if p then
                                    pcall(function() SetNet:FireServer(p, p.CFrame) end)
                                    if p:FindFirstChild("PartOwner") and p.PartOwner.Value == LocalPlayer.Name then
                                        p.CFrame = CFrame.new(0, 1000, 0)
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

local function RemoveTargetAntiKick(t)
    if not t or not t.Character then return false end
    local ok = false
    local s = workspace:FindFirstChild(t.Name .. "SpawnedInToys")
    if s then
        for _, n in ipairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
            local ty = s:FindFirstChild(n)
            if ty then
                local p = ty:FindFirstChild("SoundPart")
                if p then
                    pcall(function() SetNet:FireServer(p, p.CFrame) end)
                    p.CFrame = CFrame.new(0, 1000, 0)
                    ok = true
                end
                pcall(function() if DestroyToy then DestroyToy:FireServer(ty) end end)
            end
        end
    end
    return ok
end

-- ============================================================
-- 1つ目の Defense 系（Anti Explode / Anti Burn / Anti Void etc.）
-- ============================================================
local SH = {}

local function SAE()
    local r = MyHRP(); local h = MyHum()
    if not (r and h and h:FindFirstChild("Ragdolled")) then return end
    SH.exp = Workspace.ChildAdded:Connect(function(o)
        if o.Name == "Part"
        and (o.Position - r.Position).Magnitude < 40
        and h.Ragdolled.Value then
            r.Anchored = true; task.wait(.01); r.Anchored = false
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
            h:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end
local function DAE() if SH.exp then SH.exp:Disconnect(); SH.exp = nil end end

local function SAB()
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local r = c:WaitForChild("HumanoidRootPart", .5)
    local h = c:WaitForChild("Humanoid", .5)
    if not (r and h) then return end
    SH.burn = h.FireDebounce.Changed:Connect(function()
        if h.FireDebounce.Value then
            local pl = Workspace:FindFirstChild("Plots")
            local p1 = pl and pl:FindFirstChild("Plot1")
            local bar = p1 and p1:FindFirstChild("Barrier")
            local b = bar and bar:FindFirstChild("PlotBarrier")
            if not b then return end
            local s = b.CFrame
            task.spawn(function()
                repeat task.wait() b.CFrame = r.CFrame
                until not h.FireDebounce.Value
            end)
            task.wait(1); h.FireDebounce.Value = false
            task.wait(); b.CFrame = s
        end
    end)
end
local function DAB() if SH.burn then SH.burn:Disconnect(); SH.burn = nil end end

local function SAV(s)
    if SH.void then SH.void:Disconnect(); SH.void = nil end
    if s then
        SH.void = RunService.Heartbeat:Connect(function()
            local r = MyHRP()
            if r and r.Position.Y < -50 then
                r.CFrame = CFrame.new(r.Position.X, 100, r.Position.Z)
                r.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end
end

local function SABS(s)
    SH.bA = s
    if s then
        SH.bT = task.spawn(function()
            while SH.bA do
                local h, r = MyHum(), MyHRP()
                if h and r and h.Health > 0 then
                    h.Sit = true
                    h:ChangeState(Enum.HumanoidStateType.Running)
                    local lv = Cam.CFrame.LookVector
                    r.CFrame = CFrame.new(r.Position, r.Position + Vector3.new(lv.X, 0, lv.Z))
                end
                task.wait()
            end
        end)
    else
        if SH.bT then pcall(task.cancel, SH.bT); SH.bT = nil end
    end
end
local SABK = SABS

local function SSetRB(c)
    if not c then return end
    local h = c:FindFirstChild("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not (h and r and Ragdoll) then return end
    if SH.rbConn then SH.rbConn:Disconnect() end
    SH.rbConn = h:GetPropertyChangedSignal("SeatPart"):Connect(function()
        if h.SeatPart and h.SeatPart.Parent
        and h.SeatPart.Parent.Name == "CreatureBlobman"
        and not SH.rbFlag then
            SH.rbFlag = true
            local s = h.SeatPart
            while not h.Sit do task.wait() end
            Ragdoll:FireServer(r, 3)
            while not (h:FindFirstChild("Ragdolled") and h.Ragdolled.Value)
            and not h.Sit do task.wait() end
            task.wait(.4); h.Sit = false
            if s and s:IsA("Part") then s:Sit(h) end
            task.delay(.25, function()
                while h and h.SeatPart do
                    local rr = MyHRP()
                    if rr then Ragdoll:FireServer(rr, 1) end
                    task.wait(.05)
                end
                SH.rbFlag = false
            end)
        end
    end)
end
local function SERB(s)
    SH.rbA = s
    if s then
        SSetRB(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
        if SH.rbChConn then SH.rbChConn:Disconnect() end
        SH.rbChConn = LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(.5); SSetRB(c)
        end)
    else
        if SH.rbConn then SH.rbConn:Disconnect(); SH.rbConn = nil end
        if SH.rbChConn then SH.rbChConn:Disconnect(); SH.rbChConn = nil end
    end
end

-- Anti Kick (Kunai 旧)
local nrdC = {}
local function SSetNRD(c)
    if not SH.nrd then return end
    local r = c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart", 5)
    local h = c:FindFirstChild("Humanoid") or c:WaitForChild("Humanoid", 5)
    local hd = c:FindFirstChild("Head") or c:WaitForChild("Head", 5)
    if not (r and h and hd) then return end
    local cc = hd.ChildAdded:Connect(function(o)
        if not SH.nrd then return end
        if o and o.Name == "PartOwner" and not SH.nrdProc then
            SH.nrdProc = true
            pcall(function() h.Sit = false end)
            pcall(function() if Struggle then Struggle:FireServer(LocalPlayer) end end)
            task.spawn(function()
                while SH.nrd and hd:FindFirstChild("PartOwner") do
                    pcall(function() if Struggle then Struggle:FireServer(LocalPlayer) end end)
                    pcall(function() if Ragdoll then Ragdoll:FireServer(r, 0) end end)
                    task.wait()
                end
            end)
        end
    end)
    nrdC[#nrdC + 1] = cc
end
local function SENRD(s)
    SH.nrd = s
    for _, c in ipairs(nrdC) do pcall(function() c:Disconnect() end) end
    nrdC = {}
    if s and LocalPlayer.Character then task.defer(function() SSetNRD(LocalPlayer.Character) end) end
end

local SEKT = nil
local function PK()
    local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if inv and DestroyToy then
        for _, v in ipairs(inv:GetChildren()) do
            if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                pcall(function() DestroyToy:FireServer(v) end)
            end
        end
    end
end
local function SEK()
    if SEKT then return end
    SEKT = task.spawn(function()
        local cs = LocalPlayer:WaitForChild("CanSpawnToy", 10)
        if not SpawnToy or not cs then SEKT = nil; return end
        local function GR()
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then return c.HumanoidRootPart end
            return LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
        end
        while SEKT do
            task.wait(.05)
            local c = LocalPlayer.Character
            if not c or not c:FindFirstChild("Humanoid") or c.Humanoid.Health <= 0 then continue end
            local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            local k = inv and (inv:FindFirstChild("NinjaShuriken") or inv:FindFirstChild("AntiKick"))
            if not k then
                local t = tick()
                while not cs.Value and tick() - t < 5 do task.wait(.1) end
                local r = GR()
                if r then
                    pcall(function()
                        SpawnToy:InvokeServer("NinjaShuriken", r.CFrame * CFrame.new(0, 2, 2), Vector3.zero)
                    end)
                end
                task.wait(.5)
                inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                k = inv and (inv:FindFirstChild("NinjaShuriken") or inv:FindFirstChild("AntiKick"))
                if k then k.Name = "AntiKick" end
            end
            if k and k:FindFirstChild("StickyPart") then
                local w = k.StickyPart:FindFirstChild("StickyWeld")
                       and k.StickyPart.StickyWeld.Part1 ~= nil
                if not w and k.StickyPart.CanTouch then
                    local r = GR()
                    if r then
                        local fp = r:FindFirstChild("FirePlayerPart")
                                or r:WaitForChild("FirePlayerPart", 5)
                        if fp then
                            for _, o in pairs(k:GetChildren()) do
                                if o:IsA("BasePart") then
                                    o.CanTouch = false; o.CanCollide = false
                                    o.CanQuery = false
                                    o.AssemblyLinearVelocity = Vector3.zero
                                    o.Transparency = (o.Name == "Pyramid" or o.Name == "Main") and 0 or 1
                                end
                            end
                            k:PivotTo(fp.CFrame * CFrame.Angles(0, math.rad(90), math.rad(90)))
                            local PE = RS:FindFirstChild("PlayerEvents")
                            if PE and PE:FindFirstChild("StickyPartEvent") then
                                PE.StickyPartEvent:FireServer(k.StickyPart, fp,
                                    CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)))
                            end
                        end
                    end
                    k.Name = "AntiKick"; task.wait(.1)
                end
                local r = GR()
                if r and (r.Position - k.StickyPart.Position).Magnitude >= 20 then PK() end
            end
        end
        PK(); SEKT = nil
    end)
end
local function DEK()
    if SEKT then pcall(task.cancel, SEKT); SEKT = nil end
    PK()
end

-- ============================================================
-- FTAP Defense（1つ目から）
-- ============================================================
local NF = false; local NFT = nil
local function sNOF()
    if NF then return end
    if not S.selectedTargetName then Notify("NO Force","No target",3); return end
    NF = true
    NFT = task.spawn(function()
        while NF do
            if S.selectedTargetName then
                local t = Players:FindFirstChild(S.selectedTargetName)
                if t and t.Character then
                    for _, p in ipairs(t.Character:GetDescendants()) do
                        if p:IsA("BasePart") and SetNet then SetNet:FireServer(p, p.CFrame) end
                    end
                end
            end
            task.wait(.1)
        end
    end)
    Notify("NO Force","On",3)
end
local function tNOF()
    NF = false
    if NFT then pcall(task.cancel, NFT); NFT = nil end
    Notify("NO Force","Off",2)
end

local AA = false
local function sAAR()
    if AA then return end
    AA = true
    local function w(c)
        local h = c:FindFirstChildOfClass("Humanoid")
        local r = c:FindFirstChild("HumanoidRootPart")
        local hd = c:FindFirstChild("Head")
        if not (h and r and hd) then return end
        hd.ChildAdded:Connect(function(po)
            if not AA or po.Name ~= "PartOwner" then return end
            local v = po.Value
            if v == LocalPlayer or v == LocalPlayer.Name then return end
            pcall(function()
                if Struggle then Struggle:FireServer(LocalPlayer) end
                if Ragdoll then Ragdoll:FireServer(r, 0) end
                h.Sit = false
                h:ChangeState(Enum.HumanoidStateType.GettingUp)
                h:ChangeState(Enum.HumanoidStateType.Running)
            end)
            local t = Players:FindFirstChild(tostring(v))
            if t and t.Character then
                local th = t.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    pcall(function()
                        if SetNet then SetNet:FireServer(th, r.CFrame + Vector3.new(0, 80, 0)) end
                    end)
                end
            end
        end)
    end
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    w(c)
    LocalPlayer.CharacterAdded:Connect(w)
    Notify("AAR","On",3)
end
local function tAAR() AA = false; Notify("AAR","Off",2) end

local SS = false; local SSD = {}; local SST = nil
local function sSSF()
    if SS then return end
    if not S.selectedTargetName then Notify("SSF","No target",3); return end
    SS = true; SSD = {}
    SST = task.spawn(function()
        while SS do
            if S.selectedTargetName then
                local t = Players:FindFirstChild(S.selectedTargetName)
                if t then
                    local f = Workspace:FindFirstChild(t.Name .. "SpawnedInToys")
                    if f then
                        for _, ty in ipairs(f:GetChildren()) do
                            local n = ty.Name
                            if n == "NinjaKunai" or n == "NinjaShuriken" or n == "AntiKick"
                            or n:find("Anti") or n:find("Fling") or n:find("Kick") then
                                if DestroyToy then pcall(function() DestroyToy:FireServer(ty) end) end
                                pcall(function() ty:Destroy() end)
                                if not SSD[n] then
                                    SSD[n] = true
                                    Notify("Script Deleted", t.DisplayName .. "'s " .. n, 3)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(.15)
        end
    end)
    Notify("SSF","On",3)
end
local function tSSF()
    SS = false
    if SST then pcall(task.cancel, SST); SST = nil end
    SSD = {}
    Notify("SSF","Off",2)
end

local PA = false; local PAC
local function sPAL()
    if PA then return end
    PA = true
    PAC = RunService.Heartbeat:Connect(function()
        if not PA then return end
        local mc = LocalPlayer.Character
        local mr = mc and mc:FindFirstChild("HumanoidRootPart")
        if mr then
            mr.AssemblyLinearVelocity = Vector3.zero
            mr.AssemblyAngularVelocity = Vector3.zero
            mr.Anchored = true
            for _, p in ipairs(mc:GetDescendants()) do
                if p:IsA("BasePart") and p ~= mr then
                    p.CanCollide = false
                    p.Transparency = 1
                end
            end
        end
    end)
    Notify("PAL","On",3)
end
local function tPAL()
    PA = false
    if PAC then PAC:Disconnect(); PAC = nil end
    local mc = LocalPlayer.Character
    if mc then
        for _, p in ipairs(mc:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Anchored = false
                if p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end
            end
        end
    end
    Notify("PAL","Off",2)
end

-- FTAP 追加分
local NF2 = false; local NFT2 = nil
local function sNOF2()
    if NF2 then return end
    if not S.selectedTargetName then Notify("FTAP NoForce","No target",3); return end
    NF2 = true
    NFT2 = task.spawn(function()
        while NF2 do
            local mc = LocalPlayer.Character
            if mc then
                for _, p in ipairs(mc:GetDescendants()) do
                    if p:IsA("BasePart") and SetNet then
                        pcall(function() SetNet:FireServer(p, p.CFrame) end)
                    end
                end
            end
            if S.selectedTargetName then
                local t = Players:FindFirstChild(S.selectedTargetName)
                if t and t.Character then
                    for _, p in ipairs(t.Character:GetDescendants()) do
                        if p:IsA("BasePart") and SetNet then
                            pcall(function() SetNet:FireServer(p, p.CFrame) end)
                        end
                    end
                end
            end
            task.wait(.1)
        end
    end)
    Notify("FTAP NO Force","On",3)
end
local function tNOF2()
    NF2 = false
    if NFT2 then pcall(task.cancel, NFT2); NFT2 = nil end
    Notify("FTAP NO Force","Off",2)
end

local AA2 = false
local function sAAR2()
    if AA2 then return end
    AA2 = true
    local function w(c)
        local h = c:FindFirstChildOfClass("Humanoid")
        local r = c:FindFirstChild("HumanoidRootPart")
        local hd = c:FindFirstChild("Head")
        if not (h and r and hd) then return end
        hd.ChildAdded:Connect(function(po)
            if not AA2 or po.Name ~= "PartOwner" then return end
            local v = po.Value
            if v == LocalPlayer or v == LocalPlayer.Name then return end
            pcall(function()
                if Struggle then Struggle:FireServer(LocalPlayer) end
                if Ragdoll then Ragdoll:FireServer(r, 0) end
                h.Sit = false
                h:ChangeState(Enum.HumanoidStateType.GettingUp)
                h:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end)
    end
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    w(c)
    LocalPlayer.CharacterAdded:Connect(w)
    Notify("FTAP AAR","On",3)
end
local function tAAR2() AA2 = false; Notify("FTAP AAR","Off",2) end

local SS2 = false; local SST2 = nil
local function sSSF2()
    if SS2 then return end
    SS2 = true
    SST2 = task.spawn(function()
        while SS2 do
            local mr = MyHRP()
            if mr then
                mr.AssemblyLinearVelocity = Vector3.zero
                mr.AssemblyAngularVelocity = Vector3.zero
            end
            local c = LocalPlayer.Character
            if c then
                for _, v in ipairs(c:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
            end
            task.wait()
        end
    end)
    Notify("FTAP SSF","On",3)
end
local function tSSF2()
    SS2 = false
    if SST2 then pcall(task.cancel, SST2); SST2 = nil end
    Notify("FTAP SSF","Off",2)
end

local AD = false; local ADC = {}; local ADH = {}
local function sADB()
    if AD then return end
    AD = true; ADH = {}
    ADC[#ADC + 1] = RunService.Heartbeat:Connect(function()
        if not AD then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local h = ADH[p.Name]
                    if not h then h = {}; ADH[p.Name] = h end
                    h[#h + 1] = {cf = r.CFrame, t = tick()}
                    if #h > 10 then table.remove(h, 1) end
                end
            end
        end
    end)
    Notify("ADB","On",3)
end
local function tADB()
    AD = false
    for _, c in ipairs(ADC) do if c then c:Disconnect() end end
    ADC = {}; ADH = {}
    Notify("ADB","Off",2)
end

local CFA = false; local CFC, CFS
local function sCFAF()
    if CFA then return end
    CFA = true
    local c = LocalPlayer.Character
    if c then
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then CFS = r.CFrame end
    end
    CFC = RunService.RenderStepped:Connect(function()
        if not CFA then return end
        local mc = LocalPlayer.Character; if not mc then return end
        local r = mc:FindFirstChild("HumanoidRootPart"); if not r then return end
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
        if CFS then r.CFrame = CFS else CFS = r.CFrame end
    end)
    Notify("CFAF","On",3)
end
local function tCFAF()
    CFA = false
    if CFC then CFC:Disconnect(); CFC = nil end
    CFS = nil
    Notify("CFAF","Off",2)
end

local HB = false; local HBC
local function sHB()
    if HB then return end
    if not S.selectedTargetName then Notify("HB","No target",3); return end
    HB = true
    HBC = RunService.Heartbeat:Connect(function()
        if not HB or not S.selectedTargetName then return end
        local t = Players:FindFirstChild(S.selectedTargetName)
        if not t or not t.Character then return end
        for _, p in ipairs(t.Character:GetDescendants()) do
            if p:IsA("BasePart") and not p:GetAttribute("_HBe") then
                p:SetAttribute("_HBe", true)
                pcall(function() p.Size = p.Size + Vector3.new(20, 20, 20) end)
            end
        end
        local r = t.Character:FindFirstChild("HumanoidRootPart")
        if r and SetNet then pcall(function() SetNet:FireServer(r, r.CFrame) end) end
    end)
    Notify("HB","On",3)
end
local function tHB()
    HB = false
    if HBC then HBC:Disconnect(); HBC = nil end
    if S.selectedTargetName then
        local t = Players:FindFirstChild(S.selectedTargetName)
        if t and t.Character then
            for _, p in ipairs(t.Character:GetDescendants()) do
                if p:IsA("BasePart") and p:GetAttribute("_HBe") then
                    p:SetAttribute("_HBe", nil)
                end
            end
        end
    end
    Notify("HB","Off",2)
end

local IC = false; local ICT
local function sICP()
    if IC then return end
    if not S.selectedTargetName then Notify("IC","No target",3); return end
    IC = true
    ICT = task.spawn(function()
        while IC do
            if S.selectedTargetName then
                local t = Players:FindFirstChild(S.selectedTargetName)
                if t and t.Character then
                    local r = t.Character:FindFirstChild("HumanoidRootPart")
                    if r then
                        for _ = 1, 30 do
                            pcall(function()
                                if CGL then
                                    CGL:FireServer(r, CFrame.new(math.random(-1e9, 1e9), 0, math.random(-1e9, 1e9)))
                                end
                                if EGL then EGL:FireServer(string.rep("X", 2000)) end
                                if SetNet then SetNet:FireServer(r, r.CFrame) end
                            end)
                        end
                    end
                end
            end
            task.wait(.05)
        end
    end)
    Notify("IC","On",3)
end
local function tICP()
    IC = false
    if ICT then pcall(task.cancel, ICT); ICT = nil end
    Notify("IC","Off",2)
end

local FLY = {active = false, speed = 50, bv = nil, bg = nil, conn = nil}
local function sFly()
    if FLY.active then return end
    FLY.active = true
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local h = c:FindFirstChild("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not (h and r) then return end
    h.PlatformStand = true
    FLY.bv = Instance.new("BodyVelocity", r)
    FLY.bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    FLY.bv.Velocity = Vector3.zero
    FLY.bg = Instance.new("BodyGyro", r)
    FLY.bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    FLY.bg.P = 1e4; FLY.bg.D = 1e2
    FLY.conn = RunService.RenderStepped:Connect(function()
        if not FLY.active then return end
        local mc = LocalPlayer.Character; if not mc then return end
        local mh = mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
        local move = Vector3.zero
        local UIS = S.UIS
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then move = move.Unit * FLY.speed end
        FLY.bv.Velocity = move
        FLY.bg.CFrame = Cam.CFrame
    end)
    Notify("Fly","On",3)
end
local function tFly()
    FLY.active = false
    if FLY.conn then FLY.conn:Disconnect(); FLY.conn = nil end
    if FLY.bv then FLY.bv:Destroy(); FLY.bv = nil end
    if FLY.bg then FLY.bg:Destroy(); FLY.bg = nil end
    local h = MyHum(); if h then h.PlatformStand = false end
    Notify("Fly","Off",2)
end

local SPD = {active = false, val = 100}
local SPDC = nil
local function sSpeed()
    if SPD.active then return end
    SPD.active = true
    SPDC = RunService.Heartbeat:Connect(function()
        if not SPD.active then return end
        local h = MyHum(); if h then h.WalkSpeed = SPD.val end
    end)
    Notify("Speed","On",3)
end
local function tSpeed()
    SPD.active = false
    if SPDC then SPDC:Disconnect(); SPDC = nil end
    local h = MyHum(); if h then h.WalkSpeed = 16 end
    Notify("Speed","Off",2)
end

local CTP = {active = false, conn = nil}
local function sClickTP()
    if CTP.active then return end
    CTP.active = true
    CTP.conn = S.UIS.InputBegan:Connect(function(input, gp)
        if gp or not CTP.active then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            local r = MyHRP(); if not r then return end
            local mouse = LocalPlayer:GetMouse()
            if mouse.Target then
                local pos = mouse.Hit.Position + Vector3.new(0, 3, 0)
                r.CFrame = CFrame.new(pos)
                r.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
    Notify("ClickTP","On",3)
end
local function tClickTP()
    CTP.active = false
    if CTP.conn then CTP.conn:Disconnect(); CTP.conn = nil end
    Notify("ClickTP","Off",2)
end

local PBG = {active = false, thread = nil}
local function sPacketBypass()
    if PBG.active then return end
    PBG.active = true
    PBG.thread = task.spawn(function()
        while PBG.active do
            local my = MyHRP()
            if my and S.selectedTargetName then
                local t = Players:FindFirstChild(S.selectedTargetName)
                local th = S.PPHRP(t)
                if th then
                    for _ = 1, 5 do
                        if CGL then CGL:FireServer(th, th.CFrame) end
                        if SetNet then SetNet:FireServer(th, th.CFrame) end
                    end
                    if EGL then EGL:FireServer(string.rep("X", 500)) end
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
    Notify("PacketBypass","On",3)
end
local function tPacketBypass()
    PBG.active = false
    if PBG.thread then pcall(task.cancel, PBG.thread); PBG.thread = nil end
    Notify("PacketBypass","Off",2)
end

local SAG = {active = false, thread = nil, radius = 15}
local function sAutoGrab()
    if SAG.active then return end
    SAG.active = true
    SAG.thread = task.spawn(function()
        while SAG.active do
            local my = MyHRP()
            if my then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local th = p.Character:FindFirstChild("HumanoidRootPart")
                        if th and (th.Position - my.Position).Magnitude <= SAG.radius then
                            for _ = 1, 3 do
                                if SetNet then SetNet:FireServer(th, th.CFrame) end
                            end
                            if CGL then CGL:FireServer(th, th.CFrame) end
                        end
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
    Notify("AutoGrab","On",3)
end
local function tAutoGrab()
    SAG.active = false
    if SAG.thread then pcall(task.cancel, SAG.thread); SAG.thread = nil end
    Notify("AutoGrab","Off",2)
end

local TC2 = {active = false, thread = nil, target = nil}
local function sTargetCrasher()
    if TC2.active then return end
    if not S.selectedTargetName then Notify("Crasher","No target",3); return end
    TC2.active = true; TC2.target = S.selectedTargetName
    TC2.thread = task.spawn(function()
        while TC2.active do
            local t = Players:FindFirstChild(TC2.target)
            if t and t.Character then
                local th = t.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    for _ = 1, 50 do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(math.random(1, 5), math.random(1, 5), math.random(1, 5))
                        part.Position = th.Position + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
                        part.Anchored = false; part.CanCollide = false
                        part.Transparency = 1; part.Parent = Workspace
                        part.AssemblyLinearVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
                        if SetNet then pcall(function() SetNet:FireServer(part, part.CFrame) end) end
                        if part.SetNetworkOwner then pcall(function() part:SetNetworkOwner(LocalPlayer) end) end
                        S.Debris:AddItem(part, 2)
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
    Notify("Crasher","On",3)
end
local function tTargetCrasher()
    TC2.active = false
    if TC2.thread then pcall(task.cancel, TC2.thread); TC2.thread = nil end
    Notify("Crasher","Off",2)
end

local AL2 = {active = false, thread = nil, lastCF = nil}
local function sAntiLagback()
    if AL2.active then return end
    AL2.active = true
    AL2.thread = task.spawn(function()
        while AL2.active do
            local r = MyHRP()
            if r then
                if r.Position.Y < -50
                or (AL2.lastCF and (r.Position - AL2.lastCF.Position).Magnitude > 500) then
                    local safeCF = AL2.lastCF or CFrame.new(0, 100, 0)
                    r.CFrame = safeCF
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                    if SetNet then SetNet:FireServer(r, safeCF) end
                end
                AL2.lastCF = r.CFrame
            end
            RunService.Heartbeat:Wait()
        end
    end)
    Notify("Anti-Lagback","On",3)
end
local function tAntiLagback()
    AL2.active = false
    if AL2.thread then pcall(task.cancel, AL2.thread); AL2.thread = nil end
    AL2.lastCF = nil
    Notify("Anti-Lagback","Off",2)
end

-- ============================================================
-- UI 構築（Anti タブ）
-- ============================================================
local AntiTab = Tabs.Anti
local AntiL = AntiTab:AddLeftGroupbox("Anti Protection", "shield")
local function toggleSimple(name, text, fn)
    AntiL:AddToggle(name, {Text = text, Default = false, Callback = fn})
end

toggleSimple("AntiGrabToggle", "Anti Grab", function(v) AntiConfig.AntiGrab = v end)
AntiL:AddToggle("AntiGrabNRDToggle", {
    Text = "Anti Grab (No Ragdoll)", Default = false,
    Callback = function(v)
        _G.AntiGrabNRDEnabled = v
        if v and LocalPlayer.Character then
            task.defer(function() setupAntiGrabNRD(LocalPlayer.Character) end)
        end
    end
})
toggleSimple("AntiVoidToggle", "Anti Void", function(v) AntiConfig.AntiVoid = v end)
toggleSimple("AntiRagdollToggle", "Anti Ragdoll", function(v) AntiConfig.AntiRagdoll = v end)
toggleSimple("AntiExplodeToggle", "Anti Explode", function(v) AntiConfig.AntiExplode = v; SetupAntiExplode() end)
toggleSimple("AntiExplodeV2Toggle", "Anti Explode V2", function(v)
    AntiConfig.AntiExplodeV2 = v
    local h = LocalPlayer.PlayerScripts:FindFirstChild("ClientExoplosionHandler")
    if h then h.Enabled = not v end
end)
toggleSimple("AntiGucciToggle", "Anti Gucci", toggleAntiGucci)
toggleSimple("AntiSpamKickToggle", "Anti Spam Kick", function(v) AntiConfig.AntiSpamKick = v end)

AntiL:AddToggle("AntiBananaSitToggle", {
    Text = "Anti Banana Sit", Default = false,
    Callback = function(v)
        _G.antiBananaSitActive = v
        if v then
            _G.antiBananaSitTask = task.spawn(AntiBananaSit)
        else
            if _G.antiBananaSitTask then task.cancel(_G.antiBananaSitTask); _G.antiBananaSitTask = nil end
        end
    end
})
AntiL:AddToggle("AntiBlobmanKillToggle", {
    Text = "Anti Blobman Kill", Default = false,
    Callback = function(v)
        _G.antiBlobmanKillActive = v
        if v then
            _G.antiBlobmanKillTask = task.spawn(AntiBlobKill)
        else
            if _G.antiBlobmanKillTask then task.cancel(_G.antiBlobmanKillTask); _G.antiBlobmanKillTask = nil end
        end
    end
})
AntiL:AddToggle("AntiRagBlobToggle", {
    Text = "Anti Ragdoll on Blob", Default = false,
    Callback = function(v) _G.antiRagBlobActive = v; AntiRagBlob() end
})
toggleSimple("AntiStickyToggle", "Anti Sticky", SetupAntiSticky)
toggleSimple("AntiBurnToggle", "Anti Burn", SetupAntiBurn)
AntiL:AddToggle("GodModeToggle", {
    Text = "GOD MODE", Default = false,
    Callback = function(v)
        if v then startGodMode(); Notify("GOD MODE", "Enabled", 3)
        else stopGodMode(); Notify("GOD MODE", "Disabled", 3) end
    end
})

-- 1つ目の Defense 系追加
AntiL:AddDivider()
toggleSimple("SAE_Toggle", "Anti Explode (旧)", function(v) if v then SAE() else DAE() end end)
toggleSimple("SAB_Toggle", "Anti Burn (旧)", function(v) if v then SAB() else DAB() end end)
AntiL:AddToggle("SAV_Toggle", {Text = "Anti Void (旧)", Default = false, Callback = SAV})
AntiL:AddToggle("SABS_Toggle", {Text = "Anti Banana Sit (旧)", Default = false, Callback = SABS})
AntiL:AddToggle("SABK_Toggle", {Text = "Anti Blob Kill (旧)", Default = false, Callback = SABK})
AntiL:AddToggle("SERB_Toggle", {Text = "Anti Blob Ragdoll (旧)", Default = false, Callback = SERB})
AntiL:AddToggle("SEK_Toggle", {Text = "Anti Kick (Kunai 旧)", Default = false,
    Callback = function(v) if v then SEK() else DEK() end end})
AntiL:AddToggle("SENRD_Toggle", {Text = "Anti Grab NRD (旧)", Default = false, Callback = SENRD})

-- 1つ目 FTAP Defense 追加
AntiL:AddDivider()
AntiL:AddToggle("NF2_Toggle", {Text = "FTAP NO Force", Default = false,
    Callback = function(v) if v then sNOF2() else tNOF2() end end})
AntiL:AddToggle("AA2_Toggle", {Text = "FTAP Anti Attach Reverse", Default = false,
    Callback = function(v) if v then sAAR2() else tAAR2() end end})
AntiL:AddToggle("SS2_Toggle", {Text = "FTAP Script Freeze", Default = false,
    Callback = function(v) if v then sSSF2() else tSSF2() end end})
AntiL:AddToggle("PAL_Toggle", {Text = "FTAP Physics Anchor", Default = false,
    Callback = function(v) if v then sPAL() else tPAL() end end})
AntiL:AddToggle("ADB_Toggle", {Text = "FTAP Anti Desync", Default = false,
    Callback = function(v) if v then sADB() else tADB() end end})
AntiL:AddToggle("CFAF_Toggle", {Text = "FTAP CFrame Anti Fling", Default = false,
    Callback = function(v) if v then sCFAF() else tCFAF() end end})
AntiL:AddToggle("HB_Toggle", {Text = "FTAP Hitbox Expand", Default = false,
    Callback = function(v) if v then sHB() else tHB() end end})
AntiL:AddToggle("ICP_Toggle", {Text = "FTAP Individual Crasher", Default = false,
    Callback = function(v) if v then sICP() else tICP() end end})
AntiL:AddToggle("Fly_Toggle", {Text = "FTAP Fly Hack", Default = false,
    Callback = function(v) if v then sFly() else tFly() end end})
AntiL:AddSlider("FlySpeed", {Text = "Fly Speed", Default = 50, Min = 10, Max = 500, Rounding = 0,
    Callback = function(v) FLY.speed = v end})
AntiL:AddToggle("Speed_Toggle", {Text = "FTAP Speed Hack", Default = false,
    Callback = function(v) if v then sSpeed() else tSpeed() end end})
AntiL:AddSlider("SpeedVal", {Text = "Speed Value", Default = 100, Min = 16, Max = 500, Rounding = 0,
    Callback = function(v)
        SPD.val = v
        if SPD.active then local h = MyHum(); if h then h.WalkSpeed = v end end
    end})
AntiL:AddToggle("ClickTP_Toggle", {Text = "FTAP Click Teleport", Default = false,
    Callback = function(v) if v then sClickTP() else tClickTP() end end})
AntiL:AddToggle("PacketBypass_Toggle", {Text = "FTAP Packet Bypass Grab", Default = false,
    Callback = function(v) if v then sPacketBypass() else tPacketBypass() end end})
AntiL:AddToggle("AutoGrab_Toggle", {Text = "FTAP Silent Aim & Auto-Grab", Default = false,
    Callback = function(v) if v then sAutoGrab() else tAutoGrab() end end})
AntiL:AddSlider("AutoGrabRad", {Text = "Auto-Grab Radius", Default = 15, Min = 5, Max = 100, Rounding = 0,
    Callback = function(v) SAG.radius = v end})
AntiL:AddToggle("Crasher_Toggle", {Text = "FTAP Target Crasher", Default = false,
    Callback = function(v) if v then sTargetCrasher() else tTargetCrasher() end end})
AntiL:AddToggle("AntiLagback_Toggle", {Text = "FTAP Anti-Lagback", Default = false,
    Callback = function(v) if v then sAntiLagback() else tAntiLagback() end end})

-- ============================================================
-- Lag & Ragdoll タブ：Lags グループ
-- ============================================================
local LagRagTab = Tabs.LagRag
local LagL = LagRagTab:AddLeftGroupbox("Lags", "zap")
LagL:AddToggle("AntiLagToggle", {Text = "Anti Lag", Default = false, Callback = SetupAntiLag})
LagL:AddToggle("AutoAntiLagToggle", {Text = "Auto Anti Lag", Default = false,
    Callback = function(v)
        _G.autoantilag = v
        if v then StartAutoAntiLag()
        else pcall(function() LocalPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = true end) end
    end})
LagL:AddDivider()
_G.LineLagLPS = 100
LagL:AddSlider("LineLagLPS", {Text = "Lines Per Second", Default = 100, Min = 1, Max = 1000, Rounding = 0,
    Callback = function(v) _G.LineLagLPS = v end})
_G.lineLagActive = false
_G.lineLagTask = nil
LagL:AddToggle("LineLagToggle", {Text = "Line Lag", Default = false,
    Callback = function(v)
        _G.lineLagActive = v
        if v then
            _G.lineLagTask = task.spawn(function()
                while _G.lineLagActive do
                    for _ = 1, _G.LineLagLPS do
                        pcall(function()
                            CGL:FireServer(
                                Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn"),
                                CFrame.new(0, 9e9, 0))
                        end)
                    end
                    task.wait(1)
                end
                _G.lineLagTask = nil
            end)
        else
            if _G.lineLagTask then pcall(task.cancel, _G.lineLagTask); _G.lineLagTask = nil end
        end
    end})
LagL:AddDivider()
_G.PacketLagStrength = 2000
_G.AntiDetect = false
_G.packetLagActive = false
_G.packetLagTask = nil
LagL:AddSlider("PacketLagStrength", {Text = "Packet Strength", Default = 2000, Min = 0, Max = 60000, Rounding = 1,
    Callback = function(v) _G.PacketLagStrength = v end})
LagL:AddToggle("AntiDetectToggle", {Text = "Anti Detect (Packets)", Default = false,
    Callback = function(v) _G.AntiDetect = v end})
LagL:AddToggle("PacketLagToggle", {Text = "Packet Lag", Default = false,
    Callback = function(v)
        _G.packetLagActive = v
        if v then
            _G.packetLagTask = task.spawn(function()
                while _G.packetLagActive do
                    task.wait(1)
                    pcall(function() EGL:FireServer(string.rep("A", 100 * _G.PacketLagStrength)) end)
                end
                _G.packetLagTask = nil
            end)
        else
            if _G.packetLagTask then pcall(task.cancel, _G.packetLagTask); _G.packetLagTask = nil end
        end
    end})

-- ============================================================
-- Lag & Ragdoll タブ：Anti Input Lag グループ
-- ============================================================
local LagR = LagRagTab:AddRightGroupbox("Anti Input Lag", "zap")
S.AntiExtra = S.AntiExtra or {AntiInputLag = false}
LagR:AddToggle("AntiInputLagToggle", {Text = "Anti Input Lag", Default = false,
    Callback = function(v)
        S.AntiExtra.AntiInputLag = v
        if v then StartAntiInputLag()
        else
            if _G.antiInputLagTask then task.cancel(_G.antiInputLagTask); _G.antiInputLagTask = nil end
        end
    end})
LagR:AddToggle("RemoveAllAntiInputToggle", {Text = "Remove All Anti Input", Default = false,
    Callback = function(v)
        _G.antiAntiLagEnabled = v
        if v then StartRemoveAllAntiInput()
        else
            if _G.removeAntiInputTask then task.cancel(_G.removeAntiInputTask); _G.removeAntiInputTask = nil end
        end
    end})

-- ============================================================
-- Lag & Ragdoll タブ：FTAP Defense グループ
-- ============================================================
local DefL = LagRagTab:AddRightGroupbox("FTAP Defense", "shield")
DefL:AddToggle("NOForceToggle", {Text = "Network Ownership 強制剥奪", Default = false,
    Callback = function(v) if v then sNOF() else tNOF() end end})
DefL:AddToggle("AARToggle", {Text = "Anti Attachment + Instant Reverse", Default = false,
    Callback = function(v) if v then sAAR() else tAAR() end end})
DefL:AddToggle("SSFToggle", {Text = "Script Source Freeze", Default = false,
    Callback = function(v) if v then sSSF() else tSSF() end end})
DefL:AddToggle("PALToggle", {Text = "Physics Limiter / Invisible Anchor", Default = false,
    Callback = function(v) if v then sPAL() else tPAL() end end})

-- ============================================================
-- Anti タブ：Anti Kick Tools グループ
-- ============================================================
local AntiR = AntiTab:AddRightGroupbox("Anti Kick Tools", "zap")
AntiR:AddToggle("AntiKickToggle", {Text = "Anti Kick", Default = false, Risky = true,
    Callback = function(v) AntiConfig.AntiKick = v; setupAntiKick(v) end})
AntiR:AddToggle("AntiKillToggle", {Text = "Anti Kill", Default = false, Risky = true,
    Callback = function(v) AntiConfig.AntiKill = v; setupAntiKill(v) end})
toggleSimple("KickGrabToggle", "Kick Grab", function(v) AntiConfig.KickGrab = v end)
AntiR:AddToggle("AntiKickBreakPCLDToggle", {Text = "Anti Kick (Break PCLD)", Default = false,
    Callback = function(v) if v then ExecAntiKickPCLD() end end})
AntiR:AddDivider()
AntiR:AddToggle("TargetRemoveAntiKickToggle", {Text = "Target Remove Anti Kick", Default = false,
    Callback = function(v)
        _G.antiAntiKickActive = v
        if v and S.selectedTargetName then
            task.spawn(function() RemoveAntiKick(S.selectedTargetName) end)
            Notify("Start","Target Anti Kick Removal",2)
        elseif v then
            Notify("Error","No target selected",3)
            S.Toggles.TargetRemoveAntiKickToggle:SetValue(false)
        else
            Notify("Stop","Target Anti Kick Removal",2)
        end
    end})
AntiR:AddToggle("RemoveAntiKickAuraToggle", {Text = "Remove Anti Kick Aura", Default = false,
    Callback = function(v)
        _G.removeAntiKickAuraActive = v
        if v then task.spawn(RemoveAntiKickAura); Notify("Start","Anti Kick Aura",2)
        else Notify("Stop","Anti Kick Aura",2) end
    end})
AntiR:AddSlider("AuraRadius", {Text = "Aura Radius", Default = 50, Min = 10, Max = 200, Rounding = 0,
    Suffix = " studs", Callback = function(v) _G.removeAntiKickRadius = v end})
AntiR:AddButton({Text = "Remove Target Anti Kick (Once)", Func = function()
    if not S.selectedTargetName then Notify("Error","No target selected",3); return end
    local t = Players:FindFirstChild(S.selectedTargetName)
    if t then
        local ok = RemoveTargetAntiKick(t)
        if ok then Notify("Success","Anti-Kick removed from "..t.Name,2)
        else Notify("Info","No Anti-Kick found",2) end
    end
end})

-- ============================================================
-- 保存（Unload用）
-- ============================================================
S._AntiStops = {
    tNOF, tAAR, tSSF, tPAL, tNOF2, tAAR2, tSSF2,
    tADB, tCFAF, tHB, tICP, tFly, tSpeed, tClickTP,
    tPacketBypass, tAutoGrab, tTargetCrasher, tAntiLagback,
    DAE, DAB, DEK,
}

S._SAV = SAV
S._SABS = SABS
S._SABK = SABK
S._SERB = SERB
S._SENRD = SENRD

Notify("Anti", "Loaded", 2)
