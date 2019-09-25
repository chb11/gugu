//
//  DeviceDefine.h
//  MixDemo
//
//  Created by douyinbao on 2018/5/14.
//  Copyright © 2018年 William. All rights reserved.
//

#ifndef DeviceDefine_h
#define DeviceDefine_h

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_RECT  CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

#define FONT(font) [UIFont systemFontOfSize:(font)]
#define WeakSelf(o)  __weak typeof(o) o##Weak = o;

#define iphone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define iphone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iphone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iphonePlus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_x ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define NavBarHeight (iPhone_x?88:64)
#define BottomPadding (iPhone_x?34:0)
#define StatusBarHeight (iPhone_x?35:20)

#define IS_IOS_8  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPAD   ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)


typedef void(^SelectClicked) (NSInteger tag);

typedef void(^SliderValueChangeAction) (CGFloat currentValue);

#endif /* DeviceDefine_h */
