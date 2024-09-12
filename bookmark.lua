local mp = require("mp")
local utils = require("mp.utils")

--docs: https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst
--      https://mpv.io/manual/stable/
--      https://mpv.io/manual/stable/#lua-scripting
--      https://mpv.io/manual/stable/#command-interface-video-speed-correction
--          property list

--Get timestamp

Bookmarks = {}
CurrentBM = 0

local function getTimestamp(pos)
    --format a given time in seconds
    local result = ""

    if pos < 0 then
        pos = mp.get_property_number("time-pos")
    end

    if pos == 0 then
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



local function updateBookmarks()
    --save Bookmarks back to the file
    local fn = mp.get_property("filename/no-ext") .. ".bookmark"
    local f = io.open(fn, "w")
    if f then

        for _, times in ipairs(Bookmarks) do
            f:write(times, "\n")
        end
        f:close()
    end
end

local function lessThan(a, b)
    --comparison for sorting timestamps
    return a < b
end

local function loadBookmarks()
    --load bookmarks from file
    Bookmarks = {}
    local fn = mp.get_property("filename/no-ext") .. ".bookmark"
    local f = io.open(fn, "r")
    if f == nil then
        mp.osd_message("Load error", 3)
        return
    else
        
        --load then sort the timestamps to the global variable Bookmarks
        for line in f:lines() do
            table.insert(Bookmarks, tonumber(line))
        end
        f:close()

        if #Bookmarks == 0 then
            mp.osd_message("No Bookmarks.", 3)
            return
        else
            table.sort(Bookmarks, lessThan)
        end

        --mp.osd_message("Bookmarks Loaded.", 3)
    end
end

local function newBookmark()
    --save new timestamps to the bookmark file
    --appends onto the end
    local fn = mp.get_property("filename/no-ext") .. ".bookmark"
    local f = io.open(fn, "a")
    
    if f then
        local pos = mp.get_property_number("time-pos")
        f:write(pos, "\n")
        f:close()
        local message = "Bookmarked: " .. getTimestamp(-1)
        mp.osd_message(message, 3)
    else
        mp.osd_message("Bookmark failed.", 3)
    end

    loadBookmarks()
end

local function jumpRight()
    --jump to the right bookmark from the current spot
    if mp.get_property_number("time-pos") >= (mp.get_property_number("duration") - 1) then
        return
    end

    loadBookmarks()
    local message
    for i=1, #Bookmarks do
        if Bookmarks[i] > (mp.get_property_number("time-pos") + 0.3) then
            --jump to next bookmark bigger than current timestamp
            message = "Jumped to " .. getTimestamp(Bookmarks[i])
            mp.osd_message(message, 1.5)
            mp.set_property_number("time-pos", Bookmarks[i])
            return
        end
    end
    --otherwise jump to the end
    message = "Jumped to " .. getTimestamp(mp.get_property_number("duration"))
    mp.osd_message(message, 1.5)
    mp.set_property_number("time-pos", mp.get_property_number("duration"))

end

local function jumpLeft()
    --jump to the bookmark to the left of the current timestamp
    if mp.get_property_number("time-pos") == 0 then
        return
    end

    loadBookmarks()
    local last = 0
    local message
    for i=1, #Bookmarks do
        if Bookmarks[i] >= (mp.get_property_number("time-pos") - 1) then
            
            if i == 1 then
                --jump to beginning
                message = "Jumped to 00:00:00.0000"
                mp.set_property_number("time-pos", 0)
                mp.osd_message(message, 1.5)
                return
            else
                --otherwise jump to the next right timestamp
                message = "Jumped to " .. getTimestamp(Bookmarks[i-1])
                mp.set_property_number("time-pos", Bookmarks[i-1])
                mp.osd_message(message, 1.5)
                return
            end
        end
        last = Bookmarks[i]
    end
    --jump to last bookmark 
    message = "Jumped to " .. getTimestamp(last)
    mp.osd_message(message, 3)
    mp.set_property_number("time-pos", last)
    
end

local function deleteBookmark(ts)
    --delete the bookmark at the given timestamp
    loadBookmarks()
    for i = 1, #Bookmarks do
        if Bookmarks[i] == ts then
            table.remove(Bookmarks, i)
        end
    end
    
    updateBookmarks()
end

local function deleteClosest()
    --delete the closest bookmark before the current timestamp
end

local function deleteAll()
    --delete all Bookmarks
    Bookmarks = {}
    updateBookmarks()
    mp.osd_message("All bookmarks deleted.", 3)
end

--------------------------------------------------------------------------------


--TODO: OSD
--TODO: default save location, video directory by default
--TODO: find good keybinds

--mp.add_key_binding("C", "create_chapter", create_chapter, {repeatable=true})
--mp.add_key_binding("B", "write_chapter", write_chapter, {repeatable=false})
mp.add_key_binding("\'", "jumpRight", jumpRight, {repeatable=false})
mp.add_key_binding(";", "jumpLeft", jumpLeft, {repeatable=false})

--mp.add_key_binding("-", "loadTimestamps", loadTimestamps, {repeatable=true})
mp.add_key_binding("+", "newBookmark", newBookmark, {repeatable=true})
--loadBookmarks()