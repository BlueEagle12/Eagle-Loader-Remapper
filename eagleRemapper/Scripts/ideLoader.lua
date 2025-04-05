defValid2 = {}


function parseIDEFile(idePath,name)

	if fileExists(idePath) then
		-- 1) Open the file
		local ideFile = fileOpen(idePath)
		if not ideFile then
			outputDebugString2("Failed to open the IDE file at '" .. idePath .. "'!", 1)
			return
		end

		local size    = fileGetSize(ideFile)
		local content = fileRead(ideFile, size)
		fileClose(ideFile)

		-- 2) We'll track if we are in the 'objs' block
		local inObjsBlock = false
		local intObjsBlock = false
		local objsEntries = {}

		-- 3) Process each line
		for line in content:gmatch("[^\r\n]+") do
			-- Trim leading/trailing spaces
			line = line:match("^%s*(.-)%s*$")

			-- Skip empty or comment lines
			if line ~= "" and not line:find("^%s*%-%-") then
				
				-- Detect start/end of "objs" block
				if line:lower():find("^objs") then
					inObjsBlock = true
				elseif line:lower():find("^end") and inObjsBlock then
					-- "end" finishes the objs block
					inObjsBlock = false
				elseif line:lower():find("^end") and intObjsBlock then
					-- "end" finishes the objs block
					intObjsBlock = false
				elseif line:lower():find("^tobj") then
					intObjsBlock = true
				elseif line:lower():find("#") then
					-- Ignore
				elseif inObjsBlock or intObjsBlock then
					-------------------------------------------------------------
					-- Typical .IDE "objs" line format:
					--   ID, ModelName, TxdName, ObjectType, DrawDistance, Flags
					-------------------------------------------------------------
					local fields = {}
					for val in line:gmatch("([^,]+)") do
						table.insert(fields, val:match("^%s*(.-)%s*$"))
					end

					local dName = fields[2] or ""


					if validObject[dName:gsub("%s+", "")] then
						local tIna,tOuta = timeCalculator(dName)
					end

					if #fields == 5 then
						local id        = tonumber(fields[1]) or 0
						local modelName = fields[2] or ""
						local txdName   = fields[3] or ""
						local drawDist  = tonumber(fields[4]) or 0
						local flagsVal  = tonumber(fields[5]) or 0
						local timeIn  = tonumber(fields[6])
						local timeOut  = tonumber(fields[7])

						defValid2[modelName:gsub("%s+", "")] = true

						-- Convert that integer 'flagsVal' into a list of bits that are set
						local flagsBits = parseFlagsToList(flagsVal) or {}
						
						
						table.insert(objsEntries, {
							id        = id,
							modelName = modelName,
							txdName   = txdName,
							drawDist  = drawDist,
							flagsVal  = flagsVal,   -- original integer
							flagsBits = flagsBits,  -- table of bit positions that are ON
							zone      = name,
							tIn       = timeIn,
							tOut      = timeOut,
							fullLine  = line        -- in case you want the raw line
						})
					elseif #fields == 6 then
						local id        = tonumber(fields[1]) or 0
						local modelName = fields[2] or ""
						local txdName   = fields[3] or ""
						local drawDist  = tonumber(fields[5]) or 0
						local flagsVal  = tonumber(fields[6]) or 0

						defValid2[modelName:gsub("%s+", "")] = true

						-- Convert that integer 'flagsVal' into a list of bits that are set
						local flagsBits = parseFlagsToList(flagsVal) or {}
						
						
						table.insert(objsEntries, {
							id        = id,
							modelName = modelName,
							txdName   = txdName,
							drawDist  = drawDist,
							flagsVal  = flagsVal,   -- original integer
							flagsBits = flagsBits,  -- table of bit positions that are ON
							zone      = name,
							tIn       = timeIn,
							tOut      = timeOut,
							fullLine  = line        -- in case you want the raw line
						})
					elseif #fields == 7 then
						local id        = tonumber(fields[1]) or 0
						local modelName = fields[2] or ""
						local txdName   = fields[3] or ""
						local drawDist  = tonumber(fields[4]) or 0
						local flagsVal  = tonumber(fields[5]) or 0
						local timeIn  = tonumber(fields[6])
						local timeOut  = tonumber(fields[7])

						defValid2[modelName:gsub("%s+", "")] = true

						-- Convert that integer 'flagsVal' into a list of bits that are set
						local flagsBits = parseFlagsToList(flagsVal) or {}
						
						
						table.insert(objsEntries, {
							id        = id,
							modelName = modelName,
							txdName   = txdName,
							drawDist  = drawDist,
							flagsVal  = flagsVal,   -- original integer
							flagsBits = flagsBits,  -- table of bit positions that are ON
							zone      = name,
							tIn       = timeIn,
							tOut      = timeOut,
							fullLine  = line        -- in case you want the raw line
						})
					else

						-- Possibly a malformed line
						outputDebugString2("Warning: skipping malformed line in objs block: " .. line .. "," .. name, 2)
					end
				end
			end
		end

		return objsEntries
	end
end
