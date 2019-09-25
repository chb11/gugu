//
//  CB_UserContactCell.m
//  gugu
//
//  Created by Mike Chen on 2019/3/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_UserContactCell.h"

@implementation CB_UserContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.img_header addlayerRadius:self.img_header.height/2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(CB_ContactModel *)model{
    _model = model;
    self.lbl_name.text = model.UserName;
    [self.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    
}

@end
