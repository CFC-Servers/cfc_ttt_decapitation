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

hook.Add( "CreateClientsideRagdoll", "FWKZT.Headshot.CreateCRagdolls", function( entity, ragdoll )
    if GAMEMODE_NAME ~= "sandbox" then return end

    if entity.WasHeadshotDeath and entity:WasHeadshotDeath() then
        local head = ragdoll:LookupBone( "valvebiped.bip01_head1" )
        if not head then return end

        local pos = ragdoll:GetBonePosition( head )
        local ragHead = ragdoll:LookupBone( "valvebiped.bip01_head1" )
        if not ragHead then return end

        ragdoll:ManipulateBoneScale( ragHead, Vector( 0, 0, 0 ) )

        local eD = EffectData()
        eD:SetEntity( entity )
        eD:SetNormal( -entity:GetForward() )
        eD:SetScale( entity:EntIndex() )
        eD:SetOrigin( pos )
        util.Effect( "headshot", eD )
    end
end )
