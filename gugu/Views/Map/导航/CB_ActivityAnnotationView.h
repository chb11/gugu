//
//  CB_ActivityAnnotationView.h
//  gugu
//
//  Created by Mike Chen on 2019/6/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_ActivityAnnotationView : UIView

@property (nonatomic,assign) BOOL isShowPaoPao;
@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *img_url;

-(void)updateFrame;

@end

NS_ASSUME_NONNULL_END
