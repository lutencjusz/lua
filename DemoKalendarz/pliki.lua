
function wczytajPlikDoZmiennej(nazwaPliku)
    if file.open(nazwaPliku, "r") then 
        local line=file.read()
        file.close()
        return line
    else
        print ("Nie wczytano pliku: "..nazwaPliku)
        return "" 
    end
    file=nil; line=nil
    collectgarbage()
end

function usunPlik(nazwaPliku)
    if file.open(nazwaPliku, "r") then 
        file.remove(nazwaPliku)
    else
        print ("Nie wczytano pliku: "..nazwaPliku)
        return "" 
    end

    file=nil;
    collectgarbage()
end

function ileWierszyWPliku (nazwaPliku)
   local licznik=0
   if file.open(nazwaPliku, "r") then
        repeat
            line = file.readline()
            if line then
                licznik = licznik + 1
            end
        until line == nil
        file.close()
    end 
    file=nil; line=nil; plik=nil
    collectgarbage()
    return licznik
end

function przepiszPliki (pz, ptmp, iloscLiniPlikuD, iloscLiniiPlikuZ)
    -- pz - plik zródłowy
    -- ptmp - plik tymczasowy
    -- maxLiniCz - maksymalna liczba linii
    ali = iloscLiniiPlikuZ --ilosc linii pliku zrodlowego
    li = iloscLiniPlikuD --max ilosc linii pliku docelowego
    src = file.open(pz, "r") --przepisywanie plikow
    if src then
        dest = file.open(ptmp, "a+")
        if dest then
            local line
            repeat
                line = src:readline()
                ali = ali - 1
                if line and li >= ali then
                    dest:write(line)
                    li = li - 1
                end
            until line == nil or li == 0
            dest:close(); dest = nil
        end
        src:close(); dest = nil
    end
    file.remove(pz)
    file.rename(ptmp, pz)
    src=nil; dest=nil; li=nil
    collectgarbage() -- czyszczenie pamięci  
end

function wyslijPlik(nazwaPliku, conn)
    local plik = "[\n"
    if file.open(nazwaPliku, "r") then
        repeat
            line = file.readline()
            if line then
                --print("linia: "..line)
                plik = plik..line
            end
        until line == nil
        plik = plik.."]\n"
    else
        print ("Nie wczytano pliku: "..nazwaPliku)
        plik = plik.."]\n"
    end
    file.close()
    conn:send(plik)
    systemInfo("/wszystko max")
    file=nil; line=nil; plik=nil
    collectgarbage()
end
