//
//  MyGroupController.h
//  gugu
//
//  Created by Mike Chen on 2019/3/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyGroupController : BaseViewController
@property (nonatomic,strong) MAPointAnnotation *annotation;
//分享名片到组
@property (nonatomic,assign) BOOL isChooseForShareCard;
@property (nonatomic,strong) CB_FriendInfoModel *friendInfoModel;

@property (nonatomic,strong) CB_MessageModel *messageModel;
@property (nonatomic,copy) void(^block_chooseConvertion)(NSString *sendid,id modelObject);
@end

NS_ASSUME_NONNULL_END
