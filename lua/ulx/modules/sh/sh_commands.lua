function ulx.syncBans(calling_ply)
    ULibSync.syncULibBans()
    ulx.fancyLogAdmin(calling_ply, "#A synced bans.")
end
local syncBans = ulx.command("ULibSync", "ulx syncbans", ulx.syncBans, "!syncbans")
syncBans:defaultAccess(ULib.ACCESS_ADMIN)
syncBans:help("Syncs bans to the ULibSync database.")

function ulx.getBans(calling_ply)
    ULibSync.syncULibSyncBanData()
    ulx.fancyLogAdmin(calling_ply, "#A retreived ban data.")
end
local getBans = ulx.command("ULibSync", "ulx getbans", ulx.getBans, "!getbans")
getBans:defaultAccess(ULib.ACCESS_ADMIN)
getBans:help("Retreives ban data from the ULibSync database.")

function ulx.syncUsers(calling_ply)
    ULibSync.syncULibUsers()
    ulx.fancyLogAdmin(calling_ply, "#A synced users.")
end
local syncUsers = ulx.command("ULibSync", "ulx syncusers", ulx.syncUsers, "!syncusers")
syncUsers:defaultAccess(ULib.ACCESS_ADMIN)
syncUsers:help("Syncs users to the ULibSync database.")

function ulx.getUsers(calling_ply)
    ULibSync.syncULibSyncUsers()
    ulx.fancyLogAdmin(calling_ply, "#A retreived users.")
end
local getUsers = ulx.command("ULibSync", "ulx getusers", ulx.getUsers, "!getusers")
getUsers:defaultAccess(ULib.ACCESS_ADMIN)
getUsers:help("Retreives users from the ULibSync database.")

function ulx.syncGroups(calling_ply)
    ULibSync.syncULibGroups()
    ulx.fancyLogAdmin(calling_ply, "#A synced groups.")
end
local syncGroups = ulx.command("ULibSync", "ulx syncgroups", ulx.syncGroups, "!syncgroups")
syncGroups:defaultAccess(ULib.ACCESS_ADMIN)
syncGroups:help("Syncs groups to the ULibSync database.")

function ulx.getGroups(calling_ply)
    ULibSync.syncULibSyncGroups()
    ulx.fancyLogAdmin(calling_ply, "#A retreived groups.")
end
local getGroups = ulx.command("ULibSync", "ulx getgroups", ulx.getGroups, "!getgroups")
getGroups:defaultAccess(ULib.ACCESS_ADMIN)
getGroups:help("Retreives groups from the ULibSync database.")

function ulx.syncAll(calling_ply)
    ULibSync.syncULibBans()
    ULibSync.syncULibUsers()
    ULibSync.syncULibGroups()
    ulx.fancyLogAdmin(calling_ply, "#A synced ban data, users, and groups.")
end
local syncAll = ulx.command("ULibSync", "ulx syncall", ulx.syncAll, "!syncall")
syncAll:defaultAccess(ULib.ACCESS_ADMIN)
syncAll:help("Syncs all ULib data to the ULibSync database.")

function ulx.getAll(calling_ply)
    ULibSync.syncULibSyncBanData()
    ULibSync.syncULibSyncUsers()
    ULibSync.syncULibSyncGroups()
    ulx.fancyLogAdmin(calling_ply, "#A retreived ban data, users, and groups.")
end
local getAll = ulx.command("ULibSync", "ulx getall", ulx.getAll, "!getall")
getAll:defaultAccess(ULib.ACCESS_ADMIN)
getAll:help("Retreives all ULib data from the ULibSync database.")
