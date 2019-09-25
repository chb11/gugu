//
//  NewsDetailController.m
//  gugu
//
//  Created by Mike Chen on 2019/4/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "NewsDetailController.h"

@interface NewsDetailController ()

@property (nonatomic,strong) UIWebView *webView;

@end

@implementation NewsDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.model.Url]];
    
    [self.webView loadRequest:request];
}

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight)];
        _webView.dataDetectorTypes = UIDataDetectorTypeAll;
    }
    return _webView;
}
@end
