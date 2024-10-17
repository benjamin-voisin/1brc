-- Maybe do not hard-code that. Retrieves evry .lua file that are not 
-- the auxiliary scripts, and run them against both lua and luajit ?
local scripts = {
	{
		path = "./baseline.lua",
		interpreter = "lua",
	},
	{
		path = "./baseline.lua",
		interpreter = "luajit"
	},
	{
		path = "./1brc_BenjaminV.lua",
		interpreter = "luajit",
	},
	{
		path = "./1brc_BenjaminV.lua",
		interpreter = "lua",
	},
	{
		path = "./1brc_MikuAuahDark.lua",
		interpreter = "luajit",
	},
	{
		path = "./1brc_BenjaminV_jit.lua",
		interpreter = "luajit",
	},
	{
		path = "./1brc_felipeguilhermefs.lua",
		interpreter = "luajit",
	},
}

-- This is required to measure better times
local socket = require "socket"

-- Compute the average based on a table of measurments. The best and worst
-- results are ignored
local function balanced_average(measurments)
	local min = measurments[1]
	local max = measurments[1]
	local sum = 0
	for i = 1, #measurments do
		max = math.max(max, measurments[i])
		min = math.min(min, measurments[i])
		sum = sum + measurments[i]
	end
	return ((sum - min - max) / (#measurments - 2))
end

local function run(script_path, interpreter)
	local start_time = socket.gettime()
	local execution = io.popen(string.format("%s %s", interpreter, script_path), "r")
	if not execution then
		return nil, string.format("Error launching the command: %s %s", interpreter, script_path)
	end
	_ = execution:read("*a") -- We might want to use that to check that the result is correct ?
	local end_time = socket.gettime()
	return end_time - start_time
end

local function bench(script_path, interpreter)
	local results = {}
	print(string.format("Benchmarking %s with %s interpreter", script_path, interpreter))
	if string.match(script_path, "baseline") then
		-- Only bench the baseline 1 time, as it is very long and we don't care that much about its value
		return run(script_path, interpreter)
	else
		for _ = 1, 5, 1 do
			local result = run(script_path, interpreter)
			table.insert(results, result)
			print(string.format("One execution finished in %.3f seconds", result))
		end
		local result = balanced_average(results)
		print(string.format("Balanced average is %.3f seconds", result))
		return result
	end
end

if arg[1] then -- Check if an input script has been provided
	-- If yes, benchmark this specific script
	bench(arg[1], arg[2] or "lua")
else -- If not, just benchmark evry script

	print("Generating fresh data...")
	-- Create a fresh batch of data
	os.remove("./measurements.txt")
	require "createMeasurements"

	print("Data generated! Starting a full benchmark of evry scripts. This might take a while...")
	for _, script in pairs(scripts) do
		script.result = bench(script.path, script.interpreter)
	end
	-- Sort the table to give the results in order
	table.sort(scripts, function (i,j) return i.result < j.result end)
	print("Finished Benchmarking evry script ! Here are the results:")
	for i, script in pairs(scripts) do
		print(string.format("Number %d: %s with %s interpreter runs in %.3f seconds average", i, script.path, script.interpreter, script.result))
	end
end
