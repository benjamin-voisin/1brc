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

## Results

The baseline is `baseline.lua`, and your output should match this one.

On my laptop (Ryzen 5  7640 12 cores, 32GB RAM) :

| # | Result (m:s.ms) | Implementation     | Interpreter | Submitter     |
|---|-----------------|--------------------|-----|---------------|
| 1.|        00:10:915 |  [1brc_BenjaminV.lua](https://github.com/benjamin-voisin/1brc/blob/main/1brc_BenjaminV.lua)   | luajit 2.1 | [benjamin-voisin](https://github.com/benjamin-voisin) |
| 2.|        00:11:282 |  [1brc_felipeguilhermefs.lua](https://github.com/benjamin-voisin/1brc/blob/main/1brc_felipeguilhermefs.lua) | luajit 2.1 | [felipeguilhermefs](https://github.com/felipeguilhermefs)
| 3.|        00:44:864 |  [1brc_MikuAuahDark.lua](https://gist.github.com/MikuAuahDark/8cdbe5827a32e65157005e7163a4b9cc) | luajit 2.1 | [MikuAuahDark](https://github.com/MikuAuahDark)
| 3.|        01:30:693 |  [1brc_BenjaminV.lua](https://github.com/benjamin-voisin/1brc/blob/main/1brc_BenjaminV.lua)   | lua 5.4 | [benjamin-voisin](https://github.com/benjamin-voisin) |
| 4.|        05:51:029 |  [baseline.lua](https://github.com/benjamin-voisin/1brc/blob/main/baseline.lua)   | luajit 2.1 | baseline |
| 5.|        08:57:189 |  [baseline.lua](https://github.com/benjamin-voisin/1brc/blob/main/baseline.lua)   | lua 5.4 | baseline |

For comparaison with other languages, on the same machine, the fastest Python Implementation I found runs for 25 seconds [link](https://github.com/ifnesi/1brc#submitting), and from the original Java repository, the fastest Java implementation is ~3 seconds with the JVM and ~1 second when compiled to a native executable. So I'm very happy with the 10 seconds performance!

## Submissions

For any submissions please open a PR !
