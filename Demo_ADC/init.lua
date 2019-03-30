if adc.force_init_mode(adc.INIT_VDD33) then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end

print("System voltage ", adc.readvdd33(0)/1000, " V")
pin = 0
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.LOW)

wifi.setmode(wifi.STATION)
print("Połączenie WiFi...")
wifi.sta.config("UPC5115008", "ZPCAVNCZ")
print(wifi.sta.getip())


srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
        gpio.write(pin, gpio.LOW)
        print("Jest połaczenie...")
        conn:send("<h1>Połączyłeś się z modułem WiFi</h1>")
        conn:close()
        gpio.write(pin, gpio.HIGH)
    end)
end)