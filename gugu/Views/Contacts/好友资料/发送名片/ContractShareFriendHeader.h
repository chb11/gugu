//
//  ContractShareFriendHeader.h
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContractShareFriendHeader : UIView



@property (nonatomic,copy) void(^block_chooseGroup)(void);

@end

NS_ASSUME_NONNULL_END
