//
//  CB_SearchHistoryView.h
//  gugu
//
//  Created by Mike Chen on 2019/3/30.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_SearchHistoryView : UIView

@property (weak, nonatomic) IBOutlet UIView *view_content;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_contentHeight;
@property (nonatomic,copy) void(^block_delete)(void);

@end

NS_ASSUME_NONNULL_END
