local mp = require("mp")
local utils = require("mp.utils")

--docs:https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst

--Get timestamp
local function getTimestamp()
    local pos = mp.get_property_number("time-pos")
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


--Jump between timestamps
local function jumpToPos(pos)
    mp.set_property_number("time-pos", pos)
end

--Save to to a file

--method to delete bookmarks, delete all

-- specify location, video directory by default

--OSD?

local function printTimestamp()
    mp.osd_message(getTimestamp(), 3)
end

local function test()
    jumpToPos(3000)
end

--pick an unobtrusive keybind for bookmarking

--pick unobstrusive keybind for jumping

--mp.add_key_binding("C", "create_chapter", create_chapter, {repeatable=true})
--mp.add_key_binding("B", "write_chapter", write_chapter, {repeatable=false})
mp.add_key_binding("=", "test", test, {repeatable=true})