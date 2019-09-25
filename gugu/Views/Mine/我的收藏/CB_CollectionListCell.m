//
//  CB_CollectionListCell.m
//  gugu
//
//  Created by Mike Chen on 2019/5/26.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_CollectionListCell.h"

@interface CB_CollectionListCell()

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *lbl_msg;
@property (weak, nonatomic) IBOutlet UILabel *lbl_nickname;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_collectBrief;

@property (weak, nonatomic) IBOutlet UIView *view_voice_shadow;
@property (weak, nonatomic) IBOutlet UIView *view_voice;
@property (weak, nonatomic) IBOutlet UILabel *lbl_duration;
@property (weak, nonatomic) IBOutlet UIImageView *img_map;
@property (weak, nonatomic) IBOutlet UIImageView *img_photo;

@end

@implementation CB_CollectionListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.img addlayerRadius:self.img.height/2];
    [self.img_map addlayerRadius:self.img_map.height/2];
    [self.view_voice addlayerRadius:self.view_voice.height/2];
    // 阴影颜色
    self.view_voice_shadow.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    // 阴影偏移，默认(0, -3)
    self.view_voice_shadow.layer.shadowOffset = CGSizeMake(0,3);
    // 阴影透明度，默认0
    self.view_voice_shadow.layer.shadowOpacity = 0.5;
    // 阴影半径，默认3
    self.view_voice_shadow.layer.shadowRadius = self.view_voice_shadow.height/2;
  
}

-(void)setModel:(CB_MessageModel *)model{
    _model = model;
    
    self.view_voice.hidden = YES;
    self.view_voice_shadow.hidden = YES;
    self.img_map.hidden = YES;
    self.img_photo.hidden = YES;
    self.lbl_msg.hidden = YES;
    
    [self.img sd_setImageWithURL:[NSURL URLWithString:model.SendUserUrlURL]];
    
    self.img.contentMode = UIViewContentModeScaleAspectFill;
    if (model.MessageType == SSChatMessageTypeImage) {
        [self.img_photo sd_setImageWithURL:[NSURL URLWithString:model.FileUrlURL]];
        self.img_photo.hidden = NO;
    }else if(model.MessageType == SSChatMessageTypeMap){
        NSString *address = [[model.Message componentsSeparatedByString:@","] lastObject];
        self.lbl_msg.text = address;
        self.lbl_msg.hidden = NO;
        self.img_map.hidden = NO;
        [self.img_map sd_setImageWithURL:[NSURL URLWithString:model.FileUrlURL]];
        
    }else if(model.MessageType == SSChatMessageTypeVoice){
        self.view_voice.hidden = NO;
        self.view_voice_shadow.hidden = NO;
        self.lbl_duration.text = [NSString stringWithFormat:@"%.fs",model.Duration*0.001];
    }else if(model.MessageType == SSChatMessageTypeCard){
        CB_UserCardModel *cardmodel = [CB_UserCardModel modelWithJSON:model.Message];
        NSString *string= [NSString stringWithFormat:@"%@的[名片]\n%@",cardmodel.UserName,cardmodel.Phone];
        self.lbl_msg.text = string;
        self.lbl_msg.hidden = NO;
        
    }else{
        self.lbl_msg.text = model.Message;
        self.lbl_msg.hidden = NO;
    }
    
    
    self.lbl_nickname.text = model.SendName;
    self.lbl_time.text = model.PostDate;
    self.lbl_collectBrief.text = model.CollectName;
    
}


@end
