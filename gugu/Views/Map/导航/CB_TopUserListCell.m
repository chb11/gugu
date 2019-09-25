//
//  CB_TopUserListCell.m
//  gugu
//
//  Created by Mike Chen on 2019/6/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_TopUserListCell.h"

@implementation CB_TopUserListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.img_header addlayerRadius:25];
}

@end
