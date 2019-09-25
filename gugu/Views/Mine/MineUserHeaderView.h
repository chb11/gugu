//
//  MineUserHeaderView.h
//  gugu
//
//  Created by Mike Chen on 2019/3/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineUserHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *img_header;

@property (weak, nonatomic) IBOutlet UILabel *lbl_name;

@property (weak, nonatomic) IBOutlet UIButton *btn_photo;
@property (weak, nonatomic) IBOutlet UILabel *lbl_phone;
@property (weak, nonatomic) IBOutlet UIButton *btn_login;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_totop;
@property (nonatomic,strong) UserModel *model;

@property (nonatomic,copy) void(^block_clickLogin)(void);
@property (nonatomic,copy) void(^block_clickHeader)(void);
@property (nonatomic,copy) void(^block_goSetting)(void);
@end

NS_ASSUME_NONNULL_END
