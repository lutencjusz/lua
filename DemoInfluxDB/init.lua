LED_ON = 0
LED_OFF = 1
pin=0

require ('parametryZewn')
require ('InfluxDB')
                
czyZsynchonizowano = false
require ('WiFi')
tmr.alarm(2, 1000, tmr.ALARM_AUTO, function()
    if czyZsynchonizowano then
        tmr.stop(2)
        odswierzDaneTestowe() -- wymaga parametryZewn.lua        
        tmr.alarm(3, 1000, tmr.ALARM_AUTO, function()
        -- wczytał parametry testowe
            if pTestowe ~= nil then
                tmr.stop(3)
                require ('logika')
                -- wczytał parametry testowe
                tmr.alarm(4, 1000, tmr.ALARM_AUTO, function()
                    odswierzZakresyCzujnikow() --wymaga logika.lua oraz parametryCz.json
                    if pCz ~= nil then
                        tmr.stop(4)
                        zapiszPTestoweInfluxDB ()
                    end
                end)
            end
        end)
     end
end)

