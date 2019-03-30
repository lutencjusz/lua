-- tmr.delay(10000000) opóźnienie 10 sek

rtcmem.write32(0, 2, 5, 7)

print(rtcmem.read32(0, 3))

require('sendmail')