local function potwierdzHTML(code, type)      
    return "HTTP/1.1 " .. code .. "\r\nConnection: close\r\nServer: nunu-Luaweb\r\nContent-Type: " .. 
    type .. "\r\n\r\n";   
end

srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on('receive', function (sck, payload)
        print(payload)           
        sck:send(potwierdzHTML("200 OK","text/html"))
        if string.find(payload,"action=")~= nil then
            param={string.find(payload,"action=")}
            value=string.sub(payload,param[2]+1,param[2]+1)
            print("Value: ", value)
            if value=="1"  then
                print(value)
                pinValue=gpio.HIGH
            end
            if value=="0" then 
                print(value)
                pinValue=gpio.LOW
            end
            gpio.write(outpin,pinValue)
         end
         print(payload) 
         local status = gpio.read(outpin)
         if (status == 0) then
             status = 'enabled'
         else
             status = 'disabled'
         end
         print('Led status: '..status)
         sck:send('HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n'..
            '<!DOCTYPE html>'..
            '<html><head><title>ESP8266 Test App</title></head><body>'..
            '<h2>Hello from ESP!</h2>'..
            '<p>LED status: '..'<br/>'..
            '<a href="?action=1">enable</a> | <a href="?action=0">disable</a></p>'..
            '</body></html>')          
end)       
    conn:on("sent",function(sck) sck:close() end)
end)

