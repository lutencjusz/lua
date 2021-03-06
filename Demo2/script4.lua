 -- Set Initial Time and Date
require('ds3231')                                -- call for new created DS3231 Module Driver
sda = 2
scl = 1                                      --  declare your I2C interface PIN's
ds3231:init(sda, scl)                           -- initialize I2C Bus
ds3231:setTime(0,25,22,4,25,05,17)   -- setTime(s,min,hour,weekday,day,month, year)
-- get Time and Date
require('ds3231')
sda, scl = 2, 1
ds3231:init(sda, scl)

s, m, h, d, dt, mn, y = ds3231:readTime()
print(string.format("%s - %s/%s/20%s",d, dt, mn, y))
print(string.format(" %s:%s:%s", h, m, s))
                                              -- call for new created AT24C32 Module Driver
memadr=0x50                                                   -- let's read from begining                                           -- I2C pins setup 
  edata="4.321 - Data from the EEPROM"        -- Data to write to EEPROM
ds3231:write_EEPROM(0x50,memadr,edata)     -- Write Data edata to EEPROM starting with address=0
ds3231:read_EEPROM(0x50,memadr,28)         -- Read Data from EEPROM, address=0, length=28

--sekwencja do uruchomienia komunikacji z DS3231
require('ds3231v2')                                -- call for new created DS3231 Module Driver
sda = 2
scl = 1                                      --  declare your I2C interface PIN's
i2c.setup(0, sda, scl, i2c.SLOW)   


-- Ustawienie alarmu na minutę  
almId=2
ds3231v2.reloadAlarms()
ds3231v2.setAlarm(almId,ds3231v2.EVERYMINUTE)

ds3231v2.disableAlarm(1)

--odczyt czasu
s, m, h, d, dt, mn, y = ds3231v2:getTime()
print(string.format("%s - %s/%s/20%s",d, dt, mn, y))
print(string.format(" %s:%s:%s", h, m, s))

