//
//  CB_MyCardCell.m
//  gugu
//
//  Created by Mike Chen on 2019/5/26.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_MyCardCell.h"

@implementation CB_MyCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.view_conten.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
