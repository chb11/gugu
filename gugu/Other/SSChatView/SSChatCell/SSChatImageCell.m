//
//  SSChatImageCell.m
//  SSChatView
//
//  Created by soldoros on 2018/10/12.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import "SSChatImageCell.h"

@implementation SSChatImageCell

-(void)initSSChatCellUserInterface{
    
    [super initSSChatCellUserInterface];
    
    self.mImgView = [UIImageView new];
    self.mImgView.layer.cornerRadius = 5;
    self.mImgView.layer.masksToBounds  = YES;
    self.mImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.mImgView.backgroundColor = [UIColor whiteColor];
    [self.mBackImgButton addSubview:self.mImgView];
    
}


-(void)setLayout:(SSChatMessagelLayout *)layout{
    [super setLayout:layout];
    UIImage *image = nil;
    if (layout.message.image) {
        image = layout.message.image;
    }else{
        image = [UIImage imageNamed:layout.message.backImgString];
    }
    
    image = [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
    self.mBackImgButton.frame = layout.backImgButtonRect;
    [self.mBackImgButton setBackgroundImage:image forState:UIControlStateNormal];
    
    
    self.mImgView.frame = self.mBackImgButton.bounds;
    
    if (layout.message.image) {
        self.mImgView.image = layout.message.image;
    }else{
         [self.mImgView sd_setImageWithURL:[NSURL URLWithString:layout.message.model.FileUrlURL]];
    }
//    
//    if (self.layout.message.model.FileUrlURL) {
//        [self.mImgView sd_setImageWithURL:[NSURL URLWithString:layout.message.model.FileUrlURL]];
//    }else{
//        self.mImgView.image = layout.message.image;
//    }

    self.mImgView.contentMode = layout.message.contentMode;
    
    
    //给图片设置一个描边 描边跟背景按钮的气泡图片一样
    UIImageView *btnImgView = [[UIImageView alloc]initWithImage:image];
    btnImgView.frame = CGRectInset(self.mImgView.frame, 0.0f, 0.0f);
    self.mImgView.layer.mask = btnImgView.layer;
    
}


//点击展开图片
-(void)buttonPressed:(UIButton *)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(SSChatImageVideoCellClick:layout:)]){
        [self.delegate SSChatImageVideoCellClick:self.indexPath layout:self.layout];
    }
}

@end

