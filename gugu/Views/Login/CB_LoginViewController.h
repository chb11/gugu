//
//  CB_LoginViewController.h
//  gugu
//
//  Created by Mike Chen on 2019/3/1.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LogInState) (BOOL isLogIN);

NS_ASSUME_NONNULL_BEGIN

@interface CB_LoginViewController : UIViewController
@property (copy, nonatomic) LogInState logState;

+ (CB_LoginViewController *)shareInstance;
-(void)close;
//是否已经登录校验
+(void)LogInStateCheckWithCtrl:(UIViewController *)viewCtr LogInSucess:(LogInState)logState;

@end

NS_ASSUME_NONNULL_END
