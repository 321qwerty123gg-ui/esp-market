-- name: Gradius
menu.holdExit(2500)
local function rnd(n) return math.random(1, n) end
math.randomseed(time.now() % 100000)
local rec = score.get() or 0
local sx, sy, lv, sc, fr, wv, inv, wt, eb, en, es, sb, st, pv
local function reset()
  sx, sy, lv, sc, fr, wv, inv, wt = 20, 32, 3, 0, 0, 1, 1500, 2600
  eb, en, es, sb, st = {}, {}, {}, {}, {}
  for i = 1, 14 do st[i] = { x = rnd(120), y = rnd(60), s = 1 + (i % 3) } end
  pv = time.now() end
local function wave()
  local n = 1
  if wv > 2 then n = 2 end
  if wv > 5 then n = 3 end
  for i = 1, n do es[#es + 1] = { x = 138, y = 8 + rnd(48), sq = i > 1 and 1 or 0 } end
  wv = wv + 1 end
local function hurt()
  lv = lv - 1
  if lv <= 0 then return true end
  sx, sy, inv, eb = 20, 32, 1800, {}
  return false end
local function record()
  if score.set(sc) then
    rec = sc
    local t0 = time.now()
    while time.now() - t0 < 1000 do
      oled.clear(); oled.textBig(8, 14, "НОВЫЙ РЕКОРД!"); oled.text(2, 40, "Счёт: " .. sc)
      oled.flush(); joy.btn(); time.sleep(28) end end end
local function over()
  while true do
    oled.clear(); oled.textBig(26, 12, "ИГРА"); oled.textBig(26, 30, "ОКОНЧЕНА")
    oled.text(0, 48, "Сч:" .. sc .. " Рекорд:" .. rec)
    oled.text(20, 58, "нажми — рестарт"); oled.text(0, 62, "3с-выход")
    oled.flush()
    if joy.click() then reset() return end
    joy.btn(); time.sleep(28) end end
reset(); wave()
while true do
  fr = fr + 1
  local now, dt, ax, ay = time.now(), 0, 0, 0
  local d = joy.dir()
  if d == "left" then ax = -1 end
  if d == "right" then ax = 1 end
  if d == "up" then ay = -1 end
  if d == "down" then ay = 1 end
  dt = now - pv
  if dt > 150 then dt = 150 end
  pv = now
  if ax ~= 0 and ay ~= 0 then if fr % 2 == 0 then ay = 0 else ax = 0 end end
  sx, sy = sx + ax * 2, sy + ay * 2
  if sx < 10 then sx = 10 end; if sx > 84 then sx = 84 end
  if sy < 6 then sy = 6 end; if sy > 56 then sy = 56 end
  local my = sy - 2
  if joy.click() and #sb < 3 then sb[#sb + 1] = { x = sx + 7, y = sy } end
  if inv > 0 then inv = inv - dt end; wt = wt - dt
  if wt <= 0 then wave(); wt = 2400 - wv * 70; if wt < 800 then wt = 800 end end
  oled.clear()
  for i = 1, 14 do
    local s = st[i]
    s.x = s.x - s.s
    if s.x < 0 then s.x = 124; s.y = rnd(60) end
    oled.pixel(s.x, s.y) end
  local mort = false
  for i = #en, 1, -1 do
    local e = en[i]
    e.x = e.x - (2 + math.floor(wv / 3))
    if e.x < -10 then table.remove(en, i) else
      oled.rect(e.x - 3, e.y - 2, 5, 5, true)
      if inv <= 0 and e.x - 3 < sx + 7 and e.x + 2 > sx and e.y - 2 < sy + 3 and e.y + 3 > my then
        table.remove(en, i)
        if hurt() then mort = true end
      elseif #eb < 4 and e.x > sx and rnd(70) < 2 then eb[#eb + 1] = { x = e.x - 2, y = e.y } end end end
  for i = #es, 1, -1 do
    local e = es[i]
    e.x = e.x - (2 + math.floor(wv / 4))
    if e.sq == 1 then e.y = 30 + math.floor(22 * math.sin(fr / 9)) end
    if e.x < -10 then table.remove(es, i) else
      oled.rect(e.x - 4, e.y - 2, 5, 4, true); oled.pixel(e.x - 5, e.y)
      if inv <= 0 and e.x - 4 < sx + 7 and e.x + 1 > sx and e.y - 2 < sy + 3 and e.y + 2 > my then
        table.remove(es, i)
        if hurt() then mort = true end end end end
  for i = #sb, 1, -1 do
    local b = sb[i]
    b.x = b.x + 5
    local gone = b.x > 132
    if not gone then
      for j = #en, 1, -1 do
        local e = en[j]
        if math.abs(e.x - b.x) < 5 and math.abs(e.y - b.y) < 4 then
          table.remove(en, j); sc, gone = sc + 30, true end end
      for j = #es, 1, -1 do
        local e = es[j]
        if math.abs(e.x - b.x) < 6 and math.abs(e.y - b.y) < 3 then
          table.remove(es, j); sc, gone = sc + 50, true end end end
    if gone then table.remove(sb, i) else oled.rect(b.x, b.y, 4, 1, true) end end
  for i = #eb, 1, -1 do
    local b = eb[i]
    b.x = b.x - 4
    if b.x < sx - 6 then table.remove(eb, i) else
      oled.rect(b.x - 4, b.y, 4, 2, true)
      if inv <= 0 and b.x - 4 < sx + 7 and b.x > sx and b.y + 2 > my and b.y < sy + 3 then
        table.remove(eb, i)
        if hurt() then mort = true end end end end
  if not (inv > 0 and math.floor(fr / 4) % 2 == 1) then
    oled.rect(sx, sy - 2, 6, 5, true); oled.pixel(sx + 4, sy - 3); oled.pixel(sx + 4, sy + 3) end
  oled.text(0, 0, "Сч:" .. sc .. " Ж:" .. lv); oled.text(88, 0, "Р:" .. rec)
  oled.text(88, 58, "3с-выход"); oled.flush()
  if mort then record() over() end
  time.sleep(28)
end
