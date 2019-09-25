//
//  CB_GroupMemberView.h
//  gugu
//
//  Created by Mike Chen on 2019/5/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_GroupMemberView : UIView

@property (nonatomic,strong) __block NSMutableArray *_dataSource;
@property (nonatomic,copy) void(^block_invite)(void);
@property (nonatomic,copy) void(^block_clickUser)(CB_GroupModel *model);

+(CGFloat)heightOfMemberCount:(NSInteger)totalCount;

@end

NS_ASSUME_NONNULL_END
