sntp.sync(nil, nil, nil, 1)

tm = rtctime.epoch2cal(rtctime.get())
print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"]+2, tm["min"], tm["sec"]))

tm = rtctime.epoch2cal(rtctime.get())
if tm["year"] > 1970 then
    print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"]+2, tm["min"], tm["sec"]))
else
    print("Błędna data\n")
end

      tm = rtctime.epoch2cal(rtctime.get()) -- odzczyt synch. daty
        if tm["year"] > 1970 then -- czy data zsynchronizowana?
            s = tm["sec"]
            m = tm["min"]
            h = tm["hour"]
            dt = tm["wdey"]
            d = tm["day"]
            mn = tm["mon"]
            y = tm["year"]
        else
            s, m, h, d, dt, mn, y = ds3231v2:getTime()
        end
        print(string.format("<h2>\tDziś jest %s - %s/%s/20%s \t%s:%s:%s</h2>",d, dt, mn, y, h, m, s))

 print(ds3231v2.getWeekDay(tm["wday"]))

print(s)

ds3231v2:setTime(s, m, h, dt, d, mn, y)   -- setTime(s,min,hour,weekday,day,month, year)
ds3231v2.setTime(0, 29, 15, 7, 27, 5, 17)