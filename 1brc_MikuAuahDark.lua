local measurementFile = os.getenv("MEASUREMENT_FILE") or "./measurements.txt"

-- occurences, min, max, sum
---@type table<string, {[1]:number,[2]:number,[3]:number,[4]:number}>
local result = {}

-- Load file
local f = assert(io.open(measurementFile, "rb"))

if arg[1] == "w" then
	local fast_tonumber_for_this_purpose
	if jit then
		---@param n string
		---@return number
		function fast_tonumber_for_this_purpose(n)
			local v = 0
			local start = n:byte() == 45 and 2 or 1 -- 45 = "-" character
			local dot = n:find(".", 1, true)

			for i = start, dot - 1 do
				v = v * 10 + n:byte(i) - 48 -- 48 = "0"
			end

			return (3 - 2 * start) * (v * 10 + n:byte(dot + 1) - 48)
		end
	else
		function fast_tonumber_for_this_purpose(n)
			return tonumber(n, 10) * 10
		end
	end

	local startPos = tonumber(arg[2])
	local endPos = tonumber(arg[3])

	-- Since we're seeking anywhere, find closest line
	local lineIterator = f:lines()
	f:seek("set", math.max(startPos - 1, 0))
	if startPos > 0 and f:read(1) ~= "\n" then
		-- Align to next line
		lineIterator()
	end
	---@cast lineIterator fun():(string?)

	-- Process rows
	-- local nrows = 10000000
	for line in lineIterator do
		-- nrows = nrows - 1
		-- if nrows <= 0 then break end

		local semicolon = line:find(";", 1, true)
		local name = line:sub(1, semicolon - 1)
		local temp = fast_tonumber_for_this_purpose(line:sub(semicolon + 1))

		local r = result[name]
		if r == nil then
			r = {0, 999, -999, 0}
			result[name] = r
		end

		r[1] = r[1] + 1
		r[2] = math.min(r[2], temp)
		r[3] = math.max(r[3], temp)
		r[4] = r[4] + temp

		if f:seek() >= endPos then
			break
		end
	end
	f:close()

	-- Print out intermediate result
	for k, v in pairs(result) do
		io.write(string.format("%s;%d;%d;%d;%d\n", k, unpack(v)))
	end
else
	local function getCPUCount()
		local cpu = os.getenv("NUMBER_OF_PROCESSORS")

		if cpu then
			return assert(tonumber(cpu))
		elseif package.path:find("/", 1, true) then
			-- Linux
			local f2 = assert(io.popen("nproc", "r"))
			local num = assert(f2:read("*n"))
			f2:close()
			return num
		end
	end

	---@param v number
	local function theRounding(v)

		if v < 0 then
			return math.ceil(v - 0.5)
		else
			return math.floor(v + 0.5)
		end
	end

	local filesize = f:seek("end")
	f:close()

	local ncpu = getCPUCount()
	local splits = {0}
	local splitEvery = math.floor(filesize / ncpu)
	local splitRemainder = filesize % ncpu

	for _ = 1, ncpu do
		splits[#splits+1] = splits[#splits] + splitEvery + math.min(math.max(splitRemainder, 0), 1)
		splitRemainder = splitRemainder - 1
	end

	---@type file*[]
	local workers = {}
	for i = 1, ncpu do
		-- arg[-1] = interpreter
		-- arg[0] = script name
		local cmd = arg[-1].." "..arg[0].." w "..splits[i].." "..splits[i + 1]
		io.stderr:write("Launching ", cmd, "\n")
		local w = assert(io.popen(cmd, "r"))
		workers[#workers+1] = w
	end

	-- Collect results
	for _, w in ipairs(workers) do
		for line in w:lines() do
			-- Thank Lua strips the trailing newline for us
			local l = line
			---@cast l string
			local name, occurences, mintemp, maxtemp, sum = l:match("^([^;]+);(%-?%d+);(%-?%d+);(%-?%d+);(%-?%d+)$")

			local r = result[name]
			if r == nil then
				r = {0, 999, -999, 0}
				result[name] = r
			end

			r[1] = r[1] + occurences
			r[2] = math.min(r[2], tonumber(mintemp))
			r[3] = math.max(r[3], tonumber(maxtemp))
			r[4] = r[4] + sum
		end

		w:close()
	end

	-- Rewrite rows in alphabetical order
	---@type {[1]:string,[2]:string}[]
	local result2 = {}

	for k, v in pairs(result) do
		result2[#result2+1] = {k, string.format("%s=%.1f/%.1f/%.1f", k, v[2] / 10, theRounding(v[4] / v[1]) / 10, v[3] / 10)}
	end

	table.sort(result2, function (a, b)
		return a[1] < b[1]
	end)

	---@type string[]
	local result3 = {}
	for _, v in ipairs(result2) do
		result3[#result3+1] = v[2]
	end

	-- Print result
	io.write("{", table.concat(result3, ", "), "}\n")
end
