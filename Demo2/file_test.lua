
i=0

plik = file.open("log.txt", "a+") -- otworzenie pliku do dodawania

-- zapis do pliku ze zmienną
--if plik then
--    for i=0,10 do 
--       file.writeline(string.format('Linia %i',i))
--    end
--end
plik.close()

plik = file.open("log.txt", "r")
print (plik.read())
plik.close()

l=file.list()
for i,j in pairs(l) do
    print ("\tnazwa: "..i.."\trozmiar: "..j)
end

s = file.stat("log.txt")
print("\tnazwa: " .. s.name.."\tsize: " ..s.size)

t = s.time
print(string.format("%02d:%02d:%02d", t.hour, t.min, t.sec))
print(string.format("%04d-%02d-%02d", t.year, t.mon, t.day))

if s.is_dir then print("is directory") else print("is file") end
if s.is_rdonly then print("is read-only") else print("is writable") end
if s.is_hidden then print("is hidden") else print("is not hidden") end
if s.is_sys then print("is system") else print("is not system") end
if s.is_arch then print("is archive") else print("is not archive") end

s = nil
t = nil

    
