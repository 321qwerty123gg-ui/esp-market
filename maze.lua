-- name: Лабиринт
menu.holdExit(2500)
local rec = score.get()

-- лабиринт 15x7: '#' стена, '.' проход, 'S' старт, 'E' выход
local rows = {
  "###############",
  "#S..#.....#...#",
  "#.#.#.###.#.#.#",
  "#.#...#...#.#.#",
  "#.#####.###.#.#",
  "#.....#.....#E#",
  "###############",
}

local CW = 8
local OX = 4
local OY = 2
local MW = 15
local MH = 7

local px, py, steps, state, t0, sec, moved, newRec, te

local function start()
  px = 1
  py = 1
  for r = 1, MH do
    local line = rows[r]
    for c = 1, MW do
      local ch = string.sub(line, c, c)
      if ch == "S" then
        px = c - 1
        py = r - 1
      end
    end
  end
  steps = 0
  state = "run"
  newRec = false
  moved = false
  te = nil
  t0 = time.now()
end

local function cell(cx, cy)
  if cx < 0 or cy < 0 or cx > MW - 1 or cy > MH - 1 then
    return "#"
  end
  return string.sub(rows[cy + 1], cx + 1, cx + 1)
end

start()

while true do
  if state == "run" then
    local d = joy.dir()
    local nx, ny = px, py
    if d == "up" then ny = py - 1 end
    if d == "down" then ny = py + 1 end
    if d == "left" then nx = px - 1 end
    if d == "right" then nx = px + 1 end

    if nx ~= px or ny ~= py then
      if not moved then
        if cell(nx, ny) ~= "#" then
          px = nx
          py = ny
          steps = steps + 1
          moved = true
          if cell(px, py) == "E" then
            state = "win"
            te = time.now()
            sec = math.floor((te - t0) / 1000)
            if sec < 1 then sec = 1 end
            if score.set(sec, false) then
              rec = sec
              newRec = true
            end
          end
        end
      end
    else
      moved = false
    end
  else
    if joy.click() then start() end
  end

  oled.clear()

  -- стены и выход
  for r = 0, MH - 1 do
    for c = 0, MW - 1 do
      local ch = cell(c, r)
      if ch == "#" then
        oled.rect(OX + c * CW, OY + r * CW, CW, CW)
      elseif ch == "E" then
        oled.rect(OX + c * CW + 2, OY + r * CW + 2, 4, 4, false)
        oled.pixel(OX + c * CW + 3, OY + r * CW + 3)
        oled.pixel(OX + c * CW + 4, OY + r * CW + 4)
      end
    end
  end

  -- игрок
  oled.rect(OX + px * CW + 2, OY + py * CW + 2, 4, 4)

  local secNow = 0
  if state == "run" then
    secNow = math.floor((time.now() - t0) / 1000)
  else
    secNow = sec
  end
  oled.text(0, 62, "Шаги: " .. steps .. "  Время: " .. secNow .. "с")

  if state == "win" then
    oled.rect(6, 8, 116, 34, false)
    oled.rect(7, 9, 114, 32)
    oled.text(30, 24, "ВЫХОД!")
    oled.text(16, 38, "Время: " .. sec .. "с  Шаги: " .. steps)
    oled.text(0, 50, "Рекорд: " .. rec .. "с")
    oled.text(0, 62, "Кнопка: заново, 3с-выход")
    if newRec then
      oled.rect(10, 14, 108, 12)
      oled.text(16, 23, "НОВЫЙ РЕКОРД!")
    end
  end

  oled.flush()
  time.sleep(28)
end
