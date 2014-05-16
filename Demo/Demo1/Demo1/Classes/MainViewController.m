//
//  MainViewController.m
//  Demo1
//
//  Created by Paul Peelen on 2014-02-02.
//  Copyright (c) 2014 Paul Peelen. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()

- (IBAction)menuButtonPressed:(id)sender;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuButtonPressed:(id)sender
{
    [ApplicationDelegate.menuContainer toggleMenu:nil];
    
    [ApplicationDelegate.menuContainer setMenuClosed:^{
        NSLog(@"Menu was closed");
    }];
}

@end
