//
//  UITabBar+Badge.h
//  VoicePackage
//
//  Created by douyinbao on 2018/10/27.
//  Copyright © 2018年 douyinbao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (Badge)

- (void)showBadgeOnItemIndex:(int)index;   //显示小红点

- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点


@end

NS_ASSUME_NONNULL_END
