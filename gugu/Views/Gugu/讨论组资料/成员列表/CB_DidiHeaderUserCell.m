//
//  CB_DidiHeaderUserCell.m
//  xhs
//
//  Created by Mike Chen on 2019/4/23.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_DidiHeaderUserCell.h"

@interface CB_DidiHeaderUserCell ()

@property (weak, nonatomic) IBOutlet UIView *view_header;



@end

@implementation CB_DidiHeaderUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.view_header addlayerRadius:5];
}



@end
