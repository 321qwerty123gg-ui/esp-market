-- name: Танчики
menu.holdExit(2500)
local function rnd(n) return math.random(1, n) end
math.randomseed(time.now() % 100000)
local D = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }
local DIR = { up = 1, down = 2, left = 3, right = 4 }
local SP = { { 15, 1 }, { 1, 1 }, { 1, 11 }, { 15, 11 }, { 8, 8 } }
local mz = {
"................",".SS..BB..BB..SS.","...B.B..B..B....",".B.B.B.BBB.B.B..",
".B...B......B.S.",".BB.BBB.BBBB.B..",".B..B...W...B...",".B.BBBBB.BB.SS..",
".B.B...B......B.","...B.B.BBBBB.B..",".BBB.B........B.",".B...BW..BB....."}
local map, p, en, bl, lv, sc, rec, fr, inv, spT, pk, pv = {}
for y = 1, 12 do
  local row = {}
  for ch in mz[y]:gmatch("[.%a]") do
    row[#row + 1] = (ch == "B" and 1) or (ch == "S" and 2) or (ch == "W" and 3) or 0
  end
  map[y] = row
end
local function walk(c, r) return c > 0 and c < 17 and r > 0 and r < 13 and map[r][c] ~= 1 and map[r][c] ~= 2 end
local function near(a, b) return math.abs(a - b) < 5 end
local function px(c) return (c - 1) * 8 + 4 end
local function py(r) return (r - 1) * 5 + 2 end
local function inEnemy(x, y)
  for j = 1, #en do
    local e = en[j]
    if near(x, px(e.c)) and near(y, py(e.r)) then table.remove(en, j) return true end end
  return false end
local function shoot(pow, c, r, d)
  if #bl < 8 then bl[#bl + 1] = { x = px(c), y = py(r), d = d, pow = pow } end end
local function put()
  if #en >= 3 then return end
  for i = 1, 5 do
    local q, ok = SP[i], math.abs(SP[i][1] - p.c) + math.abs(SP[i][2] - p.r) >= 7
    for j = 1, #en do if en[j].c == q[1] and en[j].r == q[2] then ok = false end end
    if ok then en[#en + 1] = { c = q[1], r = q[2], d = 2, mv = rnd(150), ft = 600 + rnd(900) } return end end end
local function step()
  for i = #bl, 1, -1 do
    local b, v = bl[i], D[bl[i].d]
    b.x, b.y = b.x + v[1] * 3, b.y + v[2] * 3
    local c, r = math.floor(b.x / 8) + 1, math.floor(b.y / 5) + 1
    local off = b.x < 0 or b.x > 128 or b.y < 0 or b.y > 60
    if not off and map[r] and map[r][c] >= 1 then if map[r][c] == 1 then map[r][c] = 0 end; off = true end
    if not off and b.pow and inEnemy(b.x, b.y) then pk, sc, off = 14, sc + 100, true end
    if not off and not b.pow and inv <= 0 and near(b.x, px(p.c)) and near(b.y, py(p.r)) then off = true end
    if off then table.remove(bl, i) end
  end
end
local function tank(c, r, d)
  local x, y = (c - 1) * 8 + 1, (r - 1) * 5
  oled.rect(x, y, 6, 5, true)
  if d == 1 then oled.rect(x + 2, y - 2, 2, 3, true)
  elseif d == 2 then oled.rect(x + 2, y + 5, 2, 3, true)
  elseif d == 3 then oled.rect(x - 2, y + 1, 3, 3, true)
  else oled.rect(x + 6, y + 1, 3, 3, true) end
end
local function reset()
  p, en, bl, rec = { c = 8, r = 9, d = 1, mv = 0 }, {}, {}, score.get() or 0
  lv, sc, fr, inv, spT, pk, pv = 3, 0, 0, 0, 400, 0, time.now()
end
local function finish()
  if score.set(sc) then
    rec = sc
    local t0 = time.now()
    while time.now() - t0 < 1000 do
      oled.clear(); oled.textBig(8, 14, "НОВЫЙ РЕКОРД!"); oled.text(2, 40, "Счёт: " .. sc)
      oled.flush(); joy.btn(); time.sleep(28)
    end
  end
  while true do
    oled.clear(); oled.textBig(26, 12, "ИГРА"); oled.textBig(26, 30, "ОКОНЧЕНА")
    oled.text(0, 48, "Сч:" .. sc .. " Рекорд:" .. rec)
    oled.text(20, 58, "нажми — рестарт"); oled.text(0, 62, "3с-выход")
    oled.flush()
    if joy.click() then reset(); return end
    joy.btn(); time.sleep(28)
  end
end
reset()
while true do
  fr = fr + 1
  local n, lost, click, dt, now = DIR[joy.dir()], false, joy.click(), 0, time.now()
  dt = now - pv
  if dt > 150 then dt = 150 end; pv = now
  oled.clear()
  for r = 1, 12 do
    for c = 1, 16 do
      local m, x, y = map[r][c], (c - 1) * 8, (r - 1) * 5
      if m == 1 then
        oled.rect(x, y, 8, 5, true)
        oled.pixel(x + 1, y + 1); oled.pixel(x + 5, y + 3)
      elseif m == 2 then
        oled.rect(x, y, 8, 5, true); oled.rect(x + 1, y + 1, 6, 3)
      elseif m == 3 then oled.rect(x, y, 8, 5) end
    end
  end
  p.mv = n and p.mv + dt or 0
  if n and p.mv >= 165 then
    local v = D[n]
    if walk(p.c + v[1], p.r + v[2]) then p.d, p.c, p.r, p.mv = n, p.c + v[1], p.r + v[2], 0
    else p.mv = 165 end
  end
  if click then shoot(true, p.c, p.r, p.d) end
  spT = spT - dt
  if spT <= 0 then put(); spT = 900 end
  for i = 1, #en do
    local e = en[i]
    e.mv, e.ft = e.mv + dt, e.ft - dt
    if e.mv >= 190 then
      e.mv = 0
      local v = D[rnd(4)]
      if p.r < e.r and walk(e.c, e.r - 1) then e.r, e.d = e.r - 1, 1
      elseif p.r > e.r and walk(e.c, e.r + 1) then e.r, e.d = e.r + 1, 2
      elseif p.c < e.c and walk(e.c - 1, e.r) then e.c, e.d = e.c - 1, 3
      elseif p.c > e.c and walk(e.c + 1, e.r) then e.c, e.d = e.c + 1, 4
      elseif walk(e.c + v[1], e.r + v[2]) then e.c, e.r = e.c + v[1], e.r + v[2] end end
    if e.ft <= 0 then
      e.ft = 1300 + rnd(1400)
      local aim = (e.c == p.c and ((e.r < p.r and e.d == 2) or (e.r > p.r and e.d == 1)))
        or (e.r == p.r and ((e.c < p.c and e.d == 4) or (e.c > p.c and e.d == 3)))
      if aim and math.abs(e.c - p.c) + math.abs(e.r - p.r) < 12 then shoot(false, e.c, e.r, e.d) end end
    if e.c == p.c and e.r == p.r and inv <= 0 then
      lv = lv - 1
      if lv <= 0 then lost = true else p.c, p.r, p.d, inv = 8, 9, 1, 1800 end end
  end
  step()
  if inv > 0 then inv = inv - dt end
  if not (inv > 0 and math.floor(fr / 4) % 2 == 1) then tank(p.c, p.r, p.d) end
  for i = 1, #en do tank(en[i].c, en[i].r, en[i].d) end
  if pk > 0 then
    pk = pk - 1
    if en[1] then
      local x, y = (en[1].c - 1) * 8 + 1, (en[1].r - 1) * 5
      oled.rect(x, y, 6, 5); oled.pixel(x + 2, y + 2); oled.pixel(x + 3, y + 1) end end
  for i = 1, #bl do oled.rect(bl[i].x - 1, bl[i].y - 1, 3, 3, true) end
  oled.text(0, 62, "Ж" .. lv .. " Сч:" .. sc .. " Р:" .. rec); oled.flush()
  if lost then finish() end
  time.sleep(28)
end
