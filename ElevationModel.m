//
//  ElevationModel2.m
//  XYElevation
//
//  Created by Xiaoqian Yang on 19/01/2017.
//  Copyright © 2017 XiaoqianYang. All rights reserved.
//

#import "ElevationModel.h"

@implementation ElevationModel
+ (JSONKeyMapper *) keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary: @ {
        @"elevation" : @"elevation",
        @"lat" : @"location.lat",
        @"lng" : @"location.lng"
    }];
    
}
@end

@implementation ResponseModel

@end
