//
//  AltitudeHttpClient.h
//  XYElevation
//
//  Created by Xiaoqian Yang on 18/01/2017.
//  Copyright © 2017 XiaoqianYang. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>

@protocol ElevationHttpClientDelegate;

@interface ElevationHttpClient : AFHTTPSessionManager
@property (nonatomic, weak) id<ElevationHttpClientDelegate> delegate;

+ (ElevationHttpClient *)sharedAltitudeHttpClient;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)getAltitudeAtCoordinate:(CLLocationCoordinate2D )coordinate;

@end

@protocol ElevationHttpClientDelegate <NSObject>

@optional
-(void)elevationHttpClient:(ElevationHttpClient *)client didUpdateWithElevation:(id)res;
-(void)elevationHttpClient:(ElevationHttpClient *)client didFailWithError:(NSError *)error;
@end
