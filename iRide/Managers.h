//
//  Managers.h
//  iRide
//
//  Created by Jack Borthwick on 6/25/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FirstViewController.h"
@interface Managers : NSObject

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray        *directionArray;
@property (nonatomic, strong) NSDictionary        *itemArray;
@property (nonatomic, strong) NSMutableArray              *bikeshareArray;
@property (nonatomic, strong) NSString              *hostName;


+ (id)sharedHelper;
- (void)getResults;
- (void)getDirections:(CLLocation *)currentLocation;
- (void)downloadFileText:(float)latitude andLon:(float)longitude;


@end
