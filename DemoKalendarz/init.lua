local k = {}
local w = {}

function wartCzasu (g, m)
    return g*60+m
end

function odlegloscCzasu (s1, s2)
    return wartCzasu (parsowanieCzasu(s2)) - wartCzasu (parsowanieCzasu(s1))
end

function parsowanieCzasu (sA)
    gA, mA = string.match(sA, "(%d+):(%d+)")
    return tonumber(gA), tonumber(mA)
end

function parsowanieDaty (dA)
    dA, miA, rA, gA, mA, sA = string.match(dA, "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)")
    return tonumber(dA), tonumber(miA), tonumber(rA), tonumber(gA), tonumber(mA), tonumber(sA)
end

function wartDaty (dA, miA, rA, gA, mA, sA)
    return 24*60*dA + 60*gA + mA
end

function odlegloscDaty (d1, d2)
    return wartDaty (parsowanieDaty(d2)) - wartDaty (parsowanieDaty(d1))
end

function konwersjaDateNaS(dA, miA, rA, gA, mA, sA)
    return string.format("%02d/%02d/%04d %02d:%02d:%02d", dA, miA, rA, gA, mA, sA)
end

function konwersjaCzasNaData (c)
-- wymaga modułu WiFi
    dA, miA, rA, gA, mA, sA = parsowanieDaty(podajCzas())
    gB, mB = parsowanieCzasu(c)
    return konwersjaDateNaS(dA, miA, rA, gB, mB, 0)
end

function konwersjaCzasNaDataPrzyszla (c)
    dA, miA, rA, gA, mA, sA = parsowanieDaty(podajCzas())
    gB, mB = parsowanieCzasu(c)
    return konwersjaDateNaS(dA+1, miA, rA, gB, mB, 0)
end

function zapiszKalendarzDoPliku(nazwaPliku, k)
    s = sjson.encode(k)
    if file.open(nazwaPliku, "w") then 
        local line=file.write(s)
        file.close()
    else
        print ("Nie zapisano kalendarza do pliku: "..nazwaPliku)
    end
    file=nil; line=nil
    collectgarbage()
end

function odczytajKalendarzZPliku (nazwaPliku)
-- wymaga modułu pliki
    return sjson.decode(wczytajPlikDoZmiennej(nazwaPliku))
end

function zaIleUruchomicPompkiKalendarz()
-- wymaga modułu pliki
-- watość oznacza, że pomkpke należy uruchomic na wartosc minut
    local l = sjson.decode('[' .. wczytajPlikDoZmiennej("log.json") .. ']')
    if odlegloscDaty(l[#l].dataPomiaru, konwersjaCzasNaData(w[1]))>0 then
        return odlegloscDaty(podajCzas(), konwersjaCzasNaData(w[1])), konwersjaCzasNaData(w[1])
    else
        if odlegloscDaty(l[#l].dataPomiaru, konwersjaCzasNaData(w[2]))>0 then
            return odlegloscDaty(podajCzas(), konwersjaCzasNaData(w[2])), konwersjaCzasNaData(w[2])
        else
            return odlegloscDaty(podajCzas(), konwersjaCzasNaDataPrzyszla(w[1])), konwersjaCzasNaDataPrzyszla(w[1])           
        end
    end
end

-- table.insert(k, "08:20")
-- table.insert(k, "23:59")
-- local s = sjson.encode(k)
-- w = sjson.decode(s)
w = odczytajKalendarzZPliku ("kalendarz.json")
print (#w)
print (w[1])
print (parsowanieCzasu (w[1]))
print ('Wartość czasu: ' .. wartCzasu (parsowanieCzasu (w[1])))
print ('Wartość czasu: ' .. wartCzasu (parsowanieCzasu (w[2])))
print ('Odleglosc czasu: ' .. odlegloscCzasu (w[1], w[2]))
data1 = "08/03/2019 23:59:35"
data2 = "09/03/2019 00:01:35"
print ('Dla: ' .. data1 .. ' parsowanie: ')
print (parsowanieDaty(data1))
print (wartDaty(parsowanieDaty(data1)))
print ('Dla: ' .. data2 .. ' parsowanie: ')
print (parsowanieDaty(data2))
print (wartDaty(parsowanieDaty(data2)))
print ('Odleglosc dat: ' .. odlegloscDaty (data1, data2))
-- zapiszKlaendarzDoPliku("kalendarz.json", w)
zaIleUruchomicPompkiKalendarz()
print(konwersjaDateNaS (9, 3, 2019, 23, 59, 35))
print('Czas: ' .. w[1])
print(konwersjaCzasNaData(w[1]))
print('------Czy uruchomić pompki-----------')
print(zaIleUruchomicPompkiKalendarz())