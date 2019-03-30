eeprom={
        
        address = 0x50,                        -- A2, A1, A0 = 0
       id = 0, 

init = function (self, sda, scl)
               self.id = 0
              i2c.setup(self.id, sda, scl, i2c.SLOW)
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
   end
}