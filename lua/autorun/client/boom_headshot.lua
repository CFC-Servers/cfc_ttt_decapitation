-- These can be accessed without pointing to the IMaterial by using ! before the material string.
function CreateSpriteMaterials()
    local params = {
        ["$translucent"] = "1",
        ["$vertexcolor"] = "1",
        ["$vertexalpha"] = "1"
    }

    for i = 1, 8 do
        params["$basetexture"] = "Decals/blood" .. i
        CreateMaterial( "sprite_bloodspray" .. i, "UnlitGeneric", params )
    end
end

hook.Add( "Initialize", "CreateBlood.TTT", function()
    CreateSpriteMaterials()
end )

local breakableBones = {
    [HITGROUP_HEAD] = "ValveBiped.Bip01_Head1",
    [HITGROUP_LEFTARM] = "ValveBiped.Bip01_L_Clavicle",
    [HITGROUP_RIGHTARM] = "ValveBiped.Bip01_R_Clavicle",
    [HITGROUP_LEFTLEG] = "ValveBiped.Bip01_L_Thigh",
    [HITGROUP_RIGHTLEG] = "ValveBiped.Bip01_R_Thigh",
}

local function getChildBone( ent, bone )
    local bonecount = ent:GetBoneCount()
    local childBoneTable = {}
    for k = 0, bonecount do
        if ent:GetBoneParent( k ) == bone then
            table.insert( childBoneTable, k )
        end
    end

    if #childBoneTable ~= 0 then
        return childBoneTable
    end

    return false
end

local function getChildBones( ent, bone )
    local bonecount = ent:GetBoneCount()
    if bonecount == 0 and bonecount < bone then return end

    local bones = {}
    local lastBones = {bone}
    local hasBones = true

    for _ = 0, 10 do
        if not hasBones then break end
        for _, v in ipairs( lastBones ) do
            local childBones = getChildBone( ent, v )
            if not childBones then
                break
            end

            lastBones = childBones
            for _, boneNum in ipairs( childBones ) do
                table.insert( bones, boneNum )
            end
        end
    end

    return bones
end

hook.Add( "CreateClientsideRagdoll", "FWKZT.Headshot.CreateCRagdolls", function( entity, ragdoll )
    if GAMEMODE_NAME ~= "sandbox" then return end

    local hitgroup = entity:GetDTInt( 31 )
    local boneName = breakableBones[hitgroup]
    if not boneName then return end

    local bone = ragdoll:LookupBone( boneName )
    if not bone then return end

    local childTable = getChildBones( entity, bone )

    ragdoll:ManipulateBoneScale( bone, Vector( 0, 0, 0 ) )
    for _, v in ipairs( childTable ) do
        ragdoll:ManipulateBoneScale( v, Vector( 0, 0, 0 ) )
    end

    local pos = ragdoll:GetBonePosition( bone )
    local eD = EffectData()
    eD:SetEntity( entity )
    eD:SetNormal( -entity:GetForward() )
    eD:SetScale( entity:EntIndex() )
    eD:SetOrigin( pos )
    util.Effect( "headshot", eD )
end )
