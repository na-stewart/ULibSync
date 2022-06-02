<!--
*** Thanks for checking out this README Template. If you have a suggestion that would
*** make this better, please fork the repo and create a pull request or simply open
*** an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
***
***
***
*** To avoid retyping too much info. Do a search and replace for the following:
*** github_username, repo_name, twitter_handle, email
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <h3 align="center">ULibSync</h3>

  <p align="center">
    An easy, efficient, and effective Garry's Mod addon for syncing ULib data. 
    <br />
    <a href="https://github.com/sunset-developer/ulibsync/issues">Report Bug</a>
    ·
    <a href="https://github.com/sunset-developer/ulibsync/pulls">Request Feature</a>
  </p>
</p>


<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
  * [Initial Setup](#initial-setup)
  * [Commands](#commands)
* [Documentation](#documentation)
   * [Bans](#bans)
   * [Groups](#groups)
   * [Users](#users)
* [Contributing](#contributing)
* [License](#license)


<!-- ABOUT THE PROJECT -->
## About The Project

![alt text](https://github.com/sunset-developer/ulibsync/blob/main/images/ulibsync.png)

ULibSync is a Garry's Mod addon that automatically syncs bans, users, and groups.

Designed with simplicity in mind so you can focus on what matters most, providing the best experience for your community.

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

* First, make sure ULib and ULX are available on your server. ULX is standard when utilizing ULib on your gmod server.

https://ulyssesmod.net/downloads.php

* Setup a MySQL server that ULibSync can connect to.

https://www.mysql.com/

* MySQLOO is required for ULibSync to connect to your MySQL database.

https://github.com/FredyH/MySQLOO

### Installation

* Clone the repo.
```sh
https://github.com/sunset-developer/ulibsync
```
* Install addon from the steam workshop.

https://steamcommunity.com/sharedfiles/filedetails/?id=2511974758

## Usage

ULibSync was designed to be incredibly easy to configure and use. All changes made to ULib data are automatically synced. Data associated to a player, a ban for example, is automatically synced locally on join. You can simply configure and forget.

### Initial Setup

Once ULibSync has been added onto your Gmod server, you have to find the configuration file called sv_config.lua. Once found, you may configure ULibSync to your preferred preferences. Below is an example of it's contents:

```lua
-- Sync On Event Settings
ULibSync.syncPlayerBanDataOnJoin = true
ULibSync.syncUserOnJoin = true
ULibSync.syncGroupsOnInit = false

-- Logging Settings
ULibSync.logs = true
ULibSync.debug = false

-- MySQL Settings
ULibSync.ip = "example.com"
ULibSync.username = "example"
ULibSync.password = "password"
ULibSync.database = "exampledb"
ULibSync.port = 3306
```

### Commands

On setup, it is reccomended you execute the `!syncall` command in order to sync all local ULib data to your database. 

SINCE MYSQLOO USES HOOKS FOR SQL QUERY CALLBACKS, EXECUTING GET COMMANDS VIA SERVER TERMINAL WON'T WORK IF THE SERVER IS EMPTY.

`!syncbans`: Syncs bans to the database.

`!getbans`: Retreives ban data from the database.

`!syncusers`: Syncs users to the database.

`!getusers`: Retreives users from the database.

`!syncgroups`: Syncs groups to the database.

`!getgroups`: Retreives groups from the database.

`!syncall`: Syncs all ULib data to the database.

`!getall`: Retreives all ULib data from the database.


## Documentation

All ULibSync functions are kept in the table "ULibSync" to prevent conflicts.

Data that is classified as ULibSync data (ex: ULibSyncBanData) is contained on the database.

Data that is classified as ULib data (ex: ULibPlayerBan) is contained locally.


### Bans

If a player has been unbanned on server A, it will be synced when they connect to server B. However, it may be possible that this player will not be able to join until a map change or server restart.

```lua
initBanSync()
-- Initalizes ban syncing. This is currently called on a successful database connection.

syncULibBans()
-- Syncs all local ULib bans to the database.

syncULibPlayerBan(steamid, banData)
-- Syncs ULib ban to the database.

syncULibPlayerUnban(steamid)
-- Syncs unban to the database.

syncULibSyncBanData()
-- Syncs ULibSync ban data locally. This retreives all ban data on the database.

syncULibSyncPlayerBanData(steamID64)
-- Syncs ULibSync player ban data locally. This retreives ban data associated with a steamid from the database.
```

### Users

```lua
initUsersSync()
-- Initalizes user syncing. This is currently called on a successful database connection.

syncULibUsers()
-- Syncs all local ULib users to the database.

syncULibUser(steamid, group)
-- Syncs ULib user to the database. Group is the name of the group associated with a user, for example: admin or operator.

syncULibUserRemoved(steamid)
-- Syncs user removal to the database.

syncULibUsersGroupChanged(oldGroup, newGroup)
-- Syncs a group change on all users with the old group. For example, if superadmin is renamed to ultimateadmin, all users with the superadmin role will now have the ultimateadmin role.

syncULibSyncUsers()
-- Syncs ULibSync users locally. This retreives all users on the database.

syncULibSyncUser(ply)
-- Syncs ULibSync user locally. This retreives a user associated with a steamid from the database.
```

### Groups

When a group is renamed or deleted, all users with the renamed or deleted group will have their group automatcially updated. If one of your servers is behind on the group changes, a warning may appear that you are attempting to sync a user with a group that doesn't exist yet. Syncing groups locally on the server behind on changes may fix.

```lua
initGroupsSync()
-- Initalizes group syncing. This is currently called on a successful database connection.

syncULibGroups()
-- Syncs all local ULib groups to the database.

syncULibGroup(groupName, groupData)
-- Syncs ULib group to the database.

syncULibGroupRemoved(groupName)
-- Syncs group removal to the database.

syncULibGroupRenamed(oldName, newName)
-- Syncs group new name to the database. This will also change all user groups with the oldName to the newName.

syncULibGroupChanged(groupName, dataName, newData)
-- This method makes it easy to change a singular field in the ulib_groups table. Prevents repetitive code.

syncULibSyncGroups()
-- Syncs ULibSync groups locally.
```


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/sunset-developer/ulibsync.svg?style=flat-square
[contributors-url]: https://github.com/sunset-developer/ulibsync/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/sunset-developer/ulibsync.svg?style=flat-square
[forks-url]: https://github.com/sunset-developer/ulibsync/network/members
[stars-shield]: https://img.shields.io/github/stars/sunset-developer/ulibsync.svg?style=flat-square
[stars-url]: https://github.com/sunset-developer/ulibsync/stargazers
[issues-shield]: https://img.shields.io/github/issues/sunset-developer/ulibsync.svg?style=flat-square
[issues-url]: https://github.com/sunset-developer/ulibsync/issues
[license-shield]: https://img.shields.io/github/license/sunset-developer/ulibsync.svg?style=flat-square
[license-url]: https://github.com/sunset-developer/ulibsync/blob/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/github_username
[product-screenshot]: images/screenshot.png
