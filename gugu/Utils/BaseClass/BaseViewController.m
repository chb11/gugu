//
//  BaseViewController.m
//  MakeProfilePicture
//
//  Created by douyinbao on 2018/3/28.
//  Copyright © 2018年 douyinbao. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()<UIGestureRecognizerDelegate>
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f8f8f8"];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor blackColor]}];
    if (self.navigationController.viewControllers.count>1) {
        [self setDetaultReturn];
    }
    
//    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.edgesForExtendedLayout=UIRectEdgeAll;
    self.navigationController.navigationBar.translucent = NO;
    NSArray * array = @[@"VoiceMainVC",@"HLDS_ChooseLocalAudioControllerViewController",@"ChooseVoiceEditController",@"BaseViewController"];
    if ([array containsObject:NSStringFromClass([self class])]) {
        [self configYuanJiaoView];
    }
    
    UIImage *backImg = [AppGeneral gradientImageWithBounds:CGRectMake(0, 0, SCREEN_WIDTH, NavBarHeight) andColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] andGradientType:1];
    
    [self.navigationController.navigationBar setBackgroundImage:backImg forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      
                                                                      NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:17]}];
}


-(void)configYuanJiaoView
{

    self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, NavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bgView];
    [self.view sendSubviewToBack:_bgView];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_bgView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _bgView.bounds;
    maskLayer.path = maskPath.CGPath;
    _bgView.layer.mask = maskLayer;
}

-(void)setDetaultReturn{
    [self addItemWithTitle:nil imageName:@"back.png" selector:@selector(action_back) left:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self isFirsrCtrl]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer==self.navigationController.interactivePopGestureRecognizer) {
        NSString * className = NSStringFromClass([self.navigationController.topViewController class]);
        //需要关闭优化返回的界面
        NSArray * arrayCloseBack =@[];
        if (self.navigationController.viewControllers.count <= 1||[arrayCloseBack containsObject:className]){
            return NO;
        }
        return YES;
    }
    return YES;
}

-(BOOL)isFirsrCtrl
{
    NSString * className = NSStringFromClass([self class]);
    NSArray * array = @[@"HomeMainVC",@"HotArticleVC",@"ChatViewController",@"PersonDetailVC"];
    if ([array containsObject:className]) {
        return YES;
    }
    return NO;
}

//设置左右按钮
- (void)addItemWithTitle:(NSString *)itemTitle imageName:(NSString *)imageName selector:(SEL)selector left:(BOOL)isLeft{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = 40;
    
    if (itemTitle.length) {
        width = [AppGeneral textWidth:itemTitle andTitleFont:[UIFont systemFontOfSize:16]]+10;
    }
    [btn setFrame:CGRectMake(0,0,width,40)];
    if (itemTitle.length) {
        [btn setTitle:itemTitle forState:UIControlStateNormal];
        [btn setTitleColor:TEXT_NAV_TITLE_COLOR forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        btn.contentHorizontalAlignment = isLeft? UIControlContentHorizontalAlignmentLeft:UIControlContentHorizontalAlignmentRight;
    } else if (imageName.length) {
        [btn setFrame:CGRectMake(0,0,40,40)];
        btn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.contentHorizontalAlignment = isLeft? UIControlContentHorizontalAlignmentLeft:UIControlContentHorizontalAlignmentRight;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (isLeft == YES) {
        self.navigationItem.leftBarButtonItem = item;
    }else{
        self.navigationItem.rightBarButtonItem = item;
    }
}

//设置左右按钮(日历)
- (void)addImageItemWithTitle:(NSString *)itemTitle imageName:(NSString *)imageName selector:(SEL)selector left:(BOOL)isLeft{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag=12138;
    CGFloat width = 40;
    if (itemTitle.length) {
        //        width = [AppGeneral getTextWidth:itemTitle andTitleFont:15]+5;
    }
    if ([imageName isEqualToString:@"logon_failure"]) {
        width = 50;
    }
    [btn setFrame:CGRectMake(0,0,width,40)];
    
    if (itemTitle.length) {
        [btn setTitle:itemTitle forState:UIControlStateNormal];
        [btn setTitleColor: TEXT_NAV_TITLE_COLOR forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    } else if (imageName.length) {
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.contentHorizontalAlignment = isLeft? UIControlContentHorizontalAlignmentLeft:UIControlContentHorizontalAlignmentRight;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (isLeft == YES) {
        self.navigationItem.leftBarButtonItem = item;
    }else{
        self.navigationItem.rightBarButtonItem = item;
    }
}

-(void)action_back{
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
