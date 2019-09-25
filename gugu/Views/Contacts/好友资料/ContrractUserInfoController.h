//
//  ContrractUserInfoController.h
//  gugu
//
//  Created by Mike Chen on 2019/3/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContrractUserInfoController : BaseViewController

//是否从单聊进来
@property (nonatomic,assign) BOOL isFromChatSignal;
@property (nonatomic,assign) BOOL isFromGroup;
@property (nonatomic,strong) CB_FriendModel *friendModel;

@end

NS_ASSUME_NONNULL_END
