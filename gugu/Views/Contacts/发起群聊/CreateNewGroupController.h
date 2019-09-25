//
//  CreateNewGroupController.h
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "BaseViewController.h"
#import "POIAnnotation.h"
NS_ASSUME_NONNULL_BEGIN

@interface CreateNewGroupController : BaseViewController

@property (nonatomic,strong) MAPointAnnotation *annotation;
@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,strong) CB_MessageModel *messageModel;
@property (nonatomic,copy) void(^block_chooseConvertion)(NSString *sendid,id modelObject);
@end

NS_ASSUME_NONNULL_END
