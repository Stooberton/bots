do -- Required boilerplate (thanks garry!)
    -- Why don't files just run this and fail silently by default?

    AddCSLuaFile("shared.lua")
    AddCSLuaFile("cl_init.lua")

    include("shared.lua")
end

do
    ENT.Animations = {
        Run = "RunALL",
        RunAndAim = "RunAIMALL1",
        Idle = "Idle1",
        CombatIdle = "CombatIdle1",
    }
end

do -- Actions
    local Behavior = {}

    ENT.Behavior = Behavior

    function Behavior.FindPlayer(Bot) print("Find")
        local Ply = player.GetAll()[1]

        if IsValid(Ply) then print("Found")
            Bot:SetTarget(Ply)
            Bot:SetAnim(Bot.Animations.RunAndAim)
            Bot:QueueMovement(Bot.Behavior.FollowTarget)

            return true
        end
    end

    function Behavior.FollowTarget(Bot) print("Follow")
        Bot:PlayAnim()

        Bot.loco:FaceTowards(Bot.Target:GetPos())

        local Displacement = ((Bot.Target:GetPos() - Bot:GetPos()) * Vector(1, 1, 0)):GetNormalized()
        Bot:SetPos(Bot:GetPos() + Displacement * 26 * Bot.CycleMul)
    end
end

function ENT:SetAnim(Anim)
    self.Cycle     = math.huge
    self.CycleAnim = Anim

    self:PlayAnim()
end

function ENT:PlayAnim()
    if CurTime() - self.Cycle > self:SequenceDuration() / self.CycleMul then
        self:SetSequence(self.CycleAnim)
        self:ResetSequenceInfo()
        self:SetCycle(0)

        self.Cycle = CurTime()
    end

    self:SetPlaybackRate(self.CycleMul)
end

function ENT:SetTarget(Ent)
    self.Target = Ent
end

function ENT:QueueMovement(Behavior)
    table.insert(self.MovementStack, Behavior)
end

function ENT:QueueInteraction(Behavior)
    table.insert(self.InteractionStack, Behavior)
end

do -- Spawn and remove
    function ENT:Initialize()
        Bots.Bots[self] = true

        self.MovementStack    = {}
        self.InteractionStack = {}
        self.CycleMul         = 1
        self.Speed            = 25

        self:Spawned()
    end

    function ENT:OnRemove()
        self:Removed()

        Bots.Bots[self] = nil

        if self:GetTeam() then
            self:GetTeam()[self] = nil
        end
    end
end

do -- Teams
    function ENT:SetTeam(TeamName)
        if TeamName then
            for _, V in pairs(Bots.Teams) do -- Remove the bot from all other teams
                if V[self] then
                    V[self] = nil
                end
            end

            if not Bots.Teams[TeamName] then -- Create the team TeamName if it doesn't exist
                Bots.Teams[TeamName] = {}
            end

        else -- Default behavior: Pick the least full team
            local Min = math.huge

            for K in pairs(Bots.Teams) do
                local Count = table.Count(V)

                if Count < Min then
                    TeamName = K
                    Min      = Count
                end
            end
        end

        Bots.Teams[TeamName][self] = true -- Add this bot to the team TeamName

        self.Team     = Bots.Teams[TeamName]
        self.TeamName = TeamName
    end

    function ENT:GetTeam()
        return self.Team
    end

    function ENT:GetTeamName()
        return self.TeamName
    end
end

do -- Thinking
    function ENT:RunBehaviour()
        while true do

            do -- Process interaction stack
                local Function = self.InteractionStack[1]

                if Function then -- If stack item
                    if Function(self) then -- Run item
                        table.remove(self.InteractionStack, 1) -- Remove from stack if return completed (true)
                    end
                else -- Idle!
                    --self:QueueInteraction(self.Behavior.SOMETHING)
                end
            end

            do -- Process movement stack
                local Function = self.MovementStack[1]

                if Function then -- If stack item
                    if Function(self) then -- Run item
                        table.remove(self.MovementStack, 1) -- Remove from stack if return completed (true)
                    end
                else -- Idle!
                    -- Figure out what to do
                    self:QueueMovement(self.Behavior.FindPlayer)
                end
            end

            coroutine.wait(0)
        end
    end
end

-- Idle:
    -- if in the open, seek cover (cover biased outward from objective, if at objective)
    -- peek around cover
    -- 
-- If fired upon:
    -- If caught in the open with no cover nearby, suppress the enemy while moving (inaccurate fire)
    -- If within range of cover, sprint to cover
        -- if low amount of cover, suppres/smoke and move to more cover