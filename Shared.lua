-- ============================================================
-- Shared.lua - Library / Window / Tabs / 共通変数
-- ============================================================
_G.Singularity = _G.Singularity or {}
local S = _G.Singularity

if S.Loaded then return end
S.Loaded = true

-- ---------- Library 読み込み ----------
S.Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
if not S.Library then
    warn("[Singularity] Library load failed.")
    return
end

-- ---------- サービス参照（全ファイル共有） ----------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

S.Players = Players
S.Workspace = Workspace
S.RS = RS
S.RunService = RunService
S.UIS = UIS
S.Debris = Debris
S.LocalPlayer = Players.LocalPlayer
S.Cam = Workspace.CurrentCamera

-- ---------- Remotes（全ファイル共有） ----------
local GE = RS:FindFirstChild("GrabEvents")
local MT = RS:FindFirstChild("MenuToys")
local CE = RS:FindFirstChild("CharacterEvents")

S.SetNet      = GE and GE:FindFirstChild("SetNetworkOwner")
S.CGL         = GE and GE:FindFirstChild("CreateGrabLine")
S.DGL         = GE and GE:FindFirstChild("DestroyGrabLine")
S.EGL         = GE and GE:FindFirstChild("ExtendGrabLine")
S.SpawnToy    = MT and MT:FindFirstChild("SpawnToyRemoteFunction")
S.DestroyToy  = MT and MT:FindFirstChild("DestroyToy")
S.Ragdoll     = CE and CE:FindFirstChild("RagdollRemote")
S.Struggle    = CE and CE:FindFirstChild("Struggle")

-- ---------- UI参照 ----------
S.Toggles = nil  -- 後で Library.Toggles を代入

-- ---------- 共通変数 ----------
S.selectedTargetName = nil
S.Notify = function(t, d, tm) S.Library:Notify({Title = t, Description = d, Time = tm or 3}) end

-- ---------- 共通ユーティリティ ----------
function S.GetPlayerList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= S.LocalPlayer then
            table.insert(t, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    table.sort(t, function(a, b) return a:lower() < b:lower() end)
    return t
end

function S.User(s) return s and s:match("%(@(.+)%)$") end

function S.MyHRP()
    local c = S.LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

function S.MyHum()
    local c = S.LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

function S.PPHRP(player)
    if not player then return nil end
    local c = player.Character
    if c and c.Parent == Workspace then
        local h = c:FindFirstChild("HumanoidRootPart")
        if h then return h end
    end
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m.Name == player.Name then
            local h = m:FindFirstChild("HumanoidRootPart")
            if h then return h end
        end
    end
end

function S.FWD(p, n, t) return p:FindFirstChild(n) or p:WaitForChild(n, t or 5) end

function S.firePrompt(pr)
    if not pr then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(pr)
        else
            pr:InputHoldBegin()
            task.wait(0.05)
            pr:InputHoldEnd()
        end
    end)
end

-- ---------- 汎用タスク管理 ----------
S._tk = S._tk or {}
function S.reg(t)
    if t then table.insert(S._tk, t); return t end
end
function S.cancelAll()
    for _, t in ipairs(S._tk) do pcall(task.cancel, t) end
    S._tk = {}
end

-- ---------- 汎用ラグエンジン ----------
function S.makeLag(rate)
    return function()
        local conn, fc = nil, 0
        local bpf = math.floor(rate / 60)
        local rem = rate - bpf * 60
        local function start()
            if conn then conn:Disconnect() end
            conn = RunService.Heartbeat:Connect(function()
                fc = fc + 1
                local sc = bpf + (fc <= rem and 1 or 0)
                local sp = Workspace:FindFirstChild("SpawnLocation")
                        or Workspace:FindFirstChild("Spawn")
                        or S.MyHRP()
                if sp then
                    for _ = 1, sc do
                        pcall(function()
                            if S.CGL then
                                S.CGL:FireServer(sp, CFrame.new(
                                    math.random(-2010000000, 2000200000), 0,
                                    math.random(-2008100000, 2000200000)))
                            end
                        end)
                    end
                end
            end)
        end
        local function stop() if conn then conn:Disconnect(); conn = nil end end
        return start, stop
    end
end

-- ---------- UI Window + Tabs ----------
S.Window = S.Library:CreateWindow({
    Title = "Singularity hub premium",
    Footer = "Kick + Kill + Anti + Lag + Ragdoll + FTAP Defense",
    Icon = 95816097006868,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

S.Tabs = {
    Main     = S.Window:AddTab("Main", "user"),
    Kick     = S.Window:AddTab("Kick", "swords"),
    Kill     = S.Window:AddTab("Kill", "skull"),
    LagRag   = S.Window:AddTab("Lag & Ragdoll", "zap"),
    Anti     = S.Window:AddTab("Anti", "shield"),
    Gucci    = S.Window:AddTab("Gucci Break", "package"),
    Plot     = S.Window:AddTab("Plot", "hammer"),
    Tsunami  = S.Window:AddTab("Tsunami", "droplet"),
    Teleport = S.Window:AddTab("Teleport", "map-pin"),
    ToyMod   = S.Window:AddTab("Toy Mod", "wrench"),
}
S.Toggles = S.Library.Toggles

-- ---------- Main タブ（ターゲット選択） ----------
local TG = S.Tabs.Main:AddLeftGroupbox("Target", "target")
TG:AddDropdown("TargetDropdown", {
    Values = S.GetPlayerList(),
    Default = "",
    Text = "Select Target",
    Searchable = true,
    Callback = function(s)
        if s and s ~= "" then
            local u = S.User(s)
            if u then S.selectedTargetName = u; S.Notify("Target Set", u, 2) end
        end
    end
})
TG:AddButton({
    Text = "Refresh Player List",
    Func = function()
        if S.Library.Options.TargetDropdown then
            S.Library.Options.TargetDropdown:SetValues(S.GetPlayerList())
        end
    end
})

-- ---------- プレイヤーリスト自動更新 ----------
S.Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if S.Library.Options.TargetDropdown then
        S.Library.Options.TargetDropdown:SetValues(S.GetPlayerList())
    end
end)
S.Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    if S.Library.Options.TargetDropdown then
        S.Library.Options.TargetDropdown:SetValues(S.GetPlayerList())
    end
end)

S.Notify("Shared", "Loaded", 2)
