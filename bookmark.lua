local mp = require("mp")
local utils = require("mp.utils")

--docs: https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst
--      https://mpv.io/manual/stable/
--      https://mpv.io/manual/stable/#lua-scripting
--      https://mpv.io/manual/stable/#command-interface-video-speed-correction
--          property list

--Get timestamp
local function getTimestamp(pos)
    --local pos = mp.get_property_number("time-pos")
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
    mp.osd_message(getTimestamp(), 3)
end

local function lessThan(a, b)
    if a == 0 then
      -- a is either equal to b, or it has to go at the end.
      return false
    elseif b == 0 then
      -- b has to go at the end.
      return true
    else
      -- Neither argument is 0.
      return a < b
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
    end
    --timestamps[i] = tonumber(string.gsub(line, "\n", ""))
    f = io.open(fn, "w")
    if f then
        if #tstamps > 0 then
            table.sort(tstamps, lessThan)
        end

        -- TODO: return the sorted set, for now just return sorted list of 
        --      bookmarks


        for _, times in ipairs(tstamps) do
            f:write(times, "\n")
        end

        f:close()
    end
    --io.output(f)
    --io.write("test1")

    --for j = 0, #timestamps do
    --    io.write(string.format("%s", tostring(timestamps[j]), "\n"))
    --end
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

local function test()
    --jumpToPos(3000)
    --mp.osd_message(mp.get_property("filename/no-ext") .. ".ts", 3)
    saveTimestamp()
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