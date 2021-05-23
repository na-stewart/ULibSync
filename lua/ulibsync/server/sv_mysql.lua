require( 'mysqloo' )

local function initULibSync()
    ULibSync.initBanSync()
    ULibSync.initUserSync()
end

local function initMySQLOO()
    ULibSync.mysql = mysqloo.connect(ULibSync.ip, ULibSync.username, ULibSync.password, ULibSync.database, ULibSync.port)

    function ULibSync.mysql:onConnected() 
        initULibSync()
        ULibSync.log('Connection to database succeeded.', 20)
    end

    function ULibSync.mysql:onConnectionFailed( db, err )
        ULibSync.log('Connection to database failed.' , 50)
    end
    
    ULibSync.mysql:connect()
end

initMySQLOO()