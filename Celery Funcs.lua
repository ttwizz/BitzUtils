assert(rnet, "Celery not Injected/env not created.");

local runService = game:GetService("RunService");
local signal     = loadstring(game:HttpGet("https://raw.githubusercontent.com/NougatBitz/BitzUtils/main/Signal.lua"))();

local send_raw = function(raw_data) 
    local raw_data = (type(raw_data) == "string" and rnet.tobytes(send_raw)) or (raw_data);
    
    rnet.send(raw_data);
end

local blockedPackets = {};
local toggle_sid = function(sid) 
    local sidS = (typeof(sid) == "table" and sid) or ({sid})
    for index, sid in pairs(sidS) do 
        blockedPackets[sid] = not (blockedPackets[sid])
    end
end

local capture = signal.new() do 
    task.spawn(function()
        while true do task.wait()
            local currentPacket = rnet.nextPacket();
    
            if not (blockedPackets[currentPacket.sid]) then
                capture:Fire(currentPacket);
            end
        end
    end)
end

getgenv().send_raw = send_raw
getgenv().toggle_sid = toggle_sid
getgenv().capture = capture
