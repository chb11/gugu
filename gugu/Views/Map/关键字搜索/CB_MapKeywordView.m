//
//  CB_MapKeywordView.m
//  gugu
//
//  Created by Mike Chen on 2019/3/27.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_MapKeywordView.h"

@interface CB_MapKeywordView ()


@end

@implementation CB_MapKeywordView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.btn_clear.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
}

- (IBAction)action_goSearch:(UIButton *)sender {
    if (self.block_searchKeywords) {
        self.block_searchKeywords();
    }
    
}

- (IBAction)action_clear:(UIButton *)sender {
    self.txt_keyword.text = @"";
    self.btn_clear.hidden = YES;
    if (self.block_clearKeywords) {
        self.block_clearKeywords();
    }
}

-(void)setKeywordStr:(NSString *)keywordStr{
    _keywordStr = keywordStr;
    self.txt_keyword.text = keywordStr;
    if (keywordStr.length>0) {
        self.btn_clear.hidden = NO;
    }else{
        self.btn_clear.hidden = YES;
    }
    
}

@end
