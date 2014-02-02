#PPTopSlideMenu
==============

PPTopSLideMenu is a sliding menu that appears from the top. The original code is slightly based upon the [MFSlideMenu](https://github.com/mikefrederick/MFSideMenu).

##Example
=======

![image](demo1.gif)


##Installation
===

###Cocoapods

###Manually
Add the `.h` and `.m` file to your project. Add QuartzCore to your project. If you have a project that doesn't use ARC, add the `-fobjc-arc` compiler flag to the PPTopSlideMenu files.

##Usage
===
In your app delegate:<br />
```objective-c
#import "PPTopSlideMenu.h"
PPTopSlideMenuViewController *menuContainerViewController = [PPTopSlideMenuViewController topMenuWithContainer:centerPageViewController menuViewController:menuViewController];
[self.menuContainer setMenuHeight:200.0f];
    
[self.window setRootViewController:self.menuContainer];
[self.window makeKeyAndVisible];
```
###Opening & Closing Menus

```objective-c
[self.menuContainerViewController toggleMenu:^{}];```

##Todo
Currencly, panning is not yet enabled. It is, however, added to the code from `MFSlideMenu`. 


Warning! The TopSlideMenu is made quickly as a test for one of my own apps and needs refactoring. 
