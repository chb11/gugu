//
//  CB_ActivityAnnotationView.m
//  gugu
//
//  Created by Mike Chen on 2019/6/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_ActivityAnnotationView.h"
#import "FFDropDownMenuTriangleView.h"

@interface CB_ActivityAnnotationView ()

@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *img_paopao;
@property (weak, nonatomic) IBOutlet UIImageView *img_header;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_paopaoH;

@property (nonatomic,strong) FFDropDownMenuTriangleView *triangleView;

@end

@implementation CB_ActivityAnnotationView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.img_header addlayerRadius:20];
    [self.img_paopao addlayerRadius:25];
    self.layer.masksToBounds = YES;
}


-(void)updateFrame{
    self.username.text = self.name;
    [self.img_header sd_setImageWithURL:[NSURL URLWithString:self.img_url]];
    if (!self.isShowPaoPao) {
        self.frame = CGRectMake(0, 0, 40, 40);
    }else{
        self.lbl_title.text = self.title;
        CGFloat width = [AppGeneral textWidth:self.title andTitleFont:[UIFont systemFontOfSize:15]];
        self.frame = CGRectMake(0, -30, width+16, 40+10+50);
        self.triangleView = [[FFDropDownMenuTriangleView alloc] initWithFrame:CGRectMake((self.frame.size.width-16)/2, self.height-40-10, 16, 10)];
        self.triangleView.backgroundColor = [UIColor clearColor];
        self.triangleView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        self.triangleView.triangleColor = [UIColor whiteColor];
        [self addSubview:self.triangleView];
    }
    
    
}

    
@end
