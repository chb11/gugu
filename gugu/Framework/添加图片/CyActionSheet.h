//
//  CyActionSheet.h
//  ListenSpeak
//
//  Created by BingQiLin on 16/7/12.
//  Copyright © 2016年 BingQiLin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ShowActionSheetCallBack)(id obj);

@interface CyActionSheet : UIView

-(id)initCamera;
-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString * )cancelButton otherButtonTitles:(NSArray *)buttons;
+(void)DisMiss;

-(void)showActionSheet:(ShowActionSheetCallBack)callBack;
@end
