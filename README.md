#PPTopSlideMenu
==============

PPTopSLideMenu is a sliding menu that appears from the top. The original code is slightly based upon the [MFSlideMenu](https://github.com/mikefrederick/MFSideMenu).

##Example
=======

![image](demo1.gif =240x360)


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
self.menu = [[MenuViewController alloc] init];
self.menuContainer = [PPTopSlideMenuViewController topMenuWithContainer:self.buyView menuViewController:self.menu];
[self.menuContainer setMenuHeight:200.0f];
    
self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
[self.window setRootViewController:self.menuContainer];
[self.window makeKeyAndVisible];
```

