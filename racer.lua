-- name: Гонки
menu.holdExit(2500)
local function rnd(n) return math.random(1, n) end
math.randomseed(time.now() % 100000)
local rec = score.get()
local px, cx, road, spd, dist, cars, gap, dash, en
local function reset()
  px, cx, road, spd, dist, gap, dash, en = 64, 64, 0, 1.5, 0, 700, 0, 0
  cars = {}
end
local function carDraw(x, y)
  if x < 8 or x > 120 then return end
  oled.rect(x - 6, y, 12, 9, true)
  oled.rect(x - 2, y + 1, 4, 2)
  oled.rect(x - 6, y + 2, 1, 5)
  oled.rect(x + 5, y + 2, 1, 5)
end
local function over()
  while true do
    oled.clear()
    oled.textBig(22, 12, "АВАРИЯ!")
    oled.text(2, 34, "Дистанция:" .. dist)
    oled.text(2, 44, "Рекорд: " .. rec)
    oled.text(20, 58, "нажми — рестарт")
    oled.text(88, 58, "3с-выход")
    oled.flush()
    if joy.click() then reset() return end
    joy.btn()
    time.sleep(28)
  end
end
reset()
while true do
  local d = joy.dir()
  if d == "left" then px = px - 3 end
  if d == "right" then px = px + 3 end
  if px < cx - 16 then cx = cx - 16 end
  if px > cx + 16 then cx = cx + 16 end
  local lim = 8 + (cx - 64) * 0.5
  if px < lim then px = lim end
  if px > 120 - lim then px = 120 - lim end
  spd = spd + 0.02
  if spd > 6 then spd = 6 end
  dist = dist + math.floor(spd)
  local step = math.floor(spd + 0.5)
  road, dash = road + step, dash + step
  while dash >= 16 do dash = dash - 16 end
  oled.clear()
  oled.rect(6, 0, 116, 64)
  oled.line(28, 0, 28, 63)
  oled.line(44, 0, 44, 63)
  oled.line(60, 0, 60, 63)
  oled.line(68, 0, 68, 63)
  oled.line(84, 0, 84, 63)
  oled.line(100, 0, 100, 63)
  local k = dash
  while k < 64 do
    oled.line(20, k, 20, k + 6)
    oled.line(36, k, 36, k + 6)
    oled.line(52, k, 52, k + 6)
    oled.line(76, k, 76, k + 6)
    oled.line(92, k, 92, k + 6)
    oled.line(108, k, 108, k + 6)
    k = k + 16
  end
  local t = (road + 16) % 32
  for i = 1, 2 do
    local y = t + (i - 1) * 32
    while y < 64 do
      oled.rect(1, y, 3, 8, true)
      oled.rect(124, y, 3, 8, true)
      y = y + 32
    end
  end
  gap = gap - math.floor(spd)
  if gap <= 0 then
    en = en + 1
    cars[en] = { x = 12 + (rnd(5) - 1) * 22 + 11, y = -12 }
    gap = 460 + rnd(520) - math.floor(spd * 40)
    if gap < 200 then gap = 200 end
  end
  for i = 1, en do
    local c = cars[i]
    if c then
      c.y = c.y + math.floor(spd + 1)
      if c.y > 62 then cars[i] = nil
      else
        carDraw(c.x, c.y)
        if math.abs(c.x - px) < 11 and c.y + 8 > 52 and c.y < 62 then over() end
      end
    end
  end
  oled.rect(cx - 8, 52, 16, 10, true)
  oled.rect(cx - 3, 54, 6, 2)
  oled.text(0, 55, tostring(dist))
  oled.text(92, 55, "3с-выход")
  oled.flush()
  time.sleep(28)
end
