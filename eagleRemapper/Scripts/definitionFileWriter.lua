fileValid = {}
defValid3 = {}

function writeInital(definitionPath,shortName)
	if not fileValid[definitionPath] then

		metaList["Definitions"]["zones/"..shortName.."/"..shortName..".definition"] = true

		local f = fileCreate(definitionPath)
		fileValid[definitionPath] = f
		if not f then
			outputDebugString2("Failed to create definition file at: " .. definitionPath, 1)
			return
		else
			fileWrite(f, '<zoneDefinitions>\n')
			return f
		end
	else
		return fileValid[definitionPath]
	end
end

zones = {}

function writeDefinition(definitions, definitionPath,shortName,prep)


    for _, def in ipairs(definitions) do
		local dName = def.modelName

		if not (defaultIDs[dName:gsub("%s+", "")]) then
			local line
			
			if (validObject[dName:gsub("%s+", "")] or prep) then

				local dZone = def.zone

				local model = "in/resources/"..def.modelName..".dff"
				local col   = "in/resources/"..def.modelName..".col"
				local txd   = "in/resources/"..def.txdName..".txd"

				valid = true
				invalid = false


				reason = ""

				valid,reasonA = copyFile(model,"out/zones/"..dZone.."/dff/"..def.modelName..".dff",'Models',"zones/"..dZone.."/dff/"..def.modelName..".dff",prep)
				invalid = (not valid) or invalid

				reason = reason..","..(reasonA or "")

				if not invalid then
					valid,reasonB = copyFile(col,"out/zones/"..dZone.."/col/"..def.modelName..".col",'Collisons',"zones/"..dZone.."/col/"..def.modelName..".col",prep)
					invalid = (not valid) or invalid

					reason = reason..","..(reasonB or "")
				end

				if not invalid then
					valid,reasonC = copyFile(txd,"out/textures/"..def.txdName..".txd",'Textures',"textures/"..def.txdName..".txd",prep)
					invalid = (not valid) or invalid

					reason = reason..","..(reasonC or "")
				end





				if not invalid then

					if not prep then
						f = writeInital(definitionPath,shortName)
					end


					if not (def.tIn) then

						local tIna,tOuta = timeCalculator(def.modelName)

						if tIna then
							def.tIn = tIna
							def.tOut = tOuta
						end
					end
					
					defValid3[def.modelName] = true

					if def.modelName and def.zone and def.txdName and def.drawDist then

						if not prep then
							zones[def.zone] = true
						end

						if def.tIn and def.tOut then
							line = string.format(
								'    <%s id="%s" zone="%s" col="%s" txd="%s" flags="%s" lodDistance="%s" timeIn="%s" timeOut="%s"></%s>\n',
								"definition",
								def.modelName,
								def.zone,
								def.modelName, 
								def.txdName, 
								table.concat((def.flagsBits or {}), ","), 
								def.drawDist, 
								def.tIn,
								def.tOut,
								"definition"
							)
						else
							line = string.format(
								'    <%s id="%s" zone="%s" col="%s" txd="%s" flags="%s" lodDistance="%s"></%s>\n',
								"definition",
								def.modelName,
								def.zone,
								def.modelName, 
								def.txdName, 
								table.concat((def.flagsBits or {}), ","), 
								def.drawDist, 
								"definition"
							)
						end
					end
				end

				if not prep then
					if not invalid then
						fileWrite(f, line)
					else
						outputDebugString2("Notice: skipping IDE object due to invalid file: " .. def.modelName..", - "..reason, 2)
					end
				end
			end
		else 
			outputDebugString("Notice: skipping default IDE object: " .. defaultIDs[dName:gsub("%s+", "")], 2)
		end
	end
    
    -- close out the XML
	if f then
		fileWrite(f, '</zoneDefinitions>\n')
		fileClose(f)
	end
    
	f = nil
	if not prep then
    	outputDebugString("Successfully wrote .definition file: " .. definitionPath)
	end
end