-- name: GD 2D
menu.holdExit(2500)
local rec = score.get()

local GY, PH = 52, 9          -- земля, размер игрока
local spikes, plats            -- мир
local lastSpike, lastPlat, worldX, boost
local px, py, vy, onG, jumps, rot
local state, dist, t, newRec, rs

local function rnd(n)          -- свой генератор (нет math.randomseed)
  rs = (rs * 1103515245 + 12345) % 2147483648
  return rs % n
end

local function start()
  spikes, plats = {}, {}
  lastSpike, lastPlat, worldX, boost = 0, 0, 0, 20
  px, py, vy, onG, jumps, rot = 22, GY - PH, 0, true, 2, 0
  dist, newRec, state = 0, false, "run"
  rs = (time.now() % 100000) + 7919
  t = time.now()
end
start()

while true do
  local now = time.now()
  local dt = (now - t) / 1000
  if dt > 0.1 then dt = 0.1 end
  t = now
  local step = (105 + boost) * dt

  if state == "run" then
    worldX = worldX + step
    dist = dist + step
    boost = boost + dt * 5
    if boost > 70 then boost = 70 end

    if worldX - lastSpike > 70 then      -- шипы
      lastSpike = worldX
      spikes[#spikes + 1] = { x = worldX + 190 + rnd(60), h = 8 }
    end
    if worldX - lastPlat > 130 then      -- платформы
      lastPlat = worldX
      plats[#plats + 1] = { x = worldX + 260 + rnd(220), y = 44, w = 28 }
    end

    local i = 1                          -- чистка ушедших
    while i <= #spikes do
      if spikes[i].x < worldX - 20 then table.remove(spikes, i) else i = i + 1 end
    end
    i = 1
    while i <= #plats do
      if plats[i].x + plats[i].w < worldX - 20 then table.remove(plats, i) else i = i + 1 end
    end

    if joy.click() and jumps > 0 then    -- прыжок (двойной)
      vy = -168
      jumps = jumps - 1
      onG = false
    end

    vy = vy + 620 * dt                   -- физика
    py = py + vy * dt
    if py + PH >= GY then
      py, vy, onG, jumps = GY - PH, 0, true, 2
    else
      onG = false
    end

    for i = 1, #plats do                 -- посадка на платформу
      local p = plats[i]
      local sx = p.x - worldX + px
      if vy >= 0 and sx > px - 8 and sx < px + PH and py + PH >= p.y and py + PH <= p.y + 6 then
        py, vy, onG, jumps = p.y - PH, 0, true, 2
      end
    end

    for i = 1, #spikes do                -- касание шипа
      local s = spikes[i]
      local sx = s.x - worldX + px
      if sx > px - 6 and sx < px + PH and py + PH > GY - s.h then
        state = "dead"
        if score.set(math.floor(dist)) then
          rec, newRec = math.floor(dist), true
        end
        break
      end
    end
  elseif joy.click() then
    start()
  end

  oled.clear()

  if state == "run" then
    oled.text(0, 10, "Дист: " .. math.floor(dist))
    oled.text(90, 10, "x" .. jumps)
    oled.line(0, GY, 127, GY)            -- пол
    for i = 0, 7 do
      local wx = (i * 40) - (worldX % 40)
      oled.pixel(wx, GY + 3)
      oled.pixel(wx + 1, GY + 6)
      oled.pixel(wx + 2, GY + 9)
    end
    for i = 1, #spikes do                -- треугольные шипы
      local sx = math.floor(spikes[i].x - worldX + px)
      local h = spikes[i].h
      if sx > -12 and sx < 128 then
        oled.line(sx, GY, sx + 5, GY - h)
        oled.line(sx + 5, GY - h, sx + 10, GY)
      end
    end
    for i = 1, #plats do
      local sx = math.floor(plats[i].x - worldX + px)
      if sx > -34 and sx < 128 then oled.rect(sx, plats[i].y, plats[i].w, 4) end
    end
    local pyi = math.floor(py)
    oled.rect(px, pyi, PH, PH)           -- игрок
    local cx, cy = px + 4, pyi + 4
    if rot < 90 then
      oled.pixel(cx, cy - 3) oled.pixel(cx + 3, cy)
      oled.pixel(cx, cy + 3) oled.pixel(cx - 3, cy)
    else
      oled.pixel(cx - 2, cy - 2) oled.pixel(cx + 2, cy - 2)
      oled.pixel(cx + 2, cy + 2) oled.pixel(cx - 2, cy + 2)
    end
    rot = (rot + 260 * dt) % 360
    oled.text(0, 62, "Рекорд: " .. rec)
  else
    oled.text(28, 22, "КРАШ!")
    oled.text(20, 38, "Дист: " .. math.floor(dist))
    oled.text(10, 50, "Рекорд: " .. rec)
    oled.text(4, 62, "Кнопка: заново, 3с-выход")
    if newRec and (now % 1000) < 600 then
      oled.text(16, 4, "НОВЫЙ РЕКОРД!")
    end
  end

  oled.flush()
  time.sleep(28)
end
