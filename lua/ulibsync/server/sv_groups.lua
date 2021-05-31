local function createULibSyncGroupsTable()
    local q = ULibSync.mysql:query('CREATE TABLE IF NOT EXISTS `ulib_groups` (' ..
    '`id` INT AUTO_INCREMENT PRIMARY KEY,' ..
    '`name` VARCHAR(20) UNIQUE NOT NULL,' ..
    '`old_name` VARCHAR(20),' ..
    '`inherit_from` VARCHAR(20),' ..
    '`allow` TEXT,' ..
    '`removed` BOOLEAN NOT NULL DEFAULT FALSE,' ..
    '`can_target` VARCHAR(22),' ..
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
    hook.Add('ULibGroupInheritanceChanged', 'ULibSyncGroupInheritanceChanged', function (groupName, newInherit, oldInherit) 
        ULibSync.syncULibGroupChanged(groupName, 'inherit_from', newInherit)
    end)
    hook.Add('ULibGroupCanTargetChanged', 'ULibSyncGroupCanTargetChanged', function (groupName, newTarget, oldTarget) 
        ULibSync.syncULibGroupChanged(groupName, 'can_target', newTarget)
    end)
    hook.Add('ULibGroupRemoved', 'ULibSyncGroupRemoved', ULibSync.syncULibGroupRemoved)
    hook.Add('ULibGroupCreated', 'ULibSyncGroupCreated', ULibSync.syncULibGroup)
    hook.Add('ULibGroupRenamed', 'ULibSyncGroupRenamed', ULibSync.syncULibGroupRenamed)
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
    if ULibSync.syncGroupsOnInit then ULibSync.syncULibSyncGroups() end
end

function ULibSync.syncULibGroups()
    for groupName, groupData in pairs(ULib.ucl.groups) do
        ULibSync.syncULibGroup(groupName, groupData)
    end
end

function ULibSync.syncULibGroup(groupName, groupData)
    local q = ULibSync.mysql:prepare('REPLACE INTO ulib_groups (`name`, `allow`, `inherit_from`, `can_target`) VALUES (?, ?, ?, ?)')
    q:setString(1, groupName)
    if groupData.allow then q:setString(2, ULib.makeKeyValues(groupData.allow)) end
    if groupData['inherit_from'] then q:setString(3, groupData['inherit_from']) end
    if groupData['can_target'] then q:setString(4, groupData['can_target']) end
    function q:onSuccess(data)
        ULibSync.log('Group has been synced successfully', groupName, 20)
    end
    function q:onError(err)
        ULibSync.log('Group has not been synced.', groupName, 40, err)
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

function ULibSync.syncULibGroupRenamed(oldName, newName)
    local q = ULibSync.mysql:prepare('UPDATE ulib_groups SET old_name = ?, name = ? WHERE name = ?')
    q:setString(1, oldName)
    q:setString(2, newName)
    q:setString(3, oldName)
    function q:onSuccess(data)
        ULibSync.log('Group rename has been synced successfully.', newName, 20)
    end
    function q:onError(err)
        ULibSync.log('Group rename has not been synced.', newName, 40, err)
    end
    q:start()
end

function ULibSync.syncULibGroupChanged(groupName, dataName, newData)
    local q = ULibSync.mysql:prepare(string.format('UPDATE ulib_groups SET %s = ? WHERE name = ?', dataName))
    if newData then q:setString(1, newData) end
    q:setString(2, groupName)
    function q:onSuccess(data)
        ULibSync.log(string.format('Group %s has been synced successfully.', dataName), groupName, 20)
    end
    function q:onError(err)
        ULibSync.log('Group has not been synced.', groupName, 40, err)
    end
    q:start()
end

local function syncULibSyncGroupChangesLocally(uLibGroupName, uLibGroupData, uLibSyncGroupAllow, uLibSyncGroupData)
    local addedGroupPermissions = ULibSync.checkTableForChangedValues(uLibSyncGroupAllow, uLibGroupData.allow)
    local removedGroupPermissions = ULibSync.checkTableForChangedValues(uLibGroupData.allow, uLibSyncGroupAllow)
    if uLibGroupData['inherit_from'] != uLibSyncGroupData['inherit_from'] then
        ULib.ucl.setGroupInheritance(uLibGroupName, uLibSyncGroupData['inherit_from'])
        ULibSync.log(string.format('Group inherit_from %s has been synced locally.', uLibSyncGroupData['inherit_from']), uLibSyncGroupData.name, 20)     
    end
    if uLibGroupData['can_target'] != uLibSyncGroupData['can_target'] then
        ULib.ucl.setGroupCanTarget(uLibGroupName, uLibSyncGroupData['can_target'])
        ULibSync.log('Group can_target has been synced locally.', uLibSyncGroupData.name, 20)     
    end
    if next(addedGroupPermissions) or next(removedGroupPermissions)then
        ULib.ucl.groupAllow(uLibGroupName, addedGroupPermissions, true)
        ULib.ucl.groupAllow(uLibGroupName, removedGroupPermissions, false)
        ULibSync.log('Group allow has been synced locally.', uLibSyncGroupData.name, 20)
    end
    if uLibGroupName != uLibSyncGroupData.name then
        ULib.ucl.renameGroup(uLibGroupName, uLibSyncGroupData.name)
        ULibSync.log('Group rename has been synced locally.', uLibSyncGroupData.name, 20)    
    end
end

function ULibSync.convertToULibGroup(uLibSyncGroup)
    local name = uLibSyncGroup['old_name']
    if not ULib.ucl.groups[name] then
        name = uLibSyncGroup.name
    end
    return name, ULib.ucl.groups[name]
end

local function syncULibSyncGroupLocally(uLibSyncGroupData)
    local uLibGroupName, uLibGroupData = ULibSync.convertToULibGroup(uLibSyncGroupData)
    if uLibSyncGroupData.removed == 1 then
        if uLibGroupData then
            ULib.ucl.removeGroup(uLibGroupName)
            ULibSync.log('Group removal has been synced locally.', uLibGroupName, 20)       
        end
    else
        local uLibSyncGroupAllow = ULib.parseKeyValues(uLibSyncGroupData.allow)
        if not uLibGroupData then
            ULib.ucl.addGroup(uLibSyncGroupData.name, uLibSyncGroupAllow, uLibSyncGroupData['inherit_from'])
            ULib.ucl.setGroupCanTarget(uLibGroupName, uLibSyncGroupData['can_target'])
            ULibSync.log('Group has been synced locally.', uLibSyncGroupData.name, 20)     
        else 
           syncULibSyncGroupChangesLocally(uLibGroupName, uLibGroupData, uLibSyncGroupAllow, uLibSyncGroupData)
        end
    end
end

function ULibSync.syncULibSyncGroups()
    local q = ULibSync.mysql:prepare('SELECT name, old_name, inherit_from, allow, removed, can_target, removed FROM ulib_groups')
    function q:onSuccess(data)
        removeULibSyncGroupsHooks()
        for index, uLibSyncGroupData in pairs(data) do
            syncULibSyncGroupLocally(uLibSyncGroupData)
        end
        addULibSyncGroupsHooks()
    end
    function q:onError(err)
        ULibSync.log('Local syncing failed.', 'groups', 40, err)
    end
     q:start()
end
