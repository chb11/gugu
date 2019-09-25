//
//  NewFriendsCell.h
//  gugu
//
//  Created by Mike Chen on 2019/3/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewFriendsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img_header;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UIButton *btn_accept;
@property (weak, nonatomic) IBOutlet UIButton *btn_regist;
@property (weak, nonatomic) IBOutlet UILabel *lbl_reason;


@property (nonatomic,strong) CB_newFriendModel *model;
@property (nonatomic,copy) void(^block_accept)(CB_newFriendModel *model);
@property (nonatomic,copy) void(^block_regist)(CB_newFriendModel *model);

@end

NS_ASSUME_NONNULL_END
