ULibSync = ULibSync or {}

if SERVER then
    include('ulibsync/server/sv_logging.lua')
    include('ulibsync/server/sv_config.lua')
    include('ulibsync/server/sv_groups.lua')
    include('ulibsync/server/sv_bans.lua')
    include('ulibsync/server/sv_users.lua')
    include('ulibsync/server/sv_mysql.lua')
end
