//
//  SecondViewController.m
//  iRide
//
//  Created by Jack Borthwick on 6/25/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import "SecondViewController.h"
#import "Managers.h"
#import "AppDelegate.h"
#import "MetroStations.h"
#import "Trains.h"
#import "Bikeshares.h"
@interface SecondViewController ()

@property (nonatomic, strong) IBOutlet UITableView  *itemTableView;
@property (nonatomic, strong) Managers              *resultsManager;
@property (nonatomic, strong) AppDelegate           *appDelegate;

@end

@implementation SecondViewController
#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return [_resultsManager dataArray].count;
    }
    else {
        return [_resultsManager bikeshareArray].count;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {//else if you dont have one to reuse lets make a new one
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.textLabel.textColor = [UIColor purpleColor];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = [[[_resultsManager dataArray]objectAtIndex:indexPath.row] stationName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ miles away",[[[_resultsManager dataArray]objectAtIndex:indexPath.row] stationDistance]];
        //NSArray *upcomingTrains = [[[_resultsManager dataArray]objectAtIndex:indexPath.row]stationUpcomingTrains];
       // NSLog(@"UPCOMING TRAIIINS %i",upcomingTrains.count);
    }
    if (indexPath.section == 1) {
        cell.textLabel.text = [[[_resultsManager bikeshareArray]objectAtIndex:indexPath.row] bikeshareName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ bikes %@ docks",[[[_resultsManager bikeshareArray]objectAtIndex:indexPath.row]bikeshareBikesAvailable],[[[_resultsManager bikeshareArray]objectAtIndex:indexPath.row]bikeshareDocksAvailable]];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Metro Stations";
    }
    else if (section == 1){
        return @"Bikeshares";
    }
    return nil;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _resultsManager = _appDelegate.resultsManager;
    _resultsManager = [Managers sharedHelper];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
