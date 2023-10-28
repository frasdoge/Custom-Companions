CcDummyUuids = {
    ["aa772968-b5e0-4441-8d86-2d0506b4aab5"] = true,
    ["81c48711-d7cc-4a3d-9e49-665eb915c15c"] = true,
    ["6bff5419-5a9e-4839-acd4-cac4f6e41bd7"] = true,
    ["e2badbf0-159a-4ef5-9e73-7bbeb3d1015a"] = true,
}

PersistentVars = {
    PlayerPodsUsed = {
        ["S_TUT_PlayerPod_001_91b65f9b-8f2c-404c-95e4-d7eed9f2b767"] = false,
        ["S_TUT_PlayerPod_002_4a9d344d-8bfa-4bea-a8dd-cc54327b0cfb"] = false,
        ["S_TUT_PlayerPod_003_e2df8852-6539-403c-9eef-f169d129307e"] = false,
        ["S_TUT_PlayerPod_004_9cc50df2-46eb-4a32-90c3-9363c85cdd5d"] = false,
    }
}

function MakePlayer(uuid, host, avatar)
    for k,v in pairs(CcDummyUuids) do -- if it's a CC dummy exit
        if uuid == k then
            return
        end
    end

    Osi.TeleportTo(host, uuid)
    Osi.AttachToPartyGroup(host, uuid)

    Osi.DB_GLO_Playable(uuid)
    Osi.DB_Players(uuid)
    Osi.DB_PartyMembers(uuid)
    Osi.DB_PartOfTheTeam(uuid)
    Osi.DB_CanBeResurrected(uuid)
    Osi.MakePlayer(uuid, host, 1)
    Osi.RegisterAsCompanion(uuid, host)
    Osi.SetFaction(uuid, "Hero_Player1_6545a015-1b3d-66a4-6a0e-6ec62065cdb7")
    
    if avatar then
        Osi.DB_Avatars(uuid)
        Osi.DB_AvatarHasFaction(uuid, "Hero_Player1_6545a015-1b3d-66a4-6a0e-6ec62065cdb7")
    end

    Osi.DB_HasIllithidTag(uuid)
    Osi.DB_TadpolePowers_UnlockedByDefault(uuid)
end

Ext.Osiris.RegisterListener("CharacterCreationFinished", 0, "after", function ()
    local host = Osi.GetHostCharacter()
    local players = Ext.Entity.GetAllEntitiesWithComponent("Player")

    for i,player in ipairs(players) do
        local uuid = player.Uuid.EntityUuid
        MakePlayer(uuid, host, false)
    end
end)

Ext.Osiris.RegisterListener("UseStarted", 2, "after", function (character, item)
    local pods = PersistentVars['PlayerPodsUsed']
    for pod,used in pairs(pods) do
        if item == pod and not used and #Osi.DB_Players:Get(nil) < Osi.GetMaxPartySize() then
            -- can't set used because it's taken by value
            pods[pod] = true
            Osi.StartCharacterCreation()
        end
    end
end)
