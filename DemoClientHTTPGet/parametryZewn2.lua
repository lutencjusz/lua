function tempFloatNaInt (s, t) -- wyszukuje liczbe float i zmianienia ja na dwie
-- s - string do przeszukania
-- t - zmienna do znalezienia (dokładnie 4 znaki)

    local ea = string.find(s, t)
    local da = string.sub(s, ea+4)
    -- print ("da: " .. da)
    local e1a = string.find(da, ',')
        if e1a == nil then
        e1a = string.find(da, '}')
    end
    local d1a = string.sub(da, 1, e1a-1)
    -- print ("d1a: " .. d1a)
    
    local e1 = string.find(d1a, '.')
    -- print ("s: " .. s .. ";e1: " .. e1)
    local c1 = string.sub(d1a, 1, e1+2)
    local d1 = string.sub(d1a, e1+4)
    return c1+0-273, d1+0
end

function znajdzDanePogodoweJSON(s)
-- s - cały komunikat do wyszukania JSON 
    local e = string.find(s, 'main":{')
    local d = string.sub(s, e+6)
    -- print ("d: " .. d)
    local e1 = string.find(d, "}")
    return string.sub(d, 1, e1)
end

function odswierzDaneTestowe()
    print(" Wczytuje dane testowe z serwisu api.openweathermap.org...")
    local host = "api.openweathermap.org"
    local path = "/data/2.5/weather?q=Warsaw,pl&APPID=wpisz swój klucz"
    local url = "https://" .. host .. path;
    http.get(url, nil, function(code, data)
        if (code < 0) then
            print("HTTP request failed")
        else
            local dataJSON = znajdzDanePogodoweJSON(data)
            pTestowe = sjson.decode(dataJSON)
            pTestowe.temp, pTestowe.temp_u = tempFloatNaInt (dataJSON, 'mp":')
            pTestowe.temp_min, pTestowe.temp_min_u = tempFloatNaInt (dataJSON, 'in":')
            pTestowe.temp_max, pTestowe.temp_max_u = tempFloatNaInt (dataJSON, 'ax":')
            if czyZsynchonizowano then
                pTestowe.dataPomiaru = podajCzas()
            else
                pTestowe.dataPomiaru = "01/01/2019 00:00:01"
            end
            pTestowe.Vc = 3
            pTestowe.Vp = 12
    
            print ("temp: " .. pTestowe.temp .. ',' .. pTestowe.temp_u)
            print ("temp_min: " .. pTestowe.temp_min .. ',' .. pTestowe.temp_min_u)
            print ("temp_max: " .. pTestowe.temp_max .. ',' .. pTestowe.temp_max_u)
            host = nil; path = nil; url = nil
            collectgarbage() 
        end
    end)
end
    
