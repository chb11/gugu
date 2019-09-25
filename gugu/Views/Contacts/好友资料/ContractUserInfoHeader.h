//
//  ContractUserInfoHeader.h
//  gugu
//
//  Created by Mike Chen on 2019/3/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContractUserInfoHeader : UIView

@property (nonatomic,strong) CB_FriendInfoModel *model;

@property (weak, nonatomic) IBOutlet UIImageView *img_header;

@property (weak, nonatomic) IBOutlet UILabel *lbl_beizhu;
@property (weak, nonatomic) IBOutlet UILabel *lbl_nickname;
@property (weak, nonatomic) IBOutlet UILabel *lbl_guNum;
@property (weak, nonatomic) IBOutlet UILabel *lbl_phone;

@property (nonatomic,copy) void(^block_call)();

@end

NS_ASSUME_NONNULL_END
