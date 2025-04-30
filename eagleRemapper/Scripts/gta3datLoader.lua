-- Helper: extract the short name from a path (e.g. "data\maps\LA\lae2.IDE" -> "lae2")
local function getBaseNameNoExt(fullPath)
    -- 1) Extract the file name from path (remove folders).
    --    We'll match any sequence that isn't a slash at the end.
    local filename = fullPath:match("[^\\/]+$")
    if not filename then 
        -- if matching fails for some reason, return the entire path
        return fullPath
    end

    -- 2) Remove the extension, if present (like ".IDE" or ".IPL").
    local base = filename:match("^(.*)%.")
    if not base then
        -- if no dot, just return the entire filename
        base = filename
    end
    return base
end

local function parseGTAData()
    local datPath = "in/data/gta.dat"  -- adapt to your resource path

    local datFile = fileOpen(datPath)
    if not datFile then
        outputDebugString("Failed to open the gta.dat file at '" .. datPath .. "'!", 1)
        return
    end

    local size    = fileGetSize(datFile)
    local content = fileRead(datFile, size)
    fileClose(datFile)

    local datEntries = {}

    for line in content:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$") -- trim spaces

        -- Skip blank or commented lines (starting with '#')
        if line ~= "" and not line:find("^%s*#") then
            -- Split first token from the rest
            local tokens = {}
            for word in line:gmatch("%S+") do
                table.insert(tokens, word)
            end

            local cmd = tokens[1]:upper()   -- e.g. "IDE", "IPL", "COLFILE", ...
            table.remove(tokens, 1)         -- remove the command from the front

            local entry = {
                command = cmd,
                tokens  = tokens,  -- leftover tokens
                rawLine = line
            }

            ----------------------------------------------------------------
            -- If it's an IDE, IMG or IPL line, parse the path and also store 
            -- the short name (base name without extension).
            ----------------------------------------------------------------
            if cmd == "IDE" or cmd == "IPL" or cmd == "IMG" then
                -- Usually the path is in tokens[1] 
                -- (assuming the line is like "IDE data\maps\LA\lae2.IDE").
                local path = tokens[1] or ""
                entry.path = path

                -- Derive shortName by removing directories and the .IDE/.IPL/.IMG extension
                entry.shortName = getBaseNameNoExt(path)
				
				entry.path = path:gsub("\\", "/")
				
            end

            table.insert(datEntries, entry)
        end
    end

    -------------------------------------------------------------------------
    -- Now datEntries is a list of parsed lines.
    -- Each entry has:
    --   entry.command  = "IDE" or "IPL" or "COLFILE", etc.
    --   entry.tokens   = {"data\maps\LA\lae2.IDE"} (for example)
    --   entry.path     = "data\maps\LA\lae2.IDE" (if it's IDE or IPL)
    --   entry.shortName= "lae2" (the extracted base name, for IDE/IPL)
    --   entry.rawLine  = the entire line
    -------------------------------------------------------------------------

    -- Print them out

    for _, e in ipairs(datEntries) do

        if e.command == "IMG" then
            local imgFiles = parseIMGFile("in/"..e.path,e.shortName)
        end

        if e.command == "IDE" then
            local defs = parseIDEFile("in/"..e.path,e.shortName)
            writeDefinition(defs,"out/zones/"..e.shortName.."/"..e.shortName..".definition",e.shortName,true)
        end

        if e.command == "IPL" then
            local objects = parseIPLFile("in/"..e.path,e.shortName)
            
            writeMapFile(objects,"out/zones/"..e.shortName.."/"..e.shortName..".map",e.shortName)
        end
    end



    for _, e in ipairs(datEntries) do
        if e.command == "IDE" or e.command == "IPL" then
            outputDebugString(("[GTA.DAT] %s => path='%s' shortName='%s'")
                :format(e.command, e.path or "", e.shortName or ""))

			
			if e.command == "IDE" then
				local defs = parseIDEFile("in/"..e.path,e.shortName)
                writeDefinition(defs,"out/zones/"..e.shortName.."/"..e.shortName..".definition",e.shortName)
			end
        else
            outputDebugString(("[GTA.DAT] %s => tokens=[%s]")
                :format(e.command, table.concat(e.tokens, ", ")))
        end
    end

    prepMetaFile('out/meta.xml')
    writeZoneFile()
    writeDebugFile()
    writeInteriorFile()


    return datEntries
end

-- Example usage: parse on resource start
addEventHandler("onResourceStart", resourceRoot, function()
    local entries = parseGTAData()
    if entries then
        outputDebugString("Parsed " .. #entries .. " lines from gta.dat!")
    end
end)
