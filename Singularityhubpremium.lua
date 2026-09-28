-- ============================================================
-- Singularity hub premium (minified + FTAP Defense)
-- ============================================================
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Options, Toggles = Library.Options, Library.Toggles

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GE = RS:WaitForChild("GrabEvents", 10)
local SetNet = GE and GE:WaitForChild("SetNetworkOwner", 5)
local CGL = GE and GE:WaitForChild("CreateGrabLine", 5)
local DGL = GE and GE:WaitForChild("DestroyGrabLine", 5)
local EGL = GE and GE:WaitForChild("ExtendGrabLine", 5)

local MT = RS:WaitForChild("MenuToys", 10)
local SpawnToy = MT and MT:WaitForChild("SpawnToyRemoteFunction", 5)
local DestroyToy = MT and MT:WaitForChild("DestroyToy", 5)

local CE = RS:WaitForChild("CharacterEvents", 10)
local Ragdoll = CE and CE:WaitForChild("RagdollRemote", 5)
local Struggle = CE and CE:WaitForChild("Struggle", 5)

local selectedTargetName

local function Notify(t, d, tm) Library:Notify({Title=t, Description=d, Time=tm or 3}) end

local function GetPlayerList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.DisplayName.." (@"..p.Name..")") end
    end
    table.sort(t, function(a,b) return a:lower()<b:lower() end)
    return t
end

local function User(s) return s and s:match("%(@(.+)%)$") end
local function MyHRP() local c=LocalPlayer.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function MyHum() local c=LocalPlayer.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function PPHRP(player)
    if not player then return nil end
    local c = player.Character
    if c and c.Parent == Workspace then
        local h = c:FindFirstChild("HumanoidRootPart"); if h then return h end
    end
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m.Name == player.Name then
            local h = m:FindFirstChild("HumanoidRootPart"); if h then return h end
        end
    end
end
local function FWD(p,n,t) return p:FindFirstChild(n) or p:WaitForChild(n, t or 5) end

local function firePrompt(pr)
    if not pr then return end
    pcall(function()
        if fireproximityprompt then fireproximityprompt(pr)
        else pr:InputHoldBegin() task.wait(0.05) pr:InputHoldEnd() end
    end)
end

-- ---------- Teleport ----------
_G.TPState = { TargetName=nil, OffsetY=3, Loop=false, LoopTask=nil }
local function TPTo(name, offY)
    if not name then return end
    local tg = Players:FindFirstChild(name); if not tg then return end
    local th = PPHRP(tg); if not th then return end
    local mh = MyHRP(); if not mh then return end
    mh.CFrame = th.CFrame + Vector3.new(0, offY or 3, 0)
    mh.AssemblyLinearVelocity = Vector3.zero
    mh.AssemblyAngularVelocity = Vector3.zero
end
local function StopTP() if _G.TPState.LoopTask then pcall(task.cancel,_G.TPState.LoopTask); _G.TPState.LoopTask=nil end end
local function StartTP()
    StopTP()
    if not _G.TPState.TargetName then return end
    _G.TPState.LoopTask = task.spawn(function()
        while _G.TPState.Loop do TPTo(_G.TPState.TargetName,_G.TPState.OffsetY); RunService.Heartbeat:Wait() end
        _G.TPState.LoopTask=nil
    end)
end

-- ---------- Global states ----------
_G.antiAntiKickActive=false _G.removeAntiKickAuraActive=false _G.removeAntiKickRadius=50
_G.loopBlobKickSpamTask=nil _G.loopBlobKickSpamActive=false _G.loopBlobKickSpamTargetName=nil
_G.loopKill1Active=false _G.loopKill1TargetName=nil _G.loopKill2Active=false _G.loopKill2TargetName=nil
_G.kickLoopEnabled=false _G.snowballRagdollTask=nil _G.snowballRagdollActive=false _G.snowballRagdollTargetName=nil
_G.AntiExtra={AntiGrabNRD=false,AntiBananaSit=false,AntiBlobmanKill=false,AntiRagBlob=false,AntiSticky=false,AntiBurn=false,AutoAntiLag=false,AntiInputLag=false,RemoveAllAntiInput=false,AntiKickBreakPCLD=false,GodMode=false}
_G.AntiGrabNRDEnabled=false _G.AntiGrabNRDProc=false _G.AGNRDWalk=false
_G.StruggleNRD=Struggle _G.RagdollRemoteNRD=Ragdoll
_G.antiBananaSitActive=false _G.antiBananaSitTask=nil _G.antiBlobmanKillActive=false _G.antiBlobmanKillTask=nil
_G.antiRagBlobActive=false _G.antiRagBlobConnections={}
_G.antiburn=nil _G.antiburn1=nil _G.HRP_Burn=nil _G.hum_Burn=nil
_G.Lines=0 _G.lagger=nil _G.autoantilag=false _G.lineLagActive=false _G.lineLagTask=nil
_G.packetLagActive=false _G.packetLagTask=nil
_G.antiInputLagTask=nil _G.SelectedAntiInputToy="FoodHamburger" _G.antiAntiLagEnabled=false _G.removeAntiInputTask=nil

-- ============================================================
-- ★FTAP 最強防御システム（4機能）
-- ============================================================
local NOFA, NOFT = false, nil
local function startNOF()
    if NOFA then return end
    NOFA = true
    NOFT = task.spawn(function()
        while NOFA do
            local mc = LocalPlayer.Character
            if mc then
                for _, p in ipairs(mc:GetDescendants()) do
                    if p:IsA("BasePart") and SetNet then
                        pcall(function() SetNet:FireServer(p, p.CFrame) end)
                    end
                end
            end
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character then
                    for _, p in ipairs(pl.Character:GetDescendants()) do
                        if p:IsA("BasePart") and SetNet then
                            pcall(function() SetNet:FireServer(p, p.CFrame) end)
                        end
                    end
                end
            end
            task.wait(0.12)
        end
    end)
    Notify("NO Force","Enabled",3)
end
local function stopNOF()
    NOFA = false
    if NOFT then pcall(task.cancel, NOFT) NOFT=nil end
    Notify("NO Force","Disabled",2)
end

local AARA, AARC = false, nil
local function startAAR()
    if AARA then return end
    AARA = true
    local function watch(char)
        local h = char:FindFirstChildOfClass("Humanoid")
        local r = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not (h and r and head) then return end
        head.ChildAdded:Connect(function(po)
            if not AARA or po.Name ~= "PartOwner" then return end
            local v = po.Value
            if v == LocalPlayer or v == LocalPlayer.Name then return end
            pcall(function()
                if Struggle then Struggle:FireServer(LocalPlayer) end
                if Ragdoll then Ragdoll:FireServer(r, 0) end
                h.Sit = false
                h:ChangeState(Enum.HumanoidStateType.GettingUp)
                h:ChangeState(Enum.HumanoidStateType.Running)
            end)
            local tgt = Players:FindFirstChild(tostring(v))
            if tgt and tgt.Character then
                local th = tgt.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    pcall(function()
                        if SetNet then SetNet:FireServer(th, r.CFrame + Vector3.new(0,80,0)) end
                        local bp = Instance.new("BodyPosition")
                        bp.MaxForce = Vector3.new(1e8,1e8,1e8)
                        bp.P = 1e6
                        bp.Position = r.Position + Vector3.new(
                            math.random(-5,5), math.random(25,50), math.random(-5,5))
                        bp.Parent = th
                        task.delay(0.6, function() pcall(function() bp:Destroy() end) end)
                    end)
                end
            end
        end)
    end
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    watch(c)
    AARC = LocalPlayer.CharacterAdded:Connect(watch)
    Notify("Anti-Attach+Reverse","Enabled",3)
end
local function stopAAR()
    AARA = false
    if AARC then AARC:Disconnect() AARC=nil end
    Notify("Anti-Attach+Reverse","Disabled",2)
end

local SSFA, SSFC = false, {}
local function startSSF()
    if SSFA then return end
    SSFA = true
    table.insert(SSFC, Workspace.ChildAdded:Connect(function(v)
        if not SSFA then return end
        if not (v.Name == "GrabParts" or v.Name:find("Fling") or v.Name:find("Kick")) then return end
        task.spawn(function()
            task.wait(0.03)
            if not SSFA then return end
            local mc = LocalPlayer.Character
            local mr = mc and mc:FindFirstChild("HumanoidRootPart")
            if not mr then return end
            local gp = v:FindFirstChild("GrabPart")
            if not gp then return end
            local wc = gp:FindFirstChild("WeldConstraint")
            if not wc or not wc.Part1 then return end
            local t = wc.Part1
            if t:IsDescendantOf(mc) or t == mr then
                pcall(function() v:Destroy() end)
                pcall(function()
                    mr.AssemblyLinearVelocity = Vector3.zero
                    mr.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end)
    end))
    table.insert(SSFC, RunService.Heartbeat:Connect(function()
        if not SSFA then return end
        local mr = MyHRP()
        if mr then
            mr.AssemblyLinearVelocity = Vector3.zero
            mr.AssemblyAngularVelocity = Vector3.zero
        end
    end))
    Notify("Script Freeze","Enabled",3)
end
local function stopSSF()
    SSFA = false
    for _, c in ipairs(SSFC) do if c then c:Disconnect() end end
    SSFC = {}
    Notify("Script Freeze","Disabled",2)
end

local PALA, PALC = false, nil
local function startPAL()
    if PALA then return end
    PALA = true
    PALC = RunService.Heartbeat:Connect(function()
        if not PALA then return end
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
    Notify("Physics Anchor","Enabled",3)
end
local function stopPAL()
    PALA = false
    if PALC then PALC:Disconnect() PALC=nil end
    local mc = LocalPlayer.Character
    if mc then
        for _, p in ipairs(mc:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Anchored = false
                if p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end
            end
        end
    end
    Notify("Physics Anchor","Disabled",2)
end

-- ---------- 汎用ラグエンジン ----------
local function makeLag(rate)
    return function()
        local conn, fc = nil, 0
        local bpf = math.floor(rate/60)
        local rem = rate - bpf*60
        local function start()
            if conn then conn:Disconnect() end
            conn = RunService.Heartbeat:Connect(function()
                fc = fc + 1
                local sc = bpf + (fc <= rem and 1 or 0)
                local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or MyHRP()
                if sp then
                    for _ = 1, sc do
                        pcall(function()
                            CGL:FireServer(sp, CFrame.new(
                                math.random(-2010000000, 2000200000), 0,
                                math.random(-2008100000, 2000200000)))
                        end)
                    end
                end
            end)
        end
        local function stop() if conn then conn:Disconnect() conn=nil end end
        return start, stop
    end
end

-- ---------- Kick ----------
local function makeKick(rate)
    local startLag, stopLag = makeLag(rate)()
    local running, task_ = false, nil
    local function stop() running=false if task_ then pcall(task.cancel,task_) task_=nil end stopLag() end
    local function exec(single)
        if running then return end
        running = true
        task_ = task.spawn(function()
            startLag()
            local H = 35
            task.wait(single and 1 or 0.5)
            local my = MyHRP(); if not my then stop() return end
            local list = {}
            if single then
                if not selectedTargetName then stop() return end
                local tp = Players:FindFirstChild(selectedTargetName)
                local h = tp and PPHRP(tp); if h then table.insert(list,h) end
            else
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer then local h=PPHRP(p); if h then table.insert(list,h) end end
                end
            end
            if #list == 0 then task.wait(5) stop() return end
            Notify("Kick", (single and "Target" or ("All ("..#list..")")).." kicked", 3)
            local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
            local cx = sp and sp.Position.X or 0
            local cz = sp and sp.Position.Z or 0
            pcall(function() my.CFrame = CFrame.new(cx,H,cz) my.AssemblyLinearVelocity=Vector3.zero end)
            for _, h in ipairs(list) do
                pcall(function() my.CFrame=h.CFrame*CFrame.new(0,5,5) my.AssemblyLinearVelocity=Vector3.zero end)
                task.wait(0.2)
                if SetNet then
                    pcall(function() SetNet:FireServer(h,h.CFrame) end)
                    if not single then pcall(function() SetNet:FireServer(h,h.CFrame) end) end
                end
            end
            local R = single and 10 or 80
            local step = (math.pi*2)/math.max(#list,1)
            for i,h in ipairs(list) do
                local a = (i-1)*step
                local x, z = math.cos(a)*R, math.sin(a)*R
                if single and not (i==1) then break end
                pcall(function() h.CFrame=CFrame.new(cx+x,H,cz+z) h.AssemblyLinearVelocity=Vector3.zero end)
                local bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(9e9,9e9,9e9); bp.P=5e11
                bp.Position = Vector3.new(cx+x,H,cz+z); bp.Parent=h
                task.delay(2, function() pcall(function() bp:Destroy() end) end)
                task.wait()
            end
            pcall(function() my.CFrame=CFrame.new(cx,H,cz) my.AssemblyLinearVelocity=Vector3.zero end)
            for _=1,80 do
                for _,h in ipairs(list) do
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
        end)
    end
    return exec, stop
end

local AllkickExec, AllkickStop = makeKick(85)
local TlagExec, TlagStop = makeKick(85)

-- ---------- GrabKick ----------
local GrabKickChar = LocalPlayer.Character
LocalPlayer.CharacterAdded:Connect(function(c) GrabKickChar=c end)
local function GKGetBlob()
    if not GrabKickChar then return nil end
    local f = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
    if f then for _,c in ipairs(f:GetChildren()) do if c:IsA("Model") and c.Name:find("CreatureBlobman") then return c end end end
    for _,d in ipairs(GrabKickChar:GetDescendants()) do if d:IsA("Model") and d.Name:find("CreatureBlobman") then return d end end
end
local function GKWeld(det)
    if not det then return end
    for _,c in ipairs(det:GetChildren()) do
        if c:IsA("Weld") or c:IsA("ManualWeld") then c:Destroy() end
    end
end
local GKRunning = false
local function GrabKickExecute()
    if GKRunning then return end
    if not selectedTargetName then Notify("Error","No target selected",3) return end
    local tp = Players:FindFirstChild(selectedTargetName)
    if not tp or not tp.Character then return end
    local th = tp.Character:FindFirstChild("HumanoidRootPart")
    if not th then return end
    GKRunning = true
    task.spawn(function()
        local blob = GKGetBlob()
        if not blob then Notify("Error","Please sit on a Blobman",3) GKRunning=false return end
        local bs = blob:FindFirstChild("BlobmanSeatAndOwnerScript"); if not bs then GKRunning=false return end
        local gr, rr, dr = bs:FindFirstChild("CreatureGrab"), bs:FindFirstChild("CreatureRelease"), bs:FindFirstChild("CreatureDrop")
        local rd = blob:FindFirstChild("RightDetector")
        local rw = rd and rd:FindFirstChild("RightWeld")
        if not gr or not rd then GKRunning=false return end
        pcall(function() th:SetNetworkOwner(LocalPlayer) end)
        for _=1,6 do
            if not th.Parent then break end
            pcall(function()
                th.AssemblyLinearVelocity=Vector3.zero th.AssemblyAngularVelocity=Vector3.zero
                GKWeld(rd)
                local ao = blob:GetPivot():Inverse()*rd.CFrame
                blob:PivotTo(th.CFrame*ao:Inverse())
                for _=1,6 do gr:FireServer(rd,th,rw) task.wait(0.001) end
                task.wait(0.01)
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                bv.Velocity = Vector3.new(math.random(-10,10),math.random(8,18),math.random(-10,10)).Unit
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
        GKRunning=false
    end)
end

-- ---------- Lagkick ----------
local LagkRunning = false
local function LagkExecute()
    if LagkRunning then return end
    if not selectedTargetName then return end
    local tp = Players:FindFirstChild(selectedTargetName)
    if not tp or not tp.Character then return end
    local tr = tp.Character:FindFirstChild("HumanoidRootPart"); if not tr then return end
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
        if not blob then LagkRunning=false return end
        local seat = blob:FindFirstChild("VehicleSeat")
        if seat and myHum and not myHum.Sit then pcall(function() seat:Sit(myHum) end) task.wait(0.6) end
        local bs = blob:FindFirstChild("BlobmanSeatAndOwnerScript", true)
        if bs then
            local gr = bs:FindFirstChild("CreatureGrab")
            local dr = bs:FindFirstChild("CreatureDrop")
            local ld = blob:FindFirstChild("LeftDetector")
            local lw = ld and ld:FindFirstChild("LeftWeld")
            local mr = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if gr and ld and mr then
                pcall(function() gr:FireServer(ld,mr,lw) end) task.wait(0.08)
                if SetNet then pcall(function() SetNet:FireServer(tr,tr.CFrame) end) end task.wait(0.08)
                pcall(function() tr.CFrame = tr.CFrame + Vector3.new(0,16,0) end) task.wait(0.08)
                if DGL then pcall(function() DGL:FireServer(tr) end) end task.wait(0.08)
                pcall(function() gr:FireServer(ld,tr,lw) end) task.wait(0.08)
                if dr then pcall(function() dr:FireServer(ld,tr) end) end task.wait(0.08)
                if DGL then pcall(function() DGL:FireServer(tr) end) end
            end
        end
        if DestroyToy then pcall(function() DestroyToy:FireServer(blob) end) end
        Notify("Kick", tp.DisplayName.." kicked", 3)
        LagkRunning=false
    end)
end

-- ---------- Lag Kick A/S ----------
local function makeLKA(radius, mult)
    local running, task_
    local startLag, stopLag = makeLag(1000)()
    local function stop() running=false if task_ then pcall(task.cancel,task_) task_=nil end stopLag() end
    local function exec()
        if running then return end
        running = true
        task_ = task.spawn(function()
            startLag()
            local H = 35
            task.wait(0.5)
            local my = MyHRP(); if not my then stop() return end
            local list = {}
            for _,p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then local h=PPHRP(p); if h then table.insert(list,h) end end
            end
            if #list==0 then task.wait(5) stop() return end
            Notify("Kick","All ("..#list..") kicked",3)
            local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
            local cx = sp and sp.Position.X or 0
            local cz = sp and sp.Position.Z or 0
            pcall(function() my.CFrame=CFrame.new(cx,H,cz) my.AssemblyLinearVelocity=Vector3.zero end)
            for _,h in ipairs(list) do
                pcall(function() my.CFrame=h.CFrame*CFrame.new(0,5,5) my.AssemblyLinearVelocity=Vector3.zero end)
                task.wait(0.2)
                if SetNet then for _=1,mult do pcall(function() SetNet:FireServer(h,h.CFrame) end) end end
            end
            local step = (math.pi*2)/math.max(#list,1)
            for i,h in ipairs(list) do
                local a = (i-1)*step
                local x,z = math.cos(a)*radius, math.sin(a)*radius
                pcall(function() h.CFrame=CFrame.new(cx+x,H,cz+z) h.AssemblyLinearVelocity=Vector3.zero end)
                local bp = Instance.new("BodyPosition")
                bp.MaxForce=Vector3.new(9e9,9e9,9e9); bp.P=5e11
                bp.Position=Vector3.new(cx+x,H,cz+z); bp.Parent=h
                task.delay(2, function() pcall(function() bp:Destroy() end) end)
                task.wait()
            end
            pcall(function() my.CFrame=CFrame.new(cx,H,cz) my.AssemblyLinearVelocity=Vector3.zero end)
            for _=1,80 do
                for _,h in ipairs(list) do
                    task.spawn(function()
                        if CGL and DGL then
                            pcall(function()
                                CGL:FireServer(h,CFrame.new(0,1e9,0))
                                DGL:FireServer(h)
                            end)
                        end
                    end)
                end
                task.wait(0.03)
            end
            task.wait(6)
            stop()
        end)
    end
    return exec, stop
end

local function makeLKS(radius, mult)
    local running, task_
    local startLag, stopLag = makeLag(1000)()
    local function stop() running=false if task_ then pcall(task.cancel,task_) task_=nil end stopLag() end
    local function exec()
        if running then return end
        if not selectedTargetName then Notify("Error","No target selected",3) return end
        local tp = Players:FindFirstChild(selectedTargetName)
        if not tp then Notify("Error","Player not found",3) return end
        running = true
        task_ = task.spawn(function()
            startLag()
            local H=35
            task.wait(0.5)
            local my=MyHRP(); if not my then stop() return end
            local th=PPHRP(tp); if not th then stop() return end
            Notify("Kick", tp.DisplayName.." kicked", 3)
            local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
            local cx=sp and sp.Position.X or 0
            local cz=sp and sp.Position.Z or 0
            pcall(function() my.CFrame=CFrame.new(cx,H,cz) my.AssemblyLinearVelocity=Vector3.zero end)
            pcall(function() my.CFrame=th.CFrame*CFrame.new(0,5,5) my.AssemblyLinearVelocity=Vector3.zero end)
            task.wait(0.2)
            if SetNet then for _=1,mult do pcall(function() SetNet:FireServer(th,th.CFrame) end) end end
            pcall(function() th.CFrame=CFrame.new(cx,H,cz+5) th.AssemblyLinearVelocity=Vector3.zero end)
            local bp = Instance.new("BodyPosition")
            bp.MaxForce=Vector3.new(9e9,9e9,9e9); bp.P=5e11
            bp.Position=Vector3.new(cx,H,cz+5); bp.Parent=th
            task.delay(2, function() pcall(function() bp:Destroy() end) end)
            pcall(function() my.CFrame=CFrame.new(cx,H,cz) my.AssemblyLinearVelocity=Vector3.zero end)
            for _=1,80 do
                task.spawn(function()
                    if CGL and DGL then pcall(function() CGL:FireServer(th,CFrame.new(0,1e9,0)) DGL:FireServer(th) end) end
                end)
                task.wait(0.03)
            end
            task.wait(6)
            stop()
        end)
    end
    return exec, stop
end

local LKAExec, LKAStop = makeLKA(10, 2)
local LKSExec, LKSStop = makeLKS(10, 3)
local LKA2Exec, LKA2Stop = makeLKA(10, 2)
local LKS2Exec, LKS2Stop = makeLKS(10, 2)
local LKA3Exec, LKA3Stop = makeLKA(10, 2)
local LKS3Exec, LKS3Stop = makeLKS(10, 2)

-- ---------- SpamK ----------
local SpamKActive, SpamKTask = false, nil
local SpamKLagRunning, SpamKRagdollRunning = false, false
local SpamKSelectedName
local function SpamKTele(target, myRoot)
    if not target.Character then return end
    local th = target.Character:FindFirstChild("HumanoidRootPart")
    if not th or not myRoot then return end
    local s = myRoot.CFrame
    myRoot.CFrame = th.CFrame*CFrame.new(0,0,2)
    for _=1,15 do if SetNet then SetNet:FireServer(th,th.CFrame) end task.wait() end
    myRoot.CFrame = s
end
local function SpawnToy_(name)
    local ch = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = ch:WaitForChild("HumanoidRootPart")
    local folder = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys") or Workspace
    local res
    local conn = folder.ChildAdded:Connect(function(c) if c.Name==name then res=c end end)
    task.spawn(function() pcall(function() if SpawnToy then SpawnToy:InvokeServer(name, root.CFrame*CFrame.new(0,14,20), Vector3.zero) end end) end)
    local t = tick()
    repeat task.wait(0.05) until res or tick()-t>5
    conn:Disconnect()
    return res
end
local function SpawnRag()
    if SpamKRagdollRunning then return nil end
    SpamKRagdollRunning = true
    local toy = SpawnToy_("PalletLightBrown")
    if not toy then SpamKRagdollRunning=false return nil end
    local sp = toy:FindFirstChild("SoundPart") or toy:WaitForChild("SoundPart",3)
    if not sp then toy:Destroy() SpamKRagdollRunning=false return nil end
    local n=0
    while n<10 do
        if not SpamKActive then toy:Destroy() SpamKRagdollRunning=false return nil end
        if SetNet then SetNet:FireServer(sp, sp.CFrame) end
        task.wait()
        if sp:FindFirstChild("PartOwner") then break end
        n=n+1
    end
    if not sp:FindFirstChild("PartOwner") then toy:Destroy() SpamKRagdollRunning=false return nil end
    for _,d in pairs(toy:GetDescendants()) do if d:IsA("BasePart") then d.CanCollide=false d.Transparency=0.8 end end
    toy.Name = "RagdollPalete"
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Velocity = Vector3.new(0,900,0)
    bv.Parent = sp
    SpamKRagdollRunning = false
    return toy
end
local function SpamKStop()
    SpamKActive = false
    if SpamKTask then pcall(task.cancel, SpamKTask) SpamKTask=nil end
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
            local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or MyHRP()
            if sp and CGL then
                CGL:FireServer(sp, CFrame.new(math.random(-2010000000,2000200000),0,math.random(-2008100000,2000200000)))
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
                    if (my.Position-th.Position).Magnitude > 15 then SpamKTele(t, my) end
                    if SetNet then SetNet:FireServer(th, th.CFrame) end
                    if DGL then DGL:FireServer(th) end
                    th.AssemblyLinearVelocity = Vector3.zero
                    th.AssemblyAngularVelocity = Vector3.zero
                    local bp = th:FindFirstChild("ControlBP")
                    if not bp then
                        bp = Instance.new("BodyPosition")
                        bp.Name="ControlBP"
                        bp.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
                        bp.P = 800000
                        bp.Parent = th
                    end
                    bp.Position = my.Position + Vector3.new(5,10,5)
                    if rag and rag:IsDescendantOf(Workspace) then
                        local sp = rag:FindFirstChild("SoundPart")
                        if sp then
                            if not sp:FindFirstChild("PartOwner") then rag:Destroy() rag=nil end
                        else rag:Destroy() rag=nil end
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

-- ---------- Drift Kick ----------
local DriftActive, DriftRadius, DriftSpeed, DriftHeight, DriftAngle, DriftLoopId = false,19,8.5,0,0,0
local function DriftStop() DriftActive=false DriftLoopId=DriftLoopId+1 end
local function DriftStart()
    DriftActive = true
    DriftLoopId = DriftLoopId+1
    local myLoop = DriftLoopId
    if not selectedTargetName then Notify("Error","No target selected",2) DriftActive=false return end
    local t = Players:FindFirstChild(selectedTargetName)
    if not t or not t.Character then DriftActive=false return end
    Notify("Kick", t.DisplayName.." kicked",3)
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
        if not blob then DriftActive=false return end
        local seat = blob:FindFirstChild("VehicleSeat")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if seat and hum and not hum.Sit then pcall(function() seat:Sit(hum) end) task.wait(0.6) end
        local br = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        if not br then DriftActive=false return end
        local saved, last = nil, tick()
        while DriftActive and myLoop==DriftLoopId and blob.Parent do
            local tg = Players:FindFirstChild(t.Name)
            if not tg or not tg.Character then break end
            local tr = tg.Character:FindFirstChild("HumanoidRootPart")
            local th = tg.Character:FindFirstChild("Humanoid")
            if not tr or not th or th.Health<=0 then break end
            if not saved then saved = tr.CFrame end
            local center = saved + Vector3.new(0,30,0)
            local now = tick(); local dt = now-last; last = now
            DriftAngle = DriftAngle + DriftSpeed*dt
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
        if br and saved then pcall(function() br.CFrame = saved br.AssemblyLinearVelocity = Vector3.zero end) end
    end)
end

-- ---------- Anti ----------
local AntiConfig = {AntiGrab=false,AntiVoid=false,AntiRagdoll=false,AntiExplode=false,AntiExplodeV2=false,AntiGucci=false,AntiSpamKick=false,AntiLag=false,AntiKick=false,AntiKill=false,KickGrab=false}
local function DoStruggle() pcall(function() if Struggle then Struggle:FireServer(LocalPlayer) end end) end
local AntiExplodeConn
local function SetupAntiExplode()
    if AntiConfig.AntiExplode then
        if AntiExplodeConn then return end
        AntiExplodeConn = Workspace.ChildAdded:Connect(function(c) if c.Name:find("Explosion") or c.Name:find("Bomb") then pcall(function() c:Destroy() end) end end)
    else if AntiExplodeConn then AntiExplodeConn:Disconnect() AntiExplodeConn=nil end end
end
local aGRunning=false local aGConn local aGInst local aGOrig
local function aGClear()
    local h,h2 = MyHRP(), MyHum()
    if h and h2 and Ragdoll then pcall(function() Ragdoll:FireServer(h,0) h2:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end
local function aGSeq(c)
    if c.Name ~= "CreatureBlobman" then return end
    aGInst = c
    local h,h2 = MyHRP(), MyHum(); if not (h and h2) then return end
    local seat = c:WaitForChild("VehicleSeat",2) or c:FindFirstChildWhichIsA("VehicleSeat",true)
    if seat and h2 then
        seat:Sit(h2)
        local s = tick()
        while tick()-s < 0.5 and aGRunning do
            if Ragdoll then pcall(function() Ragdoll:FireServer(h,0) h2:ChangeState(Enum.HumanoidStateType.Jumping) end) end
            RunService.Heartbeat:Wait()
        end
        local p = c.PrimaryPart or c:FindFirstChild("HumanoidRootPart",true) or c:FindFirstChild("Part",true)
        if p and aGRunning then pcall(function() if p.SetNetworkOwner then p:SetNetworkOwner(LocalPlayer) end end) end
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
        local f = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
        if f then aGConn = f.ChildAdded:Connect(function(c) task.spawn(function() aGSeq(c) end) end) end
        task.spawn(function()
            while aGRunning do
                if not aGInst or not aGInst.Parent then
                    if SpawnToy then pcall(function() SpawnToy:InvokeServer("CreatureBlobman", CFrame.new(0, 999999999999999, 0), Vector3.new(0,-15.716,0)) end) end
                end
                task.wait(1)
            end
        end)
        Notify("Anti Gucci","Enabled",3)
    else
        if aGConn then aGConn:Disconnect() aGConn=nil end
        aGClear() aGInst=nil aGOrig=nil
        Notify("Anti Gucci","Disabled",2)
    end
end
local aKConn, aKCConn
local function setupAntiKick(v)
    if v then
        if aKConn then return end
        local k = RS:FindFirstChild("Kick")
        if k and k:IsA("RemoteEvent") then aKConn = k.OnClientEvent:Connect(function() print("[AntiKick] blocked") end) end
    else if aKConn then aKConn:Disconnect() aKConn=nil end end
end
local function setupAntiKill(v)
    if v then
        if aKCConn then return end
        local h = MyHum(); if not h then return end
        local lh = h.Health
        aKCConn = RunService.Heartbeat:Connect(function()
            local c = MyHum()
            if c then if c.Health<lh then c.Health=lh else lh=c.Health end end
        end)
    else if aKCConn then aKCConn:Disconnect() aKCConn=nil end end
end
local dt_ = 0
RunService.Heartbeat:Connect(function(d)
    dt_ = dt_ + d
    if dt_ >= 0.1 then
        if AntiConfig.AntiGrab or AntiConfig.AntiSpamKick then DoStruggle() end
        if AntiConfig.AntiVoid then local h=MyHRP() if h and h.Position.Y<-80 then h.CFrame=CFrame.new(0,10,0) end end
        if AntiConfig.AntiRagdoll then local h=MyHum() if h and h:GetState()==Enum.HumanoidStateType.Ragdoll then h:ChangeState(Enum.HumanoidStateType.Running) end end
        dt_ = 0
    end
end)
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
                    bp.MaxForce=Vector3.new(1e8,1e8,1e8)
                    bp.Position=Vector3.new(25e25,25e25,25e25)
                    bp.Parent=t
                    task.wait(0.5) bp:Destroy()
                end)
                pcall(function() DGL:FireServer(t) end)
            end
        end)
    end
end)
local function setupAntiGrabNRD(char)
    if not _G.AntiGrabNRDEnabled then return end
    local h,h2,hd = FWD(char,"HumanoidRootPart",5), FWD(char,"Humanoid",5), FWD(char,"Head",5)
    if not (h and h2 and hd) then return end
    hd.ChildAdded:Connect(function(po)
        if not _G.AntiGrabNRDEnabled then return end
        if po and po.Name=="PartOwner" and not _G.AntiGrabNRDProc then
            _G.AntiGrabNRDProc=true
            pcall(function() h2.Sit=false end)
            pcall(function() if _G.StruggleNRD then _G.StruggleNRD:FireServer(LocalPlayer) end end)
            task.spawn(function()
                while _G.AntiGrabNRDEnabled and hd:FindFirstChild("PartOwner") do
                    pcall(function() if _G.StruggleNRD then _G.StruggleNRD:FireServer(LocalPlayer) end end)
                    pcall(function() if _G.RagdollRemoteNRD then _G.RagdollRemoteNRD:FireServer(h,0) end end)
                    task.wait()
                end
            end)
            pcall(function() h.Anchored=true end)
            if not _G.AGNRDWalk then
                _G.AGNRDWalk=true
                while _G.AntiGrabNRDEnabled and task.wait() do
                    local ih = LocalPlayer:FindFirstChild("IsHeld")
                    if not ih or not ih.Value then break end
                    pcall(function() if h2 and h2.MoveDirection then h.CFrame=h.CFrame+h2.MoveDirection*0.43 end end)
                end
                _G.AGNRDWalk=false
            end
            pcall(function() h.Anchored=false end)
            _G.AntiGrabNRDProc=false
        end
    end)
    for _,v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name~="Head" then
            pcall(function() v.BallSocketConstraint.Enabled=false end)
            if v:FindFirstChild("RagdollLimbPart") then pcall(function() v.RagdollLimbPart.WeldConstraint.Enabled=false end) end
        end
    end
end
LocalPlayer.CharacterAdded:Connect(function(c) if _G.AntiGrabNRDEnabled then task.defer(function() setupAntiGrabNRD(c) end) end end)

local function AntiBananaSit()
    while _G.antiBananaSitActive do
        local c = LocalPlayer.Character
        if c then
            local h,h2 = c:FindFirstChild("Humanoid"), c:FindFirstChild("HumanoidRootPart")
            if h and h2 and h.Health>0 then
                h.Sit=true h:ChangeState(Enum.HumanoidStateType.Running)
                local cam = workspace.CurrentCamera
                if cam then local lv=cam.CFrame.LookVector h2.CFrame=CFrame.new(h2.Position, h2.Position+Vector3.new(lv.X,0,lv.Z)) end
            end
        end
        task.wait()
    end
end
local function AntiBlobKill()
    while _G.antiBlobmanKillActive do
        local c = LocalPlayer.Character
        if c then
            local h,h2 = c:FindFirstChild("Humanoid"), c:FindFirstChild("HumanoidRootPart")
            if h and h2 and h.Health>0 then
                h.Sit=true h:ChangeState(Enum.HumanoidStateType.Running)
                local cam = workspace.CurrentCamera
                if cam then local lv=cam.CFrame.LookVector h2.CFrame=CFrame.new(h2.Position, h2.Position+Vector3.new(lv.X,0,lv.Z)) end
            end
        end
        task.wait()
    end
end
local function AntiRagBlob()
    local RR = Ragdoll
    local sit=false
    local function disc(n) if _G.antiRagBlobConnections[n] then _G.antiRagBlobConnections[n]:Disconnect() _G.antiRagBlobConnections[n]=nil end end
    local function setup(c)
        local h = c and c:FindFirstChild("Humanoid")
        local hp = c and c:FindFirstChild("HumanoidRootPart")
        if h and hp and RR then
            disc("ARSeat")
            _G.antiRagBlobConnections["ARSeat"] = h:GetPropertyChangedSignal("SeatPart"):Connect(function()
                if h.SeatPart and h.SeatPart.Parent and h.SeatPart.Parent.Name=="CreatureBlobman" and not sit then
                    sit=true
                    local S = h.SeatPart
                    while not h.Sit do task.wait() end
                    RR:FireServer(hp,3)
                    while not (h:FindFirstChild("Ragdolled") and h.Ragdolled.Value) and not h.Sit do task.wait() end
                    task.wait(0.4) h.Sit=false
                    if S and S:IsA("Part") then S:Sit(h) end
                    task.delay(0.25, function()
                        while h and h.SeatPart do
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                RR:FireServer(LocalPlayer.Character.HumanoidRootPart,1)
                            end
                            task.wait(0.05)
                        end
                        sit=false
                    end)
                end
            end)
        end
    end
    if _G.antiRagBlobActive then
        setup(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
        disc("ARChar")
        _G.antiRagBlobConnections["ARChar"] = LocalPlayer.CharacterAdded:Connect(function(nc) task.wait(0.5) setup(nc) end)
    else
        for _,c in pairs(_G.antiRagBlobConnections) do if c then c:Disconnect() end end
        _G.antiRagBlobConnections={}
    end
end
local function SetupAntiSticky(v) pcall(function() LocalPlayer.PlayerScripts.StickyPartsTouchDetection.Enabled = not v end) end
local function SetupAntiBurn(v)
    if v then
        local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        _G.HRP_Burn = c:WaitForChild("HumanoidRootPart",0.5)
        _G.hum_Burn = c:WaitForChild("Humanoid",0.5)
        if not (_G.HRP_Burn and _G.hum_Burn) then return end
        local function h_(ch)
            if not ch then return end
            local h = ch:WaitForChild("Humanoid",5); if not h then return end
            local fd = h:WaitForChild("FireDebounce",5); if not fd then return end
            return fd.Changed:Connect(function()
                if h.FireDebounce.Value==true then
                    local p = Workspace:FindFirstChild("Plots")
                    local p1 = p and p:FindFirstChild("Plot1")
                    local b = p1 and p1:FindFirstChild("Barrier")
                    local bar = b and b:FindFirstChild("PlotBarrier")
                    if bar then
                        local pos = bar.CFrame
                        task.spawn(function() repeat task.wait() bar.CFrame=_G.HRP_Burn.CFrame until not _G.hum_Burn.FireDebounce.Value end)
                        task.wait(1) h.FireDebounce.Value=false task.wait() bar.CFrame=pos
                    end
                end
            end)
        end
        _G.antiburn1 = LocalPlayer.CharacterAdded:Connect(function(ch)
            if _G.antiburn then _G.antiburn:Disconnect() end
            task.wait(0.2) _G.antiburn = h_(ch)
        end)
        _G.antiburn = h_(c)
    else
        if _G.antiburn then _G.antiburn:Disconnect() _G.antiburn=nil end
        if _G.antiburn1 then _G.antiburn1:Disconnect() _G.antiburn1=nil end
    end
end
local function ExecAntiKickPCLD()
    local sp = CFrame.new(-272.2197265625, -7.350403785705566, 475.0108947753906)
    Workspace.FallenPartsDestroyHeight = 0/0
    local stored, root, conn, act = {}, nil, nil, false
    local function brk()
        local c = LocalPlayer.Character; if not c then return end
        root = c:WaitForChild("HumanoidRootPart")
        for _,v in ipairs(c:GetDescendants()) do if v:IsA("Motor6D") then stored[v]=v.Part0 v.Part0=nil end end
        root.CFrame = sp
        conn = RunService.RenderStepped:Connect(function()
            if root and root.Parent then root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero end
        end)
    end
    local function rst()
        if conn then conn:Disconnect() conn=nil end
        for m,p in pairs(stored) do if m and m.Parent then m.Part0=p end end
        stored = {}
    end
    local function tog() act=not act if act then brk() else rst() end end
    tog() task.wait(0.12) tog()
    LocalPlayer.CharacterAdded:Once(function() task.wait(0.25) tog() task.wait(0.12) tog() end)
end
Workspace.DescendantAdded:Connect(function(d)
    if d.Name=="GrabBeam" then
        _G.Lines = _G.Lines+1
        _G.lagger = d.Parent and d.Parent.Parent and d.Parent.Parent.Parent
    end
end)
local function SetupAntiLag(v)
    _G.Lines=0
    pcall(function() LocalPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = not v end)
end
local function StartAutoAntiLag()
    task.spawn(function()
        while _G.autoantilag and task.wait() do
            if _G.Lines>100 then
                pcall(function() LocalPlayer.PlayerScripts.CharacterAndBeamMove.Enabled=false end)
                Notify("Auto Anti Lag", (_G.lagger and _G.lagger.Name or "Unknown").." Lagged Server", 6.5)
                _G.Lines=0
            end
        end
    end)
end
local function StartAntiInputLag()
    _G.antiInputLagTask = task.spawn(function()
        while _G.AntiExtra.AntiInputLag do
            local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hr = c:WaitForChild("HumanoidRootPart")
            local tf = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
            if not tf then task.wait(0.1); continue end
            local t = tf:FindFirstChild(_G.SelectedAntiInputToy)
            if not t then
                pcall(function() SpawnToy:InvokeServer(_G.SelectedAntiInputToy, hr.CFrame*CFrame.new(0,5,0), Vector3.zero) end)
                local t0 = tick()
                repeat RunService.Heartbeat:Wait() tf=Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys") t=tf and tf:FindFirstChild(_G.SelectedAntiInputToy) until t or tick()-t0>1
            end
            if t and t.Parent then
                local hp = t:FindFirstChild("HoldPart")
                if hp then
                    local ho = hp:FindFirstChild("HoldingPlayer"); ho = ho and ho.Value
                    if ho and ho ~= LocalPlayer then
                        pcall(function() hp.DropItemRemoteFunction:InvokeServer(t, hr.CFrame*CFrame.new(0,2000,0), Vector3.zero) end)
                        t:Destroy()
                    else
                        local hi = hr.CFrame*CFrame.new(0,2000,0)
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
local function StartRemoveAllAntiInput()
    _G.removeAntiInputTask = task.spawn(function()
        local allowed = {FoodHamburger=true,FoodCoconut=true,FoodPizzaCheese=true,FoodPizzaPepperoni=true,FoodHotdog=true,FoodMushroomPoison=true,FoodBread=true,FoodDippyEgg=true,FoodMayonnaise=true,FoodFrenchFries=true,FoodMeatStick=true,FoodDonut=true,FoodCakePink=true,InstrumentGuitarBanjo=true,InstrumentGuitarViolin=true,InstrumentGuitarUkulele=true,InstrumentWoodwindSaxophone=true,InstrumentWoodwindOcarina=true,InstrumentBrassVuvuzelaQwizik=true,InstrumentBrassTrumpet=true,InstrumentDrumBongos=true,InstrumentDrumSnare=true,InstrumentPianoMelodica=true,InstrumentVoiceMicrophone=true,CupMugWhite=true,CupMugBrown=true,PoopPile=true,PoopPileSparkle=true}
        local arr = {}
        local cc = workspace.DescendantAdded:Connect(function(o) if allowed[o.Name] and o:IsA("Model") then task.spawn(function() if o:WaitForChild("HoldPart",3) then table.insert(arr,o) end end) end end)
        for _,v in ipairs(workspace:GetDescendants()) do if allowed[v.Name] and v:IsA("Model") and v:FindFirstChild("HoldPart") then table.insert(arr,v) end end
        while _G.antiAntiLagEnabled do
            local c = LocalPlayer.Character; local hr = c and c:FindFirstChild("HumanoidRootPart")
            if hr then
                for i=#arr,1,-1 do
                    local b = arr[i]
                    if not b or not b.Parent or not b:FindFirstChild("HoldPart") then table.remove(arr,i)
                    else local hp=b.HoldPart pcall(function() hp.HoldItemRemoteFunction:InvokeServer(b,c) end) task.wait() pcall(function() hp.DropItemRemoteFunction:InvokeServer(b, CFrame.new(hr.Position+Vector3.new(0,-2000,0)), Vector3.zero) end) end
                end
            end
            task.wait()
        end
        cc:Disconnect()
    end)
end
_G.GodMode = _G.GodMode or {}
_G.GodMode.isRunning = false
_G.GodMode.originalFallenHeight = Workspace.FallenPartsDestroyHeight
_G.GodMode.lastOriginalCFrame = nil
_G.GodMode.loopCoroutine = nil
local function startGodMode()
    if _G.GodMode.isRunning then return end
    _G.GodMode.isRunning = true
    local c = LocalPlayer.Character
    if c then local r=c:FindFirstChild("HumanoidRootPart") if r then _G.GodMode.lastOriginalCFrame=r.CFrame end end
    _G.GodMode.originalFallenHeight = Workspace.FallenPartsDestroyHeight
    Workspace.FallenPartsDestroyHeight = 0/0
    _G.GodMode.loopCoroutine = coroutine.wrap(function()
        while _G.GodMode.isRunning do
            local ch = LocalPlayer.Character
            if not ch then task.wait(0.5)
            else
                local r = ch:FindFirstChild("HumanoidRootPart")
                if r then
                    if _G.GodMode.lastOriginalCFrame == nil then _G.GodMode.lastOriginalCFrame = r.CFrame end
                    local o = r.CFrame
                    local s = tick()
                    while tick()-s < 1 and _G.GodMode.isRunning do
                        if not LocalPlayer.Character or not r.Parent then break end
                        local t = tick()*12
                        r.CFrame = o + Vector3.new(math.cos(t)*10000, -10000, math.sin(t)*10000)
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
        if r then r.CFrame = CFrame.new(0,-15000,0) end
    end
end)

-- ---------- BlobmanKill ----------
local BK = {isRunning=false,isKillAura=false,isSelectedKill=false,selectedPlayer=nil,currentBlobman=nil,killAuraConnection=nil,selectedKillConn=nil}
local TP_WAIT, GRAB_WAIT, RETRY_WAIT, MAX_RETRIES, MAX_DIST = 0.02, 0.01, 0.01, 5, 500
local function GetSeatedBlob()
    local c = LocalPlayer.Character; if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid"); if not h then return nil end
    local s = h.SeatPart
    if not s or not s:IsA("VehicleSeat") then return nil end
    local o = s
    while o do if o:IsA("Model") and o.Name=="CreatureBlobman" then return o end o=o.Parent end
end
function BK.SpawnBlobman()
    local sb = GetSeatedBlob()
    if sb then BK.currentBlobman=sb return sb end
    if BK.currentBlobman and BK.currentBlobman.Parent then
        local bp
        if BK.currentBlobman.PrimaryPart then bp=BK.currentBlobman.PrimaryPart.Position
        else local p=BK.currentBlobman:FindFirstChildWhichIsA("BasePart") if p then bp=p.Position end end
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        local lp = r and r.Position
        if bp and lp and (bp-lp).Magnitude < MAX_DIST then
            local s = BK.currentBlobman:FindFirstChild("VehicleSeat")
            if s then local h=c and c:FindFirstChildOfClass("Humanoid") if h then s:Sit(h) task.wait(0.08) end end
            return BK.currentBlobman
        else pcall(function() BK.currentBlobman:Destroy() end) BK.currentBlobman=nil end
    end
    local c = LocalPlayer.Character; if not c then return nil end
    local r = c:FindFirstChild("HumanoidRootPart"); if not r then return nil end
    local ok = pcall(function() SpawnToy:InvokeServer("CreatureBlobman", r.CFrame*CFrame.new(0,0,-5), Vector3.new(0,127,0)) end)
    if not ok then return nil end
    local fn = LocalPlayer.Name.."SpawnedInToys"
    local b, t0 = nil, tick()
    repeat
        local tf = workspace:FindFirstChild(fn)
        if tf then b = tf:FindFirstChild("CreatureBlobman") end
        if b then break end
        task.wait()
    until tick()-t0>2
    if not b then return nil end
    BK.currentBlobman = b
    local s = b:FindFirstChild("VehicleSeat")
    if s then local h=c:FindFirstChildOfClass("Humanoid") if h then s:Sit(h) end end
    task.wait(0.08)
    return b
end
function BK.KillPlayer(p)
    if not p or not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid"); if not h then return false end
    for _=1,MAX_RETRIES do
        local ok = pcall(function() h.BreakJointsOnDeath=false h:ChangeState(Enum.HumanoidStateType.Dead) end)
        if ok and h.Health<=0 then return true end
        task.wait(RETRY_WAIT)
    end
    return false
end
function BK.GrabRelease(blob, tr)
    if not blob or not tr then return end
    pcall(function()
        local s = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        if s then
            s.CreatureGrab:FireServer(blob.LeftDetector, tr, blob.LeftDetector.LeftWeld)
            s.CreatureRelease:FireServer(blob.LeftDetector.LeftWeld)
        end
    end)
end
function BK.ProcessPlayer(p)
    if not p or not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid"); if not h or h.Health<=0 then return false end
    local tr = p.Character:FindFirstChild("HumanoidRootPart"); if not tr then return false end
    local b = BK.SpawnBlobman(); if not b then return false end
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CFrame = tr.CFrame task.wait(TP_WAIT) end
    BK.KillPlayer(p)
    for _=1,3 do BK.GrabRelease(b, tr) task.wait(GRAB_WAIT) end
    return true
end
function BK.ProcessAll()
    local c = LocalPlayer.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local r = c.HumanoidRootPart
    local b = BK.SpawnBlobman(); if not b then return end
    local tgts = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(tgts,p) end
    end
    for _,p in ipairs(tgts) do
        if not BK.isRunning then break end
        local tc = p.Character; if not tc then continue end
        local h = tc:FindFirstChildOfClass("Humanoid"); if not h or h.Health<=0 then continue end
        local tr = tc:FindFirstChild("HumanoidRootPart"); if not tr then continue end
        r.CFrame = tr.CFrame task.wait(TP_WAIT)
        BK.KillPlayer(p)
        for _=1,2 do BK.GrabRelease(b, tr) task.wait(GRAB_WAIT) end
    end
end
function BK.StartSelLoop()
    if BK.selectedKillConn then pcall(task.cancel, BK.selectedKillConn) BK.selectedKillConn=nil end
    if not BK.selectedPlayer then return end
    BK.selectedKillConn = task.spawn(function()
        while BK.isSelectedKill and BK.selectedPlayer and BK.selectedPlayer.Parent do
            if BK.selectedPlayer.Character and BK.selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(BK.ProcessPlayer, BK.selectedPlayer)
            end
            task.wait(0.5)
        end
    end)
end
function BK.SetupAura()
    if BK.killAuraConnection then BK.killAuraConnection:Disconnect() BK.killAuraConnection=nil end
    BK.killAuraConnection = RunService.Heartbeat:Connect(function()
        if not (BK.isKillAura or BK.isRunning) then return end
        local c = LocalPlayer.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        local r = c.HumanoidRootPart
        if not BK.currentBlobman or not BK.currentBlobman.Parent then
            BK.currentBlobman = BK.SpawnBlobman()
            if not BK.currentBlobman then return end
        end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tr = p.Character.HumanoidRootPart
                if (r.Position-tr.Position).Magnitude <= 40 then
                    BK.KillPlayer(p)
                    BK.GrabRelease(BK.currentBlobman, tr)
                end
            end
        end
    end)
end
function BK.UpdateAura()
    local sr = BK.isKillAura or BK.isRunning
    if sr then if not BK.killAuraConnection then BK.SetupAura() end
    else if BK.killAuraConnection then BK.killAuraConnection:Disconnect() BK.killAuraConnection=nil end end
end

-- ---------- Anti-Kick removal ----------
local function RemoveAntiKick(name)
    while _G.antiAntiKickActive do
        local t = Players:FindFirstChild(name)
        if t then
            local s = workspace:FindFirstChild(t.Name.."SpawnedInToys")
            if s then
                for _,n in ipairs({"NinjaKunai","NinjaShuriken","AntiKick"}) do
                    local ty = s:FindFirstChild(n)
                    if ty then
                        local p = ty:FindFirstChild("SoundPart")
                        if p then
                            pcall(function() SetNet:FireServer(p, p.CFrame) end)
                            if p:FindFirstChild("PartOwner") and p.PartOwner.Value==LocalPlayer.Name then
                                p.CFrame = CFrame.new(0,1000,0)
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
        for _,t in ipairs(Players:GetPlayers()) do
            if t~=LocalPlayer then
                local tc = t.Character
                local tr = tc and tc:FindFirstChild("HumanoidRootPart")
                if tr and (tr.Position-r.Position).Magnitude <= _G.removeAntiKickRadius then
                    local s = workspace:FindFirstChild(t.Name.."SpawnedInToys")
                    if s then
                        for _,n in ipairs({"NinjaKunai","NinjaShuriken","AntiKick"}) do
                            local ty = s:FindFirstChild(n)
                            if ty then
                                local p = ty:FindFirstChild("SoundPart")
                                if p then
                                    pcall(function() SetNet:FireServer(p, p.CFrame) end)
                                    if p:FindFirstChild("PartOwner") and p.PartOwner.Value==LocalPlayer.Name then
                                        p.CFrame = CFrame.new(0,1000,0)
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
    local s = workspace:FindFirstChild(t.Name.."SpawnedInToys")
    if s then
        for _,n in ipairs({"NinjaKunai","NinjaShuriken","AntiKick"}) do
            local ty = s:FindFirstChild(n)
            if ty then
                local p = ty:FindFirstChild("SoundPart")
                if p then
                    pcall(function() SetNet:FireServer(p, p.CFrame) end)
                    p.CFrame = CFrame.new(0,1000,0)
                    ok = true
                end
                pcall(function() if DestroyToy then DestroyToy:FireServer(ty) end end)
            end
        end
    end
    return ok
end

-- ---------- Loop Blob KickSpam ----------
local function LoopBlobKickSpam()
    local REMOTE_DELAY = 0.002
    local lastRemote, savedPos = 0, nil
    while _G.loopBlobKickSpamActive do
        local tg = Players:FindFirstChild(_G.loopBlobKickSpamTargetName)
        if not tg or not tg.Character or not tg.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.3) continue
        end
        local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local h = c:WaitForChild("Humanoid")
        local s = h.SeatPart
        if not s or s.Parent.Name~="CreatureBlobman" then
            Notify("Error","Please sit on a Blobman",5)
            if Toggles.BlobSpamKickToggle then Toggles.BlobSpamKickToggle:SetValue(false) end
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
            if not s or s.Parent.Name~="CreatureBlobman" then break end
            br = s.Parent:FindFirstChild("HumanoidRootPart") or s.Parent.PrimaryPart
            local tc = ct.Character
            local tr = tc and tc:FindFirstChild("HumanoidRootPart")
            local th = tc and tc:FindFirstChild("Humanoid")
            if tr and th and th.Health>0 and br then
                tr.Velocity = Vector3.zero
                if not drag then
                    br.CFrame = tr.CFrame br.Velocity = Vector3.zero
                    if tick()-lastRemote >= REMOTE_DELAY then
                        lastRemote = tick()
                        pcall(function()
                            th.PlatformStand=true th.Sit=true
                            GE.SetNetworkOwner:FireServer(tr, br.CFrame)
                            GE.DestroyGrabLine:FireServer(tr)
                        end)
                    end
                    if gs==0 then gs=tick() end
                    if tick()-gs > 0.35 then drag=true gs=0 br.CFrame=savedPos end
                else
                    br.CFrame=savedPos br.Velocity=Vector3.zero
                    local lp = savedPos*CFrame.new(0,23,0)
                    tr.CFrame=lp th.PlatformStand=true th.Sit=true
                    if tick()-lastRemote >= REMOTE_DELAY then
                        lastRemote = tick()
                        pcall(function()
                            GE.SetNetworkOwner:FireServer(tr, lp)
                            GE.DestroyGrabLine:FireServer(tr)
                            local w = RD:FindFirstChild("RightWeld") or RD:FindFirstChildWhichIsA("Weld")
                            if w then CD:FireServer(w) CG:FireServer(RD, tr, w) end
                        end)
                    end
                end
            else drag=false gs=0 end
            RunService.Heartbeat:Wait()
        end
        if br then br.CFrame=savedPos end
    end
end

-- ---------- Loop Kill ----------
local function LoopKill1()
    while _G.loopKill1Active do
        local t = Players:FindFirstChild(_G.loopKill1TargetName)
        if t and t.Character then
            local tr = t.Character:FindFirstChild("HumanoidRootPart")
            local th = t.Character:FindFirstChild("Humanoid")
            if tr and th and th.Health>0 then
                local c = LocalPlayer.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if r then
                    local orig = r.CFrame
                    local s = tick()
                    while tick()-s < 0.35 and _G.loopKill1Active do
                        if not tr.Parent then break end
                        r.CFrame = tr.CFrame*CFrame.new(0,0,2) r.Velocity = Vector3.zero
                        pcall(function()
                            RS.GrabEvents.SetNetworkOwner:FireServer(tr, r.CFrame)
                            th.BreakJointsOnDeath=false
                            th:ChangeState(Enum.HumanoidStateType.Dead)
                            RS.GrabEvents.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false)
                            RS.GrabEvents.DestroyGrabLine:FireServer(tr)
                        end)
                        RunService.Heartbeat:Wait()
                    end
                    if r then r.CFrame=orig r.Velocity=Vector3.zero end
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
            if tr and th and th.Health>0 then
                local c = LocalPlayer.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if r then
                    local orig = r.CFrame
                    local fc = 0
                    while fc<18 and th and th.Health>0 and _G.loopKill2Active do
                        fc = fc+1
                        r.CFrame = tr.CFrame*CFrame.new(0,0,2.5) r.Velocity=Vector3.zero r.RotVelocity=Vector3.zero
                        pcall(function()
                            RS.GrabEvents.SetNetworkOwner:FireServer(tr, r.CFrame)
                            th.BreakJointsOnDeath=false
                            th:ChangeState(Enum.HumanoidStateType.Dead)
                            RS.GrabEvents.CreateGrabLine:FireServer(tr, Vector3.new(0,-200,0), tr.Position, true)
                            RS.GrabEvents.DestroyGrabLine:FireServer(tr)
                        end)
                        RunService.Heartbeat:Wait()
                    end
                    if r then r.CFrame=orig end
                end
            end
        end
        task.wait(0.05)
    end
end

-- ---------- Spam kick(grab) ----------
local function SpamKickGrab()
    local name = _G.loopBlobKickSpamTargetName or selectedTargetName
    local t = name and Players:FindFirstChild(name)
    if not t then
        if Toggles.SpamKickGrabToggle then Toggles.SpamKickGrabToggle:SetValue(false) end
        Notify("Error","Target not found",3)
        return
    end
    local c = LocalPlayer.Character
    local r = c and c:FindFirstChild("HumanoidRootPart"); if not r then return end
    local saved = r.CFrame
    local drag, gs = false, 0
    while _G.kickLoopEnabled do
        if not t or not t.Parent then
            _G.kickLoopEnabled = false
            if Toggles.SpamKickGrabToggle then Toggles.SpamKickGrabToggle:SetValue(false) end
            break
        end
        local tc = t.Character
        local tr = tc and tc:FindFirstChild("HumanoidRootPart")
        local th = tc and tc:FindFirstChild("Humanoid")
        c = LocalPlayer.Character
        r = c and c:FindFirstChild("HumanoidRootPart")
        if tr and th and th.Health>0 and r then
            tr.Velocity = Vector3.zero
            if not drag then
                r.CFrame = tr.CFrame
                pcall(function()
                    th.PlatformStand=true th.Sit=true
                    GE.SetNetworkOwner:FireServer(tr, r.CFrame)
                    GE.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false)
                end)
                if gs==0 then gs=tick() end
                if tick()-gs > 0.35 then drag=true gs=0 end
            else
                r.CFrame = saved
                local lp = saved*CFrame.new(0,17,0)
                tr.CFrame = lp th.PlatformStand=true th.Sit=false
                pcall(function()
                    GE.SetNetworkOwner:FireServer(tr, lp)
                    GE.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false)
                    GE.DestroyGrabLine:FireServer(tr)
                    GE.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false)
                end)
            end
        else drag=false gs=0 if r then r.CFrame=saved end end
        RunService.Heartbeat:Wait()
    end
    if r then r.CFrame = saved end
end

-- ---------- Snowball Ragdoll ----------
local function SnowballRag()
    while _G.snowballRagdollActive do
        local t = Players:FindFirstChild(_G.snowballRagdollTargetName)
        if not t or not t.Character then task.wait(0.5) continue end
        local tc = t.Character
        local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
        if not torso then task.wait() continue end
        pcall(function()
            local o = Vector3.new(math.random(-30,30)/100, math.random(-30,30)/100, math.random(-30,30)/100)
            SpawnToy:InvokeServer("BallSnowball", torso.CFrame*CFrame.new(o), Vector3.zero)
        end)
        local f = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
        if f then
            for _,sb in pairs(f:GetChildren()) do
                if sb.Name=="BallSnowball" and sb.Parent then
                    local p = sb.PrimaryPart or sb:FindFirstChildWhichIsA("BasePart")
                    if p then
                        local o = Vector3.new(math.random(-30,30)/100, math.random(-30,30)/100, math.random(-30,30)/100)
                        p.CFrame = torso.CFrame*CFrame.new(o)
                        p.AssemblyLinearVelocity=Vector3.zero p.AssemblyAngularVelocity=Vector3.zero
                    end
                end
            end
        end
        task.wait()
    end
end

-- ---------- Gucci Break ----------
local function sitOnce(blob)
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return end
    local s = blob:FindFirstChild("VehicleSeat")
    if not s or s:FindFirstChild("SeatWeld") then return end
    local pr = s:FindFirstChildOfClass("ProximityPrompt")
    if not pr then return end
    r.CFrame = s.CFrame
    for _=1,20 do
        firePrompt(pr)
        task.wait(0.01)
        if s:FindFirstChild("SeatWeld") then break end
    end
    if s:FindFirstChild("SeatWeld") then
        h.Sit = false
        repeat task.wait() until not s:FindFirstChild("SeatWeld")
    end
end
local function sitAll(folder)
    local c = LocalPlayer.Character
    local r = c and c:FindFirstChild("HumanoidRootPart"); if not r then return end
    local o = r.CFrame
    for _,obj in pairs(folder:GetDescendants()) do
        if obj.Name=="CreatureBlobman" and obj:IsA("Model") then sitOnce(obj) end
    end
    r.CFrame = o
end
function AllGucciBreak() sitAll(workspace) end
function TargetGucciBreak(n)
    local f = workspace:FindFirstChild(n.."SpawnedInToys")
    if f then sitAll(f) else Notify("Gucci Break","Player toy folder not found",2) end
end

-- ---------- Prayer ----------
local prayers = {
    "Singularity hub on top","Singularity hub is the best","Singularity hub x Gucci anti-grab",
    "God mode activated","Kick all blobman","Wing master system","Arkadia blob spam kick",
    "Singularity project","Gucci break system","Pray to Singularity","Singularity hub - Reign Supreme"
}
local function sendChat(msg)
    local sent = false
    local ce = RS:FindFirstChild("DefaultChatSystemChatEvents")
    if ce then
        local sm = ce:FindFirstChild("SayMessageRequest")
        if sm then pcall(function() sm:FireServer(msg,"All") sent=true end) end
    end
    if not sent then
        local TCS = game:GetService("TextChatService")
        if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch
            for _=1,10 do
                if TCS.TextChannels then ch = TCS.TextChannels:FindFirstChild("RBXGeneral") end
                if ch then break end
                task.wait(0.1)
            end
            if ch then pcall(ch.SendAsync, ch, msg) sent=true end
        end
    end
end

-- ---------- UI ----------
local Window = Library:CreateWindow({
    Title = "Singularity hub premium",
    Footer = "Kick + Kill + Anti + Lag + Ragdoll + FTAP Defense",
    Icon = 95816097006868, NotifySide = "Right", ShowCustomCursor = true,
})
local Tabs = {
    Main=Window:AddTab("Main","user"),
    Kick=Window:AddTab("Kick","swords"),
    Kill=Window:AddTab("Kill","skull"),
    LagRagdoll=Window:AddTab("Lag & Ragdoll","zap"),
    Anti=Window:AddTab("Anti","shield"),
    Gucci=Window:AddTab("Gucci Break","package"),
    Plot=Window:AddTab("Plot","hammer"),
    Tsunami=Window:AddTab("Tsunami","droplet"),
    Teleport=Window:AddTab("Teleport","map-pin"),
    ToyMod=Window:AddTab("Toy Mod","wrench"),
}

local TG = Tabs.Main:AddLeftGroupbox("Target","target")
TG:AddDropdown("TargetDropdown",{Values=GetPlayerList(),Default="",Text="Select Target",Searchable=true,
    Callback=function(s) if s and s~="" then local u=User(s) if u then selectedTargetName=u Notify("Target Set",u,2) end end end})
TG:AddButton({Text="Refresh Player List", Func=function() Options.TargetDropdown:SetValues(GetPlayerList()) end})

local KL = Tabs.Kick:AddLeftGroupbox("Kick","swords")
KL:AddToggle("AllkickToggle",{Text="Allkick",Default=false,Callback=function(v) if v then AllkickExec(false) Notify("Start","Allkick Started",2) else AllkickStop() Notify("Stop","Allkick Stopped",2) end end})
KL:AddToggle("NoblobkickToggle",{Text="Noblobkick",Default=false,Callback=function(v) if v then TlagExec(true) Notify("Start","Noblobkick Started",2) else TlagStop() Notify("Stop","Noblobkick Stopped",2) end end})
KL:AddButton({Text="Blobkick",Func=GrabKickExecute})
KL:AddButton({Text="Lagkick",Func=LagkExecute})
local function mKick(name, text, ex, st)
    KL:AddToggle(name,{Text=text,Default=false,Callback=function(v) if v then ex() Notify("Start",text.." Started",2) else st() Notify("Stop",text.." Stopped",2) end end})
end
mKick("LKA_Toggle","Lag Kick All",LKAExec,LKAStop)
mKick("LKS_Toggle","Lag Kick Select",LKSExec,LKSStop)
mKick("LKA2_Toggle","Lag Kick All (Strong)",LKA2Exec,LKA2Stop)
mKick("LKS2_Toggle","Lag Kick Select (Anti Pierce)",LKS2Exec,LKS2Stop)
mKick("LKA3_Toggle","Grab Kick All (Vision Pierce)",LKA3Exec,LKA3Stop)
mKick("LKS3_Toggle","Grab Kick Select (Visual Pierce)",LKS3Exec,LKS3Stop)
KL:AddToggle("SpamKToggle",{Text="Spam Kick",Default=false,Callback=function(v)
    if v then
        if not selectedTargetName then Notify("Error","No target selected",3) Toggles.SpamKToggle:SetValue(false) return end
        SpamKStart(selectedTargetName) Notify("Start","Spam Kick Started",2)
    else SpamKStop() Notify("Stop","Spam Kick Stopped",2) end
end})
KL:AddToggle("DriftKToggle",{Text="Drift Kick",Default=false,Callback=function(v) if v then DriftStart() Notify("Start","Drift Kick Started",2) else DriftStop() Notify("Stop","Drift Kick Stopped",2) end end})

local KR = Tabs.Kick:AddRightGroupbox("Exploits","zap")
KR:AddToggle("BlobSpamKickToggle",{Text="Blob spam kick",Default=false,Callback=function(v)
    _G.loopBlobKickSpamActive = v
    if v then
        _G.loopBlobKickSpamTargetName = selectedTargetName
        if not _G.loopBlobKickSpamTargetName then Notify("Error","No target selected",3) Toggles.BlobSpamKickToggle:SetValue(false) return end
        _G.loopBlobKickSpamTask = task.spawn(LoopBlobKickSpam) Notify("Start","Blob spam kick Started",2)
    else
        if _G.loopBlobKickSpamTask then task.cancel(_G.loopBlobKickSpamTask) _G.loopBlobKickSpamTask=nil end
        Notify("Stop","Blob spam kick Stopped",2)
    end
end})
KR:AddToggle("SpamKickGrabToggle",{Text="Spam kick(grab)",Default=false,Callback=function(on)
    _G.kickLoopEnabled = on
    if on then
        if not selectedTargetName then Notify("Error","No target selected",3) Toggles.SpamKickGrabToggle:SetValue(false) return end
        _G.loopBlobKickSpamTargetName = selectedTargetName
        task.spawn(SpamKickGrab) Notify("Start","Spam kick(grab) Started",2)
    else Notify("Stop","Spam kick(grab) Stopped",2) end
end})
KR:AddDivider()
KR:AddButton({Text="Stop All Kick",Func=function()
    AllkickStop() TlagStop() LKAStop() LKSStop() LKA2Stop() LKS2Stop() LKA3Stop() LKS3Stop()
    SpamKStop() DriftStop()
    _G.kickLoopEnabled = false
    if _G.loopBlobKickSpamTask then task.cancel(_G.loopBlobKickSpamTask) _G.loopBlobKickSpamTask=nil end
    Notify("Stop","All kicks stopped",2)
end})

local KillL = Tabs.Kill:AddLeftGroupbox("Blobman Kill","skull")
KillL:AddToggle("BlobmanKillAllToggle",{Text="Kill All",Default=false,Callback=function(v)
    BK.isRunning = v
    if v then
        if Toggles.BlobmanKillAuraToggle then Toggles.BlobmanKillAuraToggle:SetValue(false) end
        BK.UpdateAura()
        task.spawn(function() while BK.isRunning do BK.ProcessAll() task.wait() end end)
        Notify("Start","Kill All Started",2)
    else BK.UpdateAura() Notify("Stop","Kill All Stopped",2) end
end})
KillL:AddToggle("BlobmanKillAuraToggle",{Text="Kill Aura",Default=false,Callback=function(v)
    BK.isKillAura = v
    if v then
        if Toggles.BlobmanKillAllToggle then Toggles.BlobmanKillAllToggle:SetValue(false) end
        BK.SpawnBlobman() Notify("Start","Kill Aura Started",2)
    else Notify("Stop","Kill Aura Stopped",2) end
    BK.UpdateAura()
end})
KillL:AddToggle("BlobmanSelectedKillToggle",{Text="Selected Kill",Default=false,Callback=function(v)
    BK.isSelectedKill = v
    if v then
        BK.selectedPlayer = selectedTargetName and Players:FindFirstChild(selectedTargetName)
        if not BK.selectedPlayer then Notify("Error","No target selected",2) Toggles.BlobmanSelectedKillToggle:SetValue(false) return end
        BK.StartSelLoop() Notify("Start","Selected Kill Started",2)
    else
        if BK.selectedKillConn then pcall(task.cancel, BK.selectedKillConn) BK.selectedKillConn=nil end
        Notify("Stop","Selected Kill Stopped",2)
    end
end})

local KillR = Tabs.Kill:AddRightGroupbox("Loop Kill","skull")
KillR:AddToggle("LoopKillToggle",{Text="Loop kill",Default=false,Callback=function(v)
    _G.loopKill1Active = v
    if v then
        _G.loopKill1TargetName = selectedTargetName
        if not _G.loopKill1TargetName then Notify("Error","No target selected",3) Toggles.LoopKillToggle:SetValue(false) return end
        task.spawn(LoopKill1) Notify("Start","Loop kill Started",2)
    else Notify("Stop","Loop kill Stopped",2) end
end})
KillR:AddToggle("LoopKill2Toggle",{Text="Loop kill (Anti Pierce)",Default=false,Callback=function(v)
    _G.loopKill2Active = v
    if v then
        _G.loopKill2TargetName = selectedTargetName
        if not _G.loopKill2TargetName then Notify("Error","No target selected",3) Toggles.LoopKill2Toggle:SetValue(false) return end
        task.spawn(LoopKill2) Notify("Start","Loop kill(anti) Started",2)
    else Notify("Stop","Loop kill(anti) Stopped",2) end
end})

-- ============ Lag & Ragdoll 統合タブ ============
local RagL = Tabs.LagRagdoll:AddLeftGroupbox("Ragdoll","activity")
RagL:AddToggle("SnowballRagdollToggle",{Text="Snowball Ragdoll",Default=false,Callback=function(v)
    _G.snowballRagdollActive = v
    if v then
        _G.snowballRagdollTargetName = selectedTargetName
        if not _G.snowballRagdollTargetName then Notify("Error","No target selected",3) Toggles.SnowballRagdollToggle:SetValue(false) return end
        _G.snowballRagdollTask = task.spawn(SnowballRag) Notify("Start","Snowball Ragdoll Started",2)
    else
        if _G.snowballRagdollTask then task.cancel(_G.snowballRagdollTask) _G.snowballRagdollTask=nil end
        Notify("Stop","Snowball Ragdoll Stopped",2)
    end
end})

local LagL = Tabs.LagRagdoll:AddLeftGroupbox("Lags","zap")
LagL:AddToggle("AntiLagToggle",{Text="Anti Lag",Default=false,Callback=SetupAntiLag})
LagL:AddToggle("AutoAntiLagToggle",{Text="Auto Anti Lag",Default=false,Callback=function(v)
    _G.autoantilag = v
    if v then StartAutoAntiLag()
    else pcall(function() LocalPlayer.PlayerScripts.CharacterAndBeamMove.Enabled=true end) end
end})
LagL:AddDivider()
LagL:AddSlider("LineLagLPS",{Text="Lines Per Second",Default=100,Min=1,Max=1000,Rounding=0,Callback=function(v) _G.LineLagLPS=v end})
LagL:AddToggle("LineLagToggle",{Text="Line Lag",Default=false,Callback=function(v)
    _G.lineLagActive = v
    if v then
        _G.LineLagLPS = _G.LineLagLPS or 100
        _G.lineLagTask = task.spawn(function()
            while _G.lineLagActive do
                for _=1,_G.LineLagLPS do
                    pcall(function() CGL:FireServer(Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn"), CFrame.new(0,9e9,0)) end)
                end
                task.wait(1)
            end
            _G.lineLagTask = nil
        end)
    else if _G.lineLagTask then pcall(task.cancel, _G.lineLagTask) _G.lineLagTask=nil end end
end})
LagL:AddDivider()
LagL:AddSlider("PacketLagStrength",{Text="Packet Strength",Default=2000,Min=0,Max=60000,Rounding=1,Callback=function(v) _G.PacketLagStrength=v end})
LagL:AddToggle("AntiDetectToggle",{Text="Anti Detect (Packets)",Default=false,Callback=function(v) _G.AntiDetect=v end})
LagL:AddToggle("PacketLagToggle",{Text="Packet Lag",Default=false,Callback=function(v)
    _G.packetLagActive = v
    if v then
        _G.PacketLagStrength = _G.PacketLagStrength or 2000
        _G.packetLagTask = task.spawn(function()
            while _G.packetLagActive do
                task.wait(1)
                pcall(function() EGL:FireServer(string.rep("A", 100*_G.PacketLagStrength)) end)
            end
            _G.packetLagTask = nil
        end)
    else if _G.packetLagTask then pcall(task.cancel, _G.packetLagTask) _G.packetLagTask=nil end end
end})

local LagR = Tabs.LagRagdoll:AddRightGroupbox("Anti Input Lag","zap")
LagR:AddToggle("AntiInputLagToggle",{Text="Anti Input Lag",Default=false,Callback=function(v)
    _G.AntiExtra.AntiInputLag = v
    if v then StartAntiInputLag()
    else if _G.antiInputLagTask then task.cancel(_G.antiInputLagTask) _G.antiInputLagTask=nil end end
end})
LagR:AddToggle("RemoveAllAntiInputToggle",{Text="Remove All Anti Input",Default=false,Callback=function(v)
    _G.antiAntiLagEnabled = v
    if v then StartRemoveAllAntiInput()
    else if _G.removeAntiInputTask then task.cancel(_G.removeAntiInputTask) _G.removeAntiInputTask=nil end end
end})

-- ============ FTAP Defense ============
local DefL = Tabs.LagRagdoll:AddRightGroupbox("FTAP Defense","shield")
DefL:AddToggle("NOForceToggle",{Text="Network Ownership 強制剥奪",Default=false,Callback=function(v)
    if v then startNOF() else stopNOF() end
end})
DefL:AddToggle("AARToggle",{Text="Anti Attachment + Instant Reverse",Default=false,Callback=function(v)
    if v then startAAR() else stopAAR() end
end})
DefL:AddToggle("SSFToggle",{Text="Script Source Freeze",Default=false,Callback=function(v)
    if v then startSSF() else stopSSF() end
end})
DefL:AddToggle("PALToggle",{Text="Physics Limiter / Invisible Anchor",Default=false,Callback=function(v)
    if v then startPAL() else stopPAL() end
end})

-- ============ Anti ============
local AntiL = Tabs.Anti:AddLeftGroupbox("Anti Protection","shield")
local function toggleSimple(name, text, fn)
    AntiL:AddToggle(name,{Text=text,Default=false,Callback=fn})
end
toggleSimple("AntiGrabToggle","Anti Grab",function(v) AntiConfig.AntiGrab=v end)
AntiL:AddToggle("AntiGrabNRDToggle",{Text="Anti Grab (No Ragdoll)",Default=false,Callback=function(v)
    _G.AntiExtra.AntiGrabNRD = v _G.AntiGrabNRDEnabled = v
    if v and LocalPlayer.Character then task.defer(function() setupAntiGrabNRD(LocalPlayer.Character) end) end
end})
toggleSimple("AntiVoidToggle","Anti Void",function(v) AntiConfig.AntiVoid=v end)
toggleSimple("AntiRagdollToggle","Anti Ragdoll",function(v) AntiConfig.AntiRagdoll=v end)
toggleSimple("AntiExplodeToggle","Anti Explode",function(v) AntiConfig.AntiExplode=v SetupAntiExplode() end)
toggleSimple("AntiExplodeV2Toggle","Anti Explode V2",function(v)
    AntiConfig.AntiExplodeV2 = v
    local h = LocalPlayer.PlayerScripts:FindFirstChild("ClientExoplosionHandler")
    if h then h.Enabled = not v end
end)
toggleSimple("AntiGucciToggle","Anti Gucci",toggleAntiGucci)
toggleSimple("AntiSpamKickToggle","Anti Spam Kick",function(v) AntiConfig.AntiSpamKick=v end)
AntiL:AddToggle("AntiBananaSitToggle",{Text="Anti Banana Sit",Default=false,Callback=function(v)
    _G.antiBananaSitActive = v
    if v then _G.antiBananaSitTask = task.spawn(AntiBananaSit)
    else if _G.antiBananaSitTask then task.cancel(_G.antiBananaSitTask) _G.antiBananaSitTask=nil end end
end})
AntiL:AddToggle("AntiBlobmanKillToggle",{Text="Anti Blobman Kill",Default=false,Callback=function(v)
    _G.antiBlobmanKillActive = v
    if v then _G.antiBlobmanKillTask = task.spawn(AntiBlobKill)
    else if _G.antiBlobmanKillTask then task.cancel(_G.antiBlobmanKillTask) _G.antiBlobmanKillTask=nil end end
end})
AntiL:AddToggle("AntiRagBlobToggle",{Text="Anti Ragdoll on Blob",Default=false,Callback=function(v) _G.antiRagBlobActive=v AntiRagBlob() end})
toggleSimple("AntiStickyToggle","Anti Sticky",SetupAntiSticky)
toggleSimple("AntiBurnToggle","Anti Burn",SetupAntiBurn)
AntiL:AddToggle("GodModeToggle",{Text="GOD MODE",Default=false,Callback=function(v)
    if v then startGodMode() Notify("GOD MODE","Enabled",3) else stopGodMode() Notify("GOD MODE","Disabled",3) end
end})

local AntiR = Tabs.Anti:AddRightGroupbox("Anti Kick Tools","zap")
AntiR:AddToggle("AntiKickToggle",{Text="Anti Kick",Default=false,Risky=true,Callback=function(v) AntiConfig.AntiKick=v setupAntiKick(v) end})
AntiR:AddToggle("AntiKillToggle",{Text="Anti Kill",Default=false,Risky=true,Callback=function(v) AntiConfig.AntiKill=v setupAntiKill(v) end})
toggleSimple("KickGrabToggle","Kick Grab",function(v) AntiConfig.KickGrab=v end)
AntiR:AddToggle("AntiKickBreakPCLDToggle",{Text="Anti Kick (Break PCLD)",Default=false,Callback=function(v) if v then ExecAntiKickPCLD() end end})
AntiR:AddDivider()
AntiR:AddToggle("TargetRemoveAntiKickToggle",{Text="Target Remove Anti Kick",Default=false,Callback=function(v)
    _G.antiAntiKickActive = v
    if v and selectedTargetName then task.spawn(function() RemoveAntiKick(selectedTargetName) end) Notify("Start","Target Anti Kick Removal Started",2)
    elseif v then Notify("Error","No target selected",3) Toggles.TargetRemoveAntiKickToggle:SetValue(false)
    else Notify("Stop","Target Anti Kick Removal Stopped",2) end
end})
AntiR:AddToggle("RemoveAntiKickAuraToggle",{Text="Remove Anti Kick Aura",Default=false,Callback=function(v)
    _G.removeAntiKickAuraActive = v
    if v then task.spawn(RemoveAntiKickAura) Notify("Start","Anti Kick Aura Started",2)
    else Notify("Stop","Anti Kick Aura Stopped",2) end
end})
AntiR:AddSlider("AuraRadius",{Text="Aura Radius",Default=50,Min=10,Max=200,Rounding=0,Suffix=" studs",Callback=function(v) _G.removeAntiKickRadius=v end})
AntiR:AddButton({Text="Remove Target Anti Kick (Once)",Func=function()
    if not selectedTargetName then Notify("Error","No target selected",3) return end
    local t = Players:FindFirstChild(selectedTargetName)
    if t then
        local ok = RemoveTargetAntiKick(t)
        if ok then Notify("Success","Anti-Kick removed from "..t.Name,2) else Notify("Info","No Anti-Kick found",2) end
    end
end})

local GucciL = Tabs.Gucci:AddLeftGroupbox("Gucci Break","zap")
GucciL:AddButton({Text="All Gucci Break",Func=function() if AllGucciBreak then AllGucciBreak() end Notify("Gucci Break","All executed",2) end})
GucciL:AddButton({Text="Target Gucci Break",Func=function()
    if selectedTargetName then
        if TargetGucciBreak then TargetGucciBreak(selectedTargetName) end
        Notify("Gucci Break", selectedTargetName.." executed",2)
    else Notify("Error","No target selected",2) end
end})
local LGA, LGT = false, nil
GucciL:AddToggle("LoopAllGucciBreakToggle",{Text="Loop All Gucci Break",Default=false,Callback=function(v)
    LGA = v
    if v then
        LGT = task.spawn(function() while LGA do if AllGucciBreak then AllGucciBreak() end task.wait(1) end end)
        Notify("Gucci Break","Loop Started",2)
    else
        if LGT then task.cancel(LGT) LGT=nil end
        Notify("Gucci Break","Loop Stopped",2)
    end
end})

local PlotL = Tabs.Plot:AddLeftGroupbox("Plot Barrier","hammer")
PlotL:AddButton({Text="Break Barrier (Once)",Func=function() if BarrierExecute then BarrierExecute() end end})

local TsL = Tabs.Tsunami:AddLeftGroupbox("Tsunami","droplet")
TsL:AddButton({Text="Run Tsunami",Func=function() if runTsunami then task.spawn(runTsunami) end end})
TsL:AddButton({Text="Cleanup Tsunami",Func=function() if tsunamiCleanup then tsunamiCleanup() end Notify("Tsunami","Cleanup complete",2) end})

local TPL = Tabs.Teleport:AddLeftGroupbox("Player Teleport","map-pin")
TPL:AddSlider("TPOffsetY",{Text="Y Offset",Default=3,Min=-20,Max=50,Rounding=0,Suffix=" studs",Callback=function(v)
    _G.TPState.OffsetY = v
    if _G.TPState.Loop then StartTP() end
end})
TPL:AddButton({Text="Teleport Once",Func=function()
    local n = selectedTargetName or _G.TPState.TargetName
    if n then TPTo(n, _G.TPState.OffsetY) else Notify("Error","No target selected",2) end
end})
TPL:AddToggle("TPLoopToggle",{Text="Loop Teleport",Default=false,Callback=function(v)
    _G.TPState.Loop = v
    if v then
        _G.TPState.TargetName = selectedTargetName
        if not _G.TPState.TargetName then Notify("Error","No target selected",3) Toggles.TPLoopToggle:SetValue(false) return end
        StartTP() Notify("Start","Loop Teleport Started",2)
    else StopTP() Notify("Stop","Loop Teleport Stopped",2) end
end})

-- ---------- Wing Master ----------
local WM = {isActive=false,SelectedItem="TetracubeI",SearchMode="My Toys",WingSpeed=2,WingAngle=30,WingLength=5,TimeCounter=0,Wings={},Offsets={CFrame.new(-4.125,0,1),CFrame.new(4.125,0,1)},RunConnection=nil}
local function CleanupWings()
    for _,w in pairs(WM.Wings) do
        if w.Handle and w.Handle.Parent then w.Handle:Destroy() end
        for _,s in pairs(w.Segments or {}) do if s.Part and s.Part.Parent then s.Part:Destroy() end end
    end
    WM.Wings = {}
    if WM.RunConnection then WM.RunConnection:Disconnect() WM.RunConnection=nil end
end
local function GetToyFolders()
    local f = {}
    if WM.SearchMode=="My Toys" or WM.SearchMode=="All Toys" then
        local m = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
        if m then table.insert(f,m) end
    end
    if WM.SearchMode=="Plot Toys" or WM.SearchMode=="All Toys" then
        local pf = workspace:FindFirstChild("Plots")
        if pf then
            for i=1,5 do
                local p = pf:FindFirstChild("Plot"..i)
                if p then
                    local of = p:FindFirstChild("PlotSign") and p.PlotSign:FindFirstChild("ThisPlotsOwners")
                    if of then
                        for _,v in ipairs(of:GetChildren()) do
                            if v:IsA("ValueBase") and v.Value==LocalPlayer.Name then
                                local pif = workspace:FindFirstChild("PlotItems")
                                if pif and pif:FindFirstChild(p.Name) then table.insert(f, pif:FindFirstChild(p.Name)) end
                            end
                        end
                    end
                end
            end
        end
    end
    return f
end
local function SetupPhysics(p)
    local bp = p:FindFirstChildOfClass("BodyPosition") or Instance.new("BodyPosition")
    local bg = p:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro")
    bp.P=15000 bp.D=200 bp.MaxForce=Vector3.new(1,1,1)*1e10 bp.Parent=p
    bg.P=15000 bg.D=200 bg.MaxTorque=Vector3.new(1,1,1)*1e10 bg.Parent=p
    return bg, bp
end
local function BuildWings()
    CleanupWings()
    local folders = GetToyFolders()
    local all = {}
    for _,f in ipairs(folders) do
        for _,x in ipairs(f:GetDescendants()) do
            if x:IsA("Model") and x.Name==WM.SelectedItem then table.insert(all,x) end
        end
    end
    if #all == 0 then Notify("Wing Master","Target item not found",3) return false end
    for i=1,2 do
        local segs = {}
        for _=1,WM.WingLength do
            local p = Instance.new("Part")
            p.CanCollide=false p.Anchored=true p.Transparency=1 p.Size=Vector3.new(4,1,4) p.Parent=workspace
            segs[#segs+1] = {Part=p}
        end
        local h = Instance.new("Part")
        h.CanCollide=false h.Anchored=true h.Transparency=1 h.Size=Vector3.new(4,1,4) h.Parent=workspace
        table.insert(WM.Wings, {Handle=h, Segments=segs, Sync={}, Reserved=nil})
    end
    for i,v in ipairs(all) do
        local side = (i <= #all/2) and 1 or 2
        local pal = v:FindFirstChild("SoundPart") or v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
        if pal then
            for _,ch in pairs(v:GetChildren()) do if ch:IsA("BasePart") then ch.CanCollide=false end end
            local bg, bp = SetupPhysics(pal)
            if not WM.Wings[side].Reserved then WM.Wings[side].Reserved = {BG=bg, BP=bp}
            else table.insert(WM.Wings[side].Sync, {BG=bg, BP=bp}) end
        end
    end
    return true
end
local function StartWingAnim()
    if WM.RunConnection then WM.RunConnection:Disconnect() end
    WM.RunConnection = RunService.RenderStepped:Connect(function(dt)
        if not WM.isActive or #WM.Wings==0 then return end
        local C = LocalPlayer.Character
        if not C then return end
        local T = C:FindFirstChild("Torso")
        local HR = C:FindFirstChild("HumanoidRootPart")
        if not T or not HR then return end
        WM.TimeCounter = WM.TimeCounter + dt*(WM.WingSpeed + HR.Velocity.Magnitude/40)
        for i,w in ipairs(WM.Wings) do
            local dir = (i==1) and 1 or -1
            local flap = math.sin(WM.TimeCounter)*math.rad(WM.WingAngle + HR.Velocity.Magnitude/4)*dir
            w.Handle.CFrame = T.CFrame*WM.Offsets[i]*CFrame.Angles(0,0,flap)
            if w.Reserved then
                w.Reserved.BP.Position = w.Handle.Position
                w.Reserved.BG.CFrame = w.Handle.CFrame*CFrame.Angles(math.rad(90),0,math.rad(90))
            end
            for idx,seg in ipairs(w.Segments) do
                local tf = (idx==1) and w.Handle.CFrame or w.Segments[idx-1].Part.CFrame
                seg.Part.CFrame = seg.Part.CFrame:Lerp(tf*WM.Offsets[i], 0.5)
                if w.Sync[idx] then
                    w.Sync[idx].BP.Position = seg.Part.Position
                    w.Sync[idx].BG.CFrame = seg.Part.CFrame*CFrame.Angles(math.rad(90),0,math.rad(90))
                end
            end
        end
    end)
end
local function ToggleWings(v)
    if v then
        if BuildWings() then WM.isActive=true StartWingAnim() Notify("Wing Master","Enabled",3) else WM.isActive=false end
    else WM.isActive=false CleanupWings() Notify("Wing Master","Disabled",3) end
end
LocalPlayer.CharacterAdded:Connect(function()
    if WM.isActive then task.defer(function() if WM.isActive then BuildWings() end end) end
end)

local WL = Tabs.ToyMod:AddLeftGroupbox("Wing Master","activity")
WL:AddDropdown("WingItemDropdown",{Text="Select Item",Values={"TetracubeI","FireworkSparkler","PoopPile","BallSnowball","CreatureBlobman"},Default=1,
    Callback=function(v) WM.SelectedItem=v if WM.isActive then BuildWings() end end})
WL:AddDropdown("WingSearchDropdown",{Text="Search Range",Values={"My Toys","Plot Toys","All Toys"},Default=1,
    Callback=function(v) WM.SearchMode=v if WM.isActive then BuildWings() end end})
WL:AddSlider("WingSpeedSlider",{Text="Wing Speed",Default=2,Min=1,Max=10,Rounding=1,Callback=function(v) WM.WingSpeed=v end})
WL:AddSlider("WingAngleSlider",{Text="Wing Angle",Default=30,Min=10,Max=90,Rounding=0,Suffix="°",Callback=function(v) WM.WingAngle=v end})
WL:AddSlider("WingLengthSlider",{Text="Wing Length",Default=5,Min=3,Max=10,Rounding=0,
    Callback=function(v) WM.WingLength=v if WM.isActive then BuildWings() end end})
WL:AddButton({Text="Rebuild Wings",Func=function()
    if WM.isActive then BuildWings() Notify("Wing Master","Rebuilt",2) else Notify("Wing Master","Enable first",2) end
end})
WL:AddToggle("WingMasterToggle",{Text="Enable Wings System",Default=false,Callback=ToggleWings})

local PL = Tabs.ToyMod:AddRightGroupbox("Prayer","heart")
local prayIdx = 0
PL:AddDropdown("PrayerSelect",{Text="Select Prayer",Values={
    "1. Singularity hub on top","2. Singularity hub is the best","3. Singularity hub x Gucci anti-grab",
    "4. God mode activated","5. Kick all blobman","6. Wing master system","7. Arkadia blob spam kick",
    "8. Singularity project","9. Gucci break system","10. Pray to Singularity","11. Singularity hub - Reign Supreme"},
    Default=1,Callback=function(v) prayIdx = tonumber(v:match("^(%d+)")) end})
local spamC, spamI = 5, 1.0
PL:AddSlider("PrayerSpamCount",{Text="Spam Count",Default=5,Min=1,Max=50,Rounding=0,Callback=function(v) spamC=v end})
PL:AddSlider("PrayerSpamInterval",{Text="Interval (s)",Default=1.0,Min=0.1,Max=10.0,Rounding=1,Suffix="s",Callback=function(v) spamI=v end})
PL:AddButton({Text="Spam Current Prayer",Func=function()
    if prayIdx<=0 then Notify("Error","No prayer selected",2) return end
    task.spawn(function()
        for _=1,spamC do sendChat(prayers[prayIdx]) task.wait(0.3) end
        Notify("Prayer","Spam complete",2)
    end)
end})
PL:AddButton({Text="Send Once",Func=function()
    if prayIdx<=0 then Notify("Error","No prayer selected",2) return end
    sendChat(prayers[prayIdx]) Notify("Prayer","Sent",1)
end})
local LPA, LPT = false, nil
PL:AddToggle("LoopAllPrayersToggle",{Text="Loop All Prayers",Default=false,Callback=function(v)
    LPA = v
    if v then
        LPT = task.spawn(function()
            local i = 1
            while LPA do
                if i > #prayers then i=1 end
                sendChat(prayers[i])
                i = i+1
                task.wait(spamI)
            end
        end)
        Notify("Prayer","Loop All Started",2)
    else
        if LPT then task.cancel(LPT) LPT=nil end
        Notify("Prayer","Loop All Stopped",2)
    end
end})
local LSA, LST = false, nil
PL:AddToggle("LoopSelectedPrayerToggle",{Text="Loop Selected Prayer",Default=false,Callback=function(v)
    LSA = v
    if v then
        if prayIdx<=0 then Notify("Error","No prayer selected",2) Toggles.LoopSelectedPrayerToggle:SetValue(false) return end
        LST = task.spawn(function()
            while LSA do sendChat(prayers[prayIdx]) task.wait(spamI) end
        end)
        Notify("Prayer","Loop Selected Started",2)
    else
        if LST then task.cancel(LST) LST=nil end
        Notify("Prayer","Loop Selected Stopped",2)
    end
end})

Players.PlayerAdded:Connect(function() task.wait(0.5) if Options.TargetDropdown then Options.TargetDropdown:SetValues(GetPlayerList()) end end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) if Options.TargetDropdown then Options.TargetDropdown:SetValues(GetPlayerList()) end end)

Notify("Singularity hub premium","Loading complete",3)

Library:OnUnload(function()
    pcall(AllkickStop) pcall(TlagStop) pcall(LKAStop) pcall(LKSStop) pcall(LKA2Stop) pcall(LKS2Stop) pcall(LKA3Stop) pcall(LKS3Stop)
    pcall(SpamKStop) pcall(DriftStop) pcall(StopTP)
    pcall(stopNOF) pcall(stopAAR) pcall(stopSSF) pcall(stopPAL)
    pcall(function() BK.isRunning=false BK.isKillAura=false BK.isSelectedKill=false end)
    pcall(function()
        if BK.killAuraConnection then BK.killAuraConnection:Disconnect() end
        if BK.selectedKillConn then task.cancel(BK.selectedKillConn) end
    end)
    if _G.GodMode and _G.GodMode.isRunning then pcall(stopGodMode) end
    if WM and WM.isActive then pcall(CleanupWings) end
    if _G.lineLagTask then pcall(task.cancel, _G.lineLagTask) end
    if _G.packetLagTask then pcall(task.cancel, _G.packetLagTask) end
    if _G.loopBlobKickSpamTask then pcall(task.cancel, _G.loopBlobKickSpamTask) end
    _G.kickLoopEnabled = false
    print("[Singularity hub premium] Unloaded!")
end)
