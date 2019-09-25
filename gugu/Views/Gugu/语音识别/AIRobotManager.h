//
//  ASRViewController.h
//  SDKTester
//
//  Created by baidu on 16/1/27.
//  Copyright © 2016年 baidu. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>



@interface AIRobotManager : NSObject

+(instancetype) shareInstance;


//开启语音识别 唤醒
- (void)startWakeup;
-(void)action_closeAll;

@end

