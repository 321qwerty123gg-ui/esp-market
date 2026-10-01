-- name: Трон
menu.holdExit(2500)
local rec = score.get() or 0
local banner = 0
local seed = time.now() % 2147483647
local function rnd(n)
  seed = (seed * 1103515245 + 12345) % 2147483648
  return seed % n
end
local dx, dy = {0, 1, 0, -1}, {-1, 0, 1, 0}
local rev = {3, 4, 1, 2}
local dirOf = {up = 1, right = 2, down = 3, left = 4}
local occ = {}
local p, a, pnew
local state, t0, last, fin = "start", 0, 0, 0
local function safe(x, y)
  if x < 1 or x > 32 or y < 1 or y > 16 then return false end
  return occ[(y - 1) * 32 + x] == 0
end
local function put(x, y, v) occ[(y - 1) * 32 + x] = v end
local function space(x, y, d, n)
  local s = 0
  for k = 1, n do
    if safe(x + dx[d] * k, y + dy[d] * k) then s = s + 1 else break end
  end
  return s
end
local function reset()
  for i = 1, 512 do occ[i] = 0 end
  p = {x = 6, y = 8, dir = 2}
  a = {x = 26, y = 8, dir = 4}
  put(6, 8, 1)
  put(26, 8, 2)
  pnew = nil
  t0, last, fin = time.now(), time.now(), 0
  state = "play"
end
local function finish()
  fin = math.floor((time.now() - t0) / 1000)
  if score.set(fin) then rec, banner = fin, time.now() end
end
local function step()
  if pnew then p.dir = pnew; pnew = nil end
  local nx, ny = p.x + dx[p.dir], p.y + dy[p.dir]
  if not safe(nx, ny) then
    finish()
    state = "over"
    return
  end
  p.x, p.y = nx, ny
  put(nx, ny, 1)
  local bd, bs = nil, -1
  for d = 1, 4 do
    if d ~= rev[a.dir] then
      local ax, ay = a.x + dx[d], a.y + dy[d]
      if safe(ax, ay) then
        local s = space(ax, ay, d, 5) * 2 + rnd(3)
        if s > bs then bs, bd = s, d end
      end
    end
  end
  if bd then a.dir = bd end
  local ax, ay = a.x + dx[a.dir], a.y + dy[a.dir]
  if not safe(ax, ay) then
    finish()
    state = "win"
    return
  end
  a.x, a.y = ax, ay
  put(ax, ay, 2)
end
local function interval()
  local s = math.floor((time.now() - t0) / 1000)
  local v = 180 - s * 6
  if v < 70 then v = 70 end
  return v
end
local function drawField()
  for r = 1, 16 do
    local c = 1
    while c <= 32 do
      local o = occ[(r - 1) * 32 + c]
      if o == 0 then
        c = c + 1
      else
        local c0 = c
        while c <= 32 and occ[(r - 1) * 32 + c] == o do c = c + 1 end
        oled.rect((c0 - 1) * 4, (r - 1) * 4, (c - c0) * 4, 4, o == 1)
      end
    end
  end
end
while true do
  oled.clear()
  local d = joy.dir()
  local clk = joy.click()
  if state == "play" then
    if d and dirOf[d] and dirOf[d] ~= rev[p.dir] then pnew = dirOf[d] end
    if time.now() - last >= interval() then
      last = time.now()
      step()
    end
  elseif clk and (state == "start" or state == "over" or state == "win") then
    reset()
  end
  if state == "start" then
    oled.text(56, 10, "ТРОН")
    oled.text(20, 22, "Стик — поворот")
    oled.text(20, 34, "Нажми — старт")
    oled.text(20, 46, "Рекорд: "..rec.."с")
    oled.text(24, 58, "3с — выход")
  elseif state == "play" then
    drawField()
    oled.text(0, 9, "Рекорд: "..rec.."с")
    oled.text(84, 9, math.floor((time.now() - t0) / 1000).."с")
    oled.text(0, 62, "3с — выход")
  else
    if state == "win" then
      oled.text(44, 14, "ПОБЕДА!")
    else
      oled.text(8, 14, "Столкновение!")
    end
    oled.text(28, 26, "Время: "..fin.."с")
    if time.now() - banner < 1000 then
      oled.text(4, 38, "НОВЫЙ РЕКОРД!")
    else
      oled.text(16, 38, "Рекорд: "..rec.."с")
    end
    oled.text(16, 50, "Нажми — заново")
    oled.text(24, 62, "3с — выход")
  end
  oled.flush()
  time.sleep(28)
end
