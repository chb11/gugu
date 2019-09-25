//
//  RoundedTextView.m
//  七彩重师
//
//  Created by imac on 14-11-14.
//  Copyright (c) 2014年 xuner. All rights reserved.
//

#import "RoundedTextView.h"
#import <QuartzCore/QuartzCore.h>

#import "ZYKeyboardUtil.h"

#define getLimitNum (self.limitNum > 0 ? self.limitNum : 300)

@implementation RoundedTextView
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        self.delegate=self;
//        self.returnKeyType=UIReturnKeyDone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

-(id)init{
    self=[super init];
    if(self){
        self.delegate=self;
//        self.returnKeyType=UIReturnKeyDone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius=5.0f;
        self.layer.masksToBounds=YES;
        self.layer.borderWidth= 1.0f;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self setPlaceholder:@""];
        self.delegate=self;
//        self.returnKeyType=UIReturnKeyDone;
        //判读是否是夜间模式
        bool isNight =  [[[NSUserDefaults standardUserDefaults] valueForKey:@"nightModel"] boolValue];
        if (isNight) {
            self.keyboardAppearance = UIKeyboardAppearanceDark;
        }else{
            self.keyboardAppearance = UIKeyboardAppearanceDefault;
        }
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}


-(void)dismissKeyBoard
{
    [self resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self configKeyBoardRespond:self.mview andTextField:textView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideKeyBoard" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:textView,@"view", nil]];
    return YES;
}

- (void)configKeyBoardRespond:(UIViewController *)controller andTextField:(UITextView *)textField{
    self.keyboardUtil = [[ZYKeyboardUtil alloc] initWithKeyboardTopMargin:30];
    __weak UIViewController *weakSelf = controller;
    
#pragma explain - 全自动键盘弹出/收起处理 (需调用keyboardUtil 的 adaptiveViewHandleWithController:adaptiveView:)
#pragma explain - use animateWhenKeyboardAppearBlock, animateWhenKeyboardAppearAutomaticAnimBlock will be invalid.
    [_keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
        [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:textField, nil];
    }];
    // or
    //     [_keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
    //     [keyboardUtil adaptiveViewHandleWithAdaptiveView:textField, nil];
    //     }];
    
#pragma explain - 自定义键盘弹出处理(如配置，全自动键盘处理则失效)
#pragma explain - use animateWhenKeyboardAppearAutomaticAnimBlock, animateWhenKeyboardAppearBlock must be nil.
    /*
     [_keyboardUtil setAnimateWhenKeyboardAppearBlock:^(int appearPostIndex, CGRect keyboardRect, CGFloat keyboardHeight, CGFloat keyboardHeightIncrement) {
     NSLog(@"\n\n键盘弹出来第 %d 次了~  高度比上一次增加了%0.f  当前高度是:%0.f"  , appearPostIndex, keyboardHeightIncrement, keyboardHeight);
     //do something
     }];
     */
    
#pragma explain - 自定义键盘收起处理(如不配置，则默认启动自动收起处理)
#pragma explain - if not configure this Block, automatically itself.
    /*
     [_keyboardUtil setAnimateWhenKeyboardDisappearBlock:^(CGFloat keyboardHeight) {
     NSLog(@"\n\n键盘在收起来~  上次高度为:+%f", keyboardHeight);
     //do something
     }];
     */
    
    
    //获取键盘信息
    [_keyboardUtil setPrintKeyboardInfoBlock:^(ZYKeyboardUtil *keyboardUtil, KeyboardInfo *keyboardInfo) {
        NSLog(@"\n\n拿到键盘信息 和 ZYKeyboardUtil对象");
    }];
}

- (void)textChanged:(NSNotification *)notification

{//[self isContainsTwoEmoji:self.text]||[[[UITextInputMode currentInputMode ]primaryLanguage] isEqualToString:@"emoji"]
    if ([self isContainsTwoEmoji:self.text]) {
        [self deleteString:self];
    }
    if([[self placeholder] length] == 0)return;
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
    
    if (_isShowXZ) {
        NSInteger wordCount;
        NSString *str = self.text;
        NSLog(@"%@",str);
        
        wordCount = self.text.length;
        //        if (range.location == 0 && range.length == 0) {
        //            wordCount = 1;
        //        }else if(range.location == 0 && range.length == 1){
        //            wordCount = 0;
        //        }else if (range.length == 1 &&range.location != 0){
        //            wordCount = range.location;
        //        }else{
        //            wordCount = range.location+1;
        //        }
        NSLog(@"%lu",wordCount);
        if (wordCount<getLimitNum+1) {
            self.countNumLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)wordCount,getLimitNum];
        }else{
            self.countNumLabel.text = [NSString stringWithFormat:@"超出限制！ %ld/%ld",(long)wordCount,getLimitNum];
        }
        if(self.blockXZ){
            self.blockXZ((int)wordCount);
        }
        
    }
}

/**
 *  光标位置删除
 */
- (void)deleteString:(UITextView *)textView {
    NSRange range = textView.selectedRange;
    NSLog(@"%zd-表情删除-%zd",range.length,range.location);
    if (textView.text.length > 0) {
        NSUInteger location  = textView.selectedRange.location;
        NSString *head = [textView.text substringToIndex:location];
        if (range.length ==0) {
            
        }else{
            NSLog(@"文字为全选");
            textView.text =@"";
        }
        
        if (location > 0) {
            //            NSUInteger location  = self.inputView.toolBar.textView.selectedRange.location;
            NSMutableString *str = [NSMutableString stringWithFormat:@"%@",textView.text];
            [self lastRange:head];
            NSLog(@"%zd===%zd",[self lastRange:head].location,[self lastRange:head].length);
            NSLog(@"%@",str);
            
            [str deleteCharactersInRange:[self lastRange:head]];
            
            NSLog(@"%@",str);
            textView.text = str;
            self.text = str;
            textView.selectedRange = NSMakeRange([self lastRange:head].location,0);
            
        } else {
            textView.selectedRange = NSMakeRange(0,0);
        }
    }
}

/**
 *  计算选中的最后一个是字符还是表情所占长度
 *
 *  @param str 要计算的字符串
 *
 *  @return 返回一个 NSRange
 */
- (NSRange)lastRange:(NSString *)str {
    NSRange lastRange = [str rangeOfComposedCharacterSequenceAtIndex:str.length-1];
    return lastRange;
}

#pragma mark - 判断是否含有表情
-(BOOL)isContainsTwoEmoji:(NSString *)string
{
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         //         NSLog(@"hs++++++++%04x",hs);
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f)
                 {
                     isEomji = YES;
                 }
                 //                 NSLog(@"uc++++++++%04x",uc);
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3|| ls ==0xfe0f) {
                 isEomji = YES;
             }
             //             NSLog(@"ls++++++++%04x",ls);
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
         
     }];
    return isEomji;
}

-(UILabel *) countNumLabel{
    if(_countNumLabel==nil){
        _countNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mj_x+self.width-160, self.mj_y+self.height+6, 150, 20)];
        _countNumLabel.textAlignment = NSTextAlignmentRight;
        _countNumLabel.text = [NSString stringWithFormat:@"%ld",getLimitNum] ;
        _countNumLabel.textColor = [UIColor darkGrayColor];
        _countNumLabel.font = [UIFont systemFontOfSize:13];
        //        _countNumLabel.backgroundColor = [UIColor whiteColor];
        [self.superview addSubview:_countNumLabel];
    }
    return _countNumLabel;
}

- (void)setText:(NSString *)text {
    
    [super setText:text];
    
    [self textChanged:nil];
    
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if (self.placeHolderLabel == nil )
        {
            self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            self.placeHolderLabel.lineBreakMode = UILineBreakModeWordWrap;
            self.placeHolderLabel.numberOfLines = 0;
            self.placeHolderLabel.font = self.font;
            self.placeHolderLabel.backgroundColor = [UIColor clearColor];
            self.placeHolderLabel.textColor = self.placeholderColor;
            self.placeHolderLabel.alpha = 0;
            self.placeHolderLabel.tag = 999;
            [self addSubview:self.placeHolderLabel];
        }
        self.placeHolderLabel.text = self.placeholder;
        [self.placeHolderLabel sizeToFit];
        [self sendSubviewToBack:self.placeHolderLabel];
    }
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    [super drawRect:rect];
}
-(void)setBorderColor:(UIColor*)color{
    self.layer.borderColor=[color CGColor];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
