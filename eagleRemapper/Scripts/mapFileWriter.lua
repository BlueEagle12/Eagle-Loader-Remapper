fileValid = {}
validObject = {}

function writeInitalMap(mapPath,shortName)
	if not fileValid[mapPath] then

		metaList["Maps"]["zones/"..shortName.."/"..shortName..".map"] = true

		local f = fileCreate(mapPath)
		fileValid[mapPath] = f
		if not f then
			outputDebugString("Failed to create map file at: " .. mapPath, 1)
			return
		else
			fileWrite(f, '<map>\n')
			return f
		end
	else
		return fileValid[mapPath]
	end
end

mapFormat = {'id','posX','posY','posZ','rotX','rotY','rotZ','lodParent','uniqueID','lodParentID'}

function formatMap (type,id,x,y,z,xr,yr,zr,lodParent,unqiueID,lodParentID)
	local Out = {}
	local Out2 = {}
	local In = {id,x,y,z,xr,yr,zr,lodParent or "",(unqiueID or 0) > 0 and unqiueID or "",lodParentID or ""}

	for i,v in ipairs(In) do
		if not(v == "") then
			table.insert(Out,mapFormat[i])
			Out2[mapFormat[i]] = v
		end
	end

	line = string.format('    <%s ', type)
	first = true

	for i,v in pairs(Out) do
		if first then
			first = nil
			line = (line .. string.format(' %s="%s"',v,Out2[v]))
		else
			line = (line .. string.format(' %s="%s"',v,Out2[v]))
		end
	end

	line = line..string.format('></%s>\n',type)

	return line
end


function writeMapFile(objects, mapPath,short)


    for _, obj in ipairs(objects) do

        -- We'll build a single line like:
        --   <building id="apairprtbits01" model="8585" posX="-1226.50781" posY="-994.60938" ... ></building>

		local mName = obj.modelName
		
		local line

		if (defValid2[mName] or defaultIDs[mName] or defValid3[mName]) then

			zones[short] = true

			
			mF = writeInitalMap(mapPath,short)


			obj.type = (defaultIDs[obj.modelName]) and "object" or "building"

			validObject[mName:gsub("%s+", "")] = true

			line = formatMap(
				(obj.type or "building"),
				obj.modelName,
				obj.position.x, obj.position.y, obj.position.z,
				obj.rotationEuler.x, obj.rotationEuler.y, obj.rotationEuler.z,
				obj.lodParent,
				obj.uniqueID,
				obj.lodParentID
			)

		else
			outputDebugString2("Invalid ID: " .. mName)
		end
        
		if line then
       		fileWrite(mF, line)
		end
    end
    
    -- close out the XML
	if mF then
		fileWrite(mF, '</map>\n')
		fileClose(mF)
	end
    
	mF = nil
    outputDebugString("Successfully wrote .map file: " .. mapPath)
end