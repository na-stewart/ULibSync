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
* [Documentation](#documentation)
   * [Commands](#commands)
   * [Bans](#bans)
   * [Groups](#groups)
   * [Users](#users)
* [Getting Started](#getting-started)
* [Contributing](#contributing)
* [License](#license)
* [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project

ULibSync is a Garry's Mod addon that effectively syncs bans, users, and groups.

ULibSync automatically handles local changes and syncs them with the database. 

Develop your community stress free and rest easy knowing that banned users stay banned.

Designed with simplicity in mind so you can focus on what matters most, providing the best experience for your community.

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

* First, make sure ULib and ULX are available on your server. ULX is standard when utilizing ULib on your gmod server.

https://ulyssesmod.net/downloads.php

* MySQLOO also is required.

https://github.com/FredyH/MySQLOO

### Installation

* Clone the repo nj88
```sh
https://github.com/sunset-developer/ulibsync
```
* Install addon from the steam workshop.

(Coming soon)

## Documentation

All ULibSync's functions are kept in the table "ULibSync" to prevent conflicts.

Remember to configure ULibSync in the `sv_config.lua` file.

### Commands

`!syncbans`: Syncs ULib bans to the ULibSync database.

`!syncbanslocal`: Syncs ULibSync ban data locally from the ULibSync database.

`!syncgroups`: Syncs ULib groups to the ULibSync database.

`!syncgroupslocal`: Syncs ULibSync groups locally from the ULibSync database. A map change may be required for ULX to reflect any changes.

`!syncusers`: Syncs ULib users to the ULibSync database.

`!syncuserslocal`: Syncs ULibSync users locally from the ULibSync database.

### Bans

```lua
initBanSync()
-- Initalizes ban syncing. This is currently called on a successful database connection.

syncULibPlayerBans()
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

### Groups

```lua
initBanSync()
-- Initalizes group syncing. This is currently called on a successful database connection.

syncULibGroups()
-- Syncs all local ULib groups to the database.

syncULibGroup(groupName, groupData)
-- Syncs ULib group to the database.

syncULibGroupRemoved(groupName)
-- Syncs group removal to the database.

syncULibGroupRenamed(oldName, newName)
-- Syncs group new name to the database.

syncULibGroupChanged(groupName, dataName, newData)
-- This method makes it easy to change a singular field in the ulib_groups table. Prevents repetitive code.

convertToULibGroup(uLibSyncGroup)
-- Retreives local ULib group from ULibSync group.

syncULibSyncGroups()
-- Syncs ULibSync groups locally.
```

### Users

```lua
initUserSync()
-- Initalizes user syncing. This is currently called on a successful database connection.

syncULibUsers()
-- Syncs all local ULib users to the database.

syncULibUser(steamid, group)
-- Syncs ULib user to the database. Group is the name of the group associated with a user, for example: admin or operator.

syncULibUserRemoved(steamid)
-- Syncs user removal to the database.

syncULibSyncUsers()
-- Syncs ULibSync users locally. This retreives all users on the database.

syncULibSyncUser(steamID64)
-- Syncs ULibSync user locally. This retreives a user associated with a steamid from the database.
```

### Misc

```lua
areTablesEqual(t1, t2, ignore_mt) 
-- Checks if two tables are equal. ignore_mt prevents from checking recursively.

log(msg, id, level, err)
-- Used to log ULibSync activities. err is optional and only used when the log level is an error.
-- 10: DEBUG | 20: INFO | 30: WARNING | 40: ERROR | 50: CRITICAL
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

<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

Be the first and submit a pull request!


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
