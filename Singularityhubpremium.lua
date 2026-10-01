-- ============================================================
-- Singularity hub premium (Entry Point / Main)
-- ============================================================
local baseURL = "https://raw.githubusercontent.com/a73502040-star/Singularity-hub/refs/heads/main/"

-- 読み込む順序が重要（Shared → 各機能 → Unload）
local files = {
    "Shared.lua",
    "Kick.lua",
    "Kill.lua",
    "Anti.lua",
    "Utility.lua",
    "Unload.lua",
}

local loadedCount = 0
local failedFiles = {}

for _, f in ipairs(files) do
    local ok, src = pcall(function()
        return game:HttpGet(baseURL .. f)
    end)

    if ok and src and #src > 0 then
        local fn, compileErr = loadstring(src)
        if fn then
            local runOk, runErr = pcall(fn)
            if runOk then
                loadedCount = loadedCount + 1
            else
                warn("[Singularity] Runtime error in " .. f .. ": " .. tostring(runErr))
                table.insert(failedFiles, f .. " (runtime)")
            end
        else
            warn("[Singularity] Compile error in " .. f .. ": " .. tostring(compileErr))
            table.insert(failedFiles, f .. " (compile)")
        end
    else
        warn("[Singularity] Failed to fetch: " .. f)
        table.insert(failedFiles, f .. " (fetch)")
    end
end

-- 起動完了通知
local S = _G.Singularity
if S and S.Notify then
    if #failedFiles == 0 then
        S.Notify("Singularity", "Loaded (" .. loadedCount .. "/" .. #files .. ")", 3)
    else
        S.Notify("Singularity", "Partial load (" .. loadedCount .. "/" .. #files .. ")", 5)
    end
end

print("[Singularity] Loaded " .. loadedCount .. "/" .. #files .. " modules")
if #failedFiles > 0 then
    for _, f in ipairs(failedFiles) do
        print("[Singularity] FAILED: " .. f)
    end
end
