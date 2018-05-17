//
//  Record.h
//  iOS_2D_RecordPath
//
//  Created by PC on 15/8/3.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import <MAMapKit/MAConfig.h>
#import <Foundation/Foundation.h>
#import <MAMapKit/MATraceManager.h>

@import CoreLocation;

@interface AMapRouteRecord : NSObject
@property (nonatomic, readonly) NSArray<CLLocation *> *locations;
@property (nonatomic, readonly) NSArray<MATracePoint *> *tracedLocations;

- (NSString *)title;
- (NSString *)subTitle;

- (void)updateTracedLocations:(NSArray<MATracePoint *> *)tracedLocations;

- (void)addLocation:(CLLocation *)location;

- (CLLocationCoordinate2D *)coordinates;

- (NSInteger)numOfLocations;

- (CLLocation *)startLocation;

- (CLLocation *)endLocation;

- (CLLocationDistance)totalDistance;

/// 总共的时间可以写死  例如10秒（轨迹回放的时候 动画所需要的时间）
- (NSTimeInterval)totalDuration;

@end
