//
//  CyActionSheet.m
//  ListenSpeak
//
//  Created by BingQiLin on 16/7/12.
//  Copyright © 2016年 BingQiLin. All rights reserved.
//

#import "CyActionSheet.h"
#define ViewTag  30004

@interface CyActionSheet ()
@property (nonatomic, copy) ShowActionSheetCallBack callBack;

@end

@implementation CyActionSheet
{
    NSString *_title;
    NSString * _cancelButton;
    NSArray * _otherButtons;
    UIView * _viewBottom;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClicked)];
    [self addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeFromeWindow) name:NOTIFICATION_GO_TO_BG object:nil];
}

-(void)removeFromeWindow
{
    [CyActionSheet DisMiss];
}

-(void)tapClicked
{
    if (_callBack) {
        _callBack(@"取消");
    }
    [self hiddenShareView];
}

-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString * )cancelButton otherButtonTitles:(NSArray *)buttons
{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];

    _title =title;
    _cancelButton = cancelButton;
    _otherButtons = buttons;
    self.tag = ViewTag;
    [self createButtos];
    [self awakeFromNib];
    return self;
}

+(void)DisMiss
{
    UIView * view =  [[UIApplication sharedApplication] keyWindow];
    UIView * shareOld = [view viewWithTag:ViewTag];
    [shareOld removeFromSuperview];
}

-(void)showActionSheet:(ShowActionSheetCallBack)callBack
{
    UIView * view =  [[UIApplication sharedApplication] keyWindow];
    UIView * shareOld = [view viewWithTag:ViewTag];
    [shareOld removeFromSuperview];
    [view addSubview:self];
    self.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.alpha = 1;
    self.callBack = callBack;
    [UIView animateWithDuration:0.30f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _viewBottom.frame = CGRectMake(0, SCREEN_HEIGHT-_viewBottom.frame.size.height, SCREEN_WIDTH, _viewBottom.frame.size.height);
                     }
                     completion:NULL
     ];
}

-(void)hiddenShareView
{
    [UIView animateWithDuration:0.24f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _viewBottom.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _viewBottom.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self removeFromSuperview];
                         }
                     }
     ];
    
}


-(id)initCamera
{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    _cancelButton = @"取消";
    NSString * title = @"拍摄(自带美颜特效)";
    _otherButtons = @[title,@"从手机相册选择"];
    self.tag = ViewTag;
    [self createCameraButtos];
    [self awakeFromNib];
    return self;
}

-(void)createCameraButtos
{
    [_viewBottom  removeFromSuperview];
    _viewBottom = nil;
    _viewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    _viewBottom.backgroundColor =[UIColor colorWithHexString:@"f9f9f9"];
    
    CGFloat widthView = SCREEN_WIDTH;
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 40)];
    view.backgroundColor = [UIColor colorWithHexString:@"f9f9f9"];
    CGFloat startOrginy = _title.length?50:0;
    for (int i=0; i<_otherButtons.count; i++) {
        UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"write"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"light_gray_bg"] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(0, startOrginy+60*i, widthView, i==0?60:55);
        [view addSubview:button];
        if (i<_otherButtons.count-1) {
            UIImageView * imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame), widthView, 0.5)];
            imgLine.image = [UIImage imageNamed:@"icon_line"];
            [view addSubview:imgLine];
        }
        view.frame = CGRectMake(0, 0, widthView, CGRectGetMaxY(button.frame));
        [view addSubview:button];
        [view sendSubviewToBack:button];
        button.title = _otherButtons[i] ;
        if (i==0) {
            button.colorNormal = [UIColor clearColor];
            
            UILabel * label =[[UILabel alloc]initWithFrame:CGRectMake(0, (CGRectGetHeight(button.frame)-button.titleLabel.font.lineHeight-FONT(13).lineHeight-4)/2.0, SCREEN_WIDTH, button.titleLabel.font.lineHeight)];
            label.text = button.title;
            label.textColor = COLOR_APP_MAIN;
            label.textAlignment = NSTextAlignmentCenter;
            label.font =button.titleLabel.font;
            [button addSubview:label];
            
            UILabel * labelDes =[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame)+4, SCREEN_WIDTH, FONT(13).lineHeight)];
            labelDes.text = @"照片或视频";
            labelDes.textColor = COLOR_APP_MAIN;
            labelDes.textAlignment = NSTextAlignmentCenter;
            labelDes.font = FONT(13);
            [button addSubview:labelDes];
            
            
        }else {
            button.title = _otherButtons[i] ;
            button.colorNormal = COLOR_APP_MAIN;

        }
        [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_viewBottom addSubview:view];
    UIButton * buttonCancel =[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCancel setBackgroundImage:[UIImage imageNamed:@"write"] forState:UIControlStateNormal];
    [buttonCancel setBackgroundImage:[UIImage imageNamed:@"light_gray_bg"] forState:UIControlStateHighlighted];
    buttonCancel.frame = CGRectMake(0, CGRectGetMaxY(view.frame)+10, widthView, 55);
    [buttonCancel addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    buttonCancel.title = _cancelButton;;
    buttonCancel.colorNormal = [UIColor colorWithHexString:@"e74952"];
    [_viewBottom addSubview:buttonCancel];
    _viewBottom.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, CGRectGetMaxY(buttonCancel.frame));
    [self addSubview:_viewBottom];
}

-(void)createButtos
{
    [_viewBottom  removeFromSuperview];
    _viewBottom = nil;
    _viewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    _viewBottom.backgroundColor = [UIColor whiteColor];
    
    CGFloat widthView = SCREEN_WIDTH-40;
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 40)];
    [view addlayerRadius:8.9];
    
    if (_title.length) {
        UILabel * label =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, widthView, 50)];
        label.text = _title;
        label.textColor = [UIColor colorWithHexString:@"363636"];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = FONT(15);
        [view addSubview:label];
    }
    CGFloat startOrginy = _title.length?50:0;
    for (int i=0; i<_otherButtons.count; i++) {
        UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"write"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"light_gray_bg"] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(0, startOrginy+50*i, widthView, 50);
        [view addSubview:button];
        if (i<_otherButtons.count-1) {
            UIImageView * imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame), widthView, 0.5)];
            imgLine.image = [UIImage imageNamed:@"icon_line"];
            [view addSubview:imgLine];
        }
        view.frame = CGRectMake(20, 0, widthView, CGRectGetMaxY(button.frame));
        [view addSubview:button];
        [view sendSubviewToBack:button];
        button.title = _otherButtons[i];
        button.colorNormal = [UIColor colorWithHexString:@"363636"];
        [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_viewBottom addSubview:view];
    UIButton * buttonCancel =[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCancel setBackgroundImage:[UIImage imageNamed:@"write"] forState:UIControlStateNormal];
    [buttonCancel setBackgroundImage:[UIImage imageNamed:@"light_gray_bg"] forState:UIControlStateHighlighted];
    buttonCancel.frame = CGRectMake(20, CGRectGetMaxY(view.frame)+10, widthView, 50);
    [buttonCancel addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];

    buttonCancel.title = _cancelButton;;
    buttonCancel.colorNormal = COLOR_APP_MAIN;
    [_viewBottom addSubview:buttonCancel];
    [buttonCancel addlayerRadius:8.8];
    _viewBottom.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, CGRectGetMaxY(buttonCancel.frame)+20);
    [self addSubview:_viewBottom];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void )btnClicked:(UIButton *)button
{
    self.backgroundColor =  [UIColor clearColor];
    [AppGeneral resetButton:button];
    [self hiddenShareView];
    if (_callBack) {
        _callBack(button.title);
    }
}

@end
