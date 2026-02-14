local serializer = {}

local T = {
	NIL = 0,
	BOOL = 1,
	INT8 = 2,
	INT16 = 3,
	INT32 = 4,
	FLOAT32 = 5,
	STRING = 6,
	VECTOR3 = 7,
	COLOR3 = 8,
	TABLE = 9,
}

local writers: { [any]: any } = {}
local readers: { [any]: any } = {}

local function isInteger(n: number)
	return n % 1 == 0
end

local function ensureCapacity(buf, needed: number, used: number)
	if used + needed <= buffer.len(buf) then return buf end
	local newSize = math.max(buffer.len(buf) * 2, used + needed)
	local newBuf = buffer.create(newSize)
	buffer.copy(newBuf, 0, buf, 0, used)
	return newBuf
end

local function writeNumber(buf, o, v)
	if isInteger(v) then
		if v >= -128 and v <= 127 then
			buf = ensureCapacity(buf, 2, o)
			buffer.writeu8(buf, o, T.INT8)
			buffer.writei8(buf, o + 1, v)
			return buf, o + 2
		elseif v >= -32768 and v <= 32767 then
			buf = ensureCapacity(buf, 3, o)
			buffer.writeu8(buf, o, T.INT16)
			buffer.writei16(buf, o + 1, v)
			return buf, o + 3
		else
			buf = ensureCapacity(buf, 5, o)
			buffer.writeu8(buf, o, T.INT32)
			buffer.writei32(buf, o + 1, v)
			return buf, o + 5
		end
	end
	buf = ensureCapacity(buf, 5, o)
	buffer.writeu8(buf, o, T.FLOAT32)
	buffer.writef32(buf, o + 1, v)
	return buf, o + 5
end

writers["nil"] = function(buf, o)
	buf = ensureCapacity(buf, 1, o)
	buffer.writeu8(buf, o, T.NIL)
	return buf, o + 1
end

writers["boolean"] = function(buf, o, v)
	buf = ensureCapacity(buf, 2, o)
	buffer.writeu8(buf, o, T.BOOL)
	buffer.writeu8(buf, o + 1, v and 1 or 0)
	return buf, o + 2
end

writers["number"] = function(buf, o, v)
	return writeNumber(buf, o, v)
end

writers["string"] = function(buf, o, v)
	local len = #v
	buf = ensureCapacity(buf, 2 + len, o)
	buffer.writeu8(buf, o, T.STRING)
	buffer.writeu8(buf, o + 1, len)
	buffer.writestring(buf, o + 2, v)
	return buf, o + 2 + len
end

writers["Vector3"] = function(buf, o, v)
	buf = ensureCapacity(buf, 7, o)
	buffer.writeu8(buf, o, T.VECTOR3)
	buffer.writei16(buf, o + 1, v.X)
	buffer.writei16(buf, o + 3, v.Y)
	buffer.writei16(buf, o + 5, v.Z)
	return buf, o + 7
end

writers["Color3"] = function(buf, o, v: Color3)
	buf = ensureCapacity(buf, 4, o)
	buffer.writeu8(buf, o, T.COLOR3)
	buffer.writeu8(buf, o + 1, v.R * 255)
	buffer.writeu8(buf, o + 2, v.G * 255)
	buffer.writeu8(buf, o + 3, v.B * 255)
	return buf, o + 4
end

writers["table"] = function(buf, o, t)
	buf = ensureCapacity(buf, 1, o)
	buffer.writeu8(buf, o, T.TABLE)
	o += 1
	for k, v in pairs(t) do
		buf, o = serializer._writeAny(buf, o, k)
		buf, o = serializer._writeAny(buf, o, v)
	end
	buf = ensureCapacity(buf, 1, o)
	buffer.writeu8(buf, o, T.NIL)
	return buf, o + 1
end

readers[T.NIL] = function(_, o)
	return nil, o
end

readers[T.BOOL] = function(buf, o)
	return buffer.readu8(buf, o) == 1, o + 1
end

readers[T.INT8] = function(buf, o)
	return buffer.readi8(buf, o), o + 1
end

readers[T.INT16] = function(buf, o)
	return buffer.readi16(buf, o), o + 2
end

readers[T.INT32] = function(buf, o)
	return buffer.readi32(buf, o), o + 4
end

readers[T.FLOAT32] = function(buf, o)
	return buffer.readf32(buf, o), o + 4
end

readers[T.STRING] = function(buf, o)
	local len = buffer.readu8(buf, o)
	return buffer.readstring(buf, o + 1, len), o + 1 + len
end

readers[T.VECTOR3] = function(buf, o)
	return Vector3.new(buffer.readi16(buf, o), buffer.readi16(buf, o + 2), buffer.readi16(buf, o + 4)), o + 6
end

readers[T.COLOR3] = function(buf, o)
	return Color3.fromRGB(buffer.readu8(buf, o), buffer.readu8(buf, o + 1), buffer.readu8(buf, o + 2)), o + 3
end

readers[T.TABLE] = function(buf, o)
	local t = {}
	while true do
		local key
		key, o = serializer._readAny(buf, o)
		if key == nil then break end
		local val
		val, o = serializer._readAny(buf, o)
		t[key] = val
	end
	return t, o
end

function serializer._writeAny(buf, o, v)
	local w = writers[typeof(v)] :: ((...any) -> any)?
	if not w then
		warn(`Serializer: unsupported type {typeof(v)}`)
		return buf, o
	end
	return w(buf, o, v)
end

function serializer._readAny(buf, o)
	local t = buffer.readu8(buf, o)
	local r = readers[t] :: ((...any) -> any)?
	if not r then
		warn(`Deserializer: unknown type {t}`)
		return nil, o + 1
	end
	return r(buf, o + 1)
end

function serializer:Serialize(...)
	local buf = buffer.create(64)
	local o = 0
	for i = 1, select("#", ...) do
		buf, o = serializer._writeAny(buf, o, select(i, ...))
	end
	local out = buffer.create(o)
	buffer.copy(out, 0, buf, 0, o)
	return out
end

function serializer:Deserialize(buf)
	local o = 0
	local out = {}
	while o < buffer.len(buf) do
		local v
		v, o = serializer._readAny(buf, o)
		table.insert(out, v)
	end
	return table.unpack(out)
end

return serializer
