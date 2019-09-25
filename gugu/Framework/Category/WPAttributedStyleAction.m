//
//  WPAttributedStyleAction.m
//  WPAttributedMarkupDemo
//
//  Created by Nigel Grange on 20/10/2014.
//  Copyright (c) 2014 Nigel Grange. All rights reserved.
//

#import "WPAttributedStyleAction.h"

NSString* kWPAttributedStyleAction = @"WPAttributedStyleAction";

@implementation WPAttributedStyleAction

- (instancetype)initWithAction:(void (^)())action
{
    self = [super init];
    if (self) {
        self.action = action;
    }
    return self;
}

+(NSArray*)styledActionWithAction:(void (^)())action
{
    WPAttributedStyleAction* container = [[WPAttributedStyleAction alloc] initWithAction:action];
    return [container styledAction];
}


+(NSArray*)styledActionWithAction:(void (^)())action andColor:(UIColor *)color{
    WPAttributedStyleAction* container = [[WPAttributedStyleAction alloc] initWithAction:action];
    container.color = color;
    return [container styledActionColor:color];
    
}



-(NSArray*)styledAction
{
    return @[ @{kWPAttributedStyleAction:self}, @"link"];
}

-(NSArray*)styledActionColor:(UIColor *)color
{
    return @[ @{kWPAttributedStyleAction:self},color];
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
