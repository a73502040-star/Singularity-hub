-- ============================================================
-- Utility.lua - Gucci / Plot / Tsunami / Teleport / ToyMod (Wing+Prayer)
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
local firePrompt = S.firePrompt

local SetNet = S.SetNet
local CGL = S.CGL
local DGL = S.DGL
local SpawnToy = S.SpawnToy
local DestroyToy = S.DestroyToy

-- ============================================================
-- Gucci Break
-- ============================================================
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
    for _ = 1, 20 do
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
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local o = r.CFrame
    for _, obj in pairs(folder:GetDescendants()) do
        if obj.Name == "CreatureBlobman" and obj:IsA("Model") then
            sitOnce(obj)
        end
    end
    r.CFrame = o
end

local function AllGucciBreak() sitAll(workspace) end

local function TargetGucciBreak(n)
    local f = workspace:FindFirstChild(n .. "SpawnedInToys")
    if f then sitAll(f)
    else Notify("Gucci Break", "Player toy folder not found", 2) end
end

local GucciL = Tabs.Gucci:AddLeftGroupbox("Gucci Break", "zap")
GucciL:AddButton({ Text = "All Gucci Break", Func = function()
    if AllGucciBreak then AllGucciBreak() end
    Notify("Gucci Break", "All executed", 2)
end })
GucciL:AddButton({ Text = "Target Gucci Break", Func = function()
    if S.selectedTargetName then
        if TargetGucciBreak then TargetGucciBreak(S.selectedTargetName) end
        Notify("Gucci Break", S.selectedTargetName .. " executed", 2)
    else
        Notify("Error", "No target selected", 2)
    end
end })

local LGA, LGT = false, nil
GucciL:AddToggle("LoopAllGucciBreakToggle", {
    Text = "Loop All Gucci Break", Default = false,
    Callback = function(v)
        LGA = v
        if v then
            LGT = task.spawn(function()
                while LGA do
                    if AllGucciBreak then AllGucciBreak() end
                    task.wait(1)
                end
            end)
            Notify("Gucci Break", "Loop Started", 2)
        else
            if LGT then task.cancel(LGT); LGT = nil end
            Notify("Gucci Break", "Loop Stopped", 2)
        end
    end
})
S._LGA = function() LGA = false end

-- ============================================================
-- Plot Barrier
-- ============================================================
local PlotL = Tabs.Plot:AddLeftGroupbox("Plot Barrier", "hammer")
PlotL:AddButton({ Text = "Break Barrier (Once)", Func = function()
    local pl = Workspace:FindFirstChild("Plots")
    if not pl then Notify("Barrier", "No Plots", 3); return end
    local found = false
    for _, p in ipairs(pl:GetChildren()) do
        if p:IsA("Model") and p.Name:match("^Plot%d+$") then
            local b = p:FindFirstChild("Barrier")
            if b then
                local pb = b:FindFirstChild("PlotBarrier")
                if pb and pb:IsA("BasePart") then
                    local s = p:FindFirstChild("PlotSign")
                    local ow = s and s:FindFirstChild("ThisPlotsOwners")
                    local mine = false
                    if ow then
                        for _, o in ipairs(ow:GetChildren()) do
                            if o:IsA("ValueBase") and o.Value == LocalPlayer.Name then
                                mine = true; break
                            end
                        end
                    end
                    if not mine then
                        pcall(function()
                            if SetNet then SetNet:FireServer(pb, pb.CFrame) end
                            pb.Anchored = false
                            pb.CanCollide = false
                            pb.Transparency = 1
                            pb.CFrame = CFrame.new(-272.2197265625, -7.350403785705566, 475.0108947753906)
                        end)
                        found = true
                    end
                end
            end
        end
    end
    if found then Notify("Barrier", "Done", 2)
    else Notify("Barrier", "No enemy plot", 2) end
end })

-- ============================================================
-- Tsunami
-- ============================================================
local TsL = Tabs.Tsunami:AddLeftGroupbox("Tsunami", "droplet")
TsL:AddButton({ Text = "Run Tsunami", Func = function()
    local c = LocalPlayer.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local org = r.Position + Vector3.new(0, 500, 0)
    task.spawn(function()
        for i = 1, 60 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(math.random(20, 40), math.random(50, 100), math.random(20, 40))
            part.Position = Vector3.new(
                org.X + math.random(-50, 50),
                org.Y + math.random(0, 200),
                org.Z + math.random(-50, 50))
            part.Anchored = false
            part.CanCollide = true
            part.Material = Enum.Material.Water
            part.Color = Color3.fromRGB(0, 120, 200)
            part.Transparency = 0.3
            part.Parent = Workspace
            if SetNet then pcall(function() SetNet:FireServer(part, part.CFrame) end) end
            part.AssemblyLinearVelocity = Vector3.new(0, -200, 0)
            S.Debris:AddItem(part, 10)
            task.wait(0.05)
        end
        Notify("Tsunami", "Wave deployed", 3)
    end)
end })
TsL:AddButton({ Text = "Cleanup Tsunami", Func = function()
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("BasePart") and o.Material == Enum.Material.Water
        and o.Transparency == 0.3 then
            pcall(function() o:Destroy() end)
        end
    end
    Notify("Tsunami", "Cleanup complete", 2)
end })

-- ============================================================
-- Teleport
-- ============================================================
S.TPState = S.TPState or { TargetName = nil, OffsetY = 3, Loop = false, LoopTask = nil }

local function TPTo(name, offY)
    if not name then return end
    local tg = Players:FindFirstChild(name); if not tg then return end
    local th = S.PPHRP(tg); if not th then return end
    local mh = MyHRP(); if not mh then return end
    mh.CFrame = th.CFrame + Vector3.new(0, offY or 3, 0)
    mh.AssemblyLinearVelocity = Vector3.zero
    mh.AssemblyAngularVelocity = Vector3.zero
end

local function StopTP()
    if S.TPState.LoopTask then
        pcall(task.cancel, S.TPState.LoopTask)
        S.TPState.LoopTask = nil
    end
end

local function StartTP()
    StopTP()
    if not S.TPState.TargetName then return end
    S.TPState.LoopTask = task.spawn(function()
        while S.TPState.Loop do
            TPTo(S.TPState.TargetName, S.TPState.OffsetY)
            RunService.Heartbeat:Wait()
        end
        S.TPState.LoopTask = nil
    end)
end

S.StopTP = StopTP

local TPL = Tabs.Teleport:AddLeftGroupbox("Player Teleport", "map-pin")
TPL:AddSlider("TPOffsetY", {
    Text = "Y Offset", Default = 3, Min = -20, Max = 50, Rounding = 0, Suffix = " studs",
    Callback = function(v)
        S.TPState.OffsetY = v
        if S.TPState.Loop then StartTP() end
    end
})
TPL:AddButton({ Text = "Teleport Once", Func = function()
    local n = S.selectedTargetName or S.TPState.TargetName
    if n then TPTo(n, S.TPState.OffsetY)
    else Notify("Error", "No target selected", 2) end
end })
TPL:AddToggle("TPLoopToggle", {
    Text = "Loop Teleport", Default = false,
    Callback = function(v)
        S.TPState.Loop = v
        if v then
            S.TPState.TargetName = S.selectedTargetName
            if not S.TPState.TargetName then
                Notify("Error", "No target selected", 3)
                S.Toggles.TPLoopToggle:SetValue(false)
                return
            end
            StartTP()
            Notify("Start", "Loop Teleport", 2)
        else
            StopTP()
            Notify("Stop", "Loop Teleport", 2)
        end
    end
})

-- ============================================================
-- Wing Master
-- ============================================================
local WM = {
    isActive = false,
    SelectedItem = "TetracubeI",
    SearchMode = "My Toys",
    WingSpeed = 2,
    WingAngle = 30,
    WingLength = 5,
    TimeCounter = 0,
    Wings = {},
    Offsets = { CFrame.new(-4.125, 0, 1), CFrame.new(4.125, 0, 1) },
    RunConnection = nil,
}

local function CleanupWings()
    for _, w in pairs(WM.Wings) do
        if w.Handle and w.Handle.Parent then w.Handle:Destroy() end
        for _, s in pairs(w.Segments or {}) do
            if s.Part and s.Part.Parent then s.Part:Destroy() end
        end
    end
    WM.Wings = {}
    if WM.RunConnection then
        WM.RunConnection:Disconnect()
        WM.RunConnection = nil
    end
end

local function GetToyFolders()
    local f = {}
    if WM.SearchMode == "My Toys" or WM.SearchMode == "All Toys" then
        local m = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        if m then table.insert(f, m) end
    end
    if WM.SearchMode == "Plot Toys" or WM.SearchMode == "All Toys" then
        local pf = workspace:FindFirstChild("Plots")
        if pf then
            for i = 1, 5 do
                local p = pf:FindFirstChild("Plot" .. i)
                if p then
                    local of = p:FindFirstChild("PlotSign") and p.PlotSign:FindFirstChild("ThisPlotsOwners")
                    if of then
                        for _, v in ipairs(of:GetChildren()) do
                            if v:IsA("ValueBase") and v.Value == LocalPlayer.Name then
                                local pif = workspace:FindFirstChild("PlotItems")
                                if pif and pif:FindFirstChild(p.Name) then
                                    table.insert(f, pif:FindFirstChild(p.Name))
                                end
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
    bp.P = 15000; bp.D = 200
    bp.MaxForce = Vector3.new(1, 1, 1) * 1e10
    bp.Parent = p
    bg.P = 15000; bg.D = 200
    bg.MaxTorque = Vector3.new(1, 1, 1) * 1e10
    bg.Parent = p
    return bg, bp
end

local function BuildWings()
    CleanupWings()
    local folders = GetToyFolders()
    local all = {}
    for _, f in ipairs(folders) do
        for _, x in ipairs(f:GetDescendants()) do
            if x:IsA("Model") and x.Name == WM.SelectedItem then
                table.insert(all, x)
            end
        end
    end
    if #all == 0 then
        Notify("Wing Master", "Target item not found", 3)
        return false
    end
    for i = 1, 2 do
        local segs = {}
        for _ = 1, WM.WingLength do
            local p = Instance.new("Part")
            p.CanCollide = false; p.Anchored = true; p.Transparency = 1
            p.Size = Vector3.new(4, 1, 4)
            p.Parent = workspace
            segs[#segs + 1] = { Part = p }
        end
        local h = Instance.new("Part")
        h.CanCollide = false; h.Anchored = true; h.Transparency = 1
        h.Size = Vector3.new(4, 1, 4)
        h.Parent = workspace
        table.insert(WM.Wings, { Handle = h, Segments = segs, Sync = {}, Reserved = nil })
    end
    for i, v in ipairs(all) do
        local side = (i <= #all / 2) and 1 or 2
        local pal = v:FindFirstChild("SoundPart") or v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
        if pal then
            for _, ch in pairs(v:GetChildren()) do
                if ch:IsA("BasePart") then ch.CanCollide = false end
            end
            local bg, bp = SetupPhysics(pal)
            if not WM.Wings[side].Reserved then
                WM.Wings[side].Reserved = { BG = bg, BP = bp }
            else
                table.insert(WM.Wings[side].Sync, { BG = bg, BP = bp })
            end
        end
    end
    return true
end

local function StartWingAnim()
    if WM.RunConnection then WM.RunConnection:Disconnect() end
    WM.RunConnection = RunService.RenderStepped:Connect(function(dt)
        if not WM.isActive or #WM.Wings == 0 then return end
        local C = LocalPlayer.Character
        if not C then return end
        local T = C:FindFirstChild("Torso")
        local HR = C:FindFirstChild("HumanoidRootPart")
        if not T or not HR then return end
        WM.TimeCounter = WM.TimeCounter + dt * (WM.WingSpeed + HR.Velocity.Magnitude / 40)
        for i, w in ipairs(WM.Wings) do
            local dir = (i == 1) and 1 or -1
            local flap = math.sin(WM.TimeCounter) * math.rad(WM.WingAngle + HR.Velocity.Magnitude / 4) * dir
            w.Handle.CFrame = T.CFrame * WM.Offsets[i] * CFrame.Angles(0, 0, flap)
            if w.Reserved then
                w.Reserved.BP.Position = w.Handle.Position
                w.Reserved.BG.CFrame = w.Handle.CFrame * CFrame.Angles(math.rad(90), 0, math.rad(90))
            end
            for idx, seg in ipairs(w.Segments) do
                local tf = (idx == 1) and w.Handle.CFrame or w.Segments[idx - 1].Part.CFrame
                seg.Part.CFrame = seg.Part.CFrame:Lerp(tf * WM.Offsets[i], 0.5)
                if w.Sync[idx] then
                    w.Sync[idx].BP.Position = seg.Part.Position
                    w.Sync[idx].BG.CFrame = seg.Part.CFrame * CFrame.Angles(math.rad(90), 0, math.rad(90))
                end
            end
        end
    end)
end

local function ToggleWings(v)
    if v then
        if BuildWings() then
            WM.isActive = true
            StartWingAnim()
            Notify("Wing Master", "Enabled", 3)
        else
            WM.isActive = false
        end
    else
        WM.isActive = false
        CleanupWings()
        Notify("Wing Master", "Disabled", 3)
    end
end
S._CleanupWings = CleanupWings

LocalPlayer.CharacterAdded:Connect(function()
    if WM.isActive then
        task.defer(function()
            if WM.isActive then BuildWings() end
        end)
    end
end)

local WL = Tabs.ToyMod:AddLeftGroupbox("Wing Master", "activity")
WL:AddDropdown("WingItemDropdown", {
    Text = "Select Item",
    Values = {"TetracubeI", "FireworkSparkler", "PoopPile", "BallSnowball", "CreatureBlobman"},
    Default = 1,
    Callback = function(v) WM.SelectedItem = v; if WM.isActive then BuildWings() end end
})
WL:AddDropdown("WingSearchDropdown", {
    Text = "Search Range",
    Values = {"My Toys", "Plot Toys", "All Toys"},
    Default = 1,
    Callback = function(v) WM.SearchMode = v; if WM.isActive then BuildWings() end end
})
WL:AddSlider("WingSpeedSlider", { Text = "Wing Speed", Default = 2, Min = 1, Max = 10, Rounding = 1,
    Callback = function(v) WM.WingSpeed = v end})
WL:AddSlider("WingAngleSlider", { Text = "Wing Angle", Default = 30, Min = 10, Max = 90, Rounding = 0, Suffix = "°",
    Callback = function(v) WM.WingAngle = v end})
WL:AddSlider("WingLengthSlider", { Text = "Wing Length", Default = 5, Min = 3, Max = 10, Rounding = 0,
    Callback = function(v) WM.WingLength = v; if WM.isActive then BuildWings() end end})
WL:AddButton({ Text = "Rebuild Wings", Func = function()
    if WM.isActive then BuildWings(); Notify("Wing Master", "Rebuilt", 2)
    else Notify("Wing Master", "Enable first", 2) end
end})
WL:AddToggle("WingMasterToggle", { Text = "Enable Wings System", Default = false, Callback = ToggleWings })

-- ============================================================
-- Prayer
-- ============================================================
local prayers = {
    "Singularity hub on top", "Singularity hub is the best", "Singularity hub x Gucci anti-grab",
    "God mode activated", "Kick all blobman", "Wing master system", "Arkadia blob spam kick",
    "Singularity project", "Gucci break system", "Pray to Singularity", "Singularity hub - Reign Supreme"
}

local function sendChat(msg)
    local sent = false
    local ce = RS:FindFirstChild("DefaultChatSystemChatEvents")
    if ce then
        local sm = ce:FindFirstChild("SayMessageRequest")
        if sm then pcall(function() sm:FireServer(msg, "All"); sent = true end) end
    end
    if not sent then
        local TCS = game:GetService("TextChatService")
        if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch
            for _ = 1, 10 do
                if TCS.TextChannels then ch = TCS.TextChannels:FindFirstChild("RBXGeneral") end
                if ch then break end
                task.wait(0.1)
            end
            if ch then pcall(ch.SendAsync, ch, msg); sent = true end
        end
    end
end

local PL = Tabs.ToyMod:AddRightGroupbox("Prayer", "heart")
local prayIdx = 0
PL:AddDropdown("PrayerSelect", {
    Text = "Select Prayer",
    Values = {
        "1. Singularity hub on top", "2. Singularity hub is the best", "3. Singularity hub x Gucci anti-grab",
        "4. God mode activated", "5. Kick all blobman", "6. Wing master system", "7. Arkadia blob spam kick",
        "8. Singularity project", "9. Gucci break system", "10. Pray to Singularity", "11. Singularity hub - Reign Supreme"
    },
    Default = 1,
    Callback = function(v) prayIdx = tonumber(v:match("^(%d+)")) end
})
local spamC, spamI = 5, 1.0
PL:AddSlider("PrayerSpamCount", { Text = "Spam Count", Default = 5, Min = 1, Max = 50, Rounding = 0,
    Callback = function(v) spamC = v end})
PL:AddSlider("PrayerSpamInterval", { Text = "Interval (s)", Default = 1.0, Min = 0.1, Max = 10.0, Rounding = 1, Suffix = "s",
    Callback = function(v) spamI = v end})
PL:AddButton({ Text = "Spam Current Prayer", Func = function()
    if prayIdx <= 0 then Notify("Error", "No prayer selected", 2); return end
    task.spawn(function()
        for _ = 1, spamC do sendChat(prayers[prayIdx]); task.wait(0.3) end
        Notify("Prayer", "Spam complete", 2)
    end)
end})
PL:AddButton({ Text = "Send Once", Func = function()
    if prayIdx <= 0 then Notify("Error", "No prayer selected", 2); return end
    sendChat(prayers[prayIdx])
    Notify("Prayer", "Sent", 1)
end})

local LPA, LPT = false, nil
PL:AddToggle("LoopAllPrayersToggle", { Text = "Loop All Prayers", Default = false,
    Callback = function(v)
        LPA = v
        if v then
            LPT = task.spawn(function()
                local i = 1
                while LPA do
                    if i > #prayers then i = 1 end
                    sendChat(prayers[i])
                    i = i + 1
                    task.wait(spamI)
                end
            end)
            Notify("Prayer", "Loop All Started", 2)
        else
            if LPT then task.cancel(LPT); LPT = nil end
            Notify("Prayer", "Loop All Stopped", 2)
        end
    end})
S._LPA = function() LPA = false end

local LSA, LST = false, nil
PL:AddToggle("LoopSelectedPrayerToggle", { Text = "Loop Selected Prayer", Default = false,
    Callback = function(v)
        LSA = v
        if v then
            if prayIdx <= 0 then
                Notify("Error", "No prayer selected", 2)
                S.Toggles.LoopSelectedPrayerToggle:SetValue(false)
                return
            end
            LST = task.spawn(function()
                while LSA do
                    sendChat(prayers[prayIdx])
                    task.wait(spamI)
                end
            end)
            Notify("Prayer", "Loop Selected Started", 2)
        else
            if LST then task.cancel(LST); LST = nil end
            Notify("Prayer", "Loop Selected Stopped", 2)
        end
    end})
S._LSA = function() LSA = false end

Notify("Utility", "Loaded", 2)
