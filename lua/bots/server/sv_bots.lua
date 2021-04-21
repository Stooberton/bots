Bots.Defaults = {
    SetModel = "models/mossman.mdl",
    Pos = Vector(),
    Ang = Angle()
}

function CreateBot(Class, Data)
    local Ent = ents.Create(Class)

    if not IsValid(Ent) then return end

    Data = table.Merge(table.Copy(Bots.Defaults), Data or {})

    Ent:SetPos(Data.Pos)
    Ent:SetAngles(Data.Ang)
    Ent:Spawn()

    for K, V in pairs(Data) do
        if Ent[K] then -- Run metamethods
            Ent[K](Ent, V)
        elseif isfunction(V) then -- Run funcs
            V(Ent, K)
        else -- Apply values
            Ent[K] = V
        end
    end
end