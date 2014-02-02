#PPTopSlideMenu

PPTopSLideMenu is a sliding menu that appears from the top. The original code is slightly based upon the [MFSlideMenu](https://github.com/mikefrederick/MFSideMenu).

##Example


![image](Screen1.jpg)


##Installation

###Via CocoaPods (Comming soon...!)
If you don't have cocoapods yet (shame on you), install it:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```

Go to the directory of your Xcode project, and Create and/or Edit your Podfile and add PPTopSlideMenu:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
# Edit the podfile using your favorite editor or push PPTopSlideMenu to the file
$ echo "pod 'PPTopSlideMenu'," >> Podfile
$ pod setup
$ pod install
```

###Manually
Add the `.h` and `.m` file to your project. Add QuartzCore to your project. If you have a project that doesn't use ARC, add the `-fobjc-arc` compiler flag to the PPTopSlideMenu files.

##Usage
###Adding the menu to your project
In your app delegate:<br />
```objective-c
#import "PPTopSlideMenu.h"
PPTopSlideMenuViewController *menuContainerViewController = [PPTopSlideMenuViewController topMenuWithContainer:centerPageViewController menuViewController:menuViewController];
[self.menuContainer setMenuHeight:200.0f];
    
[self.window setRootViewController:self.menuContainer];
[self.window makeKeyAndVisible];
```
###Opening & Closing Menus

`[self.menuContainerViewController toggleMenu:^{}];`


###Automatically hiding/showing the statusbar
If you would like the statusbar to disapear, add the `View controller-based status bar appearance` value to your Info.plist and set it to `NO`. 

##Todo
Currencly, panning is not yet enabled. It is, however, added to the code from `MFSlideMenu`. 


Warning! The TopSlideMenu is made quickly as a test for one of my own apps and needs refactoring. 
