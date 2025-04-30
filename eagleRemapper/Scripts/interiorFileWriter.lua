
function writeInitalInt()
	local f = fileCreate("out/interiors.map")

	if not f then
		outputDebugString("Failed to create interior file at: " .. "out/interiors.enex", 1)
		return
	else
		fileWrite(f, '<map>\n')
		return f
	end
end

--[[
enexEntires[#enexEntires+1] = {
	entryPosition = {
		x = enX,
		y = enY,
		z = enZ,
		zr = enR,
		wX = enWX,
		wY = enWY,
	},
	
	exitPosition = {
		x = exX,
		y = exY,
		z = exZ,
		zr = exR,
		int = tarI
	},
	
	type = flag,
	on = tOn,
	off = tOff,
	id = name,
}
]]--

--[[
<interiorEntry	id="SPECIAL1"	posX="-225.433"	posY="1397.02"	posZ="69.0501"	rotation="0"	dimension="0"	interior="0"	/>
<interiorReturn	refid="SPECIAL1"	posX="-224.733"	posY="1395.82"	posZ="172.05"	rotation="0"	interior="0"	dimension="0"	/>
]]--

intFormat = {'id','posX','posY','posZ','rotation','interior','oneway','dimension'}

function formatInteriorLine (typeA,idType,id,x,y,z,rot,interior)
	local Out = {}
	local Out2 = {}
	local In = {id,x,y,z,rot,interior,'false',0}

	for i,v in ipairs(In) do
		local mType = intFormat[i]
		local realType = (mType == 'id') and idType or mType
		table.insert(Out,realType)
		Out2[realType] = v
	end

	line = string.format('    <%s ', typeA)
	first = true

	for i,v in pairs(Out) do
		if first then
			first = nil
			line = (line .. string.format(' %s="%s"',v,Out2[v]))
		else
			line = (line .. string.format(' %s="%s"',v,Out2[v]))
		end
	end

	line = line..' />\n'

	return line
end


function writeInteriorFile()

	local iF = writeInitalInt(mapPath,short)

    for id, obj in pairs(enexEntires) do

		print(id)

		tIn = obj[1]

		local ix,iy,iz,ir = tIn.entryPosition.x, tIn.entryPosition.y, tIn.entryPosition.z, tIn.entryPosition.zr
		local ox,oy,oz,orot = tIn.exitPosition.x, tIn.exitPosition.y, tIn.exitPosition.z, tIn.exitPosition.zr


		tOut = obj[2]

		if tOut then
		local ix1,iy1,iz1,ir = tOut.entryPosition.x, tOut.entryPosition.y, tOut.entryPosition.z, tOut.entryPosition.zr
		local ox1,oy1,oz1,orot1 = tOut.exitPosition.x, tOut.exitPosition.y, tOut.exitPosition.z, tOut.exitPosition.zr


		local line = formatInteriorLine(
			'interiorEntry','id',
			id..'-exit',ix1,iy1,iz1,ir,tOut.int
		)

		if line then
       		fileWrite(iF, line)
		end


		local line = formatInteriorLine(
			'interiorReturn','refid',
			id..'-exit',ox,oy,oz,orot,tIn.int
		)

		if line then
       		fileWrite(iF, line)
		end

--[[
		local line = formatInteriorLine(
			'interiorEntry','id',
			id,ix,iy,iz,ir,tIn.int
		)

		if line then
       		fileWrite(iF, line)
		end


		local line = formatInteriorLine(
			'interiorReturn','refid',
			id,ox1,oy1,oz1,orot1,tOut.int
		)
]]--
		if line then
       		fileWrite(iF, line)
		end
		end

    end
    
    -- close out the XML
	if iF then
		fileWrite(iF, '</map>\n')
		fileClose(iF)
	end
    
    outputDebugString("Successfully wrote interior file")
end













--intFormat = {'id','posX','posY','posZ','rotZ','pos1X','pos1Y','pos1Z','rot1Z','widthX','widthY','interior','type','on','off'}
function formatInteriorLine_EL (id,x,y,z,rot,widthx,widthy,x1,y1,z1,rot1,interior,mType,on,off)
	local Out = {}
	local Out2 = {}
	local In = {id,x,y,z,rot,x1,y1,z1,rot1,widthx,widthy,interior,mType,on,off}

	for i,v in ipairs(In) do
		if not(v == "") then
			table.insert(Out,intFormat[i])
			Out2[intFormat[i]] = v
		end
	end

	line = string.format('    <%s ', 'marker')
	first = true

	for i,v in pairs(Out) do
		if first then
			first = nil
			line = (line .. string.format(' %s="%s"',v,Out2[v]))
		else
			line = (line .. string.format(' %s="%s"',v,Out2[v]))
		end
	end

	line = line..string.format('></%s>\n',"marker")

	return line
end


function writeInteriorFile_EL()

	local iF = writeInitalInt(mapPath,short)

    for _, obj in ipairs(enexEntires) do

		local line = formatInteriorLine(
			obj.id,
			obj.entryPosition.x, obj.entryPosition.y, obj.entryPosition.z, obj.entryPosition.zr, obj.entryPosition.wX, obj.entryPosition.wX,
			obj.exitPosition.x, obj.exitPosition.y, obj.exitPosition.z, obj.exitPosition.zr, obj.exitPosition.int,
			obj.type,
			obj.tOn,
			obj.tOff
		)

		if line then
       		fileWrite(iF, line)
		end
    end
    
    -- close out the XML
	if iF then
		fileWrite(iF, '</interiors>\n')
		fileClose(iF)
	end
    
    outputDebugString("Successfully wrote interior file")
end