# Termux User Repository (TUR): 

Sounds like Archlinux User repository aka AUR ? TUR functioning mechanism is bit different. Instead of building packages in device that too in android is quite hectic work for user. 
So TUR saves resources and time since user could install pre-compiled package. 

## Add TUR in Termux: 
**Soon** 

Let's submit pull request first to add packages.

## Contribution: 

### Add new package. 
Since TUR is fork of termux-packages. So all building mechanism is same. In order to add a package. Create build.sh file under **tur** directory(_not in packages_). 
Go through the official termux [wiki](https://github.com/termux/termux-packages/wiki). 


## TUR as a solution: 
TUR solves following issues of termux user: 

* Less popular packages could be added too.
* Many python/node/ruby packages needs compilation in device. TUR could make installation easy via distributing deb file.
* Instead of hosting own apt repository, One could add their package in TUR. 
* One place for all packages which could not be part of official termux repo for some reason. 



## Suggestions:
Suggestions/ideas are always welcome.

Let's make TUR a single/trusted place for all unofficial debfile which supposed to be run in Termux. 
In order to achieve it we need your precious suggestions. Please let us know your suggestions through starting a discussion/issue.
