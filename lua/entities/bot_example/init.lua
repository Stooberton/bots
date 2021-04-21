do -- Required boilerplate (thanks garry!)
    -- Why don't files just run this and fail silently by default?

    AddCSLuaFile("shared.lua")
    AddCSLuaFile("cl_init.lua")

    include("shared.lua")
end

function ENT:Spawned()
    self:SetTeam(math.random(0, 1) == 1 and "Red" or "Blue")

    print("A bot was spawned and set to team " .. self:GetTeamName())
end

function ENT:Removed()
    print("Bot was removed!")
end