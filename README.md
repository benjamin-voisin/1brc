# 1BRC: One Billion Row Challenge in Lua

Lua implementation of Gunnar's 1 billion row challenge:
- https://www.morling.dev/blog/one-billion-row-challenge
- https://github.com/gunnarmorling/1brc

## Rules

No dependencies allowed, only lua standard library, and no C (this include the ffi lib of luajit). The programm should work in a standalone file. Lua or LuaJIT are allowed.

### Input

The input file is a list of temperature measurments in some cities. The form il of:
```
City;temperature
City;temperature
(...)
City;temperature
```
- It is UTF-8 encoded.
- city names could have spaces or hyphens in it, but it is garenteed that they do not contain semicolons `;`.
- Temperatures range frome -99.0 to 99.0, and always contains one decimal digit. So you could have : `1.3`, `-7.4`, `48.4`, `-61.1`.

The script to generate the data only contains ~400 cities, but the solution shold not depend on theese. It should work no matter the set and the number of cities.

### Output

The output should be of the form
```
{City1=min/mean/max, City2=min/mean/max, (...), Cityn=min/mean/max}
```
With the cities arranged in an alphabetical order.

## Creating the measurements file with 1B rows

Just run the scrit "createMeasurements.lua" with lua or luajit (it is much faster with luajit):
```shell
luajit ./createMeasurements.lua
```
or
```shell
lua ./createMeasurements.lua
```

Be patient as it can take more than a minute to have the file generated.

Optionnally, you can pass extra arguments to the script :
- The first one for the number of rows (default = 1 000 000 000)
- The second one for the output file (default = ./measurements.txt)
