//
//  ContractUserInfoHeader.m
//  gugu
//
//  Created by Mike Chen on 2019/3/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ContractUserInfoHeader.h"

@implementation ContractUserInfoHeader

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self.img_header addlayerRadius:self.img_header.height/2];
    
}

- (void)setModel:(CB_FriendInfoModel *)model{
    _model = model;
    
    [self.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    self.lbl_beizhu.text = model.MemoName;
    self.lbl_nickname.text = [NSString stringWithFormat:@"昵称: %@",model.NickName];
    self.lbl_guNum.text = [NSString stringWithFormat:@"咕咕号: %@",model.GuNum];
    self.lbl_phone.text = model.Phone;
}
- (IBAction)action_phonecall:(id)sender {
    if (self.block_call) {
        self.block_call();
    }
}

@end
