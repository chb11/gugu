//
//  NewFriendsCell.m
//  gugu
//
//  Created by Mike Chen on 2019/3/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "NewFriendsCell.h"

@implementation NewFriendsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.img_header addlayerRadius:self.img_header.height/2];
    [self.btn_accept addlayerRadius:4];
    [self.btn_regist addlayerRadius:4];
}

-(void)setModel:(CB_newFriendModel *)model{
    _model = model;
    
    [self.img_header sd_setImageWithURL:[NSURL URLWithString:model.ApplyUserHeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    self.lbl_reason.text = model.Reason;
    self.lbl_name.text = model.ApplyUserName;
    
}

- (IBAction)action_assept:(UIButton *)sender {
    if (self.block_accept) {
        self.block_accept(self.model);
    }
}

- (IBAction)action_regist:(UIButton *)sender {
    if (self.block_regist) {
        self.block_regist(self.model);
    }
}

@end
