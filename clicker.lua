-- name: Кликер
menu.holdExit(2500)
local rec = score.get()

local pts, clicks, t0, boost, newRec
local lastSecond, lastCount, cps, blink

local function start()
  pts = 0
  clicks = 0
  boost = 0
  newRec = false
  blink = 0
  lastSecond = time.now()
  lastCount = 0
  cps = 0
  t0 = time.now()
end

local function bar(v, mx, x, y, w, h)
  oled.rect(x, y, w, h, false)
  local f = 0
  if mx > 0 then
    f = math.floor((v / mx) * (w - 2))
    if f < 0 then f = 0 end
    if f > w - 2 then f = w - 2 end
  end
  if f > 0 then oled.rect(x + 1, y + 1, f, h - 2) end
end

start()

while true do
  local now = time.now()

  -- скорость: очки в секунду
  if now - lastSecond >= 1000 then
    local dtms = now - lastSecond
    cps = math.floor((pts - lastCount) * 1000 / dtms)
    lastCount = pts
    lastSecond = now
  end

  -- затухание эффекта
  boost = boost * 0.92
  if boost < 0.02 then boost = 0 end

  if joy.click() then
    clicks = clicks + 1
    pts = pts + 1 + math.floor(boost)
    boost = boost + 1.2
    if boost > 8 then boost = 8 end
  end

  if not newRec then
    if score.set(pts) then
      rec = pts
      newRec = true
      blink = time.now() + 1000
    end
  end

  oled.clear()

  -- крупные очки
  local s = tostring(pts)
  local x = 64 - math.floor(#s * 10 / 2)
  if x < 2 then x = 2 end
  oled.textBig(x, 30, s)

  -- анимация: расходящиеся рамки
  if boost > 0.3 then
    local r = math.floor(boost * 2)
    oled.rect(64 - r, 30 - r, r * 2, r * 2 + 8, false)
    oled.rect(64 - r - 2, 32 - r, (r + 2) * 2, (r + 2) * 2 + 4, false)
  end

  -- надписи
  oled.text(0, 10, "Очки: " .. pts)
  oled.text(84, 10, "Ск: " .. cps)
  oled.text(0, 46, "Рекорд: " .. rec)

  -- прогресс до рекорда
  if rec > 0 then
    bar(pts, rec, 0, 40, 128, 6)
  else
    bar(pts, pts + 1, 0, 40, 128, 6)
  end

  oled.text(0, 62, "Жми-очко, 3с-выход")

  if newRec and now < blink then
    if math.floor(now / 150) % 2 == 0 then
      oled.rect(12, 14, 104, 14)
      oled.text(18, 25, "НОВЫЙ РЕКОРД!")
    end
  end

  oled.flush()
  time.sleep(28)
end
