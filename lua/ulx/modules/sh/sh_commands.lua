function ulx.syncBans(calling_ply)
    ULibSync.syncULibPlayerBanData()
    PrintMessage(3, "Local ban data is now being synced.")
end
local syncBans = ulx.command("ULibSync", "ulx syncbans", ulx.syncBans, "!syncbans")
syncBans:defaultAccess(ULib.ACCESS_ADMIN)
syncBans:help("Syncs all local ban data to the ULibSync database.")


function ulx.syncUsers(calling_ply)
    ULibSync.syncULibUsers()
    PrintMessage(3, "Local users are now being synced.")
end
local syncBans = ulx.command("ULibSync", "ulx syncusers", ulx.syncUsers, "!syncusers")
syncBans:defaultAccess(ULib.ACCESS_ADMIN)
syncBans:help("Syncs all local users to the ULibSync database.")


function ulx.syncGroups(calling_ply)
    ULibSync.syncULibGroups()
    PrintMessage(HUD_PRINTTALK, "Local groups are now being synced.")
end
local syncBans = ulx.command("ULibSync", "ulx syncgroups", ulx.syncGroups, "!syncgroups")
syncBans:defaultAccess(ULib.ACCESS_ADMIN)
syncBans:help("Syncs all local groups to the ULibSync database.")



