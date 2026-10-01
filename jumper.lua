-- name: Прыгун
menu.holdExit(2500)
local rec = score.get() or 0
local banner = 0
local seed = time.now() % 2147483647
local function rnd(n)
  seed = (seed * 1103515245 + 12345) % 2147483648
  return seed % n
end
local CUBE = 7
local plats, top, cx, cy, vy, cam, best, dead
local function makePlat(py)
  local t, k = rnd(10), 1
  if t > 7 then k = 2 elseif t > 5 then k = 3 end
  local w = 18 + rnd(12)
  return {x = 6 + rnd(128 - w - 12), y = py, w = w, k = k, d = 1}
end
local function reset()
  plats = {{x = 20, y = 0, w = 88, k = 1, d = 1}}
  local py = 0
  for i = 1, 15 do
    py = py + 12 + rnd(7)
    plats[#plats + 1] = makePlat(py)
  end
  top = py
  cx, cy, vy, cam, best, dead = 60, 4, 0, -10, 0, false
end
local function over()
  if score.set(best) then rec, banner = best, time.now() end
  dead = true
end
local function drawPlats()
  for i = 1, #plats do
    local p = plats[i]
    local sy = math.floor(52 - ((p.y + 4) - cam))
    if p.k > 0 and sy > -8 and sy < 68 then
      local px = math.floor(p.x)
      if p.k == 1 then
        oled.rect(px, sy, p.w, 4, true)
      elseif p.k == 2 then
        oled.rect(px, sy, p.w, 4, false)
        oled.line(px + 3, sy + 1, px + p.w - 4, sy + 1)
      else
        oled.rect(px, sy, p.w, 4, false)
        for j = px + 2, px + p.w - 3, 4 do oled.pixel(j, sy + 1) end
      end
    end
  end
end
reset()
while true do
  oled.clear()
  local d = joy.dir()
  local clk = joy.click()
  if dead then
    oled.text(16, 14, "Игра окончена")
    oled.text(22, 26, "Высота: "..best)
    if time.now() - banner < 1000 then
      oled.text(6, 38, "НОВЫЙ РЕКОРД!")
    else
      oled.text(22, 38, "Рекорд: "..rec)
    end
    oled.text(14, 50, "Нажми — заново")
    oled.text(24, 62, "3с — выход")
    oled.flush()
    if clk then banner = 0; reset() end
  else
    if d == "left" then cx = cx - 2.4 elseif d == "right" then cx = cx + 2.4 end
    if cx < 0 then cx = 0 elseif cx > 128 - CUBE then cx = 128 - CUBE end
    for i = 1, #plats do
      local p = plats[i]
      if p.k == 2 then
        p.x = p.x + p.d * 0.8
        if p.x < 2 then p.x = 2; p.d = 1 end
        if p.x + p.w > 126 then p.x = 126 - p.w; p.d = -1 end
      end
    end
    local py0 = cy
    vy = vy - 0.6
    if vy < -7 then vy = -7 end
    cy = cy + vy
    if vy <= 0 then
      for i = 1, #plats do
        local p = plats[i]
        if p.k > 0 and p.y + 4 <= py0 and p.y + 4 >= cy and cx + CUBE > p.x and cx < p.x + p.w then
          cy, vy = p.y + 4, 5.8
          if p.k == 3 then p.k = 0 end
          break
        end
      end
    end
    if cy - 14 > cam then cam = cy - 14 end
    local h = math.floor((cy - 4) / 8)
    if h > best then best = h end
    if cy < cam - 16 then
      over()
    else
      local i = 1
      while i <= #plats do
        if plats[i].y + 4 < cam - 12 then table.remove(plats, i) else i = i + 1 end
      end
      while top < cam + 90 do
        top = top + 12 + rnd(7)
        plats[#plats + 1] = makePlat(top)
      end
      drawPlats()
      local by = math.floor(52 - (cy - cam))
      oled.rect(math.floor(cx), by - CUBE, CUBE, CUBE, true)
    end
    oled.text(0, 9, "Рекорд: "..rec)
    oled.text(0, 19, "Высота: "..best)
    oled.text(0, 62, "3с — выход")
    oled.flush()
  end
  time.sleep(28)
end
