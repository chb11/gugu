//
//  CB_MapBottomView.h
//  gugu
//
//  Created by Mike Chen on 2019/3/25.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_MapBottomView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (nonatomic,copy) void(^block_searchAround)(void);
@property (nonatomic,copy) void(^block_goToThere)(void);
@property (nonatomic,copy) void(^block_showResultList)(void);
@property (weak, nonatomic) IBOutlet UIButton *btn_shangla;

-(void)action_show;
-(void)action_hide;

@end

NS_ASSUME_NONNULL_END
