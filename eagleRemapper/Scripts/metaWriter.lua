local metaEntries = {
    {
        tag = "info",
        attributes = {
            author  = "BlueEagle",
            version = "3.0.0",
            name    = "Vice_City",
        }
    },

    {
        tag = "file",
        attributes = {
            src  = "eagleZones.txt",
            type = "client",
        }}
}





function writeMetaFile(entries, metaPath)
    -- Create (or overwrite) the meta.xml file in your resource
    local f = fileCreate(metaPath)
    if not f then
        outputDebugString("Failed to create " .. metaPath, 1)
        return false
    end

    -- Write XML header and <meta> root tag
    fileWrite(f, '<meta>\n')

    for i, entry in ipairs(entries) do

        if entry == "blank" then
            line = "\n".."\n"

            fileWrite(f, line)
        else
            local tag = entry.tag or "info"  -- default to <info> if not specified
            local attrs = entry.attributes or {}

            -- Build the line: e.g. <script src="foo.lua" type="server" />
            local line = "    <" .. tag
            for k, v in pairs(attrs) do
                -- Escape " if needed, though typically your paths won't have quotes
                line = line .. string.format(' %s="%s"', k, tostring(v))
            end

            line = line .. " />\n"

            fileWrite(f, line)
        end
    end

    fileWrite(f, "</meta>\n")
    fileClose(f)

    outputDebugString("Wrote meta.xml to: " .. metaPath)
    return true
end


function writeZoneFile()
    -- Create (or overwrite) the meta.xml file in your resource
    local f = fileCreate('out/eagleZones.txt')
    if not f then
        outputDebugString("Failed to create " .. 'eagleZones.txt', 1)
        return false
    end


    for i, entry in pairs(zones) do
        fileWrite(f, i.."\n")
    end

    fileClose(f)

    outputDebugString("Wrote eagleZones.txt to: " .. 'out/eagleZones.txt')
    return true
end



function writeDebugFile()
    -- Create (or overwrite) the meta.xml file in your resource
    local f = fileCreate('debug.txt')


    for i, entry in pairs(debugLines) do
        fileWrite(f, entry.."\n")
    end

    fileClose(f)

    outputDebugString("Wrote debug to: " .. 'debug.txt')
    return true
end


metaList['Textures'] = {}
metaList['Models'] = {}
metaList['Collisons'] = {}
metaList['Maps'] = {}
metaList['Definitions'] = {}

metaListOrder = {"Water","Maps","Definitions","Models","Collisons","Textures"}

function prepMetaFile(path)
    local entries = {}
    table.insert(entries,metaEntries[1])
    table.insert(entries,"blank")
    table.insert(entries,metaEntries[2])
    table.insert(entries,"blank")

    if fileExists('in/data/water.dat') then
        copyFile('in/data/water.dat', 'out/water.dat',"Water",'water.dat')
    end

    if interiorValid then
        table.insert(entries,                {
            tag = "file",
            attributes = {
                src  = 'interiors.map',
                type = "client",
            }})

        table.insert(entries,"blank")
    end

    if IMGSupport then
        table.insert(entries,                {
            tag = "file",
            attributes = {
            src  = 'imgs/dff.img',
            type = "client",
        }})

        table.insert(entries,                {
            tag = "file",
            attributes = {
            src  = 'imgs/col.img',
            type = "client",
        }})

        table.insert(entries,                {
            tag = "file",
            attributes = {
            src  = 'imgs/txd.img',
            type = "client",
        }})

        table.insert(entries,"blank")
    end

    for _,index in ipairs(metaListOrder) do
        for i,v in pairs(metaList[index]) do
            table.insert(entries,
                {
                tag = "file",
                attributes = {
                    src  = i,
                    type = "client",
                }})
        end
        table.insert(entries,"blank")
    end

    writeMetaFile(entries, path)

end