-- wynik = ""
czyZsynchonizowano = false
pTestowe= {}
wynik = nil

function tempFloatNaIntAirapi (s, t) -- wyszukuje liczbe float i zmianienia ja na dwie
-- s - string do przeszukania
-- t - zmienna do znalezienia (dokładnie 13 znakow)

    local ea = string.find(s, t)
    local da = string.sub(s, ea+14)
    -- print ("da: " .. da)
    local e1a = string.find(da, ',')
        if e1a == nil then
        e1a = string.find(da, '}')
    end
    local d1a = string.sub(da, 1, e1a-2)
    -- print ("d1a: " .. d1a)
    -- print ("s: " .. s .. ";e1: " .. e1)
    c1, d1 = string.match(d1a, "(%d+).(%d+)")
    -- print ("c1: " .. c1 .. ";d1: " .. d1)
    return c1+0, d1+0
end

function znajdzDanePogodoweJSON(s)
-- s - cały komunikat do wyszukania JSON 
    local s1 = ""
    local g = string.find(s, 'current')
    local g1 = string.find(s, 'history')
    if g ~= nil and g1 ~= nil then
        s1 = string.sub(s, g, g1)
    else
        return nil
    end    
    local e = string.find(s1, 'values')
    local e1 = string.find(s1, "indexes")
    if e ~= nil and e1 ~= nil then
        return string.sub(s1, e+8, e1-3)
    else
        return nil
    end
end

function odswierzDanePowietrza()
    print(" Wczytuje dane testowe z serwisu airapi.airly.eu...")
    local host = "airapi.airly.eu"
    -- 'Accept: application/json\r\n'
    -- local path = "/v2/measurements/point?&lat=50.062006&lng=19.940984"
    local path = "/v2/measurements/installation?installationId=6532"
    local url = "https://" .. host .. path;
    local srv = tls.createConnection(net.TCP, 0)
    srv:on("receive", function(code, data)
        print (#data)
        d2 = znajdzDanePogodoweJSON(data)
        if d2 ~= nil then       
            wynik = d2
            host = nil; path = nil; url = nil; srv = nil
            collectgarbage() 
        end
    end)
    srv:on("connection", function(sck, c)
    sck:send("GET " .. path .. " HTTP/1.1\r\nAccept: application/json\r\napikey: wpisz swoj klucz \r\nHost: " .. host .. "\r\nConnection: close\r\nAccept: */*\r\n\r\n")
  end)
  srv:connect(443, host)
end

odswierzDanePowietrza()

  tmr.alarm(0, 1000, tmr.ALARM_AUTO, function()
    if wynik ~= nil then
        tmr.stop(0)
            pTestowe.pm1, pTestowe.pm1_u = tempFloatNaIntAirapi (wynik, '"PM1')
            pTestowe.pm25, pTestowe.pm25_u = tempFloatNaIntAirapi (wynik, "PM25")
            pTestowe.pm10, pTestowe.pm10_u = tempFloatNaIntAirapi (wynik, '"PM10')
            pTestowe.pm25, pTestowe.pm25_u = tempFloatNaIntAirapi (wynik, "PM25")            
            pTestowe.humidity, pTestowe.humidity_u = tempFloatNaIntAirapi (wynik, "DITY")
            pTestowe.temp, pTestowe.temp_u = tempFloatNaIntAirapi (wynik, "TURE")
            pTestowe.pressure, pTestowe.pressure_u = tempFloatNaIntAirapi (wynik, "SURE")
            if czyZsynchonizowano then
                pTestowe.dataPomiaru = podajCzas()
            else
                pTestowe.dataPomiaru = "01/01/2019 00:00:01"
            end
            pTestowe.Vc = 3
            pTestowe.Vp = 12 
            print (sjson.encode(pTestowe))
            print ("temp: " .. pTestowe.temp .. ','.. pTestowe.temp_u)
            print ("PM1: " .. pTestowe.pm1 .. ',' .. pTestowe.pm1_u)
            print ("PM10: " .. pTestowe.pm10 .. ',' .. pTestowe.pm10_u)
            print ("PM25: " .. pTestowe.pm25 .. ',' .. pTestowe.pm25_u)
            print ("wilgotność: " .. pTestowe.humidity .. ',' .. pTestowe.humidity_u)
            print ("ciśnienie: " .. pTestowe.pressure .. ',' .. pTestowe.pressure_u)
            host = nil; path = nil; url = nil
            collectgarbage()
    end
end)

