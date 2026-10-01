-- name: Птица
menu.holdExit(2500)
oled.font(1)
local rec = score.get()
if type(rec) ~= "number" then rec = 0 end

local G = 0.13
local JUMP = -1.9
local BX = 30
local BYS = 56
local GAP = 34
local SP = 1.6
local state = "play"
local bird, vy, pipes, nxt, cnt, msgT, seed, t0

local function rnd(n)
  seed = math.floor(seed * 1103515245 + 12345)
  if seed < 0 then seed = -seed end
  return math.floor(seed % n) + 1
end

local function start()
  seed = time.now() + 3
  bird = 26
  vy = 0
  pipes = {}
  nxt = 0
  cnt = 0
  msgT = 0
  state = "play"
  t0 = time.now()
end

local function over()
  if cnt > rec then
    rec = cnt
    msgT = time.now()
    score.set(rec)
  end
  state = "over"
end

local function update()
  local now = time.now()
  if state ~= "play" then
    if joy.click() then start() end
    return
  end
  if joy.click() then vy = JUMP end
  vy = vy + G
  if vy > 2.6 then vy = 2.6 end
  bird = bird + vy
  if bird < 1 then bird = 1 vy = 0 end
  if now - nxt > 1400 then
    nxt = now
    local top = 4 + rnd(20)
    pipes[#pipes + 1] = { x = 132, top = top, h = top }
  end
  local i = 1
  while i <= #pipes do
    local p = pipes[i]
    p.x = p.x - SP
    p.h = p.top
    if p.x + 12 < BX and not p.sc then
      p.sc = true
      cnt = cnt + 1
    end
    if p.x + 12 < 0 then
      table.remove(pipes, i)
    else
      i = i + 1
    end
  end
  for i = 1, #pipes do
    local p = pipes[i]
    if BX + 6 > p.x and BX < p.x + 12 then
      if bird < p.h or bird + 6 > p.h + GAP then
        over()
        return
      end
    end
  end
  if bird + 6 > BYS then
    bird = BYS - 6
    over()
  end
end

local function draw()
  oled.text(2, 8, "Трубы: " .. cnt)
  oled.text(74, 8, "Рекорд: " .. rec)
  for i = 1, #pipes do
    local p = pipes[i]
    local x = math.floor(p.x)
    if x > -14 and x < 130 then
      oled.rect(x, 0, 12, p.h, true)
      local by = p.h + GAP
      oled.rect(x, by, 12, BYS - by, true)
    end
  end
  oled.rect(BX, math.floor(bird), 6, 6, true)
  oled.line(0, BYS, 127, BYS)
  oled.text(2, 63, "3с - выход")
  if state == "play" and cnt == 0 then
    oled.text(28, 32, "Жми кнопку")
  elseif state == "over" then
    oled.text(30, 32, "Игра окончена")
    oled.text(40, 41, "Трубы: " .. cnt)
  end
  if time.now() - msgT < 1000 then
    oled.text(22, 20, "НОВЫЙ РЕКОРД!")
  end
end

start()
time.sleep(500)

while true do
  oled.clear()
  update()
  draw()
  oled.flush()
  joy.click()
  time.sleep(28)
end
