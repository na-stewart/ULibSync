-- coming soon.

local synced = false

local function createULibSyncGroupsTable()
    local q = ULibSync.mysql:query('CREATE TABLE IF NOT EXISTS `ulib_groups` (' ..
    '`id` INT AUTO_INCREMENT PRIMARY KEY,' ..
    '`name` VARCHAR(255) UNIQUE NOT NULL,' ..
    '`inherit_from` VARCHAR(255),' ..
    '`allow` TEXT,' ..
    '`removed` BOOLEAN NOT NULL DEFAULT FALSE,' ..
    '`can_target` VARCHAR(255),' ..
    '`date_created` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),' ..
    '`date_updated` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)' ..
    ');')
    function q:onError(err)
        ULibSync.log('Table creation failed.', 'groups', 50, err)
    end
    q:start()
end

local function addULibSyncGroupsHooks()
    hook.Add('ULibGroupAccessChanged', 'ULibSyncGroupAccessChanged', function (groupName, access, revoke) 
        ULibSync.syncULibGroupChanged(groupName, 'allow', ULib.makeKeyValues(ULib.ucl.groups[groupName].allow))
    end)
    hook.Add('ULibGroupRenamed', 'ULibSyncGroupRenamed', function (groupName, oldName, newName) 
        ULibSync.syncULibGroupChanged(oldName, 'name', newName)
    end)
    hook.Add('ULibGroupInheritanceChanged', 'ULibSyncGroupInheritanceChanged', function (groupName, newInherit, oldInherit) 
        ULibSync.syncULibGroupChanged(groupName, 'inherited_from', newInherit)
    end)
    hook.Add('ULibGroupCanTargetChanged', 'ULibSyncGroupCanTargetChanged', function (groupName, newTarget, oldTarget) 
        ULibSync.syncULibGroupChanged(groupName, 'can_target', newTarget)
    end)
    hook.Add('ULibGroupRemoved', 'ULibSyncGroupRemoved', function (groupName, newTarget, oldTarget)
        ULibSync.syncULibGroupRemoved(groupName)
    end)
    hook.Add('ULibGroupCreated', 'ULibSyncGroupCreated', ULibSync.syncULibGroup)
end

local function removeULibSyncGroupsHooks()
    hook.Remove('ULibGroupAccessChanged', 'ULibSyncGroupAccessChanged')    
    hook.Remove('ULibGroupRenamed', 'ULibSyncGroupRenamed')  
    hook.Remove('ULibGroupInheritanceChanged', 'ULibSyncGroupInheritanceChanged')    
    hook.Remove('ULibGroupCanTargetChanged', 'ULibSyncGroupCanTargetChanged')  
    hook.Remove('ULibGroupRemoved', 'ULibSyncGroupRemoved')    
    hook.Remove('ULibGroupCreated', 'ULibSyncGroupCreated')  
end

function ULibSync.initGroupsSync()
    createULibSyncGroupsTable()
    addULibSyncGroupsHooks()
    ULibSync.syncULibSyncGroups()
end


function ULibSync.syncULibGroups()
    for groupName, groupData in pairs(ULib.ucl.groups) do
        ULibSync.syncULibGroup(groupName, groupData)
    end
end

function ULibSync.syncULibSyncGroups()
    local q = ULibSync.mysql:prepare('SELECT name, inherit_from, allow, removed, can_target FROM ulib_groups')
    function q:onSuccess(data)   
        removeULibSyncGroupsHooks()
        for index, uLibSyncGroupData in data do
            local allow = ULib.parseKeyValues(data.allow)
            if uLibSyncGroupData.removed == 1 then
                if ULib.ucl.groups[uLibSyncGroupData.name] then
                    ULib.ucl.removeGroup(uLibSyncGroupData.name)
                end
            else
                if not ULib.ucl.groups[uLibSyncGroupData.name]
                    ULib.ucl.addGroup(data.name, data['inherit_from'], allow)
                    ULib.ucl.setGroupCanTarget(data.name, data['can_target'])
                end
            end
        end
        addULibSyncGroupsHooks()
    end
    function q:onError(err)
        ULibSync.log('Groups have not been synced locally.', steamid, 20, err)
    end
    q:start()
end

function ULibSync.syncULibGroupChanged(groupName, dataName, newData)
    --Documentation for this is mandatory.
    local q = ULibSync.mysql:prepare(string.format('UPDATE ulib_groups SET %s = ? WHERE name = ?', dataName))
    if newData then q:setString(1, newData) end
    q:setString(2, groupName)
    function q:onSuccess(data)
        ULibSync.log(string.format('Group %s has been synced successfully.', dataName), groupName, 20)
    end
    function q:onError(err)
        ULibSync.log('Group %s has not been synced.', groupName, 40, err)
    end
    q:start()
end

function ULibSync.syncULibGroupRemoved(groupName)
    local q = ULibSync.mysql:prepare('UPDATE ulib_groups SET removed = ? WHERE name = ?')
    q:setBoolean(1, true)
    q:setString(2, groupName)
    function q:onSuccess(data)
        ULibSync.log('Group removal has been synced successfully.', groupName, 20)
    end
    function q:onError(err)
        ULibSync.log('Group removal has not been synced.', groupName, 40, err)
    end
    q:start()
end

function ULibSync.syncULibGroup(groupName, groupData)
    local q = ULibSync.mysql:prepare('REPLACE INTO ulib_groups (`name`, `allow`, `inherit_from`) VALUES (?, ?, ?)')
    q:setString(1, groupName)
    if groupData.allow then q:setString(2, ULib.makeKeyValues(groupData.allow)) end
    if groupData['inherit_from'] then q:setString(3, groupData['inherit_from']) end
    function q:onSuccess(data)
        ULibSync.log('Group has been synced successfully', groupName, 20)
    end
    function q:onError(err)
        ULibSync.log('Group has not been synced.', groupName, 40, err)
    end
    q:start()
end