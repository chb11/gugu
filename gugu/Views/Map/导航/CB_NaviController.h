//
//  CB_NaviController.h
//  gugu
//
//  Created by Mike Chen on 2019/5/26.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CB_NaviController : BaseViewController

@property (nonatomic,assign) CB_ROUTE_TYPE routeType;
@property (nonatomic,assign) AMapNaviDrivingStrategy strategy;
@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, strong) AMapNaviRideManager *rideManager;
@property (nonatomic, strong) AMapNaviWalkManager *walkManager;
@property (nonatomic,assign) NSInteger DriverouteID;
//单聊 群聊
@property(nonatomic,assign)SSChatConversationType chatType;
//会话id
@property (nonatomic, strong) NSString *sessionId;

//名字
@property (nonatomic, strong) NSString *titleString;

//是否是群聊
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, strong) CB_MessageModel *model;
@property (nonatomic, strong) NSString *SendId;
@property (nonatomic,strong) CB_GroupModel *groupModel;
@property (nonatomic,strong) CB_FriendInfoModel *friendModel;
@property (nonatomic,assign) CLLocationCoordinate2D userCoordinate;


@property (nonatomic,assign) BOOL isFromChat;
@property (nonatomic,assign) BOOL isGroupNavi;

@end

NS_ASSUME_NONNULL_END
