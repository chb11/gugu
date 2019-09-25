//
//  CB_BusRouteView.h
//  gugu
//
//  Created by Mike Chen on 2019/6/10.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_BusRouteView : UIView

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,copy) void(^block_choosebusLine)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
