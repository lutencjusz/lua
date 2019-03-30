
-- połaczenie z WiFi
gpio.write(pin, gpio.LOW) --zmienna pin musi być ustawiona w init
station_cfg={}
station_cfg.ssid="" -- wprowadź ssid sieci
station_cfg.pwd="" -- wprowadż hasło
station_cfg.save=true
wifi.sta.config(station_cfg)
gpio.write(pin, gpio.HIGH)

-- Ustawienie Monitaora
 wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("\n\tSTATUS: CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\tChannel: "..T.channel)
 end)

  wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("\n\tSTATUS: DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID)
 end)

  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("\n\tSTATUS: GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
 T.netmask.."\n\tGateway IP: "..T.gateway)
 end)

print("Oczekuję na przydzielenie IP...")
tmr.alarm(0, 1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() ~= nil then 
        tmr.stop(0)
        print ("Uruchomiono synch. czasu...")  
        sntp.setoffset(2) -- czas letni
        sntp.sync(nil, nil, nil, 1)
        tm = rtctime.epoch2cal(rtctime.get())
        print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
    end
end)
