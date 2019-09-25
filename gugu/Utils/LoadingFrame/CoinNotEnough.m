//
//  CoinNotEnough.m
//  BingQiLin
//
//  Created by BingQiLin on 16/3/25.
//  Copyright © 2016年 BingQiLin. All rights reserved.
//

#import "CoinNotEnough.h"
#import "AppDelegate.h"
static CoinNotEnough * CoinManager = nil;

@interface CoinNotEnough ()<UIAlertViewDelegate>
{
    UIAlertView *_alertCoin;
    UIAlertView *  _alertGame;
}
@property (nonatomic, weak)UIViewController * weakVC;

@end

@implementation CoinNotEnough

+ (CoinNotEnough*)sharedInstance
{

    @synchronized (self)
    {
        if (CoinManager == nil)
        {
            CoinManager = [[self alloc]init];
        }
    }
    return CoinManager;
}


-(void)dealloc
{
    _weakVC = nil;
    [_alertCoin removeFromSuperview];
    _alertCoin = nil;
    
    [_alertGame removeFromSuperview];
    _alertGame  = nil;
}

+(void)ShowAlertMsg:(NSString *)msg
{
    if (msg&&msg.length) {
        UIAlertView * aletView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
        [aletView show];
    }
}

+(void)ShowMessage:(NSString *)msg
{
    if (msg&&msg.length) {
        UIAlertView * aletView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
        [aletView show];
    }
}

-(void)setAlertResult:(NSInteger )result andMsg:(NSString *)msg delegate:(id)obj
{
    if (result==212) {
        if (!_alertCoin) {
            _alertCoin  = [[UIAlertView alloc]initWithTitle:nil message:@"当前金币不足,快去购买金币吧" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去购买", nil];
        }
        if (![_alertCoin isVisible]) {
            [_alertCoin show];
        }
        _alertCoin.delegate =obj;
    }else if (result==261&&(msg&&msg.length)) {
        if (!_alertGame) {
            _alertGame  = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"刷新", nil];
        }
        if (![_alertGame isVisible]) {
            [_alertGame show];
        }
        _alertGame.delegate =obj;
    } else if(msg&&msg.length) {
        if (!_alertCoin) {
            _alertCoin  = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
        }
        if (![_alertCoin isVisible]) {
            [_alertCoin show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (_alertCoin==alertView) {
        if (buttonIndex!=alertView.cancelButtonIndex) {
          
        }
    }else if (_alertGame==alertView) {
       
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    CoinManager = nil;
}


@end
