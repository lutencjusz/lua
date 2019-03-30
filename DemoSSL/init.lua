pin=0
-- require("WiFi")

function liczbaFloatNaInt (s, t) -- wyszukuje liczbe float i zmianienia ja na dwie
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
    return c1+0, d1+0
end

function znajdzDanePogodoweJSON(s)
-- s - cały komunikat do wyszukania JSON 
    local e = string.find(s, 'main":{')
    local d = string.sub(s, e+6)
    -- print ("d: " .. d)
    local e1 = string.find(d, "}")
    return string.sub(d, 1, e1)
end

function test()
  local host = "api.openweathermap.org"
  local path = "/data/2.5/weather?q=Warsaw,pl&APPID=podaj wsój klucz"
  local url = "https://" .. host .. path;
  local srv = tls.createConnection(net.TCP, 0)
  srv:on("receive", function(sck, dane)
    -- print("net/TLS to " .. url .. " succeeded\nData:\n" .. dane)
    local dataJSON = znajdzDanePogodoweJSON(dane)
    print ("DataJSON: " .. dataJSON)
    local u = sjson.decode(dataJSON)
    -- print ("u: " .. u.humidity)
    u.temp, u.temp_u = liczbaFloatNaInt (dataJSON, 'mp":')
    u.temp_min, u.temp_min_u = liczbaFloatNaInt (dataJSON, 'in":')
    u.temp_max, u.temp_max_u = liczbaFloatNaInt (dataJSON, 'ax":')

    print ("temp: " .. u.temp .. ',' .. u.temp_u)
    print ("temp_min: " .. u.temp_min .. ',' .. u.temp_min_u)
    print ("temp_max: " .. u.temp_max .. ',' .. u.temp_max_u)
    print (sjson.encode(u))
  end)
  srv:on("connection", function(sck, c)
    sck:send("GET " .. path .. " HTTP/1.1\r\nHost: " .. host .. "\r\nConnection: close\r\nAccept: */*\r\n\r\n")
  end)
  srv:connect(443, host)
end
-- test("raw.githubusercontent.com", "/espressif/esptool/master/MANIFEST.in")
-- test("nodemcu-build.com", "/")
-- test("google.com", "/")
test()
-- d, u = liczbaFloatNaInt ("281.22")
-- print ("d: "..d.."u: "..u.."d+u"..d+u)
