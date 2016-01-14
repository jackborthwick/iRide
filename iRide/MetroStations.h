//
//  MetroStations.h
//  iRide
//
//  Created by Jack Borthwick on 6/26/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trains.h"
@interface MetroStations : NSObject

@property (nonatomic, strong) NSString *stationLatitude;
@property (nonatomic, strong) NSString *stationLongitude;
@property (nonatomic, strong) NSString *stationName;
@property (nonatomic, strong) NSString *stationDistance;
@property (nonatomic, strong) NSString *stationLineOne;
@property (nonatomic, strong) NSString *stationLineTwo;
@property (nonatomic, strong) NSString *stationLineThree;
@property (nonatomic, strong) NSString *stationLineFour;
@property (nonatomic, strong) NSArray *stationUpcomingTrains;





@end
