//
//  SSChatBaseCell.m
//  SSChatView
//
//  Created by soldoros on 2018/10/9.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import "SSChatBaseCell.h"

@implementation SSChatBaseCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        // Remove touch delay for iOS 7
        for (UIView *view in self.subviews) {
            if([view isKindOfClass:[UIScrollView class]]) {
                ((UIScrollView *)view).delaysContentTouches = NO;
                break;
            }
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self initSSChatCellUserInterface];
    }
    return self;
}


-(void)initSSChatCellUserInterface{
    
    
    // 2、创建头像
    _mHeaderImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _mHeaderImgBtn.backgroundColor =  [UIColor brownColor];
    _mHeaderImgBtn.tag = 10;
    _mHeaderImgBtn.userInteractionEnabled = YES;
    [self.contentView addSubview:_mHeaderImgBtn];
    _mHeaderImgBtn.clipsToBounds = YES;
    [_mHeaderImgBtn addTarget:self action:@selector(buttonHeadPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //创建时间
    _mMessageTimeLab = [UILabel new];
    _mMessageTimeLab.bounds = CGRectMake(0, 0, SSChatTimeWidth, SSChatTimeHeight);
    _mMessageTimeLab.top = SSChatTimeTop;
    _mMessageTimeLab.centerX = SCREEN_Width*0.5;
    [self.contentView addSubview:_mMessageTimeLab];
    _mMessageTimeLab.textAlignment = NSTextAlignmentCenter;
    _mMessageTimeLab.font = [UIFont systemFontOfSize:SSChatTimeFont];
    _mMessageTimeLab.textColor = [UIColor whiteColor];
    _mMessageTimeLab.backgroundColor = [UIColor clearColor];
    _mMessageTimeLab.clipsToBounds = YES;
    _mMessageTimeLab.layer.cornerRadius = 3;
    
    
    //背景按钮
    _mBackImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _mBackImgButton.backgroundColor =  [UIColor clearColor];
    _mBackImgButton.tag = 50;
    [self.contentView addSubview:_mBackImgButton];
    [_mBackImgButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
    longGes.minimumPressDuration = 0.5;
    
    [_mBackImgButton addGestureRecognizer:longGes];
}


-(BOOL)canBecomeFirstResponder{
    return YES;
}


-(void)setLayout:(SSChatMessagelLayout *)layout{
    _layout = layout;
    
    _mMessageTimeLab.hidden = !layout.message.showTime;
    _mMessageTimeLab.text = layout.message.messageTime;
    [_mMessageTimeLab sizeToFit];
    _mMessageTimeLab.height = SSChatTimeHeight;
    _mMessageTimeLab.width += 20;
    _mMessageTimeLab.backgroundColor = makeColorRgb(220, 220, 220);
    if (layout.message.messageFrom == SSChatMessageFromMe) {
        _mMessageTimeLab.centerX = SCREEN_WIDTH- _mMessageTimeLab.width/2-10;
    }else{
        _mMessageTimeLab.centerX = 10+_mMessageTimeLab.width/2;
    }
//    _mMessageTimeLab.centerX = SCREEN_Width*0.5;
    _mMessageTimeLab.top = SSChatTimeTop;
    
    
    self.mHeaderImgBtn.frame = layout.headerImgRect;
    [self.mHeaderImgBtn sd_setImageWithURL:[NSURL URLWithString:layout.message.headerImgurl] forState:UIControlStateNormal];
    self.mHeaderImgBtn.layer.cornerRadius = self.mHeaderImgBtn.height*0.5;

    
}


//消息按钮
-(void)buttonPressed:(UIButton *)sender{
    if (self.block_messageClick) {
        self.block_messageClick(self.layout);
    }
    NSLog(@"点击消息");
}

-(void)buttonHeadPressed:(UIButton *)sender{
 
    NSLog(@"点击头像");
    if (self.block_headClick) {
        self.block_headClick(self.layout);
    }
}

-(void)longAction:(UILongPressGestureRecognizer *)gesture{
    
    
    if (gesture.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    NSLog(@"长按消息");
    if (self.block_messageLongAction) {
        self.block_messageLongAction(self.layout);
    }
}

@end
