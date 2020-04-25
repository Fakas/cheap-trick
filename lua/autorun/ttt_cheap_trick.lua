-- Set up Cheap Trick object
CHEAP_TRICK = {}
CHEAP_TRICK.__index = CHEAP_TRICK
CHEAP_TRICK.hosts = {}

-- Set up ConVars
-- TODO: ConVars
CreateConVar("ttt_ct_debug", "0", FCVAR_NONE, "Enable Cheap Trick debug messages", 0, 1)


-- Set up commands
-- TODO: Commands


-- Cheap Trick functions
function CHEAP_TRICK:is_behind(host, target)
    local angle = host:GetAngles().y - target:GetAngles().y

    if angle < -180 then
        angle = 360 + angle
    end

    if angle <= 90 and angle >= -90 and host:IsLineOfSightClear(target) then
        CHEAP_TRICK:log(target:GetName().." is behind "..host:GetName().."!")
        return true
    else
        return false
    end
end

function CHEAP_TRICK:find_victim(user)
    local host = CHEAP_TRICK.hosts[user:UserID()]
    local plys = player.GetAll()
    local behind = {}
    -- Get all players behind the host
    for _, ply in pairs(plys) do
        if host ~= ply and user ~= ply and CHEAP_TRICK:is_behind(host, ply) then
            table.insert(behind, ply)
        end
    end
    if #behind == 0 then
        CHEAP_TRICK:log("No potential victims for "..host:GetName().."!")
        return nil
    end
    -- Get the closest player
    local closest  -- Closest player
    local shortest  -- Shortest distance
    local distance  -- Iter distance
    for _, ply in pairs(behind) do
        distance = host:GetPos():DistToSqr(ply:GetPos())
        if shortest == nil or shortest > distance then
            shortest = distance
            closest = ply
        end
    end
    CHEAP_TRICK:log(closest:GetName().." is the closest victim for "..host:GetName().."!")
    return closest
end

function CHEAP_TRICK:possess_victim(user, victim)
    user:StripAmmo()
    user:StripWeapons()
    user:Spectate(OBS_MODE_CHASE)
    user:SpectateEntity(victim)
    user:CrosshairDisable()
    CHEAP_TRICK.hosts[user:UserID()] = victim
end

function CHEAP_TRICK:jump(user)
    local host = CHEAP_TRICK.hosts[user:UserID()]
    local victim = CHEAP_TRICK:find_victim(user)
    if victim then
        CHEAP_TRICK:log(user:GetName().." will kill "..host:GetName().." and jump to "..victim:GetName().."!")
        CHEAP_TRICK:possess_victim(user, victim)
        host:Kill()
    end
end

function CHEAP_TRICK:log(message)
    if GetConVar("ttt_ct_debug"):GetBool() then
        PrintMessage(3, message)
    end
end
