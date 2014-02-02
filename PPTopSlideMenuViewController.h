//
//  PPTopSlideMenuViewController.h
//  halplatsen
//
//  Created by Paul Peelen on 2013-12-10.
//
//

#import <UIKit/UIKit.h>

extern NSString * const PPTopSlideMenuStateNotificationEvent;

typedef enum {
    PPTopSlideMenuPanModeNone = 0, // pan disabled
    PPTopSlideMenuPanModeCenterViewController = 1 << 0, // enable panning on the centerViewController
    PPTopSlideMenuPanModeSideMenu = 1 << 1, // enable panning on side menus
    PPTopSlideMenuPanModeDefault = PPTopSlideMenuPanModeCenterViewController | PPTopSlideMenuPanModeSideMenu
} PPTopSlideMenuPanMode;

typedef enum {
    PPTopSlideMenuClosed = 0,
    PPTopSlideMenuOpened
} PPTopSlideMenuState;

typedef enum {
    PPTopSlideMenuStateEventMenuWillOpen, // the menu is going to open
    PPTopSlideMenuStateEventMenuDidOpen, // the menu finished opening
    PPTopSlideMenuStateEventMenuWillClose, // the menu is going to close
    PPTopSlideMenuStateEventMenuDidClose // the menu finished closing
} PPTopSlideMenuStateEvent;

@interface PPTopSlideMenuViewController : UIViewController <UIGestureRecognizerDelegate>

+ (PPTopSlideMenuViewController *)topMenuWithContainer:(id)containerViewController
                                    menuViewController:(id)menuViewController;

@property (nonatomic, strong) id containerViewController;
@property (nonatomic, strong) UIViewController *menuViewController;

@property (nonatomic, assign) PPTopSlideMenuState menuState;
@property (nonatomic, assign) PPTopSlideMenuPanMode panMode;

// menu open/close animation duration -- user can pan faster than default duration, max duration sets the limit
@property (nonatomic, assign) CGFloat menuAnimationDefaultDuration;
@property (nonatomic, assign) CGFloat menuAnimationMaxDuration;

// Height of the menu
@property (nonatomic, assign) CGFloat menuHeight;

// menu slide-in animation
@property (nonatomic, assign) BOOL menuSlideAnimationEnabled;
@property (nonatomic, assign) CGFloat menuSlideAnimationFactor; // higher = less menu movement on animation

- (void)toggleMenu:(void (^)(void))completion;

@end
