local ENTITY = FindMetaTable("Entity")

function ENTITY:NearEntity(entity, radius)
    for k, v in ipairs(ents.FindInSphere(self:GetPos(), radius or 96)) do
        if ( v:GetClass() == entity:GetClass() ) then
            return true
        end
    end
    return false
end

if ( CLIENT ) then
    net.Receive("ixEntityNameRequest", function(len)
        local name = net.ReadString()
        local ent  = net.ReadEntity()
        if not( IsValid(ent) ) then return end

        ent._name = name
    end)

    net.Receive("ixEntityIDRequest", function(len)
        local id = net.ReadString()
        local ent  = net.ReadEntity()
        if not( IsValid(ent) ) then return end

        ent._id = id
    end)

    function ENTITY:GetName()
        if not ( self._name ) then
            net.Start("ixEntityNameRequest")
                net.WriteEntity(self)
            net.SendToServer()
            return ""
        end

        return self._name
    end

    function ENTITY:MapCreationID()
        if not ( self._id ) then
            net.Start("ixEntityIDRequest")
                net.WriteEntity(self)
            net.SendToServer()
            return ""
        end

        return self._id
    end
else
    util.AddNetworkString("ixEntityNameRequest")
    net.Receive("ixEntityNameRequest", function(len, ply)
        local ent = net.ReadEntity()
        if not ( IsValid(ent) ) then return end
        local name = ent:GetName()

        net.Start("ixEntityNameRequest")
            net.WriteString(name)
            net.WriteEntity(ent)
        net.Send(ply)
    end)

    util.AddNetworkString("ixEntityIDRequest")
    net.Receive("ixEntityIDRequest", function(len, ply)
        local ent = net.ReadEntity()
        if not ( IsValid(ent) ) then return end
        local name = tostring(ent:MapCreationID())

        net.Start("ixEntityIDRequest")
            net.WriteString(name)
            net.WriteEntity(ent)
        net.Send(ply)
    end)
end