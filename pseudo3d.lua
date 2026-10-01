-- name: Псевдо-3D
menu.holdExit(2500)
local rec = score.get()
local HOR, CX, SPD = 26, 64, 16     -- горизонт, центр, скорость
local obstacles = {}
local state, ppos, dist, nextZ, t, newRec, flash, rs

local function rnd(n)               -- свой генератор (нет math.randomseed)
  rs = (rs * 1103515245 + 12345) % 2147483648
  return rs % n
end

local function start()
  obstacles = {}
  ppos, dist, nextZ, SPD = 0, 0, 40, 16
  state, newRec, flash = "run", false, 0
  rs = (time.now() % 100000) + 7919
  t = time.now()
end
start()

while true do
  local now = time.now()
  local dt = (now - t) / 1000
  if dt > 0.1 then dt = 0.1 end
  t = now
  if flash > 0 then flash = flash - dt end

  if state == "run" then
    dist = dist + SPD * dt
    if SPD < 30 then SPD = SPD + dt * 1.2 end

    local d = joy.dir()             -- уворачивание стиком
    if d == "left" then ppos = ppos - 78 * dt end
    if d == "right" then ppos = ppos + 78 * dt end
    if ppos < -30 then ppos = -30 end
    if ppos > 30 then ppos = 30 end

    local nz = math.floor(dist) + 45
    while nextZ < nz do             -- рождение объектов у горизонта
      obstacles[#obstacles + 1] = { z = nextZ + rnd(10), x = -26 + rnd(52) }
      nextZ = nextZ + 22 + rnd(12)
    end

    local i = 1                     -- движение к камере + чистка
    while i <= #obstacles do
      local o = obstacles[i]
      o.z = o.z - SPD * dt
      if o.z < 2 then table.remove(obstacles, i) else i = i + 1 end
    end

    for i = 1, #obstacles do        -- столкновение вблизи камеры
      local o = obstacles[i]
      if o.z < 13 and o.z > 3 and math.abs(o.x - ppos) < 20 then
        state = "dead"
        if score.set(math.floor(dist)) then
          rec, newRec, flash = math.floor(dist), true, 1.2
        end
        break
      end
    end
  elseif joy.click() then
    start()
  end

  oled.clear()

  if state == "run" then
    oled.line(0, HOR, 127, HOR)                       -- дорога
    local sh = CX - math.floor(ppos)
    oled.line(sh, HOR, sh - 10, 63)
    oled.line(sh, HOR, sh + 10, 63)
    oled.line(CX, HOR, CX, 63)

    for i = #obstacles, 1, -1 do                      -- дальние раньше ближних
      local o = obstacles[i]
      local k = 60 / o.z
      local sx = CX + math.floor((o.x - ppos) * k)
      local sy = HOR + math.floor(12 * k)
      local w = math.floor(10 * k)
      local h = math.floor(14 * k)
      if w < 1 then w = 1 end
      if h < 1 then h = 1 end
      if sx > -30 and sx < 128 then
        oled.rect(sx - math.floor(w / 2), sy - h, w, h, k <= 1.5)
      end
    end

    oled.rect(60, 42, 9, 9, false)                    -- прицел игрока
    oled.pixel(64, 46)

    local bar = math.floor((SPD - 16) / 14 * 40)      -- полоса скорости
    if bar > 40 then bar = 40 end
    oled.rect(84, 27, 41, 5, false)
    if bar > 0 then oled.rect(85, 28, bar, 3) end
    oled.text(0, 10, "Д: " .. math.floor(dist))
    oled.text(0, 62, "Рекорд: " .. rec)
  else
    oled.text(30, 22, "КРУШЕНИЕ")
    oled.text(24, 38, "Дист: " .. math.floor(dist))
    oled.text(10, 50, "Рекорд: " .. rec)
    oled.text(4, 62, "Кнопка: заново, 3с-выход")
    if newRec and flash > 0 then
      oled.text(16, 4, "НОВЫЙ РЕКОРД!")
    end
  end

  oled.flush()
  time.sleep(28)
end
