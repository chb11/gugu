//
//  ContractListHeader.h
//  gugu
//
//  Created by Mike Chen on 2019/3/5.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContractListHeader : UIView

@property (weak, nonatomic) IBOutlet UIView *view_search;
@property (weak, nonatomic) IBOutlet UIView *view_newFriend;
@property (weak, nonatomic) IBOutlet UIView *view_myGroup;

@property (nonatomic,copy) void(^block_search)(void);
@property (nonatomic,copy) void(^block_new_friend)(void);
@property (nonatomic,copy) void(^block_my_group)(void);

@end

NS_ASSUME_NONNULL_END
