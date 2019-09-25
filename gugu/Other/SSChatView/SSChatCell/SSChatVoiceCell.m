//
//  SSChatVoiceCell.m
//  SSChatView
//
//  Created by soldoros on 2018/10/15.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import "SSChatVoiceCell.h"

@implementation
SSChatVoiceCell


-(void)initSSChatCellUserInterface{
    
    [super initSSChatCellUserInterface];
    
    
    _voiceBackView = [[UIView alloc]init];
    [self.mBackImgButton addSubview:self.voiceBackView];
    _voiceBackView.userInteractionEnabled = YES;
    _voiceBackView.backgroundColor = [UIColor clearColor];
    
    
    _mTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
    _mTimeLab.textAlignment = NSTextAlignmentCenter;
    _mTimeLab.font = [UIFont systemFontOfSize:SSChatVoiceTimeFont];
    _mTimeLab.userInteractionEnabled = YES;
    _mTimeLab.backgroundColor = [UIColor clearColor];

    
    _mVoiceImg = [[UIImageView alloc]initWithFrame:CGRectMake(80, 5, 20, 20)];
    _mVoiceImg.userInteractionEnabled = YES;
    _mVoiceImg.animationDuration = 1;
    _mVoiceImg.animationRepeatCount = 0;
    _mVoiceImg.backgroundColor = [UIColor clearColor];
    
    
//    _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    self.indicator.center=CGPointMake(80, 15);
    
    self.redFlag = [[UILabel alloc] initWithFrame:CGRectMake(self.mBackImgButton.mj_x+self.mBackImgButton.mj_w+8, self.mBackImgButton.centerY-4, 8, 8)];
    [self.redFlag addlayerRadius:4];
    self.redFlag.tag = 5555;
    self.redFlag.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.redFlag];
//    [_voiceBackView addSubview:_indicator];
    [_voiceBackView addSubview:_mVoiceImg];
    [_voiceBackView addSubview:_mTimeLab];
    
    
    //整个列表只能有一个语音处于播放状态 通知其他正在播放的语音停止
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
    
}


-(void)setLayout:(SSChatMessagelLayout *)layout{
    [super setLayout:layout];
    
    UIImage *image = [UIImage imageNamed:layout.message.backImgString];
    image = [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
    
    self.mBackImgButton.frame = layout.backImgButtonRect;
    [self.mBackImgButton setBackgroundImage:image forState:UIControlStateNormal];
    if (![self.layout.message.model.SendUserId isEqualToString:[UserModel shareInstance].Guid]) {
        self.redFlag.frame = CGRectMake(self.mBackImgButton.mj_x+self.mBackImgButton.mj_w+8, self.mBackImgButton.centerY-4, 8, 8);
        self.redFlag.hidden = layout.message.model.ReadState;
    }else{
        self.redFlag.hidden = YES;
    }

    _mVoiceImg.image = layout.message.voiceImg;
    _mVoiceImg.animationImages = layout.message.voiceImgs;
    _mVoiceImg.frame = layout.voiceImgRect;
    _mTimeLab.text = layout.message.voiceTime;
    _mTimeLab.frame = layout.voiceTimeLabRect;
}

//播放音频 暂停音频
-(void)buttonPressed:(UIButton *)sender{
    if(!_contentVoiceIsPlaying){
        if ([self.layout.message.model.SendUserId isEqualToString:[UserModel shareInstance].Guid]) {
            if (self.block_readVoice) {
                self.block_readVoice(nil);
            }
        }else{
            if (self.layout.message.model.ReadState) {
                if (self.block_readVoice) {
                    self.block_readVoice(nil);
                }
            }else{
                if (self.block_readVoice) {
                    self.block_readVoice(self.layout);
                }
            }
        }
        
        self.redFlag.hidden = YES;
        if (self.layout.message.voice.length>0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            self.contentVoiceIsPlaying = YES;
            [self.mVoiceImg startAnimating];
            self.audio = [UUAVAudioPlayer sharedInstance];
            self.audio.delegate = self;
            [self.audio playSongWithData:self.layout.message.voice];
        }else{
            [[NetWorkConnect manager] downloadFileWithUrl:self.layout.message.voiceRemotePath andFileName:@"chat_voice" downloadSuccess:^(NSURL *filePath, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
                self.contentVoiceIsPlaying = YES;
                [self.mVoiceImg startAnimating];
                self.audio = [UUAVAudioPlayer sharedInstance];
                self.audio.delegate = self;
                [self.audio playSongWithUrl:filePath.path];
            }];
        }
    }else{
        if (self.block_readVoice) {
            self.block_readVoice(nil);
        }
        [self UUAVAudioPlayerDidFinishPlay];
    }
}

//播放显示开始加载
- (void)UUAVAudioPlayerBeiginLoadVoice{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicator startAnimating];
    });
}

////开启红外线感应
- (void)UUAVAudioPlayerBeiginPlay{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        [self.indicator stopAnimating];
    });
}
//
////关闭红外线感应
- (void)UUAVAudioPlayerDidFinishPlay{
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        [self.mVoiceImg stopAnimating];
        self.contentVoiceIsPlaying = NO;
        [[UUAVAudioPlayer sharedInstance] stopSound];
//    });
}

@end
