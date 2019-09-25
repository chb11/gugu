//
//  CB_NaviMapView.h
//  gugu
//
//  Created by Mike Chen on 2019/5/25.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_NaviMapView : UIView

@property (nonatomic, strong) NSMutableArray *activityUsers;

@property (nonatomic,assign) NSInteger DriverRouteid;
@property (nonatomic,assign) CB_ROUTE_TYPE routeType;
@property (nonatomic,strong) AMapNaviRideManager *rideManager;
@property (nonatomic,strong) AMapNaviWalkManager *walkManager;
@property (nonatomic,assign) AMapNaviDrivingStrategy strategy;
@property (nonatomic,strong) AMapNaviPoint *startPoint;
@property (nonatomic,strong) AMapNaviPoint *endPoint;
@property (nonatomic,strong) NSString *currNaviInfo;
@property (nonatomic,strong) NSString *selectUserId;

@property (nonatomic,copy) void(^block_closeNavi)(void);

-(void)action_updateUserPosition;
-(void)action_startNavi;
-(void)action_closeNavi;

@end

NS_ASSUME_NONNULL_END
