-- wczytanie paramtrów sieci WiFi z pliku ustawienia.json
print("Wczytuje ustawienia WiFi...")

plik = file.open ("ustawieniaZ.json","r")
if plik == nil then
    print ("Nie znalazłem pliku ustawień sieciowych: ustawieniaZ.json")
end
--print (plik)
l=plik:read()
file.close()

key = "abcdef0987654321" -- klucz musi sie składać z 16 znakow
print(l)
u = sjson.decode(l)
-- ustawienie połaczenie z WiFi
-- local pin=0
gpio.write(pin, gpio.LOW) --zmienna pin musi być ustawiona w init
station_cfg={}
station_cfg.ssid=""
station_cfg.pwd=""
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
 serverIP = T.IP -- serverIP musi być utworzony w init.lua
 end)

print("Oczekuję na przydzielenie IP...")

tmr.alarm(0, 1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() ~= nil then 
        tmr.stop(0)
        print ("Uruchomiono synch. czasu...")  
        sntp.setoffset(1) -- czas letni
        sntp.sync(nil, nil, nil, 1)
    end
end)

offsetCzasLetni=1 --ustawienie dla przesunięcia w naszej strefie

function podajCzas ()
    tm = rtctime.epoch2cal(rtctime.get())
    if offsetCzasLetni == nil then
        gl = tm["hour"]
    else           
        gl = tm["hour"]+offsetCzasLetni
    end
    return string.format("%02d/%02d/%04d %02d:%02d:%02d", tm["day"], tm["mon"], tm["year"], gl, tm["min"], tm["sec"])
end

tmr.alarm(1, 5000, tmr.ALARM_AUTO, function()
    tm = rtctime.epoch2cal(rtctime.get())
    if  tm["year"]~=1970 then
        tmr.stop(1)
        print ("Czas zsynchronizowano.")
        if offsetCzasLetni == nil then
            gl = tm["hour"]
        else
            gl = tm["hour"]+offsetCzasLetni
        end
        print(string.format("%02d/%02d/%04d %02d:%02d:%02d", tm["day"], tm["mon"], tm["year"], gl, tm["min"], tm["sec"]))
        tm=nil; gl=nil
        collectgarbage() 
    end
end) 
