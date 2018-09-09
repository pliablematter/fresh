//
//  PMViewController.m
//  Fresh
//
//  Created by doug@pliablematter.com on 09/09/2018.
//  Copyright (c) 2018 doug@pliablematter.com. All rights reserved.
//

#import "PMViewController.h"
#import "PMAppDelegate.h"

@interface PMViewController ()

@end

@implementation PMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)updateButtonTapped:(id)sender {
    PMAppDelegate *ad = (PMAppDelegate*) UIApplication.sharedApplication.delegate;
    [ad.directoryFresh update];
    [ad.fileFresh updateWithHeaders:@{@"Test1": @"123", @"Test2": @"ABC"}];
    [ad.containerFresh update];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
