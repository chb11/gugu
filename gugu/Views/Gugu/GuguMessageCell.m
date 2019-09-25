//
//  GuguMessageCell.m
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "GuguMessageCell.h"

@implementation GuguMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.img_header addlayerRadius: self.img_header.height/2];
    [self.view_count addlayerRadius:self.view_count.height/2];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setModel:(CB_MessageModel *)model{
    _model = model;
    if (model.IsGroup||model.GroupId.length>0) {
        [self.img_header sd_setImageWithURL:[NSURL URLWithString:model.GroupHeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
        self.lbl_title.text = model.GroupName;
    }else{
        [self.img_header sd_setImageWithURL:[NSURL URLWithString:model.GuUserHeadURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
        self.lbl_title.text = model.GuUserName;
    }

    if (model.IsGroup) {
        
        if ([model.Abbr containsString:@":"]) {
            self.lbl_brief.text = model.Abbr;
        }else{
            if ([model.GuUserName isEqualToString:[UserModel shareInstance].UserName]) {
                self.lbl_brief.text = [NSString stringWithFormat:@"我:%@",model.Abbr];
            }else{
                self.lbl_brief.text = [NSString stringWithFormat:@"%@:%@",model.GuUserName,model.Abbr];
            }
        }
    }else{
        self.lbl_brief.text = model.Abbr;
    }


    NSString *extractedExpr = [AppGeneral timePublish:model.PostDate];
    self.lbl_time.text = extractedExpr;
    if (model.NoReadNum>0) {
        if (model.NoReadNum>99) {
            self.lbl_isread.text = @"99+";
        }else{
            self.lbl_isread.text = [NSString stringWithFormat:@"%ld",model.NoReadNum];
        }
        self.lbl_isread.hidden = NO;
        self.view_count.hidden = NO;
    }else{
        self.lbl_isread.text = @"";
        self.lbl_isread.hidden = YES;
        self.view_count.hidden = YES;
    }
    
    
}

@end
