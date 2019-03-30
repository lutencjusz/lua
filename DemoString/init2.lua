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

tAlert = wczytajPlikDoZmiennej("alert2.json")



local decJSON = sjson.decoder()
if decJSON:write (tAlert) == nil then
    print "tAlert nie działa..."
else
    ob = decJSON:result()
    print (ob.opis)
end

