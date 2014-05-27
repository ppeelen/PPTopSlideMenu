//
//  PPTopSlideMenuViewController.m
//  PPTopSlideMenu
//
//  Created by Paul Peelen on 2013-12-10.
//  Copyright (c) 2013 Appified.net. All rights reserved.
//

#import "PPTopSlideMenuViewController.h"
#import <QuartzCore/QuartzCore.h>

NSString * const PPTopSlideMenuStateNotificationEvent = @"PPTopSlideMenuStateNotificationEvent";

typedef enum {
    PPTopSlideMenuPanDirectionNone,
    PPTopSlideMenuPanDirectionUp,
    PPTopSlideMenuPanDirectionDown
} PPTopSlideMenuPanDirection;

@interface PPTopSlideMenuViewController ()

@property (nonatomic, strong) UIView *menuContainerView;
@property (nonatomic, assign) BOOL viewHasAppeared;

@property (nonatomic, assign) CGPoint panGestureOrigin;
@property (nonatomic, assign) CGFloat panGestureVelocity;
@property (nonatomic, assign) PPTopSlideMenuPanDirection panDirection;

@end

@implementation PPTopSlideMenuViewController

@synthesize menuViewController = _menuViewController;
@synthesize menuState = _menuState;
@synthesize viewHasAppeared = _viewHasAppeared;
@synthesize menuHeight = _menuHeight;
@synthesize panMode = _panMode;
@synthesize panDirection = _panDirection;

@synthesize menuContainerView;
@synthesize menuAnimationDefaultDuration;
@synthesize menuAnimationMaxDuration;

#pragma mark - Initialization

+ (PPTopSlideMenuViewController *)topMenuWithContainer:(id)containerViewController
                                    menuViewController:(id)menuViewController {
    PPTopSlideMenuViewController *controller = [PPTopSlideMenuViewController new];
    controller.containerViewController = containerViewController;
    controller.menuViewController = menuViewController;
    
    return controller;
}

- (id) init {
    if (self = [super init]) {
        [self setDefaultSettings];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)inCoder {
    id coder = [super initWithCoder:inCoder];
    [self setDefaultSettings];
    return coder;
}

- (void)setDefaultSettings {
    if(self.menuContainerView) return;
    
    self.menuContainerView = [[UIView alloc] init];
    self.menuState = PPTopSlideMenuClosed;
    self.menuHeight = 270.0f;
    self.menuSlideAnimationFactor = 3.0f;
    self.menuAnimationDefaultDuration = 0.2f;
    self.menuAnimationMaxDuration = 0.4f;
    self.panMode = PPTopSlideMenuPanModeDefault;
    self.viewHasAppeared = NO;
}

- (void)setupMenuContainerView {
    if (self.menuContainerView.superview) return;
    
    self.menuContainerView.frame = self.view.bounds;
    self.menuContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self.view insertSubview:self.menuContainerView atIndex:0];
    
    [self.menuContainerView addSubview:self.menuViewController.view];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!self.viewHasAppeared) {
        [self setupMenuContainerView];
        [self setMenuFrameToClosedPosition];
        [self addGestureRecognizers];
        
        self.viewHasAppeared = YES;
    }
}

#pragma mark - UIViewController Rotation

-(NSUInteger)supportedInterfaceOrientations {
    if (self.containerViewController) {
        if ([self.containerViewController isKindOfClass:[UINavigationController class]]) {
            return [((UINavigationController *)self.containerViewController).topViewController supportedInterfaceOrientations];
        }
        return [self.containerViewController supportedInterfaceOrientations];
    }
    return [super supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate {
    if (self.containerViewController) {
        if ([self.containerViewController isKindOfClass:[UINavigationController class]]) {
            return [((UINavigationController *)self.containerViewController).topViewController shouldAutorotate];
        }
        return [self.containerViewController shouldAutorotate];
    }
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.containerViewController) {
        if ([self.containerViewController isKindOfClass:[UINavigationController class]]) {
            return [((UINavigationController *)self.containerViewController).topViewController preferredInterfaceOrientationForPresentation];
        }
        return [self.containerViewController preferredInterfaceOrientationForPresentation];
    }
    return UIInterfaceOrientationPortrait;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


#pragma mark -
#pragma mark - UIViewController Containment

- (void)setMenuViewController:(UIViewController *)MenuViewController {
    [self removeChildViewControllerFromContainer:_menuViewController];
    
    _menuViewController = MenuViewController;
    if(!_menuViewController) return;
    
    [self addChildViewController:_menuViewController];
    if(self.menuContainerView.superview) {
        [self.menuContainerView insertSubview:[_menuViewController view] atIndex:0];
    }
    [_menuViewController didMoveToParentViewController:self];
    
    if(self.viewHasAppeared) [self setMenuFrameToClosedPosition];
}

- (void)setContainerViewController:(UIViewController *)containerViewController {
    [self removeCenterGestureRecognizers];
    [self removeChildViewControllerFromContainer:_containerViewController];
    
    CGPoint origin = ((UIViewController *)_containerViewController).view.frame.origin;
    _containerViewController = containerViewController;
    if(!_containerViewController) return;
    
    [self addChildViewController:_containerViewController];
    [self.view addSubview:[_containerViewController view]];
    [((UIViewController *)_containerViewController) view].frame = (CGRect){.origin = origin, .size=containerViewController.view.frame.size};
    
    [_containerViewController didMoveToParentViewController:self];
    
    [self addCenterGestureRecognizers];
}

- (void)removeChildViewControllerFromContainer:(UIViewController *)childViewController {
    if(!childViewController) return;
    [childViewController willMoveToParentViewController:nil];
    [childViewController removeFromParentViewController];
    [childViewController.view removeFromSuperview];
}


#pragma mark -
#pragma mark - UIGestureRecognizer Helpers

- (UIPanGestureRecognizer *)panGestureRecognizer {
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
	[recognizer setMaximumNumberOfTouches:1];
    [recognizer setDelegate:self];
    return recognizer;
}

- (void)addGestureRecognizers {
    [self addCenterGestureRecognizers];
    [self.menuContainerView addGestureRecognizer:[self panGestureRecognizer]];
}

- (void)removeCenterGestureRecognizers
{
    if (self.containerViewController)
    {
        [[self.containerViewController view] removeGestureRecognizer:[self centerTapGestureRecognizer]];
        [[self.containerViewController view] removeGestureRecognizer:[self panGestureRecognizer]];
    }
}
- (void)addCenterGestureRecognizers
{
    if (self.containerViewController)
    {
        [[self.containerViewController view] addGestureRecognizer:[self centerTapGestureRecognizer]];
        [[self.containerViewController view] addGestureRecognizer:[self panGestureRecognizer]];
    }
}

- (UITapGestureRecognizer *)centerTapGestureRecognizer
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(centerViewControllerTapped:)];
    [tapRecognizer setDelegate:self];
    return tapRecognizer;
}


#pragma mark -
#pragma mark - Menu state

- (void)toggleMenu:(void (^)(void))completion {
    if (self.menuState == PPTopSlideMenuClosed) {
        [self setMenuState:PPTopSlideMenuOpened completion:completion];
    } else {
        [self setMenuState:PPTopSlideMenuClosed completion:completion];
    }
}

- (void)openMenuCompletion:(void (^)(void))completion {
    if(!self.menuViewController) return;
    [self.menuContainerView bringSubviewToFront:[self.menuViewController view]];
    [self setContainerViewControllerOffset:self.menuHeight animated:YES completion:completion];
}

- (void)closeMenuCompletion:(void (^)(void))completion {
    [self setContainerViewControllerOffset:0 animated:YES completion:completion];
}

- (void)setMenuState:(PPTopSlideMenuState)menuState {
    [self setMenuState:menuState completion:nil];
}

- (void)setMenuState:(PPTopSlideMenuState)menuState completion:(void (^)(void))completion {
    void (^innerCompletion)() = ^ {
        _menuState = menuState;
        
        [self setUserInteractionStateForContainerViewController];
        PPTopSlideMenuStateEvent eventType = (_menuState == PPTopSlideMenuClosed) ? PPTopSlideMenuStateEventMenuDidClose : PPTopSlideMenuStateEventMenuDidOpen;
        [self sendStateEventNotification:eventType];
        
        if(completion) completion();
    };
    
    switch (menuState) {
        case PPTopSlideMenuClosed: {
            [self sendStateEventNotification:PPTopSlideMenuStateEventMenuWillClose];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [self setNeedsStatusBarAppearanceUpdate];
            [self closeMenuCompletion:^{
                //                [self.menuViewController view].hidden = YES;
                innerCompletion();
            }];
            if (self.menuClosed) {
                self.menuClosed();
            }
            break;
        }
        case PPTopSlideMenuOpened:
            if(!self.menuViewController) return;
            [self sendStateEventNotification:PPTopSlideMenuStateEventMenuWillOpen];
            [self menuWillShow];
            [self openMenuCompletion:innerCompletion];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            [self setNeedsStatusBarAppearanceUpdate];
            break;
        default:
            break;
    }
}

- (void)menuWillShow {
    [self.menuViewController view].hidden = NO;
    [self.menuContainerView bringSubviewToFront:[self.menuViewController view]];
}

- (void)setUserInteractionStateForContainerViewController {
    // disable user interaction on the current stack of view controllers if the menu is visible
    if([self.containerViewController respondsToSelector:@selector(viewControllers)]) {
        NSArray *viewControllers = [self.containerViewController viewControllers];
        for(UIViewController* viewController in viewControllers) {
            viewController.view.userInteractionEnabled = (self.menuState == PPTopSlideMenuClosed);
        }
    }
}

#pragma mark - State Event Notification

- (void)sendStateEventNotification:(PPTopSlideMenuStateEvent)event {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:event]
                                                         forKey:@"eventType"];
    [[NSNotificationCenter defaultCenter] postNotificationName:PPTopSlideMenuStateNotificationEvent
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark -
#pragma mark - MFSideMenuPanMode

- (BOOL) containerViewControllerPanEnabled {
    return ((self.panMode & PPTopSlideMenuPanModeCenterViewController) == PPTopSlideMenuPanModeCenterViewController);
}

- (BOOL) slideMenuPanEnabled {
    return ((self.panMode & PPTopSlideMenuPanModeSideMenu) == PPTopSlideMenuPanModeSideMenu);
}


#pragma mark -
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] &&
       self.menuState != PPTopSlideMenuClosed) return YES;
    
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if([gestureRecognizer.view isEqual:[self.containerViewController view]])
            return [self containerViewControllerPanEnabled];
        
        if([gestureRecognizer.view isEqual:self.menuContainerView])
            return [self slideMenuPanEnabled];
        
        // pan gesture is attached to a custom view
        return YES;
    }
    
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return NO;
}


#pragma mark -
#pragma mark - UIGestureRecognizer Callbacks

// this method handles any pan event
// and sets the navigation controller's frame as needed
- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    UIView *view = [self.containerViewController view];
    
	if(recognizer.state == UIGestureRecognizerStateBegan) {
        // remember where the pan started
        self.panGestureOrigin = view.frame.origin;
        self.panDirection = PPTopSlideMenuPanDirectionNone;
	}
    
    if(self.panDirection == PPTopSlideMenuPanDirectionNone) {
        CGPoint translatedPoint = [recognizer translationInView:view];
        if(translatedPoint.y > 0) {
            self.panDirection = PPTopSlideMenuPanDirectionUp;
            if(self.menuViewController && self.menuState == PPTopSlideMenuClosed) {
                [self menuWillShow];
            }
        }
    }
    
    if((self.menuState == PPTopSlideMenuOpened && self.panDirection == PPTopSlideMenuPanDirectionDown)
       || (self.menuState == PPTopSlideMenuOpened && self.panDirection == PPTopSlideMenuPanDirectionUp)) {
        self.panDirection = PPTopSlideMenuPanDirectionNone;
        return;
    }
    
    if(self.panDirection == PPTopSlideMenuPanDirectionDown) {
        [self handleTopPan:recognizer];
    }
}

- (void) handleTopPan:(UIPanGestureRecognizer *)recognizer {
    if(!self.menuViewController && self.menuState == PPTopSlideMenuClosed) return;
    
    UIView *view = [self.containerViewController view];
    
    CGPoint translatedPoint = [recognizer translationInView:view];
    CGPoint adjustedOrigin = self.panGestureOrigin;
    translatedPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x,
                                  adjustedOrigin.y + translatedPoint.y);
    
    translatedPoint.y = MAX(translatedPoint.y, -1*self.menuHeight);
    translatedPoint.y = MIN(translatedPoint.y, self.menuHeight);
    if(self.menuState == PPTopSlideMenuOpened) {
        // don't let the pan go less than 0 if the menu is already open
        translatedPoint.y = MAX(translatedPoint.y, 0);
    } else {
        // we are opening the menu
        translatedPoint.y = MIN(translatedPoint.y, 0);
    }
    
    [self setContainerViewControllerOffset:translatedPoint.y];
    
	if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:view];
        CGFloat finalY = translatedPoint.y + (.35*velocity.y);
        CGFloat viewHeight = view.frame.size.height;
        
        if(self.menuState == PPTopSlideMenuClosed) {
            BOOL showMenu = (finalY < -1*viewHeight/2) || (finalY < -1*self.menuHeight/2);
            if(showMenu) {
                self.panGestureVelocity = velocity.y;
                [self setMenuState:PPTopSlideMenuOpened];
            } else {
                self.panGestureVelocity = 0;
                [self setContainerViewControllerOffset:0 animated:YES completion:nil];
            }
        } else {
            BOOL hideMenu = (finalY < adjustedOrigin.y);
            if(hideMenu) {
                self.panGestureVelocity = velocity.y;
                [self setMenuState:PPTopSlideMenuClosed];
            } else {
                self.panGestureVelocity = 0;
                [self setContainerViewControllerOffset:adjustedOrigin.y animated:YES completion:nil];
            }
        }
	} else {
        [self setContainerViewControllerOffset:translatedPoint.y];
    }
}

- (void)centerViewControllerTapped:(id)sender {
    if(self.menuState != PPTopSlideMenuClosed) {
        [self setMenuState:PPTopSlideMenuClosed];
    }
}

- (void)setUserInteractionStateForCenterViewController {
    // disable user interaction on the current stack of view controllers if the menu is visible
    if([self.containerViewController respondsToSelector:@selector(viewControllers)]) {
        NSArray *viewControllers = [self.containerViewController viewControllers];
        for(UIViewController* viewController in viewControllers) {
            viewController.view.userInteractionEnabled = (self.menuState == PPTopSlideMenuClosed);
        }
    }
}

#pragma mark -
#pragma mark - Center View Controller Movement

- (void)setContainerViewControllerOffset:(CGFloat)offset animated:(BOOL)animated completion:(void (^)(void))completion {
    [self setContainerViewControllerOffset:offset additionalAnimations:nil
                                  animated:animated completion:completion];
}

- (void)setContainerViewControllerOffset:(CGFloat)offset
                    additionalAnimations:(void (^)(void))additionalAnimations
                                animated:(BOOL)animated
                              completion:(void (^)(void))completion {
    void (^innerCompletion)() = ^ {
        if(completion) completion();
    };
    
    if(animated) {
        CGFloat containerViewControllerYPosition = ABS([self.containerViewController view].frame.origin.y);
        CGFloat duration = [self animationDurationFromStartPosition:containerViewControllerYPosition toEndPosition:offset];
        
        [UIView animateWithDuration:duration animations:^{
            [self setContainerViewControllerOffset:offset];
            if(additionalAnimations) additionalAnimations();
        } completion:^(BOOL finished) {
            innerCompletion();
        }];
    } else {
        [self setContainerViewControllerOffset:offset];
        if(additionalAnimations) additionalAnimations();
        innerCompletion();
    }
}

- (void) setContainerViewControllerOffset:(CGFloat)yOffset {
    CGRect frame = [self.containerViewController view].frame;
    frame.origin.y = yOffset;
    [self.containerViewController view].frame = frame;
    
    if(!self.menuSlideAnimationEnabled) return;
    
    if(yOffset > 0){
        [self alignMenuControllerWithCenterViewController];
    } else {
        [self setMenuFrameToClosedPosition];
    }
}

- (CGFloat)animationDurationFromStartPosition:(CGFloat)startPosition toEndPosition:(CGFloat)endPosition {
    CGFloat animationPositionDelta = ABS(endPosition - startPosition);
    
    CGFloat duration;
    if(ABS(self.panGestureVelocity) > 1.0) {
        // try to continue the animation at the speed the user was swiping
        duration = animationPositionDelta / ABS(self.panGestureVelocity);
    } else {
        // no swipe was used, user tapped the bar button item
        // TODO: full animation duration hard to calculate with two menu widths
        CGFloat menuHeight = self.menuHeight;
        CGFloat animationPerecent = (animationPositionDelta == 0) ? 0 : menuHeight / animationPositionDelta;
        duration = self.menuAnimationDefaultDuration * animationPerecent;
    }
    
    return MIN(duration, self.menuAnimationMaxDuration);
}

#pragma mark - Side Menu Positioning

- (void) setMenuFrameToClosedPosition {
    if(!self.menuViewController) return;
    
    CGRect menuFrame = [self.menuViewController view].frame;
    menuFrame.size.height = self.menuHeight;
    menuFrame.origin.x = 0;
    menuFrame.origin.y = (self.menuSlideAnimationEnabled) ? -1*menuFrame.size.height / self.menuSlideAnimationFactor : 0;
    [self.menuViewController view].frame = menuFrame;
    [self.menuViewController view].autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
}

- (void)alignMenuControllerWithCenterViewController {
    CGRect menuFrame = [self.menuViewController view].frame;
    menuFrame.size.height = self.menuHeight;
    
    CGFloat yOffset = [self.containerViewController view].frame.origin.y;
    CGFloat yPositionDivider = (self.menuSlideAnimationEnabled) ? self.menuSlideAnimationFactor : 1.0;
    menuFrame.origin.y = yOffset / yPositionDivider - _menuHeight / yPositionDivider;
    
    [self.menuViewController view].frame = menuFrame;
}

#pragma mark -


@end
