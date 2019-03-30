require('DS3231')

sda, scl = 2, 1 
DS3231:init(sda, scl) 

address = 0x51

i2c.setup(0, 2, 1, i2c.SLOW)

setTime(5,08,12,3,6,04,15)   -- setTime(s,min,hour,weekday,day,month, year)
-- get Time and Date
require('ds3231')
sda, scl = 2, 1
ds3231:init(sda, scl)

s, m, h, d, dt, mn, y = readTime()
print(string.format("%s - %s/%s/",d, dt, mn))
print(string.format(" %i:%i:%i", h, m, s))
