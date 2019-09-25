//
//  CB_NewTagView.m
//  VoicePackage
//
//  Created by Mike Chen on 2018/7/27.
//  Copyright © 2018年 王之共力. All rights reserved.
//

#import "CB_NewTagView.h"

@interface CB_NewTagView()
{
    CGFloat height;
    CGFloat width;
    NSInteger font;
    CGFloat originX;
    NSInteger line;
    CGFloat margin ;
}

@end

@implementation CB_NewTagView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        height = 20;//初始化每个item的高度
        width = 40;//初始化每个item的宽度
        font = 12;//字体
        originX = 0;//记录x坐标偏移多少
        line = 0;//行数
        margin = 10;
        
    }
    return self;
}

-(void)setTypes:(NSArray<NSString *> *)types{
    _types = types;
    [self viewWithButtons:types];
}

-(void)viewWithButtons:(NSArray *)array{
    NSArray *items = self.subviews;
    for (UIView *item in items) {
        [item removeFromSuperview];
    }
    
    if (array.count>0) {
        for (int i =0; i<array.count; i++) {
            
            NSString *name = array[i];
            UIButton *button = [[UIButton alloc] init];
            button.tag = 200+i;
            //设置边框颜色
            if (self.itemBorderColorArray.count>0) {
                NSString *colorHex = self.itemBorderColorArray[i%self.itemBorderColorArray.count];
                button.layer.borderColor = [UIColor colorWithHexString:colorHex].CGColor;
                button.layer.borderWidth = 1;
                
            }else{
                button.layer.borderColor = [UIColor lightGrayColor].CGColor;
            }
            //设置标签颜色
            if (self.itemTitleColorArray.count>0) {
                NSString *colorHex = self.itemTitleColorArray[i%self.itemTitleColorArray.count];
                [button setTitleColor:[UIColor colorWithHexString:colorHex] forState:UIControlStateNormal];
            }else{
                [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
            
            if (self.itemMargin) {
                margin = self.itemMargin;
            }
            
            //设置标签字体
            if (self.itemFont) {
                font = self.itemFont;
            }
            
            if (self.itemWidth) {
                width = self.itemWidth;
            }
            if (self.itemHeight) {
                height = self.itemHeight;
            }
            
            //背景颜色
            if (self.itemBackColorArray.count>0) {
                NSString *colorHex = self.itemBackColorArray[i%self.itemBackColorArray.count];
                button.backgroundColor = [UIColor colorWithHexString:colorHex];
            }
            if (i ==0) {
                [button setTitleColor:COLOR_APP_MAIN forState:UIControlStateNormal];
                button.layer.borderColor = COLOR_APP_MAIN.CGColor;
            }
            
            button.titleLabel.font = [UIFont systemFontOfSize:font];
            
            [button setTitle:name forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(action_click:) forControlEvents:UIControlEventTouchUpInside];
            
            if (name&&name.length>0) {
                CGSize size = [name sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:(font+2)]}];
                //如果一行大于容器的宽度，就换行
                if((originX + size.width+margin)>self.width){
                    
                    line += 1;
                    
                    if (self.limitedLine && line >= self.limitedLine) {
                        break;
                    }
                    
                    originX = 0;
                    CGRect frame = self.frame;
                    frame.size.height = (line+1)*(height+margin);
                    self.frame = frame;
                }
                
                [button setFrame:CGRectMake(originX, (height+margin)*line, size.width+margin, height)];

                originX += button.width+margin;
                
                if (self.itemRadio) {
//                    [button addCornerRadius:self.itemRadio cithCorners:UIRectCornerAllCorners];
                    [button addlayerRadius:self.itemRadio];
                }else{
                    [button addCornerRadius:button.height/2 cithCorners:UIRectCornerAllCorners];
                }
                
                [self addSubview:button];
            }
        }
    }
}

-(void)setCurrIndex:(NSInteger)currIndex{
    _currIndex = currIndex;
    
//    [self viewWithButtons:self.types];
//
//    for (UIButton *btn in self.subviews) {
//        if (btn.tag == currIndex+200) {
//            [btn setTitleColor:COLOR_APP_MAIN forState:UIControlStateNormal];
//            btn.layer.borderColor = COLOR_APP_MAIN.CGColor;
//            btn.layer.borderWidth = 1;
//        }
//    }
}

-(void)action_click:(UIButton *)button{
//    self.currIndex = btn.tag-200;
    
    
    for (UIButton *btn in self.subviews) {
        if (btn.tag == button.tag) {
            [btn setTitleColor:COLOR_APP_MAIN forState:UIControlStateNormal];
            btn.layer.borderColor = COLOR_APP_MAIN.CGColor;
            
        }else{
            [btn setTitleColor:[UIColor colorWithHexString:@"363636"] forState:UIControlStateNormal];
            btn.layer.borderColor = [UIColor colorWithHexString:@"363636"].CGColor;
        }
    }
    
    
    
    if (self.block_select) {
        self.block_select(button.title);
    }
}

+(CGFloat)heightWithTags:(NSArray *)array withFont:(NSInteger)fontSize withitemHeight:(CGFloat)itemHeight withWidth:(CGFloat)width{
    
    NSInteger height = itemHeight;
    NSInteger line = 1;
    NSInteger originX = 0;//记录x坐标偏移多少
    NSInteger margin = 10;
    
    CGFloat totalHeight = 0;
    
    for (int i =0; i<array.count; i++) {
        NSString *name = array[i];
        UIButton *button = [[UIButton alloc] init];
        
        button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        
        [button setTitle:name forState:UIControlStateNormal];
        
        if (name&&name.length>0) {
            CGSize size = [name sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:(fontSize+2)]}];
            //如果一行大于容器的宽度，就换行
            if((originX + size.width+margin)>width){
                line += 1;
                originX = 0;
            }
            [button setFrame:CGRectMake(originX, (height+margin)*line, size.width+margin, height)];
            originX += button.width+margin;
        }
    }
    totalHeight = (height+margin)*line - margin;
    return totalHeight;
}



@end
