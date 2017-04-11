//
//  AltitudeHttpClient.m
//  XYElevation
//
//  Created by Xiaoqian Yang on 18/01/2017.
//  Copyright © 2017 XiaoqianYang. All rights reserved.
//

#import "ElevationHttpClient.h"
#import "ElevationKeys.h"

@implementation ElevationHttpClient

+ (ElevationHttpClient *)sharedAltitudeHttpClient {
    static ElevationHttpClient * _altitudeHttpClient = nil;
    static dispatch_once_t oncetoken;
    _dispatch_once(&oncetoken, ^{
        _altitudeHttpClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:GoogleMapAPIURL]];
    });
    return _altitudeHttpClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    };
    
    return self;
}

- (void)getAltitudeAtCoordinate:(CLLocationCoordinate2D )coordinate {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"locations"] = [NSString stringWithFormat:@"%f,%f",coordinate.latitude, coordinate.longitude];
    parameters[@"key"] = googleAPIKey;
        
    [self GET:@"/maps/api/elevation/json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(elevationHttpClient:didUpdateWithElevation:)]) {
            [self.delegate elevationHttpClient:self didUpdateWithElevation:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(elevationHttpClient:didFailWithError:)]) {
            [self.delegate elevationHttpClient:self didFailWithError:error];
        }
    }];

}

// to delete
- (void)getAltitudeAtCoordinate2:(CLLocationCoordinate2D )coordinate {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"locations"] = [NSString stringWithFormat:@"%f%f",coordinate.latitude, coordinate.longitude];
    parameters[@"key"] = googleAPIKey;
    
    NSString * urlString = [NSString stringWithFormat:@"/maps/api/elevation/json?locations=%f,%f&key=%@",coordinate.latitude, coordinate.longitude,googleAPIKey];
    
    [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(altitudeHttpClient:didUpdateWithClient:)]) {
            [self.delegate elevationHttpClient:self didUpdateWithElevation:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(altitudeHttpClient:didFailWithError:)]) {
            [self.delegate elevationHttpClient:self didFailWithError:error];
        }
    }];
    
}
@end
