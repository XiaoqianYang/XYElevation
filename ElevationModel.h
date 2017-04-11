//
//  ElevationModel2.h
//  XYElevation
//
//  Created by Xiaoqian Yang on 19/01/2017.
//  Copyright © 2017 XiaoqianYang. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol ElevationModel;

@interface ElevationModel : JSONModel
@property (nonatomic) double elevation;
@property (nonatomic) double lat;
@property (nonatomic) double lng;

+ (JSONKeyMapper *) keyMapper;
@end

@interface ResponseModel : JSONModel
@property (nonatomic) NSArray <ElevationModel> * results;
@property (nonatomic) NSString * status;
@end


