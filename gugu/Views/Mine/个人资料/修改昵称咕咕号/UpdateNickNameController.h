//
//  UpdateNickNameController.h
//  gugu
//
//  Created by Mike Chen on 2019/3/3.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, USERINFO_UPDATETYPE) {
    USERINFO_UPDATETYPE_NICKNAME = 0,
    USERINFO_UPDATETYPE_GUNUM ,
};

@interface UpdateNickNameController : BaseViewController

@property (nonatomic,assign) USERINFO_UPDATETYPE updateType;

@end

NS_ASSUME_NONNULL_END
