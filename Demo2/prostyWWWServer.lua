pin=4
gpio.mode(pin,gpio.OUTPUT)

l = file.list();
for k,v in pairs(l) do
    if string.find(k, ".lua")~=nil and string.find(k, "init.lua")==nil then 
        if file.exists(k) then -- czy trzeba kompilować moduł
            s = string.gsub(k, ".lua", ".lc")
            file.remove(s)
            node.compile(k)
            file.remove(k)
            print ("Skompilowano "..k)
        end
    end
end

l=nil; k=nil; v=nil; s=nil
collectgarbage()

station_cfg={}
station_cfg.ssid="" -- wprowadz swoj SSID
station_cfg.pwd="" -- wprowadz swoje hasło
station_cfg.save=true
wifi.sta.config(station_cfg)

-- Ustawienie Monitaora
-- Ustawienie Monitaora
 wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("\n\tStatus: połączony".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\tChannel: "..T.channel)
 end)

  wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("\n\tStatus: rozłączony".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID)
 end)

  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("\n\tSTATUS: pobrane IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
 T.netmask.."\n\tGateway IP: "..T.gateway)
 end)

tmr.alarm(0, 1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() ~= nil then 
        tmr.stop(0)
        print ("Uruchomiono synch. czasu...")
        sntp.setoffset(7200) -- czas letni
        sntp.sync(nil, nil, nil, 1)
    end
end)

tmr.alarm(1, 3000, tmr.ALARM_AUTO, function()
    tm = rtctime.epoch2cal(rtctime.get())
    if  tm["year"]~=1970 then
        tmr.stop(1)
        print ("Czas zsynchronizowano.")
        if offsetCzasLetni == nil then
            gl = tm["hour"]
        else
            gl = tm["hour"]+offsetCzasLetni
        end
        print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], gl, tm["min"], tm["sec"]))
        tm=nil; gl=nil
        collectgarbage()
    end
end) 

 srv=net.createServer(net.TCP)
 print("Uruchomiono serwer WWW");
 srv:listen(80,function(conn)
conn:on("receive",function(conn,payload)
    gpio.write(pin,gpio.LOW)
    print ("Wysłana odpowiedź...")
    conn:send("<h1>Połączyłeś się z modułem ESP 8266</h1>")
    conn:close()
    gpio.write(pin,gpio.HIGH)
    end)
end)

