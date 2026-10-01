-- name: 2048
menu.holdExit(2500)
oled.font(1)
local rec = score.get()
if type(rec) ~= "number" then rec = 0 end
local SX, SY, TS, GP = 3, 9, 29, 2
local g, sc, mx, state, msg, last, sd
local function rnd(n)
sd = math.floor(sd * 1103515245 + 12345)
if sd < 0 then sd = -sd end
return math.floor(sd % n) + 1
end
local function key(d)
if d == "up" then return 1 end
if d == "down" then return 2 end
if d == "left" then return 3 end
if d == "right" then return 4 end
return 0
end
local function lline(r, c, d)
local a, t = {}, {}
for i = 1, 4 do
if d == 1 or d == 2 then a[i] = g[r][i] else a[i] = g[i][c] end
end
for i = 1, 4 do
if a[i] ~= 0 then t[#t + 1] = a[i] end
end
local o, i, n = {}, 1, #t
while i <= n do
if i < n and t[i] == t[i + 1] then
o[#o + 1] = t[i] * 2
sc = sc + t[i] * 2
i = i + 2
else
o[#o + 1] = t[i]
i = i + 1
end
end
for k = #o + 1, 4 do o[k] = 0 end
if d == 1 or d == 4 then
local q = {}
for k = 1, 4 do q[k] = o[5 - k] end
o = q
end
local ch = false
for k = 1, 4 do
if a[k] ~= o[k] then ch = true end
if d == 1 or d == 2 then g[r][k] = o[k] else g[k][c] = o[k] end
end
return ch
end
local function mv(d)
local ch = false
for i = 1, 4 do
local e
if d == 1 or d == 2 then e = lline(i, 0, d) else e = lline(0, i, d) end
if e then ch = true end
end
return ch
end
local function tst(d)
local o = {}
for r = 1, 4 do for c = 1, 4 do o[r * 4 + c] = g[r][c] end end
local os = sc
local ch = mv(d)
for r = 1, 4 do for c = 1, 4 do g[r][c] = o[r * 4 + c] end end
sc = os
return ch
end
local function any()
return tst(1) or tst(2) or tst(3) or tst(4)
end
local function spn()
local e = {}
for r = 1, 4 do for c = 1, 4 do if g[r][c] == 0 then e[#e + 1] = r * 10 + c end end end
if #e == 0 then return end
local v = 2
if rnd(10) <= 2 then v = 4 end
local p = e[rnd(#e)]
g[math.floor(p / 10)][p % 10] = v
end
local function tmax()
local m = 0
for r = 1, 4 do for c = 1, 4 do if g[r][c] > m then m = g[r][c] end end end
return m
end
local function st()
sd, sc, state, msg, last = time.now() + 91, 0, "play", 0, time.now()
g = { { 0, 0, 0, 0 }, { 0, 0, 0, 0 }, { 0, 0, 0, 0 }, { 0, 0, 0, 0 } }
spn() spn()
mx = tmax()
end
st()
time.sleep(400)
while true do
local now = time.now()
oled.clear()
oled.text(34, 8, "Счёт: " .. sc)
oled.text(30, 17, "Рекорд: " .. rec)
for r = 1, 4 do
for c = 1, 4 do
local x = SX + (c - 1) * (TS + GP)
local y = SY + (r - 1) * (TS + GP)
local v = g[r][c]
oled.rect(x, y, TS, TS, v > 0)
if v > 0 then
local s = tostring(v)
local w = string.len(s) * 6
if v > 999 then oled.text(x + 14 - string.len(s) * 2, y + 24, s)
else oled.textBig(x + 14 - math.floor(w / 2), y + 16, s) end
end
end
end
if state == "over" then
if joy.click() then st() end
oled.text(42, 47, "Ходов нет")
oled.text(26, 56, "Кнопка - заново")
else
local k = key(joy.dir())
if k > 0 and now - last > 150 then
last = now
if mv(k) then
spn() mx = tmax()
if mx > rec then
rec, msg = mx, now
score.set(rec)
end
if not any() then state = "over" end
end
end
end
if now - msg < 1000 then
oled.text(22, 33, "НОВЫЙ РЕКОРД!")
end
oled.text(2, 63, "3с - выход")
oled.flush()
joy.click()
time.sleep(28)
end
