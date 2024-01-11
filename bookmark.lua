local mp = require("mp")
local utils = require("mp.utils")

--docs:https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst

--Get timestamp
local function getTimestamp()
    local pos = mp.get_property_number("time-pos")
    if pos <= 0 then
        return "00:00:00.000";
    else
        local hours = string.format("%02.f", math.floor(pos/3600))
        local mins = string.format("%02.f", math.floor(pos/60 - (hours*60)))
        local secs = string.format("%02.f", math.floor(pos - hours*60*60 - mins*60))
        local msecs = string.format("%03.f", pos*1000 - hours*60*60*1000 - mins*60*1000 - secs*1000)
        local result = hours..":"..mins..":"..secs.."."..msecs
    end
    return result
end
--Save to to a file

--Jump between timestamps


--method to delete bookmarks, delete all

-- specify location, video directory by default

--OSD?

local function printTimestamp()
    mp.osd_message(getTimestamp, 3)
    --mp.osd_message("test", 3)
end

--pick an unobtrusive keybind for bookmarking

--pick unobstrusive keybind for jumping

--mp.add_key_binding("C", "create_chapter", create_chapter, {repeatable=true})
--mp.add_key_binding("B", "write_chapter", write_chapter, {repeatable=false})
mp.add_key_binding("=", "printTimestamp", printTimestamp, {repeatable=true})