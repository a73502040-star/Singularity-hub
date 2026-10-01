-- ============================================================
-- Unload.lua - OnUnload 処理
-- ============================================================
local S = _G.Singularity
if not S or not S.Library then
    warn("[Singularity] Shared.lua not loaded")
    return
end

local Library = S.Library
local Players = S.Players
local Workspace = S.Workspace
local LocalPlayer = S.LocalPlayer

Library:OnUnload(function()
    -- 全タスク停止
    pcall(S.cancelAll)

    -- 各Stop関数を呼ぶ（存在する場合のみ）
    for _, fn in ipairs({
        S.AllkickStop, S.TlagStop, S.LKAStop, S.LKSStop,
        S.LKA2Stop, S.LKS2Stop, S.LKA3Stop, S.LKS3Stop,
        S.SpamKStop, S.DriftStop, S.StopTP,
    }) do
        if fn then pcall(fn) end
    end

    -- Anti系の停止
    if S._AntiStops then
        for _, fn in ipairs(S._AntiStops) do
            if fn then pcall(fn) end
        end
    end

    -- Defense系
    if S._SAV then pcall(S._SAV, false) end
    if S._SABS then pcall(S._SABS, false) end
    if S._SABK then pcall(S._SABK, false) end
    if S._SERB then pcall(S._SERB, false) end
    if S._SENRD then pcall(S._SENRD, false) end

    -- BK 停止
    if S.BK then
        S.BK.isRunning = false
        S.BK.isKillAura = false
        S.BK.isSelectedKill = false
        if S.BK.killAuraConnection then
            S.BK.killAuraConnection:Disconnect()
            S.BK.killAuraConnection = nil
        end
        if S.BK.selectedKillConn then
            pcall(task.cancel, S.BK.selectedKillConn)
            S.BK.selectedKillConn = nil
        end
    end

    -- KAKT 停止（Kick All）
    if S.KAKT then pcall(S.KAKT) end

    -- God Mode 停止
    if _G.GodMode and _G.GodMode.isRunning then
        _G.GodMode.isRunning = false
        _G.GodMode.loopCoroutine = nil
        local c = LocalPlayer.Character
        if c and _G.GodMode.lastOriginalCFrame then
            local r = c:FindFirstChild("HumanoidRootPart")
            if r then r.CFrame = _G.GodMode.lastOriginalCFrame end
        end
        Workspace.FallenPartsDestroyHeight = _G.GodMode.originalFallenHeight or -100
    end

    -- Wings 停止
    if S._CleanupWings then pcall(S._CleanupWings) end

    -- ループフラグ停止
    if S._LGA then pcall(S._LGA) end
    if S._LPA then pcall(S._LPA) end
    if S._LSA then pcall(S._LSA) end

    -- ループ系タスク停止
    if _G.lineLagTask then pcall(task.cancel, _G.lineLagTask); _G.lineLagTask = nil end
    if _G.packetLagTask then pcall(task.cancel, _G.packetLagTask); _G.packetLagTask = nil end
    if _G.loopBlobKickSpamTask then pcall(task.cancel, _G.loopBlobKickSpamTask); _G.loopBlobKickSpamTask = nil end
    if _G.snowballRagdollTask then pcall(task.cancel, _G.snowballRagdollTask); _G.snowballRagdollTask = nil end
    if _G.antiBananaSitTask then pcall(task.cancel, _G.antiBananaSitTask); _G.antiBananaSitTask = nil end
    if _G.antiBlobmanKillTask then pcall(task.cancel, _G.antiBlobmanKillTask); _G.antiBlobmanKillTask = nil end
    if _G.antiInputLagTask then pcall(task.cancel, _G.antiInputLagTask); _G.antiInputLagTask = nil end
    if _G.removeAntiInputTask then pcall(task.cancel, _G.removeAntiInputTask); _G.removeAntiInputTask = nil end

    -- フラグリセット
    _G.loopBlobKickSpamActive = false
    _G.loopKill1Active = false
    _G.loopKill2Active = false
    _G.kickLoopEnabled = false
    _G.snowballRagdollActive = false
    _G.antiBananaSitActive = false
    _G.antiBlobmanKillActive = false
    _G.antiRagBlobActive = false
    _G.antiAntiKickActive = false
    _G.removeAntiKickAuraActive = false
    _G.antiAntiLagEnabled = false
    _G.autoantilag = false
    _G.lineLagActive = false
    _G.packetLagActive = false
    _G.AntiGrabNRDEnabled = false

    print("[Singularity hub premium] Unloaded!")
end)
