//
//  AppDelegate.h
//  iRide
//
//  Created by Jack Borthwick on 6/25/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Managers.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) Managers *resultsManager;


@end

