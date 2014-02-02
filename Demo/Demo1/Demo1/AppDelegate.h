//
//  AppDelegate.h
//  Demo1
//
//  Created by Paul Peelen on 2014-02-02.
//  Copyright (c) 2014 Paul Peelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTopSlideMenuViewController.h"
#import "MenuViewController.h"
#import "MainViewController.h"

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) PPTopSlideMenuViewController *menuContainer;

@end
