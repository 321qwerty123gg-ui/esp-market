-- name: Пятнашки 15
menu.holdExit(2500)
local rec = score.get() or 0
local banner = 0
local seed = time.now() % 2147483647
local function rnd(n)
  seed = (seed * 1103515245 + 12345) % 2147483648
  return seed % n
end
local dirs = {"left", "up", "right", "down"}
local b = {}
for i = 1, 16 do b[i] = i end
b[16] = 0
local bx, by = 4, 4
local state, moves, shuf, t0, fin = "start", 0, 0, 0, 0
local lastd, lastt = nil, 0
local function idx(x, y) return (y - 1) * 4 + x end
local function move(d)
  if d == "left" and bx < 4 then
    b[idx(bx, by)] = b[idx(bx + 1, by)]
    b[idx(bx + 1, by)] = 0
    bx = bx + 1
  elseif d == "right" and bx > 1 then
    b[idx(bx, by)] = b[idx(bx - 1, by)]
    b[idx(bx - 1, by)] = 0
    bx = bx - 1
  elseif d == "up" and by < 4 then
    b[idx(bx, by)] = b[idx(bx, by + 1)]
    b[idx(bx, by + 1)] = 0
    by = by + 1
  elseif d == "down" and by > 1 then
    b[idx(bx, by)] = b[idx(bx, by - 1)]
    b[idx(bx, by - 1)] = 0
    by = by - 1
  end
end
local function solved()
  for i = 1, 15 do
    if b[i] ~= i then return false end
  end
  return b[16] == 0
end
local function newGame()
  for i = 1, 16 do b[i] = i end
  b[16] = 0
  bx, by = 4, 4
  moves, shuf, t0, fin = 0, 300, 0, 0
  lastd, lastt = nil, time.now()
  state = "shuffle"
end
local function drawBoard()
  for r = 1, 4 do
    for c = 1, 4 do
      local v = b[idx(c, r)]
      if v > 0 then
        local x = 72 + (c - 1) * 13
        local y = 8 + (r - 1) * 13
        oled.rect(x, y, 12, 12, false)
        oled.text(x + 2, y + 10, tostring(v))
      end
    end
  end
end
while true do
  oled.clear()
  local d = joy.dir()
  local clk = joy.click()
  if state == "shuffle" then
    local n = 0
    while n < 12 and shuf > 0 do
      move(dirs[rnd(4) + 1])
      shuf = shuf - 1
      n = n + 1
    end
    if shuf <= 0 then
      if solved() then shuf = 25 else state = "play"; lastd, lastt = nil, time.now() end
    end
  elseif state == "play" then
    if d and (d ~= lastd or time.now() - lastt > 150) then
      if move(d) then
        if moves == 0 then t0 = time.now() end
        moves = moves + 1
      end
      lastt = time.now()
    end
    lastd = d
    if moves > 0 and solved() then
      fin = math.floor((time.now() - t0) / 1000)
      if score.set(moves, false) then rec, banner = moves, time.now() end
      state = "win"
    end
  elseif clk and (state == "start" or state == "win") then
    newGame()
  end
  if state == "start" then
    oled.text(20, 10, "Пятнашки 15")
    oled.text(14, 22, "Нажми — мешать")
    oled.text(20, 34, "Стик — сдвиг")
    oled.text(20, 46, "Рекорд: "..rec)
    oled.text(24, 58, "3с — выход")
  elseif state == "win" then
    oled.text(44, 10, "ПОБЕДА!")
    oled.text(16, 22, "Ходы: "..moves.."  "..fin.."с")
    if time.now() - banner < 1000 then
      oled.text(4, 34, "НОВЫЙ РЕКОРД!")
    else
      oled.text(20, 34, "Рекорд: "..rec)
    end
    oled.text(20, 46, "Нажми — заново")
    oled.text(24, 58, "3с — выход")
  else
    drawBoard()
    local el = 0
    if t0 > 0 then el = math.floor((time.now() - t0) / 1000) end
    if state == "shuffle" then
      oled.text(0, 12, "Мешаю...")
    else
      oled.text(0, 12, "Ходы: "..moves)
    end
    oled.text(0, 28, "Время: "..el.."с")
    oled.text(0, 44, "Рекорд: "..rec)
    oled.text(0, 60, "3с — выход")
  end
  oled.flush()
  time.sleep(28)
end
