//
//  CB_ContractnewHeader.h
//  gugu
//
//  Created by Mike Chen on 2019/6/10.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_ContractnewHeader : UIView

@property (weak, nonatomic) IBOutlet UIView *view_top;
@property (weak, nonatomic) IBOutlet UIView *view_content;

@property (nonatomic,copy) void(^block_newFriend)(void);
@property (nonatomic,copy) void(^block_group)(void);
@property (nonatomic,copy) void(^block_addFriend)(void);
@property (nonatomic,copy) void(^block_search)(void);

@end

NS_ASSUME_NONNULL_END
