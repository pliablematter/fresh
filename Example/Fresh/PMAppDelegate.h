//
//  PMAppDelegate.h
//  Fresh
//
//  Created by doug@pliablematter.com on 09/09/2018.
//  Copyright (c) 2018 doug@pliablematter.com. All rights reserved.
//

@import UIKit;
#import "PMFresh.h"

@interface PMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PMFresh *fileFresh;
@property (strong, nonatomic) PMFresh *directoryFresh;
@property (strong, nonatomic) PMFresh *containerFresh;

@end
