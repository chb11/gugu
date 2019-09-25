//
//  ChooseFriendForGroupCell.m
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ChooseFriendForGroupCell.h"

@implementation ChooseFriendForGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.img_header addlayerRadius:self.img_header.height/2];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFriendModel:(CB_FriendModel *)friendModel{
    _friendModel = friendModel;
    [self.img_header sd_setImageWithURL:[NSURL URLWithString:friendModel.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    self.lbl_name.text = friendModel.FriendUserName;
    
}

@end
