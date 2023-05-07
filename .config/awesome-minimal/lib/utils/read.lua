local io = io
local assert = assert
local read = {}
function read.file(path)
	local file = io.open(path)
	if file then
		local output = file:read("*a")
		file:close()
		return output
	else
		return nil
	end
end
function read.output(cmd)
	local file = assert(io.popen(cmd, 'r'))
	local output = file:read('*all')
	file:close()
	return output
end
return read
