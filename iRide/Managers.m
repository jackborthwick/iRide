//
//  Managers.m
//  iRide
//
//  Created by Jack Borthwick on 6/25/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//
#import "Managers.h"
#import "FirstViewController.h"
#import "Trains.h"
#import "MetroStations.h"
#import "Bikeshares.h"
@implementation Managers

+ (id)sharedHelper {
    static Managers *sharedHelper = nil;
    @synchronized(self) {
        if (sharedHelper == nil)
            sharedHelper = [[self alloc] init];
    }
    return sharedHelper;
}

- (void)getDirections:(CLLocation *)currentLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        MKPlacemark *placemark = [placemarks objectAtIndex:0];
        MKMapItem *destItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        MKDirectionsRequest *dirRequest = [[MKDirectionsRequest alloc] init];
        dirRequest.source = [MKMapItem mapItemForCurrentLocation];
        dirRequest.destination = destItem;
        dirRequest.requestsAlternateRoutes = false;//talk with tom about why no location
        MKDirections *directions = [[MKDirections alloc]initWithRequest:dirRequest];
        NSLog(@"error 1v");
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            // CODE GOES HERE
            _directionArray = response.routes;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DirectionsDoneNotification" object:nil];
        }];
    }];
}

- (void)downloadFileText:(float)latitude andLon:(float)longitude {
    NSLog(@"download text pressed");
        _dataArray = [[NSMutableArray alloc]init];
    _bikeshareArray = [[NSMutableArray alloc]init];
        //_searchTerm = _searchField.text;
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://mobile-metro.herokuapp.com/?user_latitude=%f&user_longitude=%f",latitude,longitude]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        [NSURLConnection sendAsynchronousRequest: urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (([data length] > 0) && (error == nil)) {
                NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"Got Data: %@",dataString);
                NSError *jsonError = nil;
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                _itemArray = [(NSDictionary *) json objectForKey:@"location"];//create an array of dictionary items to read the array of dictionary items from the json
                //NSLog(@"THIS MANY ARTISTS  %li",_itemArray.count);
                NSLog(@"THIS MANY FROM _ITEMARRY %lu",(unsigned long)_itemArray.count);
                
                NSArray *stations = [_itemArray objectForKey:@"stations"];
                NSLog(@"%li is the count of stations dictionary",(unsigned long)stations.count );
                for (MetroStations *station in stations) {
                    MetroStations *stationToAdd = [[MetroStations alloc]init];
                    stationToAdd.stationName = [(NSDictionary *)station objectForKey:@"station_name"];
                    stationToAdd.stationDistance = [(NSDictionary *)station objectForKey:@"station_distance"];
                    stationToAdd.stationLineOne = [(NSDictionary *)station objectForKey:@"line_1"];
                    stationToAdd.stationLineTwo = [(NSDictionary *)station objectForKey:@"line_2"];
                    stationToAdd.stationLineThree = [(NSDictionary *)station objectForKey:@"line_3"];
                    stationToAdd.stationLineFour = [(NSDictionary *)station objectForKey:@"line_4"];
                    stationToAdd.stationLatitude = [(NSDictionary *)station objectForKey:@"station_latitude"];
                    stationToAdd.stationLongitude = [(NSDictionary *)station objectForKey:@"station_longitude"];
                    NSArray *upcomingTrains = [(NSDictionary *)station objectForKey:@"upcoming"];
                    NSMutableArray *upcomingTrainsToAdd = [[NSMutableArray alloc]init];
                    for (Trains *upcomingTrain in upcomingTrains) {
                        Trains *newTrain = [[Trains alloc]init];
                        newTrain.trainDestination =[(NSDictionary *)upcomingTrain objectForKey:@"destination"];
                        newTrain.trainLine =[(NSDictionary *)upcomingTrain objectForKey:@"line"];
                        newTrain.trainMin =[(NSDictionary *)upcomingTrain objectForKey:@"min"];
                        [upcomingTrainsToAdd addObject:newTrain];
                    }
                    stationToAdd.stationUpcomingTrains = upcomingTrainsToAdd;
                    //NSArray *stations = [(NSDictionary *) objectForKey:@"upcoming"];
                    [_dataArray addObject:stationToAdd];
                }
                NSArray *bikeShares = [_itemArray objectForKey:@"bikeshares"];
                NSLog(@"this many bikeshares %i",bikeShares.count);
                for (Bikeshares *bikeshare in bikeShares) {
                    Bikeshares *newBikeshare = [[Bikeshares alloc]init];
                    newBikeshare.bikeshareName = [(NSDictionary *)bikeshare objectForKey:@"bikeshare_name"];
                    newBikeshare.bikeshareLatitude = [(NSDictionary *)bikeshare objectForKey:@"bikeshare_latitude"];
                    newBikeshare.bikeshareLongitude = [(NSDictionary *)bikeshare objectForKey:@"bikeshare_longitude"];
                    newBikeshare.bikeShareDistance = [(NSDictionary *)bikeshare objectForKey:@"bikes_availability"];
                    NSArray *availability = [(NSDictionary *)bikeshare objectForKey:@"availability"];
                    newBikeshare.bikeshareBikesAvailable = [(NSDictionary *)availability objectForKey:@"bikes_available"];
                    newBikeshare.bikeshareDocksAvailable = [(NSDictionary *)availability objectForKey:@"empty_docks"];
                    [_bikeshareArray addObject:newBikeshare];

                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultsFromAPIDoneNotification" object:nil];
            } else if (([data length] == 0) && (error == nil)) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"No Data Found" message:@"It looks like we weren't able to find a file" delegate:self
                                      cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            } else if (error.code == -1009) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Internet Disabled" message:@"It looks like your device may not be connected to the Internet. Please make sure the Internet is on and try the update again." delegate:self
                                      cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            } else if (error != nil) {
                NSLog(@"Error = %@", error);
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Unknown Error" message:[NSString stringWithFormat:@"An error has occured. Please contact support. Error %@",error] delegate:self
                                      cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
        }];
    
//    else {
//        UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"NO INTERNET" message:@"NO INTERNET" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:nil, nil];
//        [noInternetAlert show];
//    }
}


- (void)getResults {
    _dataArray = [[NSMutableArray alloc]init];
    NSLog(@"apple search IN RESUKLTS");
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"food";
    //request.region = [_mapView region];
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count == 0) {
            NSLog(@"nada");
        }
        else {
            for (MKMapItem *item in response.mapItems) {
                MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
                pa.coordinate = item.placemark.location.coordinate;
                pa.title = item.name;
                [_dataArray addObject:pa];
                NSLog(@"I GOT %@",pa.title);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultsDoneNotification" object:nil];
        }
    }];
}

@end