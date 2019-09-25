//
//  CB_GroupScanResultController.m
//  gugu
//
//  Created by Mike Chen on 2019/6/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_GroupScanResultController.h"
#import "SSChatController.h"

@interface CB_GroupScanResultController ()
@property (weak, nonatomic) IBOutlet UIImageView *img_groupHeader;
@property (weak, nonatomic) IBOutlet UILabel *lbl_groupname;
@property (weak, nonatomic) IBOutlet UIButton *btn_send;

@property (nonatomic,strong) CB_GroupModel *groupModel;
@end

@implementation CB_GroupScanResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群二维码";
    [self.btn_send addlayerRadius:self.btn_send.height/2];
    
    NSDictionary *para1 = @{@"Guid":self.groupId};
    [[NetWorkConnect manager] postDataWith:para1 withUrl:CHAT_GROUP_SHOW_GROUP withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSDictionary *dict = responseObject;
//            self.groupDict = dict.mutableCopy;
            [self refreshWithGroupDict:dict];
        }
    }];
}

-(void)refreshWithGroupDict:(NSDictionary *)groupDict{
    self.groupModel = [CB_GroupModel modelWithDictionary:groupDict];
    self.groupModel.GroupId = groupDict[@"Guid"];
    self.groupModel.GroupHeadPhoto = groupDict[@"PhotoUrl"];
    self.groupModel.GroupName = groupDict[@"Name"];
    [self.img_groupHeader sd_setImageWithURL:[NSURL URLWithString:self.groupModel.GroupHeadPhotoURL]];
    self.lbl_groupname.text = self.groupModel.GroupName;
    
    
}

- (IBAction)action_send:(UIButton *)sender {
    SSChatController *page = [SSChatController new];
    page.chatType = SSChatConversationTypeGroupChat;
    page.sessionId = self.groupModel.GroupId;
    page.SendId = self.groupModel.GroupId;
    page.groupModel = self.groupModel;
    [self.navigationController pushViewController:page animated:YES];
    
}


@end
