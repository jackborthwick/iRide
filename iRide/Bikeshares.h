//
//  Bikeshares.h
//  iRide
//
//  Created by Jack Borthwick on 6/26/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bikeshares : NSObject

@property (nonatomic, strong) NSString *bikeshareName;
@property (nonatomic, strong) NSString *bikeshareLatitude;
@property (nonatomic, strong) NSString *bikeshareLongitude;
@property (nonatomic, strong) NSString *bikeShareDistance;
@property (nonatomic, strong) NSString *bikeshareBikesAvailable;
@property (nonatomic, strong) NSString *bikeshareDocksAvailable;

@end
