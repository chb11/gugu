//
//  CB_RouteBottomView.h
//  gugu
//
//  Created by Mike Chen on 2019/4/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface CB_RouteBottomView : UIView
@property (nonatomic,assign) NSInteger currIndex;
@property (nonatomic,strong) NSArray *routes;

-(void)action_showPianHao:(BOOL)isShow;

@property (nonatomic,copy) void(^block_changeRoute)(NSInteger currindex);
@property (nonatomic,copy) void(^block_click_pianhao)(void);
@property (nonatomic,copy) void(^block_click_go)(void);

@end

NS_ASSUME_NONNULL_END
