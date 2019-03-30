
local function wyslijPlikHTML(conn, filename)      
if file.open(filename, "r") then         
    repeat           
    local line=file.readline()           
    if line then               
        conn:send(line);          
    end           
    until not line           
    file.close();      
    else
    conn:send(responseHeader("404 Not Found","text/html"));          
    conn:send("Page not found");              
    end  
end 

local function potwierdzHTML(code, type)      
    return "HTTP/1.1 " .. code .. "\r\nConnection: close\r\nServer: nunu-Luaweb\r\nContent-Type: " .. 
    type .. "\r\n\r\n";   
end

local function wyslijAlert (conn, s, wy, akt)

    if akt == 1 then
        sakt = '<strong>Odczyt aktualny!</strong> '
    else
        sakt = '<strong>Odczyt nieaktualny!</strong> '
        wy = 'n'   
    end
    if wy == 'g' then
        conn:send('<div class="alert alert-success alert-dismissable">'
            ..'<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>'
            ..sakt)
    end
    if wy == 'c' then
        conn:send('<div class="alert alert-danger alert-dismissable">'
            ..'<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>'
            ..sakt)        
    end
    if wy == 'z' then
        conn:send('<div class="alert alert-warning alert-dismissable">'
            ..'<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>'
            ..sakt)
    end
    if wy == 'n' then
        conn:send('<div class="alert alert-info alert-dismissable">'
            ..'<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>'
            ..sakt)        
    end
    conn:send(s.."</div>")
end

local function jakiAlert (np, max)

    p1 = 0.5 -- max. prog dla czer
    p2 = 0.8 -- max. prog dla zoltego

    local w = 'z' -- domyslna wartosc zolta
    
    if np == 0 then
        w = 'n'
    end
    if (np / max) > 0 and (np / max) < p1 then
        w = 'c'
    end
    if (np / max) > p2 then 
        w = 'g'
    end
    return w;

end

function polaczony(sck)
    sck:on("receive",function(c,request)           
        c:send(potwierdzHTML("200 OK","text/html"))
    end)
    sck:on("connection", function(c,payload)
    --c:on("receive", function(c,payload)
        gpio.write(pin, gpio.LOW)
        print("\tJest połaczenie...")
        wyslijPlikHTML(c, "Naglowek.html") -- nagłowek strony
        c:send('<div class="jumbotron"><h1>SterKwiat</h1>'
            ..'<p>Sterownik do podlewania kwiatków na balkonie</p></div>')

        -- oczyt daty i czasu z DS3231 lub synch.        
        s, m, h, d, dt, mn, y = ds3231v2.pobierzCzas()
        c:send('<div class="row">'
                ..'<div class="col-sm-4">')
        c:send(string.format("Dziś jest %s - %s/%s/20%s \t%s:%s:%s</p>",d, dt, mn, y, h, m, s))
        c:send('</div>')
                
        -- odczyt temperatury
        c:send('<div class="col-sm-4">')
        th, tl = ds3231v2:getTemp()
        c:send(string.format("Temperatura: %d.%d C", th, tl))
        c:send('</div></div>')

        nz = adc.readvdd33(0)/1000 -- napięcie zasilania
        wyslijAlert(c, string.format("Napięcie zasilania układu: %.2f V", nz), jakiAlert(nz, 3), 1)
        
        np =  rtcmem.read32(pam+7, 1) + (rtcmem.read32(pam+8, 1)/100)

        wyslijAlert(c, string.format("Napięcie zasiania pompek: %.2f V", np), jakiAlert(np, 49), rtcmem.read32(pam, 1))        
        
        c:send("<h2>Alerty z czujników:</h2>")
        c:send('<table class="table table-condensed"><thead><tr><th>Godzin odczytu</th>'
                        ..'<th>Czas odczytu</th><th>Napięcie zasialania</th>'
                        ..'<th>Napięcie pompek</th></tr></thead><tbody>')

        plik = file.open("LogOdczytCz.log", "r") --odczyt logów
        repeat
            fi=plik.read()
            if fi ~= nil then
                c:send(string.format("%s", fi))
            end          
        until fi==nil
        plik.close() -- plik zamknięty

        plik = nil
        fi = nil; nz = nil; np = nil; th = nil; tl = nil

        c:send('</tbody></table></div></body></html>')
        gpio.write(pin, gpio.HIGH)
    end)
    sck:on('sent', function(c)
        c:close()
    end)
end

-- uruchomienie klienta WWW
srv=net.createServer(net.TCP)
srv:listen(80,polaczony)
