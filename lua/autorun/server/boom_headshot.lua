if SERVER then
    AddCSLuaFile( "effects/headshot.lua" )
    AddCSLuaFile( "effects/bloodstream.lua" )
    AddCSLuaFile( "autorun/client/boom_headshot.lua" )
    resource.AddFile( "materials/fwkzt/sprite_bloodspray1.vmt" )
    resource.AddFile( "materials/fwkzt/sprite_bloodspray2.vmt" )
    resource.AddFile( "materials/fwkzt/sprite_bloodspray3.vmt" )
    resource.AddFile( "materials/fwkzt/sprite_bloodspray4.vmt" )
    resource.AddFile( "materials/fwkzt/sprite_bloodspray5.vmt" )
    resource.AddFile( "materials/fwkzt/sprite_bloodspray6.vmt" )
    resource.AddFile( "materials/fwkzt/sprite_bloodspray7.vmt" )
    resource.AddFile( "materials/fwkzt/sprite_bloodspray8.vmt" )
end

local function gibPlayerHead( Ply, Normal )
    local Head = Ply:LookupBone( "valvebiped.bip01_head1" )
    if not Head then return end
    local Pos = Ply:GetBonePosition( Head )
    local RagHead = Ply.server_ragdoll:LookupBone( "valvebiped.bip01_head1" )
    if not RagHead then return end
    Ply.server_ragdoll:ManipulateBoneScale( RagHead, Vector( 0, 0, 0 ) )
    local ED = EffectData()
    ED:SetEntity( Ply )
    ED:SetNormal( Normal )
    ED:SetScale( Ply.server_ragdoll:EntIndex() )
    ED:SetOrigin( Pos )
    util.Effect( "headshot", ED )
end

-- Player Headshots
local function PlayerDeath( Ply, _, Attacker )
    if GAMEMODE_NAME ~= "terrortown" then return end
    if not IsValid( Ply.server_ragdoll ) then return end
    if not Ply.was_headshot then return end
    if not IsValid( Attacker ) or not Attacker:IsPlayer() then return end
    if not IsValid( Attacker:GetActiveWeapon() ) then return end
    if Ply.IsGhost and Ply:IsGhost() then return end

    if Ply.OwnedBlackMarketItems and Ply.OwnedBlackMarketItems[CAT_EQUIPMENT] == "fiber_helmet" then
        return
    end

    local Normal = Attacker:GetForward()
    gibPlayerHead( Ply, Normal )
end

hook.Add( "PlayerDeath", "HeadshotDecap.PlayerDeath", PlayerDeath )

--hook.Add( "InitPostEntity", "FWKZT.SandboxHeadshot.InitPostEntity", function() -- GAMEMODE_NAME is only available later so we have to wait.
    if GAMEMODE_NAME ~= "sandbox" then return end

    hook.Add( "DoPlayerDeath", "FWKZT.SandboxHeadshot.DoPlayerDeath", function( ply )
        ply:SetDTInt( 31, ply:LastHitGroup() )
    end )

    hook.Add( "ScaleNPCDamage", "FWKZT.SandboxHeadshot.ScaleNPCDamage", function( npc, hitgroup )
        npc.LastHitGroup = hitgroup
        npc:SetDTInt( 31, hitgroup )
    end )

    hook.Add( "OnNPCKilled", "FWKZT.SandboxHeadshot.OnNPCKilled", function( npc )
        npc:SetDTInt( 31, npc.LastHitGroup )
    end )
--end)
