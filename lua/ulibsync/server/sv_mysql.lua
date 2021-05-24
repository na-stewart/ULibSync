require( 'mysqloo' )

local function initULibSync()
    ULibSync.initBanSync()
    ULibSync.initUserSync()
    ULibSync.initGroupsSync()
end

local function initMySQLOO()
    ULibSync.mysql = mysqloo.connect(ULibSync.ip, ULibSync.username, ULibSync.password, ULibSync.database, ULibSync.port)

    function ULibSync.mysql:onConnected() 
        initULibSync()
        ULibSync.log('Connection to database succeeded.', ULibSync.ip, 20)
    end

    function ULibSync.mysql:onConnectionFailed(err)
        ULibSync.log('Connection to database failed.', ULibSync.ip, 50, err)
    end
    
    ULibSync.mysql:connect()
end

initMySQLOO()