-- name: Счётчик
local count = 0
while true do
  oled.clear()
  oled.textBig(0, 20, tostring(count))
  oled.text(0, 50, "SW +1, долгое - выход")
  oled.flush()
  local j = joy.get()
  if j == "click" then count = count + 1 end
  if j == "long" then menu.back() end
  time.sleep(100)
end
