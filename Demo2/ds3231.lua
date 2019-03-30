 function decToBcd(val)
             local d = string.format("%d",tonumber(val / 10))
             local d1 = tonumber(d*10)
             local d2 = val - d1
            return tonumber(d*16+d2)
         end

     function bcdToDec(val)
           local hl=bit.rshift(val, 4)
           local hh=bit.band(val,0xf)
          local hr = string.format("%d%d", hl, hh)
          return string.format("%d%d", hl, hh)
     end

ds3231={           
       address = 0x68, -- A2, A1, A0 = 0
        id = 0,

        init = function (self, sda, scl)
               self.id = 0
              i2c.setup(self.id, sda, scl, i2c.SLOW)
       end, 

  readTime = function (self)
       wkd = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
       i2c.start(self.id)
       i2c.address(self.id, self.address, i2c.TRANSMITTER)
       i2c.write(self.id, 0x00)
       i2c.stop(self.id)
       i2c.start(self.id)
       i2c.address(self.id, self.address, i2c.RECEIVER)
       c=i2c.read(self.id, 7)
       i2c.stop(self.id)
       return  bcdToDec(string.byte(c,1)),
               bcdToDec(string.byte(c,2)),
               bcdToDec(string.byte(c,3)),
               wkd[tonumber(bcdToDec(string.byte(c,4)))],
               bcdToDec(string.byte(c,5)),
               bcdToDec(string.byte(c,6)),
               bcdToDec(string.byte(c,7))
   end,

      setTime = function (self, second, minute, hour, day, date, month, year)
       i2c.start(self.id)
       i2c.address(self.id, self.address, i2c.TRANSMITTER)
       i2c.write(self.id, 0x00)
       i2c.write(self.id, decToBcd(second))
       i2c.write(self.id, decToBcd(minute))
       i2c.write(self.id, decToBcd(hour))
       i2c.write(self.id, decToBcd(day))
       i2c.write(self.id, decToBcd(date))
       i2c.write(self.id, decToBcd(month))
       i2c.write(self.id, decToBcd(year))
       i2c.stop(self.id)
   end,

   read_EEPROM = function (self, devadr, memadr, length)
            adrh=bit.rshift(memadr, 8)
            adrl=bit.band(memadr,0xff)
            i2c.start(self.id)
            i2c.address(self.id, self.address, i2c.TRANSMITTER)
            i2c.write(self.id, adrh)
            i2c.write(self.id, adrl)
            i2c.stop(self.id)
            i2c.start(self.id)
            i2c.address(self.id, self.address, i2c.RECEIVER)
            c=i2c.read(self.id, length)
            i2c.stop(self.id)
           print(c)
           return  c
      end,

write_EEPROM = function (self, devadr, memadr, edata)
       i = 1
       length = string.len(edata)
       adrh=bit.rshift(memadr, 8)
       adrl=bit.band(memadr,0xff)
       i2c.start(self.id)
       i2c.address(self.id, self.address, i2c.TRANSMITTER)
       i2c.write(self.id, adrh)
       i2c.write(self.id, adrl)
       print(edata)                               --debug only
       print(string.byte(edata,1))        --debug only
       while i<=length do
          tmr.wdclr()
          i2c.write(self.id,string.byte(edata,i))
          i = i+1
       end
       i2c.stop(self.id)
   end,

-- Reset alarmId flag to let alarm to be triggered again
reloadAlarms = function ()
  if bit == nil or bit.band == nil or bit.bor == nil then
    print("[ERROR] Module bit is required to use alarm function")
    return nil
  end
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0F)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local d = string.byte(i2c.read(id, 1), 1)
  i2c.stop(id)
  -- Both flag needs to be 0 to let alarms trigger
  d = bit.band(d,252)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0F)
  i2c.write(id, d)
  i2c.stop(id)
  print('[LOG] Alarm '..almId..' reloaded')
end,

-- Enable alarmId bit. Let it to be triggered
enableAlarm = function (almId)
  if bit == nil or bit.band == nil or bit.bor == nil then
    print("[ERROR] Module bit is required to use alarm function")
    return nil
  end
  if almId ~= 1 and almId ~= 2 then print('[ERROR] Wrong alarm id (1 or 2): '..almId) return end
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c = string.byte(i2c.read(id, 1), 1)
  i2c.stop(id)
  c = bit.bor(c,4)
  if almId == 1 then c = bit.bor(c,1)
  else c = bit.bor(c,2) end
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.write(id, c)
  i2c.stop(id)
  M.reloadAlarms()
  print('[LOG] Alarm '..almId..' enabled')
end,

-- If almID equals 1 or 2 disable that alarm, otherwise disables both.
disableAlarm = function (almId)
  if bit == nil or bit.band == nil or bit.bor == nil then
    print("[ERROR] Module bit is required to use alarm function")
    return nil
  end
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c = string.byte(i2c.read(id, 1), 1)
  i2c.stop(id)
  if almId == 1 then c = bit.band(c, 254)
  elseif almId == 2 then c = bit.band(c, 253)
  else
    almId = '1 and 2'
    c = bit.band(c, 252)
  end
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.write(id, c)
  i2c.stop(id)
  print('[LOG] Alarm '..almId..' disabled')
end,

-- almId can be 1 or 2;
-- almType should be taken from constants
setAlarm = function (almId, almType, second, minute, hour, date)
  if bit == nil or bit.band == nil or bit.bor == nil then
    print("[ERROR] Module bit is required to use alarm function")
    return nil
  end
  if almId ~= 1 and almId ~= 2 then print('[ERROR] Wrong alarm id (1 or 2): '..almId) return end
  ds3231:enableAlarm(almId)
  second = decToBcd(second)
  minute = decToBcd(minute)
  hour = decToBcd(hour)
  date = decToBcd(date)
  if almType == M.EVERYSECOND or almType == M.EVERYMINUTE then
    second = addAlarmBit(second)
    minute = addAlarmBit(minute)
    hour = addAlarmBit(hour)
    date = addAlarmBit(date)
  elseif almType == M.SECOND then
    minute = addAlarmBit(minute)
    hour = addAlarmBit(hour)
    date = addAlarmBit(date)
  elseif almType == M.MINUTE then
    hour = addAlarmBit(hour)
    date = addAlarmBit(date)
  elseif almType == M.HOUR then
    date = addAlarmBit(date)
  elseif almType == M.DAY then
    date = addAlarmBit(date,1)
  end
  local almStart = 0x07
  if almId == 2 then almStart = 0x0B end
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, almStart)
  if almId == 1 then i2c.write(id, second) end
  i2c.write(id, minute)
  i2c.write(id, hour)
  i2c.write(id, date)
  i2c.stop(id)
  print('[LOG] Alarm '..almId..' setted')
end,

-- Get Control and Status bytes
getBytes = function ()
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c = i2c.read(id, 2)
  i2c.stop(id)
  return tonumber(string.byte(c, 1)), tonumber(string.byte(c, 2))
end,

-- Resetting RTC Stop Flag
resetStopFlag = function ()
  if bit == nil or bit.band == nil or bit.bor == nil then
    print("[ERROR] Module bit is required to reset stop flag")
    return nil
  end
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0F)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local s = string.byte(i2c.read(id, 1))
  i2c.stop(id)
  s = bit.band(s,127)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0F)
  i2c.write(id, s)
  i2c.stop(id)
  print('[LOG] RTC stop flag resetted')
end   

}
