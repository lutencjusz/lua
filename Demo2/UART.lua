--uart.alt(0) -- 1 wyłacza terminal
--print (uart.getconfig(0))

pam = 100 -- powtorzenie z init

local function wpisLog (p1, rok, ms, dz, go, mi, se, wo1, wo2)
    local plik = file.open(p1, "a+")
    if plik then
        plik.write(string.format("<tr><th> 20%02d/%02d/%02d </th>", rok, ms, dz))
        plik.write(string.format("<th> %02d:%02d:%02d </th>", go, mi, se))
        plik.write(string.format("<th> %2.2f </th>", wo1))
        plik.writeline(string.format("<th> %2.2f </th></tr>", wo1))
        plik.close()
     else
        print("Nie można otworzyć %s", p1)   
     end   
end  

function pobierzCzas2()
    tm = rtctime.epoch2cal(rtctime.get()) -- odzczyt synch. daty
--    if tm["year"] > 1970 then -- czy data zsynchronizowana?
        s = string.format("%02d",tm["sec"])
        m = string.format("%02d",tm["min"])
        h = string.format("%02d",tm["hour"]) --skorygowany czas letni
        d = string.format("%s", tm["wday"])
        dt = string.format("%02d",tm["day"])
        mn = string.format("%02d",tm["mon"])
        y = string.format("%02d",tm["year"]-2000) --skrócona wersja roku
--    else
--        s, m, h, d, dt, mn, y = M.getTime()
--    end
    return s, m, h, d, dt, mn, y
end
-- przerwanie na wprowadzenie wyników z czujników

l = 0 -- licznik do powtorzeń pobierania danych
uart.on("data", 7,
    function(data)
        local a = {} -- deklaracja tablicy   
        st = string.match(data, '1.*1')
        if st ~= nil then
            print("receive from uart:", st)
            print(#st)
        else
            print("dane są puste")
        end
        if st ~= nil and #st>=6 then
            for i=1,#st do
                a[i] = tonumber(string.byte(st,i))
            end
            print(string.format("%d; %d; %d; %d", a[2], a[3], a[4], a[5]))
            if l<3 then
                l = l + 1
                if a[1]==49 and a[6]==49 then
                    uart.write(0, "ok")
                    s, m, h, d, dt, mn, y = pobierzCzas2()
                    rtcmem.write32(pam, 1, h, m, s, dt, mn, y, a[2], a[3], a[4], a[5]) -- zapis do pamięci
                    wpisLog ("LogOdczytCz.log", y, mn, dt, h, m, s, a[2]+(a[3]/100), a[4]+(a[5]/100))
                    uart.on("data") -- unregister callback function
                else
                    uart.write(0, "blad1")
                    rtcmem.write32(pam, 0)
                end
            else
                print("Wystarczy...")
                uart.on("data") -- unregister callback function
            end
        else
            uart.write(0, "blad2")
            rtcmem.write32(pam, 0)
            uart.on("data") -- unregister callback function        
        end
end, 0)
a=nil; st=nil
collectgarbage() -- czyszczenie pamięci
--print(string.format("Znacznik: %d %2d:%2d:%2d %d/%d/20%2d d1=%d, d2=%d, d3=%d, d4=%d", rtcmem.read32(pam, 11)))

