//
//  CB_TopUserListView.h
//  gugu
//
//  Created by Mike Chen on 2019/6/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_TopUserListView : UIView

@property (nonatomic,strong) __block NSMutableArray *_dataSource;
@property (nonatomic,copy) void(^block_clickuser)(CB_MessageModel *model);

@end

NS_ASSUME_NONNULL_END
