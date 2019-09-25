//
//  ChooseFriendSearchView.m
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ChooseFriendSearchView.h"

@implementation ChooseFriendSearchView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.view_text addlayerRadius:self.view_text.height/2];
    [self.btn_search addborderColor:[UIColor colorWithHexString:@"363636"] borderWith:1 layerRadius:4];
}

- (IBAction)action_search:(id)sender {
    [self.txt_name resignFirstResponder];
    if (self.block_search) {
        self.block_search(self.txt_name.text);
    }
}


@end
