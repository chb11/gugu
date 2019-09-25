//
//  CB_MessageTransHeader.h
//  gugu
//
//  Created by Mike Chen on 2019/4/30.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_MessageTransHeader : UIView

@property (nonatomic,copy) void(^block_chooseFriend)(void);
@property (nonatomic,copy) void(^block_chooseGroup)(void);

@end

NS_ASSUME_NONNULL_END
