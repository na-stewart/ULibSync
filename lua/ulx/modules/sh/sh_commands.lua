function ulx.syncBans(calling_ply)
    ULibSync.syncULibPlayerBanData()
    ulx.fancyLogAdmin(calling_ply, "#A synced ULib ban data.")
end
local syncBans = ulx.command("ULibSync", "ulx syncbans", ulx.syncBans, "!syncbans")
syncBans:defaultAccess(ULib.ACCESS_ADMIN)
syncBans:help("Syncs ULib ban data to the ULibSync database.")

function ulx.syncUsers(calling_ply)
    ULibSync.syncULibUsers()
    ulx.fancyLogAdmin(calling_ply, "#A synced ULib users.")
end
local syncUsers = ulx.command("ULibSync", "ulx syncusers", ulx.syncUsers, "!syncusers")
syncUsers:defaultAccess(ULib.ACCESS_ADMIN)
syncUsers:help("Syncs ULib users to the ULibSync database.")

function ulx.syncGroups(calling_ply)
    ULibSync.syncULibGroups()
    ulx.fancyLogAdmin(calling_ply, "#A synced ULib groups.")
end
local syncGroups = ulx.command("ULibSync", "ulx syncgroups", ulx.syncGroups, "!syncgroups")
syncGroups:defaultAccess(ULib.ACCESS_ADMIN)
syncGroups:help("Syncs ULib groups to the ULibSync database.")

function ulx.syncGroupsLocal(calling_ply)
    ULibSync.syncULibSyncGroups()
    ulx.fancyLogAdmin(calling_ply, "#A synced ULibSync groups locally.")
end
local syncGroupsLocal = ulx.command("ULibSync", "ulx syncgroupslocal", ulx.syncGroupsLocal, "!syncgroupslocal")
syncGroupsLocal:defaultAccess(ULib.ACCESS_ADMIN)
syncGroupsLocal:help("Syncs ULibSync groups locally from the ULibSync database. A map change may be required for ULX to reflect any changes.")

