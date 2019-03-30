outpin=4
pinValue=gpio.HIGH
gpio.mode(outpin,gpio.OUTPUT,pinValue)
gpio.write(outpin,pinValue)


--station_cfg={}
--station_cfg.save=true
--wifi.sta.config(station_cfg)

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
 
tmr.alarm(0, 2000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() == nil then
        print('\n\tCzekam na IP...')
    else
        tmr.stop(0)
        print(' IP address: ' .. wifi.sta.getip())
 
        if file.exists('WWWServer.lua') then
            file.remove("WWWServer.lc")
            node.compile("WWWServer.lua")
            file.remove("WWWServer.lua")            
        end
 
        print('Uruchamian WWWSerwer za 3 sek...')
 
        abort = function()
            tmr.stop(1)
            abort = nil
            print('Running app.lua aborted...')
        end
 
        tmr.alarm(1, 3000, tmr.ALARM_SINGLE, function()
            abort = nil
            print('Uruchamiam WWWServer...')
            require('WWWServer') 
        end)
 
    end
end)
