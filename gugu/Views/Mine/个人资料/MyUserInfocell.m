//
//  MyUserInfocell.m
//  gugu
//
//  Created by Mike Chen on 2019/3/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "MyUserInfocell.h"

@implementation MyUserInfocell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.img_header addlayerRadius:self.img_header.height/2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
