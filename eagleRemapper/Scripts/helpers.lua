if not bit then
    bit = {}
end

if not bit.band then
    function bit.band(a, b)
        local r, m = 0, 1
        while a > 0 and b > 0 do
            -- Compare the lowest bit of both
            if (a % 2 == 1) and (b % 2 == 1) then
                r = r + m
            end
            a = math.floor(a/2)
            b = math.floor(b/2)
            m = m * 2
        end
        return r
    end
end

function math.sign(num)
    if num > 0 then
        return 1
    elseif num < 0 then
        return -1
    else
        return 0
    end
end


function quaternionToEuler(x, y, z, w)

    local sinr_cosp = 2 * (w * x + y * z)
    local cosr_cosp = 1 - 2 * (x * x + y * y)
    local roll = math.atan2(sinr_cosp, cosr_cosp)

    local sinp = 2 * (w * y - z * x)
    local pitch
    if math.abs(sinp) >= 1 then
        pitch = math.pi / 2 * math.sign(sinp)
    else
        pitch = math.asin(sinp)
    end

    local siny_cosp = 2 * (w * z + x * y)
    local cosy_cosp = 1 - 2 * (y * y + z * z)
    local yaw = math.atan2(siny_cosp, cosy_cosp)

    local correctedRoll = math.deg(roll)
    local correctedPitch = math.deg(pitch)
    local correctedYaw = math.deg(yaw)

    return correctedRoll, correctedPitch, correctedYaw
end


local identityMatrix = {
	[1] = {1, 0, 0},
	[2] = {0, 1, 0},
	[3] = {0, 0, 1}
}
 
function QuaternionTo3x3(x,y,z,w)
	local matrix3x3 = {[1] = {}, [2] = {}, [3] = {}}
 
	local symetricalMatrix = {
		[1] = {(-(y*y)-(z*z)), x*y, x*z},
		[2] = {x*y, (-(x*x)-(z*z)), y*z},
		[3] = {x*z, y*z, (-(x*x)-(y*y))} 
	}

	local antiSymetricalMatrix = {
		[1] = {0, -z, y},
		[2] = {z, 0, -x},
		[3] = {-y, x, 0}
	}
 
	for i = 1, 3 do 
		for j = 1, 3 do
			matrix3x3[i][j] = identityMatrix[i][j]+(2*symetricalMatrix[i][j])+(2*w*antiSymetricalMatrix[i][j])
		end
	end
	
	return matrix3x3
end

function getEulerAnglesFromMatrix(x1,y1,z1,x2,y2,z2,x3,y3,z3)
	local nz1,nz2,nz3
	nz3 = math.sqrt(x2*x2+y2*y2)
	nz1 = -x2*z2/nz3
	nz2 = -y2*z2/nz3
	local vx = nz1*x1+nz2*y1+nz3*z1
	local vz = nz1*x3+nz2*y3+nz3*z3
	return math.deg(math.asin(z2)),-math.deg(math.atan2(vx,vz)),-math.deg(math.atan2(x2,y2))
end

function fromQuaternion(x,y,z,w) 
	local matrix = QuaternionTo3x3(x,y,z,w)
	local ox,oy,oz = getEulerAnglesFromMatrix(
		matrix[1][1], matrix[1][2], matrix[1][3], 
		matrix[2][1], matrix[2][2], matrix[2][3],
		matrix[3][1], matrix[3][2], matrix[3][3]
	)

	return ox,oy,oz
end

-- Wrapper to convert quaternion to Euler angles in degrees
function quatToEuler(x, y, z, w)

    --local len = math.sqrt(x*x + y*y + z*z + w*w)
    --local x, y, z, w = x/len, y/len, z/len, w/len

    local roll, pitch, yaw = fromQuaternion(x, y, z, w)
    return roll, pitch, yaw
end



function parseFlagsToList(flagsValue)
    -- Converts an integer 'flagsValue' into a list of bits that are ON.
    -- e.g. if flagsValue=50 (binary 110010), bits set are 1,4,5 => {1,4,5}.
    local list = {}
    for bitPos = 0, 31 do
        local mask = 2^bitPos
        if bit.band(flagsValue, mask) ~= 0 then
            table.insert(list, bitPos)
        end
    end
    return list
end

metaList = {}
metaList['Textures'] = {}
metaList['Water'] = {}
metaList['Models'] = {}
metaList['Collisons'] = {}
metaList['Maps'] = {}
metaList['Definitions'] = {}


function getFileNameAndExtension(path)
    return path:match("([^/\\]+)%.([^%.\\/]+)$")
end

function getContent (file,imgFile)
    if imgFile then
        return imgFile
    else
        local size = fileGetSize(file)
        local content = fileRead(file, size)
        fileClose(file)
        return content
    end
end



function copyFile(srcPath, dstPath,type,actualpath,dontCopy,ignoreMeta)
    -- 1. Check if source file actually exists inside the resource

    local sName,ext = getFileNameAndExtension(actualpath)
    local nameExt = string.lower(sName..'.'..ext)

    local fileValid = globalIMGFiles[nameExt] or fileExists(srcPath)

    if dontCopy then
        if fileValid then
            return true
        else
            return false
        end
    end

    if not fileValid then
        return false, "Source file does not exist: " .. nameExt
    end

    -- 2. Open and read the entire source
    
    if fileExists(dstPath) then
        if type then 
            if not ignoreMeta then
                metaList[type][actualpath] = true
            end
            return true
        end
    end

    local inFile = globalIMGFiles[nameExt] or fileOpen(srcPath)
    if not inFile then
        return false, "Failed to open source: " .. nameExt
    end

    if not ignoreMeta then
        if type then 
            metaList[type][actualpath] = true
        end
    end

    local content = getContent(inFile,globalIMGFiles[nameExt])

    -- 3. Create/write the destination file
    local outFile = fileCreate(dstPath)
    if not outFile then
        return false, "Failed to create destination: " .. dstPath
    end

    fileWrite(outFile, content)
    fileClose(outFile)

    return true
end

debug.sethook(nil)


local nightNames = {"_nt","_ng"}
local dayNames = {"_dy"}

local pair_day = {}
local pair_night = {}

local ignore = {''}

function timeCalculator(name)


    for i,v in pairs(nightNames) do
        if string.find(name,v) then
            local cleanedName = string.gsub(name,v, "")
            pair_day[cleanedName] = true

            print(cleanedName)
            if pair_night[cleanedName] then
                return 20,6
            else
                return false
            end
        end
    end

    for i,v in pairs(dayNames) do 
        if string.find(name,v) then
            local cleanedName = string.gsub(name,v, "")
            pair_night[cleanedName] = true
            if pair_day[cleanedName] then
                return 6,20
            else
                return false
            end
        end
    end

end

debugLines = {}
function outputDebugString2(string,a)
    outputDebugString(string,a)

    table.insert(debugLines,string)
end