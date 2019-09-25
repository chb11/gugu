//
//  HYActivityIndicator.m
//  网络加载等待框
//
//  Created by douyinbao on 14-5-12.
//

#import "HYActivityIndicator.h"
#import "DDIndicator.h"

static DDIndicator *circleLoadingView = nil;
static UIView *circleLoadingBgView = nil;
static UIActivityIndicatorView * activity = nil;
@implementation HYActivityIndicator

//打开等待指示框 页面默认可以点击
+ (void)startActivityAnimation:(UIView *)view
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [HYActivityIndicator startActivityAnimation:view userInteractionEnable:NO];
    });
    
    //10秒后停止
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HYActivityIndicator stopActivityAnimation];
    });
    
}

//打开等待指示框
+ (void)startActivityAnimation:(UIView *)view userInteractionEnable:(BOOL)enable
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!activity) {
            circleLoadingBgView = [[UIView alloc] initWithFrame:view.bounds];
            circleLoadingBgView.backgroundColor = [UIColor clearColor];
            activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];//指定进度轮的大小
            [activity setCenter:CGPointMake(160, 140)];//指定进度轮中心点
            [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
            [activity setCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-40)];
            activity.color = [UIColor darkGrayColor];
            [circleLoadingBgView addSubview:activity];
        }
        
        [view addSubview:circleLoadingBgView];
        [activity startAnimating];
        circleLoadingBgView.userInteractionEnabled = !enable;
    });
    
}

//停止等待指示框
+ (void)stopActivityAnimation
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        circleLoadingBgView.superview.userInteractionEnabled = YES;
        [activity stopAnimating];
        [activity removeFromSuperview];
        activity = nil;
        [circleLoadingBgView removeFromSuperview];
        circleLoadingBgView = nil;
    });
    
}

//判断等待框是否正在显示
+ (BOOL)isAnimating
{
    return activity.superview;
}
@end
