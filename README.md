#DOTlog_iOS
iOS App Component to the DOTlog Project for the Spring 2015 UAF Computer Science Senior Project group.
Takes log event entries from users and syncs them with the DOTlog server application.

[![License](https://img.shields.io/:License-MIT-blue.svg)](http://dotlog.mit-license.org)
[![Platform](https://img.shields.io/:Platform-iOS-lightgrey.svg)](https://github.com/williamshowalter/DOTlog_iOS)

#Documentation
Documentation of the project architecture can be found in the Documents folder.

[Project Architecture Documentation](Documentation/Project_Architecture_Documentation.md)

#Instructions:
This project includes submodules, so you should perform clones recursively.

`git clone --recursive https://github.com/williamshowalter/DOTlog_iOS.git`

or

`git clone --recursive git@github.com:williamshowalter/DOTlog_iOS.git`

If you clone without the recursive option, you will need to manually initialize the SwiftyJSON submodule:

`git submodule init SwiftyJSON`

`git submodule update`
