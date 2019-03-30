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

function odswierzDanePowietrza()
    print(" Wczytuje dane testowe z serwisu airapi.airly.eu...")
    local host = "airapi.airly.eu"
    local headers = 'apikey: wpisz swój klucz\r\n', 
    'Accept: application/json\r\n'
    local path = "/v2/measurements/point?&lat=50.062006&lng=19.940984"
    local url = "http://" .. host .. path;
    http.get(url, headers, function(code, data)
        if (code < 0) then
            print("HTTP request failed")
            print (code)
        else
            -- local dataJSON = znajdzDanePogodoweJSON(data)
            print (code .. ";" .. data)
            host = nil; path = nil; url = nil
            collectgarbage() 
        end
    end)
end
   
