-- name: Рисовалка Lua
local cx, cy = 64, 32
oled.clear()
while true do
  oled.pixel(cx, cy)
  oled.flush()
  local j = joy.get()
  if j == "up" then cy = math.max(0, cy - 2) end
  if j == "down" then cy = math.min(63, cy + 2) end
  if j == "left" then cx = math.max(0, cx - 2) end
  if j == "right" then cx = math.min(127, cx + 2) end
  if j == "click" then oled.clear() end
  if j == "long" then menu.back() end
  time.sleep(30)
end
