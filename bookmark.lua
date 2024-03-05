local mp = require("mp")
local utils = require("mp.utils")

--docs: https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst
--      https://mpv.io/manual/stable/
--      https://mpv.io/manual/stable/#lua-scripting
--      https://mpv.io/manual/stable/#command-interface-video-speed-correction
--          property list

--Get timestamp
local function getTimestamp(pos)
    --formats a given time in seconds
    local result = ""
    if pos <= 0 then
        return "00:00:00.0000";
    else
        local h = string.format("%02.f", math.floor(pos/3600))
        local m = string.format("%02.f", math.floor(pos/60 - (h*60)))
        local s = string.format("%02.f", math.floor(pos - h*60*60 - m*60))
        local ms = string.format("%04.f", pos*1000 - h*60*60*1000 - m*60*1000 - s*1000)
        result = h..":"..m..":"..s.."."..ms
    end
    return result
end

local function printTimestamp()
    --prints the current timestamp in a readable format
    mp.osd_message(getTimestamp(), 3)
end

local function lessThan(a, b)
    --comparison for sorting timestamps
    return a < b
end

local function sortTimestamps(tstamps)
    --tstamps an array of timestamps
    local fn = mp.get_property("filename/no-ext") .. ".bookmark"
    local f = io.open(fn, "w")
    if f then
        if #tstamps > 0 then
            table.sort(tstamps, lessThan)
        end

        -- TODO: return the sorted set, for now just return sorted list of 
        --      bookmarks

        --write to file
        for _, times in ipairs(tstamps) do
            f:write(times, "\n")
        end
        f:close()
    end
end

local function updateTimestamps(tstamps)
    --save timestamps back to file
    local fn = mp.get_property("filename/no-ext") .. ".bookmark"
    local f = io.open(fn, "w")
    if f then
        --if #tstamps > 0 then
        --    table.sort(tstamps, lessThan)
       -- end
        --write to file
        for _, times in ipairs(tstamps) do
            f:write(times, "\n")
        end
        f:close()
    end
end

local function loadTimestamps()
    local fn = mp.get_property("filename/no-ext") .. ".bookmark"
    local f = io.open(fn, "r")
    local tstamps = {}

    if f == nil then
        mp.osd_message("Load error", 3)
    else
        
        for line in f:lines() do
            --table.insert(tstamps, tonumber(string.gsub(line, "\n", "")))
            table.insert(tstamps, tonumber(line))
            --mp.osd_message(tostring(line), 3)    -- test
        end
        f:close()

        updateTimestamps(tstamps)
        return tstamps
    end
end



local function saveTimestamp()
    --save new timestamps to the bookmark file
    --appends onto the end
    local fn = mp.get_property("filename/no-ext") .. ".bookmark"
    local f = io.open(fn, "a")

    if f then
        local pos = mp.get_property_number("time-pos")
        --f:write(string.format("%s", tostring(pos)), "\n")
        f:write(pos, "\n")
        f:close()
        mp.osd_message("Export file to: "..fn, 3)
    end
end

local function deleteTimestamp(ts)
    --delete the timestamp from the given array of timestamps
    local tstamps = loadTimestamps()
    for i = 1, #tstamps do
        if tstamps[i] == ts then
            table.remove(tstamps, i)
        end
    end
    --sorts it back into the file
    sortTimestamps(tstamps)
end

local function test()
    --jumpToPos(3000)
    --mp.osd_message(mp.get_property("filename/no-ext") .. ".ts", 3)
    --saveTimestamp()
    deleteTimestamp(766.453)
end


--Jump between timestamps
local function jumpToPos(pos)
    mp.set_property_number("time-pos", pos)
end

--TODO: delete bookmark

--TODO: delete all bookmarks

--TODO: OSD

--TODO: default save location, video directory by default

--TODO: find good keybinds


--mp.add_key_binding("C", "create_chapter", create_chapter, {repeatable=true})
--mp.add_key_binding("B", "write_chapter", write_chapter, {repeatable=false})
mp.add_key_binding("=", "test", test, {repeatable=true})
mp.add_key_binding("-", "loadTimestamps", loadTimestamps, {repeatable=true})