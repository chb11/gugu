//
//  CB_PianHaoView.h
//  gugu
//
//  Created by Mike Chen on 2019/4/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_PianHaoView : UIView

@property (nonatomic,copy) void(^block_choosePianHao)(AMapNaviDrivingStrategy strategy);

- (AMapNaviDrivingStrategy)strategyWithIsMultiple:(BOOL)isMultiple;

@end

NS_ASSUME_NONNULL_END
