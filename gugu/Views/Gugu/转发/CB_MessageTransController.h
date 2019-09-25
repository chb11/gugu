//
//  CB_MessageTransController.h
//  gugu
//
//  Created by Mike Chen on 2019/4/30.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CB_MessageTransController : BaseViewController

@property (nonatomic,strong) MAPointAnnotation *annotation;

@property (nonatomic,strong) CB_MessageModel *model;

@property (nonatomic,copy) void(^block_chooseConvertion)(NSString *sendid,id modelObject);

@end

NS_ASSUME_NONNULL_END
