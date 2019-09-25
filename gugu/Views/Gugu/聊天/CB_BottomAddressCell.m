//
//  CB_BottomAddressCell.m
//  gugu
//
//  Created by Mike Chen on 2019/6/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_BottomAddressCell.h"

@implementation CB_BottomAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.img_header addlayerRadius:self.img_header.height/2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
