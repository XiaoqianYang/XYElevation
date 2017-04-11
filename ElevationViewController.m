//
//  ViewController.m
//  XYElevation
//
//  Created by Xiaoqian Yang on 17/01/2017.
//  Copyright © 2017 XiaoqianYang. All rights reserved.
//

#import "ElevationViewController.h"
#import <Masonry.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GooglePlacePicker/GooglePlacePicker.h>
#import <AFNetworking.h>
#import "ElevationHttpClient.h"
#import "ElevationModel.h"

@interface ElevationViewController ()<GMSAutocompleteResultsViewControllerDelegate, ElevationHttpClientDelegate, CLLocationManagerDelegate>
@property (nonatomic) GMSPlacePicker *placePicker;
@end

@implementation ElevationViewController {
    UISearchController *_searchController;
    GMSAutocompleteResultsViewController *_acViewController;
    GMSMapView * _mapView;
    CLLocationManager *_locationManager;
    GMSPlacesClient *_placesClient;
    GMSPlace *_currentPlace;
    GMSMarker *_marker;
}

- (id) init {
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor blueColor];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:10];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = NO;
    self.view = _mapView;
    
    _marker = [[GMSMarker alloc]init];
    
    _acViewController = [[GMSAutocompleteResultsViewController alloc] init];
    _acViewController.delegate = self;
    
    _searchController =
    [[UISearchController alloc] initWithSearchResultsController:_acViewController];
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.dimsBackgroundDuringPresentation = YES;
    
    _searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    [_searchController.searchBar sizeToFit];
    self.navigationItem.titleView = _searchController.searchBar;
    self.definesPresentationContext = YES;
    
    // Work around a UISearchController bug that doesn't reposition the table view correctly when
    // rotating to landscape.
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    _searchController.searchResultsUpdater = _acViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _searchController.modalPresentationStyle = UIModalPresentationPopover;
    } else {
        _searchController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
        
    //set button to select current place
    UIButton * currentLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    currentLocationBtn.accessibilityLabel = @"currentLocationButton";
    [currentLocationBtn setFrame:CGRectMake(0, 0, 20, 20)];
    [currentLocationBtn addTarget:self action:@selector(selectCurrentPlace:) forControlEvents:UIControlEventTouchUpInside];
    
    [currentLocationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [self.view addSubview:currentLocationBtn];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(30, 30, 50, 30);
    [currentLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-padding.bottom);
        make.right.equalTo(self.view.mas_right).with.offset(-padding.right);
    }];

    //set button to pick place
    UIButton * pickLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pickLocationBtn.accessibilityLabel = @"picLocationButton";
    [pickLocationBtn setFrame:CGRectMake(0, 0, 20, 20)];
    [pickLocationBtn addTarget:self action:@selector(pickPlace:) forControlEvents:UIControlEventTouchUpInside];

    [pickLocationBtn setImage:[UIImage imageNamed:@"pick2"] forState:UIControlStateNormal];
    [self.view addSubview:pickLocationBtn];
    
    UIEdgeInsets padding2 = UIEdgeInsetsMake(30, 30, 30, 30);
    [pickLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(currentLocationBtn.mas_top).with.offset(-padding2.bottom);
        make.right.equalTo(self.view.mas_right).with.offset(-padding.right);
    }];
    
    _locationManager = [[CLLocationManager alloc] init];
    _placesClient = [GMSPlacesClient sharedClient];
    
    [self setCurrentPlace];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GMSAutocompleteResultsViewControllerDelegate

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    // Display the results and dismiss the search controller.
    [_searchController setActive:NO];
    [self autocompleteDidSelectPlace:place];
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    // Display the error and dismiss the search controller.
    [_searchController setActive:NO];
    //[self autocompleteDidFail:error];
}

// Show and hide the network activity indicator when we start/stop loading results.

- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - AltitudeHttpClient delegate

-(void)elevationHttpClient:(ElevationHttpClient *)client didUpdateWithElevation:(id)res {
    NSError * error;
        
    ResponseModel * responseModel = [[ResponseModel alloc] initWithDictionary:res error:&error];
    
    if (error) {
        NSLog(@"Model Init Error : %@", error.description);
        return;
    }
    
    if ([responseModel.results count]) {
        [self setMarkerWithElevation:responseModel.results[0]];
    }
}

- (void) setMarkerWithElevation : (ElevationModel*) elevation {
    _marker.position = CLLocationCoordinate2DMake(elevation.lat, elevation.lng);
    _marker.title = _currentPlace.name;
    _marker.snippet = [NSString stringWithFormat:@"Address: %@\nElevation: %fm",_currentPlace.formattedAddress, elevation.elevation];
    _marker.map = _mapView;
    
    
    
    [_mapView animateToLocation:CLLocationCoordinate2DMake(elevation.lat, elevation.lng)];
    
}

-(void)elevationHttpClient:(ElevationHttpClient *)client didFailWithError:(NSError *)error {
    
}

#pragma mark - IBAction

-(IBAction)selectCurrentPlace:(id)sender {
    [self setCurrentPlace];
}

- (IBAction)pickPlace:(UIButton *)sender {
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(_currentPlace.coordinate.latitude + 0.001, _currentPlace.coordinate.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(_currentPlace.coordinate.latitude - 0.001, _currentPlace.coordinate.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place attributions %@", place.attributions.string);
            
            [self setPlaceOnMap:place];
        } else {
            NSLog(@"No place selected");
        }
        
        _placePicker = nil;
    }];
}




#pragma mark - Help Method

- (void) autocompleteDidSelectPlace:(GMSPlace*) place {
    [self setPlaceOnMap:place];
}

- (void) setPlaceOnMap : (GMSPlace*)place {
    _currentPlace = place;
    ElevationHttpClient * altitudeClient = [ElevationHttpClient sharedAltitudeHttpClient];
    altitudeClient.delegate = self;
    [altitudeClient getAltitudeAtCoordinate:place.coordinate];
}

- (void) setCurrentPlace {
    
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    
    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        /*
        for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
            GMSPlace* place = likelihood.place;
            NSLog(@"Current Place name %@ at likelihood %g", place.name, likelihood.likelihood);
            NSLog(@"Current Place address %@", place.formattedAddress);
            NSLog(@"Current Place attributions %@", place.attributions);
            NSLog(@"Current PlaceID %@", place.placeID);
        }*/
        
        GMSPlace * place = likelihoodList.likelihoods.firstObject.place;
        [self setPlaceOnMap:place];
        
    }];
}

@end
