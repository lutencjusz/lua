plik = file.open ("ustawienia.json","r")
print (plik)
l=plik:read()
file.close()

print(l)
u = sjson.decode(l)
print(u.id)
print(u.pass.."\n")
l2 = sjson.encode(u)
print(l2)

--plik = file.open ("ustawienia.json","a+")
--print (plik)
--plik:writeline(","..l2)
--file.close()



