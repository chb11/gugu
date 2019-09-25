//
//  MineUserHeaderView.m
//  gugu
//
//  Created by Mike Chen on 2019/3/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "MineUserHeaderView.h"

@implementation MineUserHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
//    [self.img_header addlayerRadius:self.img_header.height/2];
    [self.btn_login addborderColor:[UIColor whiteColor] borderWith:1 layerRadius:5];
    [self.img_header addborderColor:[UIColor whiteColor] borderWith:2 layerRadius:self.img_header.height/2];
    self.constrain_totop.constant = StatusBarHeight+20;
}

-(void)setModel:(UserModel *)model{
    _model = model;
    if (model) {
        self.btn_photo.hidden = NO;
        self.img_header.hidden = NO;
        self.lbl_name.hidden = NO;
        self.lbl_phone.hidden = NO;
        self.btn_login.hidden = YES;
        [self.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
        self.lbl_name.text = model.UserName;
        self.lbl_phone.text = model.Phone;
    }else{
        self.btn_photo.hidden = YES;
        self.img_header.hidden = YES;
        self.lbl_name.hidden = YES;
        self.lbl_phone.hidden = YES;
        self.btn_login.hidden = NO;
    }
}

- (IBAction)action_clickHeader:(UIButton *)sender {
    if (self.block_clickHeader) {
        self.block_clickHeader();
    }
}

- (IBAction)action_login:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEED_LOGIN object:nil];
}
- (IBAction)action_setting:(id)sender {
    if (self.block_goSetting) {
        self.block_goSetting();
    }
}

@end
