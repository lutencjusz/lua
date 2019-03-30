-- Module declaration
local Parser = {}

function Parser.parse(request)
     --print(request)
     -- Find start
     local e = string.find(request, "/")
     if e == nil then return nil,nil end
     local request_handle = string.sub(request, e + 1)
     --print(request_handle)
     -- Cut end
     e = string.find(request_handle, "HTTP")
     if e == nil then return nil,nil end
     request_handle = string.sub(request_handle, 0, (e-2))
     --print(request_handle)    
     e = string.find(request_handle,"/")
     if e == nil then return nil,nil end
     local id = string.sub(request_handle,0,e-1)
     local action =    string.sub(request_handle,e+1)
     --print(id)
     --print(action)
     return id,action

end

return Parser
