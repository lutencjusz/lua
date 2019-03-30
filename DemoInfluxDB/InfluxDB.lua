gpio.write (pin, LED_ON)

function zapiszInfluxDB (db, body)
http.post('http://192.168.0.11:8086/write?db=' ..db,
  'Content-Type: application/json\r\n', --bez tego komunikat jest nieprawidłowy
  body,
  function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code, data)
    end
  end)
end

function zapiszPTestoweInfluxDB ()
-- wymaga modulu parametryZewn.lua
-- wymaga modulu logika,lua oraz pliku parametryCz.json
    zapiszInfluxDB ("test", "temp,value=" ..pTestowe.temp .. "." .. pTestowe.temp_u
    .. ' kom="Temperatura powietrza"')
    zapiszInfluxDB ("test", "pGraniczne,temp_min=" ..pTestowe.temp_min .. "." .. pTestowe.temp_min_u
    .." temp_max=" ..pTestowe.temp_max .. "." .. pTestowe.temp_max_u)
    zapiszInfluxDB ("test", "V,Vc=" .. pTestowe.Vc .." Vp=" ..pTestowe.Vp)
    zapiszInfluxDB ("test", "pGraniczne,humidityMax=" .. pCz.humidityMax .." humidityMin=" .. pCz.humidityMin)
    zapiszInfluxDB ("test", "humidity,humidity=" .. pTestowe.humidity .." humidityOpt=" .. pCz.humidityOpt)
end

gpio.write (pin, LED_OFF)
