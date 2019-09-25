//
//  AgreementViewController.m
//  Fatoring
//
//  Created by chun on 15/8/3.
//  Copyright (c) 2015年 chun. All rights reserved.
//

#import "AgreementViewController.h"

@interface AgreementViewController ()
{
    UIWebView * webView;
}
@end

@implementation AgreementViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setNavStaus:NavStatusHight WithTitle:@"用户协议" WithNeedBackBtn:YES];
    self.title = @"用户协议";

    webView =[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-BottomPadding)];
    [self.view addSubview:webView];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"register.docx" ofType:nil];
    NSURL *url = [NSURL URLWithString:@"http://gugu.holdone.cn/agreement.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webView.scalesPageToFit = YES;
    [webView loadRequest:request];
    webView.scalesPageToFit = YES;
    webView.opaque = YES;
    webView.backgroundColor = [UIColor clearColor];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    webView.clipsToBounds = NO;
    // Do any additional setup after loading the view.
}

-(void)hlsd_action_return{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
