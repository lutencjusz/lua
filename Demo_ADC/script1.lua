pin = 0
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.LOW)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
        gpio.write(pin, gpio.LOW)
        print("Jest połaczenie...")
        conn:send("Połączyłeś się z modułem WiFi")
        gpio.write(pin, gpio.HIGH)
    end)
end)