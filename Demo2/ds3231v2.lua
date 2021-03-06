--------------------------------------------------------------------------------
-- DS3231 I2C module for NODEMCU
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tobie Booth <tbooth@hindbra.in>
--------------------------------------------------------------------------------

require("bit")
require("i2c")

local moduleName = 'ds3231v2'
local M = {}
_G[moduleName] = M

-- Constants:
M.EVERYSECOND = 6
M.EVERYMINUTE = 7
M.SECOND = 1
M.MINUTE = 2
M.HOUR = 3
M.DAY = 4
M.DATE = 5
M.DISABLE = 0

--nazwy dni tygodnia
wkd = {"Niedziela", "Poniedzialek", "Wtorek", "Sroda", "Czwartek", "Piatek", "Sobota" }


-- Default value for i2c communication
local id = 0

--device address
local dev_addr = 0x68

local function decToBcdv2(val)
             local d = string.format("%d",tonumber(val / 10))
             local d1 = tonumber(d*10)
             local d2 = val - d1
            return tonumber(d*16+d2)
         end

local function bcdToDec(val)
           local hl=bit.rshift(val, 4)
           local hh=bit.band(val,0xf)
          local hr = string.format("%d%d", hl, hh)
          return string.format("%d%d", hl, hh)
end

local function decToBcd(val)
  if val == nil then return 0 end
  return ((((val/10) - ((val/10)%1)) *16) + (val%10))
end

local function bcdToDecOld(val)
  return((((val/16) - ((val/16)%1)) *10) + (val%16))
end

local function addAlarmBit(val,day)
  if day == 1 then return bit.bor(val,64) end
  return bit.bor(val,128)
end

function M.getWeekDay(d)
    return wkd[d]
end

--get time from DS3231
function M.getTime() 
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x00)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c=i2c.read(id, 7)
  i2c.stop(id)
  return bcdToDec(tonumber(string.byte(c, 1))),
  bcdToDec(tonumber(string.byte(c, 2))),
  bcdToDec(tonumber(string.byte(c, 3))),
  wkd[tonumber(bcdToDec(string.byte(c,4)))],
  bcdToDec(tonumber(string.byte(c, 5))),
  bcdToDec(tonumber(string.byte(c, 6))),
  bcdToDec(tonumber(string.byte(c, 7)))
end

--set time for DS3231
-- enosc setted to 1 disables oscilation on battery, stopping time
function M.setTime(second, minute, hour, day, date, month, year, disOsc)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x00)
  i2c.write(id, decToBcd(second))
  i2c.write(id, decToBcd(minute))
  i2c.write(id, decToBcd(hour))
  i2c.write(id, decToBcd(day))
  i2c.write(id, decToBcd(date))
  i2c.write(id, decToBcd(month))
  i2c.write(id, decToBcd(year))
  i2c.stop(id)

  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c = string.byte(i2c.read(id, 1), 1)
  i2c.stop(id)
  if disOsc == 1 then c = bit.bor(c,128)
  else c = bit.band(c,127) end
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.write(id, c)
  i2c.stop(id)
end

-- Reset alarmId flag to let alarm to be triggered again
function M.reloadAlarms ()
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
end

-- Enable alarmId bit. Let it to be triggered
function M.enableAlarm (almId)
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
end
-- If almID equals 1 or 2 disable that alarm, otherwise disables both.
function M.disableAlarm (almId)
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
end

-- almId can be 1 or 2;
-- almType should be taken from constants
function M.setAlarm (almId, almType, second, minute, hour, date)
  if bit == nil or bit.band == nil or bit.bor == nil then
    print("[ERROR] Module bit is required to use alarm function")
    return nil
  end
  if almId ~= 1 and almId ~= 2 then print('[ERROR] Wrong alarm id (1 or 2): '..almId) return end
  M.enableAlarm(almId)
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
end

function M.getTemp ()
  --uruchomienie CONV - niepotrzebne
  --i2c.start(id)
  --i2c.address(id, dev_addr, i2c.TRANSMITTER)
  --i2c.write(id, 0x0E)
  --i2c.stop(id)
  --i2c.start(id)
  --i2c.address(id, dev_addr, i2c.RECEIVER)
  --local r = tonumber(string.byte(i2c.read(id, 1)))
  --local m = bit.bit(5)
  --i2c.write(id,bit.bor(r,m)
  --i2c.stop(id)

  --pobranie temperatury
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x11)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local t = i2c.read(id, 2)
  i2c.stop(id)
  
  return tonumber(string.byte(t, 1)), bit.rshift(tonumber(string.byte(t, 2)),6)
end

-- Resetting RTC Stop Flag
function M.resetStopFlag ()
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

function M.pobierzCzas()
    tm = rtctime.epoch2cal(rtctime.get()) -- odzczyt synch. daty
    if tm["year"] > 1970 then -- czy data zsynchronizowana?
        s = string.format("%02d",tm["sec"])
        m = string.format("%02d",tm["min"])
        h = string.format("%02d",tm["hour"]+h_RPL) --skorygowany czas letni
        d = ds3231v2.getWeekDay(tm["wday"])
        dt = string.format("%02d",tm["day"])
        mn = string.format("%02d",tm["mon"])
        y = string.format("%02d",tm["year"]-2000) --skrócona wersja roku
    else
        s, m, h, d, dt, mn, y = M.getTime()
    end
    return s, m, h, d, dt, mn, y
end

return M
