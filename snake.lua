-- name: Змейка
menu.holdExit(2500)
local rec = score.get()
if type(rec) ~= "number" then rec = 0 end
local seed = time.now() % 65535 + 1
local function rnd() seed = (seed * 75) % 65537 return (seed - 1) / 65536 end
local CW, CH, CS = 16, 8, 8
local sx, sy = {}, {}
local dirx, diry, pdx, pdy = 1, 0, 1, 0
local foodx, foody = 0, 0
local state, stepMs, lastStep, recUntil = "play", 300, 0, 0

local function placeFood()
  local fx, fy, ok, t = 0, 0, false, 0
  repeat
    fx = math.floor(rnd() * CW)
    fy = math.floor(rnd() * CH)
    ok = true
    for i = 1, #sx do
      if sx[i] == fx and sy[i] == fy then ok = false end
    end
    t = t + 1
  until ok or t > 300
  foodx, foody = fx, fy
end

local function newGame()
  sx, sy = {}, {}
  for i = 1, 3 do
    sx[i] = 5 - i
    sy[i] = 4
  end
  dirx, diry, pdx, pdy = 1, 0, 1, 0
  stepMs, state = 300, "play"
  placeFood()
  lastStep = time.now()
end

newGame()

while true do
  local now = time.now()
  local d = joy.dir()
  local click = joy.click()

  if state == "play" then
    if d then
      local nx, ny = 0, 0
      if d == "up" then nx, ny = 0, -1
      elseif d == "down" then nx, ny = 0, 1
      elseif d == "left" then nx, ny = -1, 0
      elseif d == "right" then nx, ny = 1, 0 end
      if not (nx == -dirx and ny == -diry) then pdx, pdy = nx, ny end
    end
    if now - lastStep >= stepMs then
      lastStep = now
      dirx, diry = pdx, pdy
      local hx, hy = sx[1] + dirx, sy[1] + diry
      local dead = false
      if hx < 0 or hx >= CW or hy < 0 or hy >= CH then dead = true end
      if not dead then
        for i = 1, #sx - 1 do
          if sx[i] == hx and sy[i] == hy then dead = true end
        end
      end
      if dead then
        state = "over"
        if #sx > rec then
          rec = #sx
          if score.set(#sx) then recUntil = now + 1000 end
        end
      else
        table.insert(sx, 1, hx)
        table.insert(sy, 1, hy)
        if hx == foodx and hy == foody then
          stepMs = stepMs - 8
          if stepMs < 90 then stepMs = 90 end
          placeFood()
        else
          table.remove(sx)
          table.remove(sy)
        end
      end
    end
  elseif state == "over" then
    if click then newGame() end
  end

  oled.clear()
  if state == "play" then
    oled.rect(foodx * CS + 1, foody * CS + 1, 6, 6, true)
    for i = 1, #sx do
      oled.rect(sx[i] * CS + 1, sy[i] * CS + 1, 6, 6, true)
    end
    oled.text(0, 8, "Длина: " .. #sx)
    oled.text(68, 8, "Рекорд:" .. rec)
    oled.text(0, 63, "3с — выход")
  else
    oled.text(18, 12, "ИГРА ОКОНЧЕНА")
    oled.text(18, 26, "Длина: " .. #sx)
    oled.text(18, 38, "Рекорд: " .. rec)
    if now < recUntil then oled.text(18, 50, "НОВЫЙ РЕКОРД!") else oled.text(18, 50, "Нажми — заново") end
    oled.text(18, 62, "3с — выход")
  end
  oled.flush()
  time.sleep(28)
end
