-- name: Понг
menu.holdExit(2500)
local rec = score.get()
if type(rec) ~= "number" then rec = 0 end
local seed = time.now() % 65535 + 1
local function rnd() seed = (seed * 75) % 65537 return (seed - 1) / 65536 end
local W, TOP, BOT = 128, 10, 54
local P1X, PW, PH, P2X = 3, 3, 12, 122
local state, ps, ai = "play", 0, 0
local p1y, p2y = 26, 26
local bx, by, vx, vy = 62, 30, 2, 1
local recUntil = 0

local function serve(toRight)
  local sp = 1.6 + 0.1 * (ps + ai)
  if sp > 3.2 then sp = 3.2 end
  local a = rnd() * 0.7 - 0.35
  bx, by = 62, 30
  vy = sp * a
  local hx = sp * math.sqrt(1 - a * a)
  if toRight then vx = hx else vx = -hx end
end

local function newMatch()
  ps, ai = 0, 0
  p1y, p2y = 26, 26
  state = "play"
  serve(rnd() < 0.5)
end

local function clampPaddle(y)
  if y < TOP then y = TOP end
  if y + PH > BOT + 1 then y = BOT + 1 - PH end
  return y
end

local function bounceY(py)
  local nv = vy + ((by + 1.5) - (py + PH / 2)) * 0.16
  if nv > 2.4 then nv = 2.4 end
  if nv < -2.4 then nv = -2.4 end
  return nv
end

newMatch()

while true do
  local now = time.now()
  local d = joy.dir()
  local click = joy.click()

  if state == "play" then
    if d == "up" then p1y = p1y - 3 elseif d == "down" then p1y = p1y + 3 end
    p1y = clampPaddle(p1y)
    local sp = 1.0 + 0.05 * (ps + ai)
    if sp > 1.9 then sp = 1.9 end
    local dif = by + 1.5 - PH / 2 - p2y
    if dif > sp then p2y = p2y + sp elseif dif < -sp then p2y = p2y - sp else p2y = p2y + dif end
    p2y = clampPaddle(p2y)
    bx = bx + vx
    by = by + vy
    if by < TOP then by = TOP vy = -vy end
    if by + 3 > BOT + 1 then by = BOT + 1 - 3 vy = -vy end
    if vx < 0 and bx <= P1X + PW and bx + 3 >= P1X and by + 3 > p1y and by < p1y + PH then
      bx = P1X + PW
      vx = -vx * 1.04
      if vx > 3.6 then vx = 3.6 end
      vy = bounceY(p1y)
    end
    if vx > 0 and bx + 3 >= P2X and bx <= P2X + PW and by + 3 > p2y and by < p2y + PH then
      bx = P2X - 3
      vx = -vx * 1.04
      if vx < -3.6 then vx = -3.6 end
      vy = bounceY(p2y)
    end
    local scored = false
    if bx + 3 < 0 then ai = ai + 1 scored = true
    elseif bx > W then ps = ps + 1 scored = true end
    if scored then
      if ps >= 7 or ai >= 7 then
        state = "over"
        if ps > rec then
          rec = ps
          if score.set(ps) then recUntil = now + 1000 end
        end
      else
        serve(rnd() < 0.5)
      end
    end
  elseif state == "over" then
    if click then newMatch() end
  end

  oled.clear()
  if state == "play" then
    oled.rect(math.floor(bx), math.floor(by), 3, 3, true)
    oled.rect(P1X, math.floor(p1y), PW, PH, true)
    oled.rect(P2X, math.floor(p2y), PW, PH, true)
    oled.line(0, TOP - 1, 127, TOP - 1)
    for i = 0, 3 do oled.rect(63, 14 + i * 12, 1, 6, true) end
    oled.text(0, 8, "Т:" .. ps .. " И:" .. ai)
    oled.text(60, 8, "Рекорд:" .. rec)
    oled.text(0, 63, "3с — выход")
  else
    oled.text(22, 14, "МАТЧ ОКОНЧЕН")
    oled.text(22, 28, "Ты: " .. ps .. "  ИИ: " .. ai)
    oled.text(22, 40, "Рекорд: " .. rec)
    if now < recUntil then oled.text(22, 52, "НОВЫЙ РЕКОРД!") else oled.text(22, 52, "Нажми — заново") end
    oled.text(22, 63, "3с — выход")
  end
  oled.flush()
  time.sleep(28)
end
