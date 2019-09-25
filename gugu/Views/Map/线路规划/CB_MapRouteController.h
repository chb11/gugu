//
//  CB_MapRouteController.h
//  gugu
//
//  Created by Mike Chen on 2019/4/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CB_MapRouteController : BaseViewController


@property (nonatomic,assign) CLLocationCoordinate2D startCoordinate;
@property (nonatomic,assign) CLLocationCoordinate2D endCoordinate;

//单聊 群聊
@property(nonatomic,assign)SSChatConversationType chatType;
//会话id
@property (nonatomic, strong) NSString *sessionId;

//名字
@property (nonatomic, strong) NSString *titleString;

@property (nonatomic,assign) BOOL isFromChat;
//是否组队导航
@property (nonatomic,assign) BOOL isGroupNavi;

//是否是群聊
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, strong) CB_MessageModel *model;
@property (nonatomic, strong) NSString *SendId;
@property (nonatomic,strong) CB_GroupModel *groupModel;
@property (nonatomic,strong) CB_FriendInfoModel *friendModel;
@property (nonatomic,assign) CLLocationCoordinate2D userCoordinate;

@end

NS_ASSUME_NONNULL_END
