-- name: Привет
oled.clear()
oled.text(0, 10, "Привет, мир!")
oled.text(0, 25, "Это Lua на ESP32")
oled.text(0, 40, "SW - выход")
oled.flush()
while true do
  local j = joy.get()
  if j == "click" or j == "long" then menu.back() end
  time.sleep(50)
end
