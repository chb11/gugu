//
//  CB_ReportCell.m
//  xhs
//
//  Created by Mike on 2019/8/26.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_ReportCell.h"

@implementation CB_ReportCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.lbl_title addlayerRadius:self.lbl_title.height/2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
