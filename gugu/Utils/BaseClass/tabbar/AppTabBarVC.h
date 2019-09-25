//
//  AppTabBarVC.h
//  XiaXuan
//
//  Created by JonyHan on 14/12/8.
//  Copyright (c) 2014年 JonyHan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppTabBarVC : UITabBarController<UIGestureRecognizerDelegate>

-(void)changeIndex:(NSInteger)selectIndex;

@end
