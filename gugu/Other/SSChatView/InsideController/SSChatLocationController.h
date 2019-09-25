//
//  SSChatLocationController.h
//  SSChatView
//
//  Created by soldoros on 2018/10/15.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SSChatLocationBlock)(MAPointAnnotation *annotation);

@interface SSChatLocationController : BaseViewController

@property(nonatomic,copy) SSChatLocationBlock locationBlock;


@end


