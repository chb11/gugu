//
//  SSSearchmapView.h
//  gugu
//
//  Created by Mike Chen on 2019/5/22.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CB_MapKeywordView.h"
NS_ASSUME_NONNULL_BEGIN

@interface SSSearchmapView : UIView

@property (nonatomic,strong) CB_MapKeywordView *keywordView;

@property (nonatomic,copy) void(^block_chooseAddress)(MAPointAnnotation *annotaion);

@property (nonatomic,copy) void(^block_userCount)(NSInteger count);

-(void)action_updateUserPositionWith:(CB_MessageModel *)msgModel;

@end

NS_ASSUME_NONNULL_END
