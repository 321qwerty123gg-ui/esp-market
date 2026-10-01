-- name: Тетрис
menu.holdExit(2500)
local rec = score.get()
if type(rec) ~= "number" then rec = 0 end
local seed = time.now() % 65535 + 1
local function rnd() seed = (seed * 75) % 65537 return (seed - 1) / 65536 end
local BW, BH, CSX, CSY, BX, BY = 10, 16, 4, 3, 4, 8
local P = {
  { {0,1,1,1,2,1,3,1}, {2,0,2,1,2,2,2,3}, {0,2,1,2,2,2,3,2}, {1,0,1,1,1,2,1,3} },
  { {1,0,2,0,1,1,2,1}, {1,0,2,0,1,1,2,1}, {1,0,2,0,1,1,2,1}, {1,0,2,0,1,1,2,1} },
  { {1,0,0,1,1,1,2,1}, {1,0,1,1,2,1,1,2}, {0,1,1,1,2,1,1,2}, {1,0,0,1,1,1,1,2} },
  { {1,0,2,0,0,1,1,1}, {1,0,1,1,2,1,2,2}, {1,1,2,1,0,2,1,2}, {0,0,0,1,1,1,1,2} },
  { {0,0,1,0,1,1,2,1}, {2,0,1,1,2,1,1,2}, {0,1,1,1,1,2,2,2}, {1,0,0,1,1,1,0,2} },
  { {0,0,0,1,1,1,2,1}, {1,0,2,0,1,1,1,2}, {0,1,1,1,2,1,2,2}, {1,0,1,1,0,2,1,2} },
  { {2,0,0,1,1,1,2,1}, {1,0,1,1,1,2,2,2}, {0,1,1,1,2,1,0,2}, {0,0,1,0,1,1,1,2} },
}
local board, state, pts, recUntil = {}, "play", 0, 0
local cur, curRot, curX, curY, nxt = 1, 1, 4, 1, 1
local gravMs, lastDrop, lastMove, prevH = 600, 0, 0, nil
local function newBoard() board = {} for y = 1, BH do board[y] = {} for x = 1, BW do board[y][x] = 0 end end end
local function collides(px, py, rot)
  local r = P[cur][rot]
  for i = 1, 8, 2 do
    local x, y = px + r[i], py + r[i + 1]
    if x < 1 or x > BW or y > BH then return true end
    if y >= 1 and board[y][x] == 1 then return true end
  end
  return false
end
local function spawn()
  cur = nxt
  nxt = math.floor(rnd() * 7) + 1
  curRot, curX, curY = 1, 4, 1
  lastDrop = time.now()
  if collides(curX, curY, curRot) then
    state = "over"
    if pts > rec then rec = pts if score.set(pts) then recUntil = lastDrop + 1000 end end
  end
end
local function lockPiece()
  local r = P[cur][curRot]
  for i = 1, 8, 2 do
    local x, y = curX + r[i], curY + r[i + 1]
    if y >= 1 and y <= BH and x >= 1 and x <= BW then board[y][x] = 1 end
  end
  local n, y = 0, BH
  while y >= 1 do
    local full = true
    for x = 1, BW do if board[y][x] == 0 then full = false end end
    if full then
      n = n + 1
      for yy = y, 2, -1 do for x = 1, BW do board[yy][x] = board[yy - 1][x] end end
      for x = 1, BW do board[1][x] = 0 end
    else
      y = y - 1
    end
  end
  if n > 0 then pts = pts + 100 * n * n gravMs = gravMs - 35 * n end
  if gravMs < 130 then gravMs = 130 end
  spawn()
end
local function stepDown() if collides(curX, curY + 1, curRot) then lockPiece() else curY = curY + 1 end end
local function newGame()
  newBoard()
  pts, gravMs, state, prevH, lastMove = 0, 600, "play", nil, 0
  nxt = math.floor(rnd() * 7) + 1
  spawn()
end
newGame()

while true do
  local now = time.now()
  local d = joy.dir()
  local click = joy.click()

  if state == "play" then
    local h = nil
    if d == "left" then h = -1 elseif d == "right" then h = 1 end
    if h ~= prevH then
      if h and not collides(curX + h, curY, curRot) then curX = curX + h end
      prevH, lastMove = h, now
    elseif h and now - lastMove >= 120 then
      if not collides(curX + h, curY, curRot) then curX = curX + h end
      lastMove = now
    end
    if click then
      local nr = curRot % 4 + 1
      local kicks = {0, -1, 1, -2, 2}
      for i = 1, 5 do
        if not collides(curX + kicks[i], curY, nr) then
          curX, curRot = curX + kicks[i], nr
          break
        end
      end
    end
    local iv = gravMs
    if d == "down" then iv = 60 end
    if now - lastDrop >= iv then
      lastDrop = now
      stepDown()
    end
  elseif click then
    newGame()
  end

  oled.clear()
  if state == "play" then
    oled.rect(BX - 1, BY - 1, BW * CSX + 2, BH * CSY + 2, false)
    for y = 1, BH do
      for x = 1, BW do
        if board[y][x] == 1 then oled.rect(BX + (x - 1) * CSX, BY + (y - 1) * CSY, 3, 2, true) end
      end
    end
    local r = P[cur][curRot]
    for i = 1, 8, 2 do
      local y = curY + r[i + 1]
      if y >= 1 and y <= BH then oled.rect(BX + (curX + r[i] - 1) * CSX, BY + (y - 1) * CSY, 3, 2, true) end
    end
    oled.text(46, 8, "ТЕТРИС")
    oled.text(46, 20, "Счёт:" .. pts)
    oled.text(46, 30, "Рекорд:" .. rec)
    oled.text(46, 42, "Далее:")
    local pr = P[nxt][1]
    for i = 1, 8, 2 do
      oled.rect(92 + pr[i] * CSX, 38 + pr[i + 1] * CSY, 3, 2, true)
    end
    oled.text(70, 63, "3с — выход")
  else
    oled.text(20, 14, "ИГРА ОКОНЧЕНА")
    oled.text(20, 28, "Счёт: " .. pts)
    oled.text(20, 40, "Рекорд: " .. rec)
    if now < recUntil then oled.text(20, 52, "НОВЫЙ РЕКОРД!") else oled.text(20, 52, "Нажми — заново") end
    oled.text(20, 63, "3с — выход")
  end
  oled.flush()
  time.sleep(28)
end
