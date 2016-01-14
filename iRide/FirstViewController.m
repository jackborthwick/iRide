//
//  FirstViewController.m
//  iRide
//
//  Created by Jack Borthwick on 6/25/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import "FirstViewController.h"
#import "Managers.h"
#import "AppDelegate.h"
#import "MetroStations.h"
#import "Trains.h"  
#import "Bikeshares.h"

@interface FirstViewController ()

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, weak) IBOutlet MKMapView      *mapView;
@property (nonatomic, strong) Reachability          *hostReach;
@property (nonatomic, strong) Reachability          *internetReach;
@property (nonatomic, strong) Reachability          *wifiReach;
@property (nonatomic, strong) NSString              *hostName;
@property (nonatomic, strong) Managers              *resultsManager;
@property (nonatomic, strong) AppDelegate           *appDelegate;
@property (nonatomic, strong) NSMutableArray        *annotationArray;
@property (nonatomic, strong) CLLocation            *lastLocation;

@end

@implementation FirstViewController

BOOL internetAvailable;
BOOL serverAvailable;
BOOL didGetInfo = false;

#pragma mark - interactivity methods

- (void)getMetroAndBikeData {
    NSLog(@"you are here %f %f",_lastLocation.coordinate.latitude,_lastLocation.coordinate.longitude);
    didGetInfo = true;
    [_resultsManager downloadFileText:_lastLocation.coordinate.latitude andLon:_lastLocation.coordinate.longitude];


}


#pragma mark - Location Methods

-(void)annotateMapLocations {
    NSMutableArray *locs = [[NSMutableArray alloc] init];
    for (id <MKAnnotation> annot in [_mapView annotations]) {
        [locs addObject:annot];
    }
    [_mapView removeAnnotations:locs];
    [_mapView addAnnotations:_annotationArray];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _lastLocation = locations.lastObject;
    NSLog(@"location: %f,%f",_lastLocation.coordinate.latitude,_lastLocation.coordinate.longitude);
    
    [self zoomToLocationWithLat:_lastLocation.coordinate.latitude andLon:_lastLocation.coordinate.longitude];
    [_mapView reloadInputViews];
    if (_lastLocation.coordinate.latitude != 0 && !didGetInfo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getLocationDoneNotification" object:nil];
    }
    [_locationManager stopUpdatingLocation];
}

- (void)turnOnLocationMonitoring {
    [_locationManager startUpdatingLocation];
    _mapView.showsUserLocation = true;
    
}

- (void) setupLocationMonitoring {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedAlways: //is location services authorized always
                [self turnOnLocationMonitoring];
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [self turnOnLocationMonitoring];
                break;
            case kCLAuthorizationStatusDenied:{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AHHHH" message:@"SO TURN IT ON LIKE DIDDY KONG" delegate:self cancelButtonTitle:@"AY" otherButtonTitles: nil];
                [alert show];
                break;
            }
            case kCLAuthorizationStatusNotDetermined:
                if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [_locationManager requestWhenInUseAuthorization];
                }
            default:
                break;
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"locationservices off" message:@"SO TURN IT ON LIKE DIDDY KONG" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}


- (void)zoomToLocationWithLat:(float)latitude andLon:(float)longitude {
    if (latitude == 0 && longitude == 0) {
        NSLog(@"Bad Coordinates");
    } else {
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = latitude;
        zoomLocation.longitude = longitude;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 90000, 90000);
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:true];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation != mapView.userLocation) {
        MKPinAnnotationView *anotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if (anotationView == nil) {
            anotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"DAT DER SPOT"];
            anotationView.canShowCallout = true;
            if ([_resultsManager dataArray].count==0){
                anotationView.pinColor = MKPinAnnotationColorGreen;
            }
            else {
                anotationView.pinColor = MKPinAnnotationColorPurple;
            }
            anotationView.animatesDrop = true;
        }
        else {
            anotationView.annotation = annotation;
        }
        return anotationView;
    }
    return nil;
}



- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        NSLog(@"rendering");
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc]initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor purpleColor];
        return routeRenderer;
    }
    return nil;
}


#pragma mark - Connectivity Methods

- (void)updateReachabilityStatus:(Reachability *)curReach {
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if(curReach == _hostReach) {
        switch (netStatus)
        {
            case NotReachable:
            {
                NSLog(@"Server Not Available");
                serverAvailable = NO;
                break;
            }
                
            case ReachableViaWWAN:
            {
                NSLog(@"Server Reachable via WWAN");
                serverAvailable = YES;
                break;
            }
            case ReachableViaWiFi:
            {
                NSLog(@"Server Reachable via WiFi");
                serverAvailable = YES;
                break;
            }
        }
    }
    if(curReach == _internetReach || curReach == _wifiReach) {
        switch (netStatus)
        {
            case NotReachable:
            {
                NSLog(@"Internet Not Available");
                internetAvailable = NO;
                break;
            }
                
            case ReachableViaWWAN:
            {
                NSLog(@"Internet Reachable via WWAN");
                internetAvailable = YES;
                break;
            }
            case ReachableViaWiFi:
            {
                NSLog(@"Internet Reachable via WiFi");
                internetAvailable = YES;
                break;
            }
        }
    }
}

- (void)reachabilityChanged:(NSNotification*)note
{
    Reachability* curReach = [note object];
    [self updateReachabilityStatus:curReach];
}

#pragma mark - managers methods

- (void)newDataReceived {
    NSLog(@"JUST GOT FROM MANAGERS %@",[[[_resultsManager dataArray]objectAtIndex:0]title]);
    NSLog(@"%lu",(unsigned long)[_resultsManager dataArray].count);

    [_mapView addAnnotations:[_resultsManager dataArray]];
    [_mapView showAnnotations:[_mapView annotations] animated:true];
    //CLLocation *lastLocation = locations.lastObject;
    
    
    for (MKPointAnnotation *annotation in _mapView.annotations) {
        CLLocation *currentAnnotationLocation = [[CLLocation alloc]initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        [_resultsManager getDirections:currentAnnotationLocation];
    }
    [_mapView reloadInputViews];
}

-(void)newDirectionsReceived {
    for (MKRoute *route in [_resultsManager directionArray]){
        [_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
    [_mapView reloadInputViews];
}

-(void)newStationsReceived {
    NSLog(@"WE GOT IT FROM MANAGERS  %@",[[[_resultsManager dataArray]objectAtIndex:1]stationName]);
    NSLog(@"in 1st upcoming train is %@",[[[[[_resultsManager dataArray]objectAtIndex:1]stationUpcomingTrains]objectAtIndex:1]trainDestination]);
    for (MetroStations *station in [_resultsManager dataArray]) {
        MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc]init];
        newAnnotation.title =[NSString stringWithFormat:@"metro: %@",station.stationName];
        //newAnnotation.subtitle = [NSString stringWithFormat:@"%@ bikes %@ docks",current.bikeshareBikesAvailable,current.bikeshareDocksAvailable];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([station.stationLatitude floatValue], [station.stationLongitude floatValue]);
        newAnnotation.coordinate = coord;
        [_annotationArray addObject:newAnnotation];
        [_mapView addAnnotation:newAnnotation];
    }
    for (Bikeshares *current in [_resultsManager bikeshareArray]) {
        NSLog(@"bike share name::::  %@",current.bikeshareDocksAvailable);
        MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc]init];
        newAnnotation.title = [NSString stringWithFormat:@"bikeshare: %@",current.bikeshareName];
        newAnnotation.coordinate = CLLocationCoordinate2DMake([current.bikeshareLatitude floatValue], [current.bikeshareLongitude floatValue]);
        newAnnotation.subtitle = [NSString stringWithFormat:@"%@ bikes %@ docks",current.bikeshareBikesAvailable,current.bikeshareDocksAvailable];
        [_annotationArray addObject:newAnnotation];
        [_mapView addAnnotation:newAnnotation];
    }
    for (MKPointAnnotation *annotation in _mapView.annotations) {
        CLLocation *currentAnnotationLocation = [[CLLocation alloc]initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        [_resultsManager getDirections:currentAnnotationLocation];
    }
    [_mapView reloadInputViews];
    [_mapView showAnnotations:[_mapView annotations] animated:true];

    //NSLog(@"upcoming trains count is %lu",[[[[_resultsManager dataArray]objectAtIndex:2]stationUpcomingTrains]count]);
}

#pragma mark - life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostName = @"itunes.apple.com";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];//any time kreachability changes we will run reachability changed
    _hostReach = [Reachability reachabilityWithHostName:_hostName];
    [_hostReach startNotifier];
    [self updateReachabilityStatus:_hostReach];
    
    _internetReach = [Reachability reachabilityForInternetConnection];
    [_internetReach startNotifier];
    [self updateReachabilityStatus:_internetReach];
    
    _wifiReach = [Reachability reachabilityForLocalWiFi];
    [_wifiReach startNotifier];
    [self updateReachabilityStatus:_wifiReach];
    [self setupLocationMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataReceived) name:@"ResultsDoneNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDirectionsReceived) name:@"DirectionsDoneNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newStationsReceived) name:@"ResultsFromAPIDoneNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMetroAndBikeData) name:@"getLocationDoneNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self annotateMapLocations];
    [_mapView showAnnotations:[_mapView annotations] animated:true];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _resultsManager = _appDelegate.resultsManager;
    _resultsManager = [Managers sharedHelper];
    //[_resultsManager getResults];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self annotateMapLocations];
    [_mapView showAnnotations:[_mapView annotations] animated:true];
//    NSLog(@"you are here %f %f",_lastLocation.coordinate.latitude,_lastLocation.coordinate.longitude);
    //[_resultsManager downloadFileText:_mapView.userLocation.coordinate.latitude andLon:_mapView.userLocation.coordinate.longitude];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
