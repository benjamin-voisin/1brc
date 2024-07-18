# 1BRC: One Billion Row Challenge in Lua

Lua implementation of Gunnar's 1 billion row challenge:
- https://www.morling.dev/blog/one-billion-row-challenge
- https://github.com/gunnarmorling/1brc

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
