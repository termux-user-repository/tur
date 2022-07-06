# Termux User Repository (TUR): 

Sounds like Archlinux User repository aka AUR ? TUR functioning mechanism is bit different. Instead of building packages in device that too in android is quite hectic work for user. 
So TUR saves resources and time since user could install pre-compiled package. 

## Subscribe TUR
Add TUR in Termux, simply with executing following command:

```
echo "deb https://tur.kcubeterm.com tur-packages tur" > $PREFIX/etc/apt/sources.list.d/tur.list
apt update
```
## Request:
*Request to all TUR users.*

Please don't Discuss/Open issues about any of TUR packages in Termux Offical forum. TUR packages are not Termux official packages so any discussion just waste time of Termux maintainters. Users are free to discuss/open isuess here. 

## Contribution: 

### Add new package. 
TUR uses same building scripts what Termux does.So all building mechanism is same.
* Clone this repository.
* Change directory and Execute `./setup-environment.sh` It will fetch Termux package building scripts. 
* Create build.sh file under **tur** directory (_not in packages_). 
Go through the official termux [wiki](https://github.com/termux/termux-packages/wiki). 


## TUR as a solution: 
TUR solves following issues of termux user: 

* Less popular packages could be added too.
* Many python/node/ruby packages needs compilation in device. TUR could make installation easy via distributing deb file.
* Instead of hosting own apt repository, One could add their package in TUR. 
* One place for all packages which could not be part of official termux repo for some reason.
* Old versions of packages availabe in TUR. 



## Suggestions:
Suggestions/ideas are always welcome.

Let's make TUR a single/trusted place for all unofficial debfile which supposed to be run in Termux. 
In order to achieve it we need your precious suggestions. Please let us know your suggestions through starting a discussion/issue.
