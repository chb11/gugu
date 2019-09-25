//
//  CB_RegistViewController.h
//  gugu
//
//  Created by Mike Chen on 2019/3/1.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SUBMIT_TYPE) {
    SUBMIT_TYPE_REGIST = 0,
    SUBMIT_TYPE_FORGETPWD,
    
};

NS_ASSUME_NONNULL_BEGIN

@interface CB_RegistViewController : UIViewController

@property (nonatomic,assign) SUBMIT_TYPE submitType;

@end

NS_ASSUME_NONNULL_END
