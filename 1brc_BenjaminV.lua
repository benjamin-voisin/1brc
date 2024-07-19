local measurments = io.open("measurements.txt", "rb")

if jit then
	require "table.new"
else
	table.new = function () return {} end
end

local page_size = 4096 * 8

if not measurments then
	io.stderr:write("measurements.txt file not found\n")
	os.exit(1)
end

collectgarbage("stop")


if arg[1] == "w" then
	-- Case for juste a worker

	local line_iterator = measurments:lines()
	local start_pos = tonumber(arg[2])
	local end_pos = tonumber(arg[3])
	measurments:seek("set", start_pos)
	local first_line = line_iterator() -- Always skip first line. Evry workers will use 1 line more than whats required, but miss the first. So only the first line of the file will be omitted
	local to_read = end_pos - start_pos - #first_line
	local read = 0

	local results = table.new(0, 500)

	local get_ch = string.byte
	local s = string.sub

	local t = {0,0,0,0,0}
	local t_length = 0
	local city_start
	local city_end
	local is_number
	local iter = 1

	while read < to_read do
		city_start = 0
		city_end = 0
		is_number = false

		if iter % 1000 == 0 then
			collectgarbage("step")
		end
		iter = iter + 1

		local feur = measurments:read(page_size)
		local remaining_line = measurments:read()
		read = read + page_size

		if feur then
			for i = 1, #feur, 1 do
				local c = get_ch(feur, i)
				if c == 59 then -- reads a ;

					city_end = i - 1
					is_number = true

				elseif c == 10 then -- reads a \n

					local city = s(feur, city_start, city_end)
					city_start = i + 1

					local n
					if t[1] == 45 then
						if t[3] == 46 then
							n = -((t[2] - 48) + ((t[4] - 48) / 10))
						else
							n = -(((t[2] - 48)*10) + (t[3] - 48) +  ((t[5] - 48) / 10))
						end
					else
						if t [2] == 46 then
							n = ((t[1] - 48) + ((t[3] - 48) / 10))
						else
							n = (((t[1] - 48)*10) + (t[2] - 48) +  ((t[4] - 48) / 10))
						end
					end
					is_number = false
					t_length = 0
					local result = results[city]
					if result then
						result[3] = result[3] + n
						result[4] = result[4] + 1
						if n > result[2] then
							result[2] = n
						end
						if n < result[1] then
							result[1] = n
						end
					else
						results[city] = {n, n, n, 1}
					end
				elseif is_number then
					t_length = t_length + 1
					t[t_length] = c
				end

			end
		end
		if remaining_line then
			read = read + #remaining_line
			for j = 1, #remaining_line do
				local c = get_ch(remaining_line, j)
				if c == 59 then
					-- reads a ;
					city_end = j - 1
					is_number = true

				elseif c == 10 then
					-- reads a \n
					local city = s(feur, city_start, city_end)
					city_start = j + 1

					local n
					if t[1] == 45 then
						if t [3] == 46 then
							n = -((t[2] - 48) + ((t[4] - 48) / 10))
						else
							n = -(((t[2] - 48)*10) + (t[3] - 48) +  ((t[5] - 48) / 10))
						end
					else
						if t [2] == 46 then
							n = ((t[1] - 48) + ((t[3] - 48) / 10))
						else
							n = (((t[1] - 48)*10) + (t[2] - 48) +  ((t[4] - 48) / 10))
						end
					end

					is_number = false
					t_length = 0

					if results[city] then
						local result = results[city]
						result[3] = result[3] + n
						result[4] = result[4] + 1
						if n > result[2] then
							result[2] = n
						end
						if n < result[1] then
							result[1] = n
						end
					else
						results[city] = {n, n, n, 1}
					end
				elseif is_number then
					t_length = t_length + 1
					t[t_length] = c
				end
			end
		end
	end
	for city, value in pairs(results) do
		io.write(city,";",value[1],";",value[2],";",value[3],";",value[4],"\n")
	end
	measurments:close()
else
	-- Case for the main thread
	local results = table.new(0, 500)
	-- Results in the forme { min, max, sum, occurences
	local size = measurments:seek("end")
	measurments:seek("set")

	local n_cpu = 12 --Hard coded for my laptop, make it dynamic after
	local slices = table.new(n_cpu, 0)
	local slice_start = 0
	local slice_size = math.floor(size / n_cpu)
	slice_size = slice_size + - (slice_size % page_size) + page_size - 1
	for i = 1, n_cpu, 1 do
		local slice_end = math.min(slice_start + slice_size, size)
		slices[i] = { slice_start, slice_end }
		slice_start = slice_end + 1
	end
	local workers = table.new(n_cpu, 0)

	-- Spawn workers
	for i = 1, n_cpu, 1 do
		local cmd = arg[-1].." "..arg[0].." w "..slices[i][1].." "..slices[i][2]
		workers[i] = io.popen(cmd, "r")
	end

	-- Compute the first line, as it is ignored by the first worker
	local first_line = measurments:lines()()
	local c1, t1 = first_line:match("(.*);(.*)")
	results[c1] = { tonumber(t1), tonumber(t1), tonumber(t1), 1 }
	measurments:close()

	-- Collect results
	for i = 1, n_cpu do
		for line in workers[i]:lines() do
			local name, mintemp, maxtemp, sum, occurences = line:match("(.*);(.*);(.*);(.*);(.*)")
			if results[name] then
				local r = results[name]
				r[3] = r[3] + tonumber(sum)
				r[4] = r[4] + tonumber(occurences)
				if tonumber(mintemp) < r[1] then
					r[1] = tonumber(mintemp)
				end
				if tonumber(maxtemp) > r[2] then
					r[2] = tonumber(maxtemp)
				end
			else
				results[name] = { tonumber(mintemp), tonumber(maxtemp), tonumber(sum), tonumber(occurences) }
			end
		end
		workers[i]:close()
	end

	local t = table.new(500, 0)
	for city, result in pairs(results) do
		t[#t + 1] = { ["city"] = city, ["result"] = result}
	end
	table.sort(t, function (x,y) return (x.city < y.city) end)
	local function number_to_string(n)
		if n == math.floor(n) then
			return tostring(n)..".0"
		else
			return tostring(n)
		end
	end

	io.write("{")
	local first = true
	for _, value in pairs(t) do
		local city = value.city
		local result = value.result
		local mean = math.floor((result[3] / result[4]) * 10) / 10
		if first then
			io.write(city, "=", number_to_string(result[1]), "/", number_to_string(mean), "/", number_to_string(result[2]))
			first = false
		else
			io.write(", ",city, "=", number_to_string(result[1]), "/", number_to_string(mean), "/", number_to_string(result[2]))
		end
	end
	io.write("}\n")
end
