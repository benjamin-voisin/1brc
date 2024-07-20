local measurments = io.open("measurements.txt", "rb")

local dic = {"Abha","Abidjan","Abéché","Accra","AddisAbaba","Adelaide","Aden","Ahvaz","Albuquerque","Alexandra","Alexandria","Algiers","AliceSprings","Almaty","Amsterdam","Anadyr","Anchorage","AndorralaVella","Ankara","Antananarivo","Antsiranana","Arkhangelsk","Ashgabat","Asmara","Assab","Astana","Athens","Atlanta","Auckland","Austin","Baghdad","Baguio","Baku","Baltimore","Bamako","Bangkok","Bangui","Banjul","Barcelona","Bata","Batumi","Beijing","Beirut","Belgrade","BelizeCity","Benghazi","Bergen","Berlin","Bilbao","Birao","Bishkek","Bissau","Blantyre","Bloemfontein","Boise","Bordeaux","Bosaso","Boston","Bouaké","Bratislava","Brazzaville","Bridgetown","Brisbane","Brussels","Bucharest","Budapest","Bujumbura","Bulawayo","Burnie","Busan","CaboSanLucas","Cairns","Cairo","Calgary","Canberra","CapeTown","Changsha","Charlotte","ChiangMai","Chicago","Chihuahua","Chișinău","Chittagong","Chongqing","Christchurch","CityofSanMarino","Colombo","Columbus","Conakry","Copenhagen","Cotonou","Cracow","DaLat","DaNang","Dakar","Dallas","Damascus","Dampier","DaresSalaam","Darwin","Denpasar","Denver","Detroit","Dhaka","Dikson","Dili","Djibouti","Dodoma","Dolisie","Douala","Dubai","Dublin","Dunedin","Durban","Dushanbe","Edinburgh","Edmonton","ElPaso","Entebbe","Erbil","Erzurum","Fairbanks","Fianarantsoa","Flores,Petén","Frankfurt","Fresno","Fukuoka","Gabès","Gaborone","Gagnoa","Gangtok","Garissa","Garoua","GeorgeTown","Ghanzi","GjoaHaven","Guadalajara","Guangzhou","GuatemalaCity","Halifax","Hamburg","Hamilton","HangaRoa","Hanoi","Harare","Harbin","Hargeisa","HatYai","Havana","Helsinki","Heraklion","Hiroshima","HoChiMinhCity","Hobart","HongKong","Honiara","Honolulu","Houston","Ifrane","Indianapolis","Iqaluit","Irkutsk","Istanbul","İzmir","Jacksonville","Jakarta","Jayapura","Jerusalem","Johannesburg","Jos","Juba","Kabul","Kampala","Kandi","Kankan","Kano","KansasCity","Karachi","Karonga","Kathmandu","Khartoum","Kingston","Kinshasa","Kolkata","KualaLumpur","Kumasi","Kunming","Kuopio","KuwaitCity","Kyiv","Kyoto","LaCeiba","LaPaz","Lagos","Lahore","LakeHavasuCity","LakeTekapo","LasPalmasdeGranCanaria","LasVegas","Launceston","Lhasa","Libreville","Lisbon","Livingstone","Ljubljana","Lodwar","Lomé","London","LosAngeles","Louisville","Luanda","Lubumbashi","Lusaka","LuxembourgCity","Lviv","Lyon","Madrid","Mahajanga","Makassar","Makurdi","Malabo","Malé","Managua","Manama","Mandalay","Mango","Manila","Maputo","Marrakesh","Marseille","Maun","Medan","Mek'ele","Melbourne","Memphis","Mexicali","MexicoCity","Miami","Milan","Milwaukee","Minneapolis","Minsk","Mogadishu","Mombasa","Monaco","Moncton","Monterrey","Montreal","Moscow","Mumbai","Murmansk","Muscat","Mzuzu","N'Djamena","Naha","Nairobi","NakhonRatchasima","Napier","Napoli","Nashville","Nassau","Ndola","NewDelhi","NewOrleans","NewYorkCity","Ngaoundéré","Niamey","Nicosia","Niigata","Nouadhibou","Nouakchott","Novosibirsk","Nuuk","Odesa","Odienné","OklahomaCity","Omaha","Oranjestad","Oslo","Ottawa","Ouagadougou","Ouahigouya","Ouarzazate","Oulu","Palembang","Palermo","PalmSprings","PalmerstonNorth","PanamaCity","Parakou","Paris","Perth","Petropavlovsk-Kamchatsky","Philadelphia","PhnomPenh","Phoenix","Pittsburgh","Podgorica","Pointe-Noire","Pontianak","PortMoresby","PortSudan","PortVila","Port-Gentil","Portland(OR)","Porto","Prague","Praia","Pretoria","Pyongyang","Rabat","Rangpur","Reggane","Reykjavík","Riga","Riyadh","Rome","Roseau","Rostov-on-Don","Sacramento","SaintPetersburg","Saint-Pierre","SaltLakeCity","SanAntonio","SanDiego","SanFrancisco","SanJose","SanJosé","SanJuan","SanSalvador","Sana'a","SantoDomingo","Sapporo","Sarajevo","Saskatoon","Seattle","Ségou","Seoul","Seville","Shanghai","Singapore","Skopje","Sochi","Sofia","Sokoto","Split","St.John's","St.Louis","Stockholm","Surabaya","Suva","Suwałki","Sydney","Tabora","Tabriz","Taipei","Tallinn","Tamale","Tamanrasset","Tampa","Tashkent","Tauranga","Tbilisi","Tegucigalpa","Tehran","TelAviv","Thessaloniki","Thiès","Tijuana","Timbuktu","Tirana","Toamasina","Tokyo","Toliara","Toluca","Toronto","Tripoli","Tromsø","Tucson","Tunis","Ulaanbaatar","Upington","Ürümqi","Vaduz","Valencia","Valletta","Vancouver","Veracruz","Vienna","Vientiane","Villahermosa","Vilnius","VirginiaBeach","Vladivostok","Warsaw","Washington,D.C.","Wau","Wellington","Whitehorse","Wichita","Willemstad","Winnipeg","Wrocław","Xi'an","Yakutsk","Yangon","Yaoundé","Yellowknife","Yerevan","Yinchuan","Zagreb","ZanzibarCity","Zürich"}

if jit then
	-- If using LuaJIT, we can use table.new to initialize table with a given size
	require "table.new"
else
	-- Else, we just create an empty table
	table.new = function () return {} end
end

local page_size = 4096 * 8 -- Reading file page by page is faster

if not measurments then
	io.stderr:write("measurements.txt file not found\n")
	os.exit(1)
end

local buff = require "string.buffer"
local socket = require "socket"

collectgarbage("stop") -- Stop the GC (we will run it manually for better performances)

-- To allow real parralelization, we basically re-run the same script, with its
-- fist argument being "w" to differenciate a "worker" from the main thread
-- that spawns them. It also gets the positions in the file to work on.
if arg[1] == "w" then
	-- Case for juste a worker

	local start_pos = tonumber(arg[2])
	local end_pos = tonumber(arg[3])
	measurments:seek("set", start_pos)
	local first_line = measurments:read() -- Always skip first line. Evry workers will use 1 line more than whats required, but miss the first. So only the first line of the file will be omitted
	-- size_to_read is here to make sure that reads are done by pages (multiples of page_size)
	local to_read = end_pos - start_pos - #first_line
	local size_to_read = page_size - #first_line
	local read = #first_line

	-- We initialize with 512 possibles city values
	local results = table.new(0, 512)

	-- Assign local values to often used functions.
	-- This reduce overhead as local variables are faster to obtain in lua.
	local get_ch = string.byte
	local s = string.sub
	local gc = collectgarbage

	-- This table will contains the numbers read. It is recycled to be used
	-- for evry lines, so only on table is creted
	local t = {0,0,0,0,0}
	local t_length = 0
	local city_start = 0
	-- Value to determine wether we are reading a city name or a temperature
	local is_number = false
	local iter = 1
	local city = buff.new(100, {dict = dic})
	local city_beg = nil
	local feur

	while read < to_read do

		-- We do one GC step evry 1000 reads
		if iter % 1000 == 0 then
			gc("step")
		end
		iter = iter + 1

		feur = measurments:read(size_to_read)
		read = read + size_to_read
		size_to_read = page_size

		-- To avoid creating string as much as possible, we iterate char by char
		-- over the read chunck
		if feur then
			for i = 1, #feur, 1 do
				-- We get the ascii value for the char
				local c = get_ch(feur, i)
				if c == 59 then -- reads a ;
					-- We finished reading a city name
					if not city_beg then
						-- The city name is entierly in the current chunk
						city:set(s(feur, city_start, i - 1))
					else
						-- The city name began in the previous chunk
						city:set(city_beg..s(feur, 0, i-1))
						city_beg = nil
					end
					is_number = true

				elseif c == 10 then -- reads a \n
					-- We finished reading a temperature, tho the next thing
					-- we'll be reading is a city name
					city_start = i + 1

					-- Conversion from the table containing the ASCII of the
					-- temperature to an int
					-- the temperature is multiplied by 10 to work with integers
					local n
					if t[1] == 45 then
						if t[3] == 46 then
							n = -10 * ((t[2] - 48) + ((t[4] - 48) / 10))
						else
							n = -10 * (((t[2] - 48)*10) + (t[3] - 48) +  ((t[5] - 48) / 10))
						end
					else
						if t [2] == 46 then
							n = 10 * ((t[1] - 48) + ((t[3] - 48) / 10))
						else
							n = 10 * (((t[1] - 48)*10) + (t[2] - 48) +  ((t[4] - 48) / 10))
						end
					end
					is_number = false
					t_length = 0

					-- Adding the result to the result table
					local result = results[city:tostring()]
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
						results[city:tostring()] = {n, n, n, 1}
					end
				elseif is_number then
					t_length = t_length + 1
					t[t_length] = c
				end

			end
			-- Check if we stop while reading a city name
			if not is_number then
				-- We save the part in the current chunk in the city_beg variable
				city_beg = s(feur, city_start, #feur)
			else
				city_beg = nil
			end
		end
	end
	-- We repeat the whole char iteration over one new line. This is done to
	-- make sure evry lines are read, while the multi-threading slicing might
	-- give chunk that splits line. Evry worker skips first line, and read one
	-- more line that asked, so only the very first line of the file is
	-- missed (and is catched by the main thread)
	local remaining_line = measurments:read()
	if remaining_line then
		-- Same iteration as before. Some variable assignation have been removed
		-- as they become useless when we know it's the last line that we will parse
		for j = 1, #remaining_line do
			local c = get_ch(remaining_line, j)

			if c == 59 then -- reads a ;

				if not city_beg then
					city:set(s(remaining_line, 0, j - 1))
				else
					city:set(city_beg..s(feur, 0, j-1))
				end
				is_number = true

			elseif c == 10 then -- reads a \n

				local n
				if t[1] == 45 then
					if t[3] == 46 then
						n = -10 * ((t[2] - 48) + ((t[4] - 48) / 10))
					else
						n = -10 * (((t[2] - 48)*10) + (t[3] - 48) +  ((t[5] - 48) / 10))
					end
				else
					if t [2] == 46 then
						n = 10 * ((t[1] - 48) + ((t[3] - 48) / 10))
					else
						n = 10 * (((t[1] - 48)*10) + (t[2] - 48) +  ((t[4] - 48) / 10))
					end
				end
				local result = results[city:tostring()]
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
					results[city:tostring()] = {n, n, n, 1}
				end
			elseif is_number then
				t_length = t_length + 1
				t[t_length] = c
			end
		end
	end

	-- Outputs the worker results to its stdout the main thread can get them
	for city, value in pairs(results) do
		io.write(city,";",value[1],";",value[2],";",value[3],";",value[4],"\n")
	end
	measurments:close()
else
	-- We are in the main thread case

	local function getCPUCount() -- Copied from MikuAuahDark solution
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

	-- We initialize with 512 possibles city values
	local results = table.new(0, 512)

	local size = measurments:seek("end")
	measurments:seek("set")

	local n_cpu = getCPUCount() or 4
	local slices = table.new(n_cpu, 0)
	local slice_start = 0
	local slice_size = math.floor(size / n_cpu)
	slice_size = slice_size + - (slice_size % page_size) + page_size - 1

	-- We compute slices so that their sizes are multiples of page_size
	for i = 1, n_cpu, 1 do
		local slice_end = math.min(slice_start + slice_size, size)
		slices[i] = { slice_start, slice_end }
		print(slice_end)
		slice_start = slice_end + 1
	end

	local workers = table.new(n_cpu, 0)

	-- Spawn workers
	for i = 1, n_cpu, 1 do -- Copied from MikuAuahDark solution
		-- We just re-execute the same script, with the same interpreter/compiler
		-- and give it slice positions as arguments.
		-- This allows real parralelization
		local cmd = arg[-1].." "..arg[0].." w "..slices[i][1].." "..slices[i][2]
		workers[i] = io.popen(cmd, "r")
	end

	-- Compute the first line, as it is ignored by the first worker
	local first_line = measurments:lines()()
	local c1, t1 = first_line:match("(.*);(.*)")
	results[c1] = { tonumber(t1), tonumber(t1), tonumber(t1), 1 }
	measurments:close()

	local first = true
	local time = socket.gettime()
	local end_time

	-- Collect results
	for i = 1, n_cpu do
		workers[i]:read("*a")
		print("Got worker", i)
		-- for line in workers[i]:lines() do
		-- 	if first then
		-- 		end_time = socket.gettime()
		-- 		print(end_time - time)
		-- 		first = false
		-- 	end
		-- 	local name, mintemp, maxtemp, sum, occurences = line:match("(.*);(.*);(.*);(.*);(.*)")
		-- 	if results[name] then
		-- 		local r = results[name]
		-- 		r[3] = r[3] + tonumber(sum)
		-- 		r[4] = r[4] + tonumber(occurences)
		-- 		if tonumber(mintemp) < r[1] then
		-- 			r[1] = tonumber(mintemp)
		-- 		end
		-- 		if tonumber(maxtemp) > r[2] then
		-- 			r[2] = tonumber(maxtemp)
		-- 		end
		-- 	else
		-- 		results[name] = { tonumber(mintemp), tonumber(maxtemp), tonumber(sum), tonumber(occurences) }
		-- 	end
		-- end
		workers[i]:close()
	end
	print("All results collected in", socket.gettime() - time)


	-- We need to sort the results alphabetically for the final output.
	-- We do this by first putting all results in an array (instead of the
	-- hash-map), and then sort the array
	local t = table.new(512, 0)
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

	-- Simple function to round up temperatures
	local function theRounding(v) -- Copied from MikuAuahDark solution

		if v < 0 then
			return math.ceil(v - 0.5)
		else
			return math.floor(v + 0.5)
		end
	end

	-- We finally outputs the results
	io.write("{")
	local first = true
	for _, value in pairs(t) do
		local city = value.city
		local result = value.result
		local mean = theRounding(result[3] / result[4]) / 10
		if first then
			io.write(city, "=", number_to_string(result[1] / 10), "/", number_to_string(mean), "/", number_to_string(result[2] / 10))
			first = false
		else
			io.write(", ",city, "=", number_to_string(result[1] / 10), "/", number_to_string(mean), "/", number_to_string(result[2] / 10))
		end
	end
	io.write("}\n")
	-- print("Time since first result :", socket.gettime() - end_time)
end
