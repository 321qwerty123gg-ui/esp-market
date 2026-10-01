-- name: Арканоид
menu.holdExit(2500)
oled.font(1)
local rec = score.get()
if type(rec) ~= "number" then rec = 0 end
local W, H, PW, PH, PY, SPD = 128, 64, 24, 3, 56, 2.4
local BW, BH, X0, Y0 = 14, 5, 6, 18
local bricks, bl, px, sc, lv, state, msg, bs, sd
local function rnd(n)
  sd = math.floor(sd * 1103515245 + 12345)
  if sd < 0 then sd = -sd end
  return math.floor(sd % n) + 1
end
local function alv()
  local n = 0
  for i = 1, 32 do if bricks[i] then n = n + 1 end end
  return n
end
local function spd(v)
  local len = math.sqrt(bl.dx * bl.dx + bl.dy * bl.dy)
  if len < 0.01 then len = 1 end
  bl.dx = bl.dx / len * v
  bl.dy = bl.dy / len * v
  bs = v
end
local function st()
  px, sc, lv, state = 52, 0, 3, "play"
  for i = 1, 32 do bricks[i] = true end
  bl = { x = 60, y = 40, dx = 1.7, dy = -1.7 }
  bs = SPD
end
local function rball()
  bl.x, bl.y, bl.dx, bl.dy = px + math.floor(PW / 2), PY - 6, 1.6, -1.7
  bs = SPD
  state = "pause"
end
local function over()
  if sc > rec then
    rec, msg = sc, time.now()
    score.set(rec)
  end
  state = "over"
end
local function upd()
  if state == "pause" then
    if joy.click() then state = "play" end
    return
  end
  if state ~= "play" then
    if joy.click() then st() end
    return
  end
  local d = joy.dir()
  if d == "left" then
    px = px - 4
    if px < 1 then px = 1 end
  elseif d == "right" then
    px = px + 4
    if px > W - PW - 1 then px = W - PW - 1 end
  end
  local ox, oy = bl.x, bl.y
  bl.x = bl.x + bl.dx
  bl.y = bl.y + bl.dy
  if bl.x < 1 then bl.x = 1 bl.dx = -bl.dx end
  if bl.x > W - 5 then bl.x = W - 5 bl.dx = -bl.dx end
  if bl.y < 1 then bl.y = 1 bl.dy = -bl.dy end
  if bl.dy > 0 and bl.y + 4 >= PY and bl.y <= PY + PH and bl.x + 4 >= px and bl.x <= px + PW then
    bl.y = PY - 5
    local off = ((bl.x + 2) - (px + math.floor(PW / 2))) * 0.14
    if off > 1.5 then off = 1.5 end
    if off < -1.5 then off = -1.5 end
    bl.dx = off
    bl.dy = -math.sqrt(6 - off * off)
    spd(bs + 0.08)
  end
  local hit = 0
  for i = 1, 32 do
    if bricks[i] then
      local r = math.floor((i - 1) / 8)
      local c = (i - 1) % 8
      local X = X0 + c * 16
      local Y = Y0 + r * 6
      if bl.x + 4 > X and bl.x < X + BW and bl.y + 4 > Y and bl.y < Y + BH then
        bricks[i] = false
        hit = i
        if oy + 4 <= Y then
          bl.dy = -bl.dy
          bl.y = Y - 5
        elseif oy >= Y + BH then
          bl.dy = -bl.dy
          bl.y = Y + BH + 1
        else
          bl.dx = -bl.dx
          if ox + 2 < X + BW / 2 then bl.x = X - 5 else bl.x = X + BW + 1 end
        end
        break
      end
    end
  end
  if hit > 0 then
    sc = sc + 10
    if alv() == 0 then state = "win" else spd(bs + 0.07) end
  end
  if bl.y > H - 1 then
    lv = lv - 1
    if lv <= 0 then over() else rball() end
  end
end
local function draw()
  oled.text(2, 8, "Очки: " .. sc)
  oled.text(74, 8, "Рекорд: " .. rec)
  oled.line(0, 10, 127, 10)
  for i = 1, 32 do
    if bricks[i] then
      oled.rect(X0 + ((i - 1) % 8) * 16, Y0 + math.floor((i - 1) / 8) * 6, BW, BH, true)
    end
  end
  oled.rect(px, PY, PW, PH, true)
  oled.rect(math.floor(bl.x), math.floor(bl.y), 4, 4, true)
  oled.text(2, 63, "3с - выход")
  oled.text(44, 63, "Жизни:" .. lv)
  oled.text(96, 63, "Ур." .. (math.floor((bs - SPD) / 0.4) + 1))
  if state == "pause" then oled.text(28, 34, "Нажми кнопку")
  elseif state == "over" then oled.text(30, 34, "Игра окончена")
  elseif state == "win" then oled.text(26, 34, "Все кирпичи!") end
  if state ~= "play" then oled.text(38, 43, "Очки: " .. sc) end
  if time.now() - msg < 1000 then oled.text(22, 34, "НОВЫЙ РЕКОРД!") end
end
sd = time.now() + 7
st()
time.sleep(500)
while true do
  oled.clear()
  upd()
  draw()
  oled.flush()
  time.sleep(28)
end
