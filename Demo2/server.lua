-- Relay pin as output
gpio.mode(1, gpio.OUTPUT)
gpio.mode(2, gpio.OUTPUT)
-- Include url_parser module
local Parser = require "url_parser"

function http_ok(conn)
   conn:send('HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n '
   ..'OK')
end
   
function main_page(conn)
   conn:send('HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n' 
    ..'<head>' 
    ..'<meta name="viewport" content="width=device-width, initial-scale=1">'
    ..'<script src="https://code.jquery.com/jquery-2.1.3.min.js"></script>'
    ..'<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">'
    ..'</head>'
    
    ..'<div class="container">'
    .."<h1>Relay Control</h1>"
    ..'<div class="row">'
    ..'<h3>Relay 1</h3>'    
    ..'<div class="col-md-2"><input class="btn btn-block btn-lg btn-primary" type="button" value="On" onclick="on1()"></div>'
    ..'<div class="col-md-2"><input class="btn btn-block btn-lg btn-danger" type="button" value="Off" onclick="off1()"></div>'
    ..'</div>'
    
    ..'<div class="row">'
    ..'<h3>Relay 2</h3>'    
    ..'<div class="col-md-2"><input class="btn btn-block btn-lg btn-primary" type="button" value="On" onclick="on2()"></div>'
    ..'<div class="col-md-2"><input class="btn btn-block btn-lg btn-danger" type="button" value="Off" onclick="off2()"></div>'
    ..'</div>'

    ..'</div>'
    
    ..'<script>function on1() {$.get("/1/on");}</script>'
    ..'<script>function off1() {$.get("/1/off");}</script>'
    ..'<script>function on2() {$.get("/2/on");}</script>'
    ..'<script>function off2() {$.get("/2/off");}</script>')
end
-- Create server
srv=net.createServer(net.TCP) 
print("Server")

srv:listen(80,function(conn) 
  conn:on("receive",function(conn,payload) 
    id,parsed_request = Parser.parse(payload)
    if parsed_request == 'on' then gpio.write(id, gpio.LOW) end
    if parsed_request == 'off' then gpio.write(id, gpio.HIGH) end

    if id == nil then
        main_page(conn)
    else
        http_ok(conn)
    end
        
    -- Display main page
 
  end) 
  conn:on("sent",function(conn) conn:close() end)
end)
