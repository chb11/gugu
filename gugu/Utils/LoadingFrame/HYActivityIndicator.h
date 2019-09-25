//
//  HYActivityIndicator.h
//  等待框添加与删除类
//
//  Created by douyinbao 14-5-12.
//

#import <Foundation/Foundation.h>

@interface HYActivityIndicator : NSObject

//打开等待指示框 页面默认可以点击
+ (void)startActivityAnimation:(UIView *)view;

//打开等待指示框 页面是否可以点击啊
+ (void)startActivityAnimation:(UIView *)view userInteractionEnable:(BOOL)enable;

//停止等待指示框
+ (void)stopActivityAnimation;

//判断等待框是否正在显示
+ (BOOL)isAnimating;
@end
