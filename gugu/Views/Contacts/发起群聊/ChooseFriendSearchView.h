//
//  ChooseFriendSearchView.h
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChooseFriendSearchView : UIView
@property (weak, nonatomic) IBOutlet UITextField *txt_name;
@property (weak, nonatomic) IBOutlet UIButton *btn_search;
@property (weak, nonatomic) IBOutlet UIView *view_text;

@property (nonatomic,copy) void(^block_search)(NSString *text);

@end

NS_ASSUME_NONNULL_END
