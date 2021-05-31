local function createULibSyncUsersTable()
    local q = ULibSync.mysql:query('CREATE TABLE IF NOT EXISTS `ulib_users` (' ..
    '`id` INT AUTO_INCREMENT PRIMARY KEY,' ..
    '`steamid` VARCHAR(18) UNIQUE NOT NULL,' ..
    '`removed` BOOLEAN NOT NULL DEFAULT FALSE,' ..
    '`group` VARCHAR(20),' ..
    '`date_created` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),' ..
    '`date_updated` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)' ..
    ');')
    function q:onError(err)
        ULibSync.log('Table creation failed.', 'users', 50, err)
    end
    q:start()
end

local function addULibSyncUsersHooks()
    hook.Add('ULibUserGroupChange', 'ULibSyncUserGroupChange', function (id, allows, denies, newGroup, oldGroup)
        ULibSync.syncULibUser(id, newGroup)
    end)
    hook.Add('ULibUserRemoved', 'ULibSyncUserRemoved', ULibSync.syncULibUserRemoved)
end

local function removeULibSyncUsersHooks()
    hook.Remove('ULibUserGroupChange', 'ULibSyncUserGroupChange')    
    hook.Remove('ULibUserRemoved', 'ULibSyncUserRemoved')
end

function ULibSync.initUserSync()
    createULibSyncUsersTable()
    addULibSyncUsersHooks()
end

function ULibSync.syncULibUsers()
    for steamid, userData in pairs(ULib.ucl.users) do
       ULibSync.syncULibUser(steamid, userData['group'])
    end
end

function ULibSync.syncULibUser(steamid, group)
    local q = ULibSync.mysql:prepare('REPLACE INTO ulib_users (`steamid`, `group`) VALUES (?, ?)')
    q:setString(1, steamid)
    q:setString(2, group)
    function q:onSuccess(data)
        ULibSync.log('User has been synced successfully.', steamid, 20)
    end
    function q:onError(err)
        ULibSync.log('User has not been synced.', steamid, 40, err)
    end
    q:start()
end

function ULibSync.syncULibUserRemoved(steamid)
    local q = ULibSync.mysql:prepare('UPDATE ulib_users SET removed = ? WHERE steamid = ?')
    q:setBoolean(1, true)
    q:setString(2, steamid)
    function q:onSuccess(data)
        ULibSync.log('User removal has been synced successfully.', steamid, 20)
    end
    function q:onError(err)
        ULibSync.log('User removal has not been synced.', steamid, 40, err)
    end
    q:start()
end

local function syncULibSyncUserLocally(steamid, uLibSyncUser)
    if uLibSyncUser['removed'] == 0 then
        if not ULib.ucl.users[steamid] or ULib.ucl.users[steamid].group != uLibSyncUser.group then
            ULib.ucl.addUser(steamid, nil, nil, uLibSyncUser.group, nil)
            ULibSync.log('User has been synced locally.', steamid, 20)       
        end
    else
        if ULib.ucl.users[steamid] then
            ULib.ucl.removeUser(steamid)
            ULibSync.log('User removal has been synced locally.', steamid, 20, err)       
        end
    end       
end

function ULibSync.syncULibSyncUsers()
    local q = ULibSync.mysql:prepare('SELECT `group`, removed, steamid FROM ulib_users')
    function q:onSuccess(data)   
        removeULibSyncUsersHooks()
        for index, uLibSyncUser in pairs(data) do
            syncULibSyncUserLocally(uLibSyncUser.steamid, uLibSyncUser)
        end
        addULibSyncUsersHooks()   
    end
    function q:onError(err)
        ULibSync.log('Local syncing failed.', 'users', 40, err)
    end
    q:start()
end

function ULibSync.syncULibSyncUser(steamID64)
    local steamid = util.SteamIDFrom64(steamID64)
    local q = ULibSync.mysql:prepare('SELECT `group`, removed FROM ulib_users WHERE steamid = ?')
    q:setString(1, steamid)
    function q:onSuccess(data)   
        local uLibSyncUser = data[1]
        if uLibSyncUser then
            removeULibSyncUsersHooks()
            syncULibSyncUserLocally(steamid, uLibSyncUser)
            addULibSyncUsersHooks()
        end
    end
    function q:onError(err)
        ULibSync.log('User has not been synced locally.', steamid, 40, err)
    end
     q:start()
end
if ULibSync.syncUsersOnJoin then hook.Add('CheckPassword', 'ULibSyncUserGroupChange', ULibSync.syncULibSyncUser) end
