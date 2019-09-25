//
//  SSChatController.m
//  SSChatView
//
//  Created by soldoros on 2018/9/25.
//  Copyright © 2018年 soldoros. All rights reserved.
//

//if (IOS7_And_Later) {
//    self.automaticallyAdjustsScrollViewInsets = NO;
//}

#import "SSChatController.h"
#import "SSChatKeyBoardInputView.h"
#import "SSAddImage.h"
#import "SSChatBaseCell.h"
#import "SSChatLocationController.h"
#import "SSImageGroupView.h"
#import "SSChatMapController.h"
#import "MyUserInfoController.h"
#import "ContrractUserInfoController.h"
#import "CyActionSheet.h"
#import "AIRobotManager.h"
#import "CB_MessageTransController.h"
#import "CollectionlistController.h"
#import "CB_GroupInfoController.h"
#import "CB_ActivityController.h"
#import "SSChatVoiceCell.h"
#import "CB_ChatShareLocationView.h"
#import "CB_MapRouteController.h"


#define ETRECORD_RATE 44100

typedef enum : NSUInteger {
    CB_CHAT_TYPE_DEFAULT = 0,
    CB_CHAT_TYPE_MAP,
    CB_CHAT_TYPE_ALL,
} CB_CHAT_TYPE;

@interface SSChatController ()<SSChatKeyBoardInputViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,SSChatBaseCellDelegate>

//承载表单的视图 视图原高度
@property (strong, nonatomic) UIView    *mBackView;
@property (assign, nonatomic) CGFloat   backViewH;

//表单
@property(nonatomic,strong)HLDS_BaseListView *mTableView;
@property(nonatomic,strong)NSMutableArray *datas;

//底部输入框 携带表情视图和多功能视图
@property(nonatomic,strong)SSChatKeyBoardInputView *mInputView;

//访问相册 摄像头
@property(nonatomic,strong)SSAddImage *mAddImage;

@property (nonatomic,strong) UIButton *btn_back;
@property (nonatomic,strong) UIButton *btn_huanxing;
@property (nonatomic,strong) UIButton *btn_map;
@property (nonatomic,strong) UIButton *btn_more;

@property (nonatomic,strong) NSMutableArray *unreadAudioMessage;

//当前正在播放的音频
@property (nonatomic,assign) __block BOOL isPlaying;
@property (nonatomic,assign) __block BOOL isContinue;
@property (nonatomic,assign) __block NSInteger currPlayingIndex;
//当前是自动还是手动
@property (nonatomic,assign) __block BOOL isAuto;

@property (nonatomic,assign) NSInteger chatViewType;
@property (nonatomic,strong) CB_ChatShareLocationView *mapView;

@property (nonatomic,assign) BOOL isFirstIn;

@end

@implementation SSChatController

-(instancetype)init{
    if(self = [super init]){
        _sessionId = @"0";
        
        _chatType = SSChatConversationTypeChat;
        _datas = @[].mutableCopy;
    }
    return self;
}

//不采用系统的旋转
- (BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstIn = YES;
    self.isAuto = NO;
    self.isContinue = NO;
    self.isPlaying = NO;
    self.currPlayingIndex = -1;
    [self initUI];
    [self initData];
    [self initAction];
    [self action_configNavButtons];
    [self action_readMessage:self.model];
    
    
}

-(void)action_configNavButtons{
    self.btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn_back addTarget:self action:@selector(action_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_back setFrame:CGRectMake(0,0,22,40)];
    self.btn_back.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.btn_back.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.btn_back setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.btn_back];
    
    self.btn_huanxing = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn_huanxing addTarget:self action:@selector(action_huanxing:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_huanxing setTitle:@"自动" forState:UIControlStateNormal];
    [self.btn_huanxing setTitle:@"手动" forState:UIControlStateSelected];
    self.btn_huanxing.tintColor = [UIColor whiteColor];
    UIBarButtonItem *hxItem = [[UIBarButtonItem alloc] initWithCustomView:self.btn_huanxing];
    self.navigationItem.leftBarButtonItems  = @[backItem,hxItem];
    
    self.btn_map = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn_map addTarget:self action:@selector(action_changeMap:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_map setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_map setTitle:@"显示地图" forState:UIControlStateNormal];
    UIBarButtonItem *mapItem = [[UIBarButtonItem alloc] initWithCustomView:self.btn_map];
    
    if (self.model.IsGroup||self.groupModel) {
        self.btn_more = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btn_more addTarget:self action:@selector(action_showmore:) forControlEvents:UIControlEventTouchUpInside];
        [self.btn_more setImage:[UIImage imageNamed:@"更多.png"] forState:UIControlStateNormal];
        if (@available(iOS 9.0, *)) {
            [self.btn_more setFrame:CGRectMake(0,0,24,24)];
            [self.btn_more.widthAnchor constraintEqualToConstant:24].active = YES;
            [self.btn_more.heightAnchor constraintEqualToConstant:24].active = YES;
        } else {
            self.btn_more.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
            [self.btn_more setFrame:CGRectMake(0,0,40,40)];
        }
        
        self.btn_more.tintColor = [UIColor whiteColor];
        UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:self.btn_more];
        self.navigationItem.rightBarButtonItems  = @[moreItem,mapItem];
    }else{
        self.navigationItem.rightBarButtonItems  = @[mapItem];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRecordin) name:@"map_startRecord" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedRecord) name:@"map_finishedRecord" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action_onNewMessage:) name:NOTIFICATION_SOCKET_MESSAGE_RECEIVED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action_playNext) name:NOTIFICATION_AUDIO_PLAY_FINISHED object:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SOCKET_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_AUDIO_PLAY_FINISHED object:nil];
    [[AIRobotManager shareInstance] action_closeAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"map_startRecord" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"map_finishedRecord" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isFirstIn) {
        if (self.mTableView.contentSize.height>0) {
        }else{
            [self.mTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        }
        [self action_refreshHistory];
    }

}

-(void)initUI{
    
    
    
    self.navigationItem.title = _titleString;
    self.view.backgroundColor = [UIColor whiteColor];
    self.unreadAudioMessage = @[].mutableCopy;
    
    self.mapView = [[CB_ChatShareLocationView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mapView];
    
    _mInputView = [SSChatKeyBoardInputView new];
    _mInputView.delegate = self;
    [self.view addSubview:_mInputView];
    
    _backViewH = SCREEN_Height-SSChatKeyBoardInputViewH-BottomPadding-NavBarHeight;
    _mBackView = [UIView new];
    _mBackView.frame = CGRectMake(0, 0, SCREEN_Width, _backViewH);
    _mBackView.backgroundColor = SSChatCellColor;
    [self.view addSubview:self.mBackView];
    

    _mTableView = [[HLDS_BaseListView alloc]initWithFrame:_mBackView.bounds style:UITableViewStylePlain];
    _mTableView.dataSource = self;
    _mTableView.delegate = self;
    _mTableView.backgroundColor = [UIColor clearColor];
//    _mTableView.backgroundView.backgroundColor = [UIColor whiteColor];
    [_mBackView addSubview:self.mTableView];
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mTableView.mj_footer = nil;
    _mTableView.animationTime = 0.1;
    _mTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _mTableView.scrollIndicatorInsets = _mTableView.contentInset;
    if (@available(iOS 11.0, *)){
        _mTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _mTableView.estimatedRowHeight = 0;
        _mTableView.estimatedSectionHeaderHeight = 0;
        _mTableView.estimatedSectionFooterHeight = 0;
    }else{
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    [_mTableView registerClass:NSClassFromString(@"SSChatBaseCell") forCellReuseIdentifier:SSChatBaseCellId];
    [_mTableView registerClass:NSClassFromString(@"SSChatTextCell") forCellReuseIdentifier:SSChatTextCellId];
    [_mTableView registerClass:NSClassFromString(@"SSChatImageCell") forCellReuseIdentifier:SSChatImageCellId];
    [_mTableView registerClass:NSClassFromString(@"SSChatVoiceCell") forCellReuseIdentifier:SSChatVoiceCellId];
    [_mTableView registerClass:NSClassFromString(@"SSChatMapCell") forCellReuseIdentifier:SSChatMapCellId];
    [_mTableView registerClass:NSClassFromString(@"SSChatVideoCell") forCellReuseIdentifier:SSChatVideoCellId];
    
    [_mTableView reloadData];
}

-(void)initData{
    self.mTableView.refreshUrl = CHAT_MESSAGE_HISTORY;
    self.mTableView.refreshDic = @{@"SendId":self.SendId};
}

-(void)initAction{
    __weak typeof(self) waekSelf = self;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [waekSelf.mTableView hlds_action_loadMoreWithHeader];
    }];
    [header setTitle:@"下拉加载更多" forState:MJRefreshStateIdle];
    [header setTitle:@"松开加载更多" forState:MJRefreshStatePulling];
    self.mTableView.mj_header = header;
    
    _mTableView.hlds_block_loadMore = ^(NSDictionary *result) {
        NSArray *items = result[@"list"];
        [waekSelf refreshWithItems:items];
    };
}

-(void)refreshWithItems:(NSArray *)items{
    if (items.count==0) {
        [AppGeneral showMessage:@"没有更多消息了" andDealy:1];
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *newDatas = [SSChatDatas receiveMessages:[self sortedArrayFrom:items]];
        [self.datas insertObjects:newDatas atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newDatas.count)]];
        [self action_readAllMessageWithMessage:self.datas];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mTableView reloadData];
            /* 滚动指定段的指定row  到 指定位置*/
            [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:items.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
    });
}

-(void)action_back:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)action_huanxing:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [[AIRobotManager shareInstance] startWakeup];
        self.isAuto = YES;
    }else{
        [[AIRobotManager shareInstance] action_closeAll];
        self.isAuto = NO;
    }
}

-(void)action_changeMap:(UIButton *)btn{
    self.chatViewType +=1;
}

-(void)action_showmore:(UIButton *)btn{
    CB_GroupInfoController *page = [CB_GroupInfoController new];
    page.groupId = self.sessionId;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)startRecordin{
    
    [self.mInputView beginRecordVoice:nil];
}
-(void)finishedRecord{
    [self.mInputView endRecordVoice:nil];
}

-(void)setChatViewType:(NSInteger)chatViewType{
    _chatViewType = chatViewType;
    //默认聊天
    if (chatViewType%3 == 0) {
        [self.btn_map setTitle:@"显示地图" forState:UIControlStateNormal];
        [self.view bringSubviewToFront:_mBackView];
        _mBackView.backgroundColor = SSChatCellColor;
        [self action_showMap];
    }
    //默认地图
    if (chatViewType%3 == 1) {
        [self.view bringSubviewToFront:self.mapView];
        [self.btn_map setTitle:@"显示全部" forState:UIControlStateNormal];
        [self action_showAll];
    }
    //默认全显示
    if (chatViewType%3 == 2) {
        [self.view sendSubviewToBack:self.mapView];
        _mBackView.backgroundColor = [UIColor clearColor];
        [self.btn_map setTitle:@"显示聊天" forState:UIControlStateNormal];
        [self action_showChat];
    }
}



-(NSArray *)sortedArrayFrom:(NSArray *)items{
    NSArray *newArr =  [items sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *dict1 = obj1;
        NSDictionary *dict2 = obj2;
        NSString *postdate1 = dict1[@"PostDate"];
        NSString *postdate2 = dict2[@"PostDate"];
        if (![AppGeneral compareDate:postdate1 andDate:postdate2]) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
        return NSOrderedSame; //降序
    }];
    return newArr;
}

-(void)action_refreshHistory{
    NSDictionary *para = @{@"SendId":self.SendId,@"from":@(0),@"to":@(9)};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_MESSAGE_HISTORY withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if(resultCode == 1){
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSArray *items = responseObject[@"list"];
                self.datas = [SSChatDatas receiveMessages:[self sortedArrayFrom:items]];
                [self action_readAllMessageWithMessage:self.datas];
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.mTableView reloadData];
                });
            });
        }
    }];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _datas.count==0?0:1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [(SSChatMessagelLayout *)_datas[indexPath.row] cellHeight];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SSChatMessagelLayout *layout = _datas[indexPath.row];
    SSChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:layout.message.cellString];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.redFlag.hidden = YES;
    cell.indexPath = indexPath;
    cell.layout = layout;
    [self configCell:cell atIndex:indexPath];
    
    if (layout.message.model.MessageType == SSChatMessageTypeVoice) {
        if ([self.unreadAudioMessage containsObject:@(indexPath.row)]) {
            if ([cell isKindOfClass:[SSChatVoiceCell class]]) {
                SSChatVoiceCell *voiceCell = (SSChatVoiceCell *)cell;
                if (self.currPlayingIndex == indexPath.row) {
                    [voiceCell.mImgView startAnimating];
                    voiceCell.redFlag.hidden = YES;
                    [voiceCell buttonPressed:nil];
                }else{
                    [voiceCell.mImgView stopAnimating];
                    cell.redFlag.hidden = NO;
                }
            }
        }
    }

    return cell;
}

-(void)configCell:(SSChatBaseCell *)cell atIndex:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    cell.block_headClick = ^(SSChatMessagelLayout *layout) {
        [weakSelf action_lookUserInfoWithModel:layout.message.model];
    };
    cell.block_messageLongAction = ^(SSChatMessagelLayout *layout) {
        [weakSelf action_showlongGesture:layout];
    };
    cell.block_messageClick = ^(SSChatMessagelLayout *layout) {
        if (layout.message.model.MessageType == SSChatMessageTypeCard) {
            [weakSelf action_lookUserInfoWithModel:layout.message.model];
        }
    };
    cell.block_readVoice = ^(SSChatMessagelLayout *layout) {
        if (!layout) {
            weakSelf.isContinue = NO;
            weakSelf.isPlaying = NO;
            weakSelf.currPlayingIndex = -1;
            return;
        }
        weakSelf.currPlayingIndex = indexPath.row;
        weakSelf.isPlaying = YES;
        weakSelf.isContinue = YES;
        [weakSelf action_readMessage:layout.message.model];
    };
    
}

//视图归位
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_mInputView SetSSChatKeyBoardInputViewEndEditing];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_mInputView SetSSChatKeyBoardInputViewEndEditing];
}

#pragma SSChatKeyBoardInputViewDelegate 底部输入框代理回调
//点击按钮视图frame发生变化 调整当前列表frame
-(void)SSChatKeyBoardInputViewHeight:(CGFloat)keyBoardHeight changeTime:(CGFloat)changeTime{
    if (self.datas.count==0) {
        return;
    }
    CGFloat height = _backViewH - keyBoardHeight;
    [UIView animateWithDuration:changeTime animations:^{
        self.mBackView.frame = CGRectMake(0, 0, SCREEN_Width, height);
        self.mTableView.frame = self.mBackView.bounds;
        NSIndexPath *indexPath = [NSIndexPath     indexPathForRow:self.datas.count-1 inSection:0];
        [self.mTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    } completion:^(BOOL finished) {
        
    }];
}

//发送文本 列表滚动至底部
-(void)SSChatKeyBoardInputViewBtnClick:(NSString *)string{
    NSDictionary *dic = @{@"Message":string};
    [self action_sendMsgwithDict:@{@"Message":string}];
    [self sendMessage:dic messageType:SSChatMessageTypeText];    
}

//发送语音
-(void)SSChatKeyBoardInputViewBtnClick:(SSChatKeyBoardInputView *)view sendVoice:(NSData *)voice voicePath:(NSString *)voicePath time:(NSInteger)second{
    NSDictionary *dic = @{@"voicrData":voice,
                          @"Duration":@(second*1000)};
    [self sendMessage:dic messageType:SSChatMessageTypeVoice];
    NSDictionary *para = @{@"Type":@"AUDIO",
                           @"Duration":@(second*1000)};
    [self action_sendVoiceWith:voicePath withDict:para];
}

//多功能视图点击回调  图片10  视频11  位置12
-(void)SSChatKeyBoardInputViewBtnClickFunction:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    //相册
    if (index == 10) {
        NSLog(@"相册");
        if(!_mAddImage) _mAddImage = [[SSAddImage alloc]init];
        _mAddImage.controller = self;
        _mAddImage.wayStyle = SSImagePickerWayFormIpc;
        _mAddImage.pickerBlock = ^(SSImagePickerWayStyle wayStyle, SSImagePickerModelType modelType, id object) {
            UIImage *image = (UIImage *)object;
            NSLog(@"%@",image);
            NSDictionary *dic = @{@"image":image};
            [weakSelf sendMessage:dic messageType:SSChatMessageTypeImage];
            [weakSelf action_sendImage:image withDict:@{}];
        };
        [_mAddImage addImagePickerFromIpc:SSImagePickerModelImage];
    }
    
    //拍照
    if (index == 11) {
        NSLog(@"拍照");
        if(!_mAddImage) _mAddImage = [[SSAddImage alloc]init];
        _mAddImage.controller = self;
        _mAddImage.pickerBlock = ^(SSImagePickerWayStyle wayStyle, SSImagePickerModelType modelType, id object) {
            UIImage *image = (UIImage *)object;
            NSLog(@"%@",image);
            NSDictionary *dic = @{@"image":image};
            [weakSelf sendMessage:dic messageType:SSChatMessageTypeImage];
            [weakSelf action_sendImage:image withDict:@{}];
        };
        [_mAddImage addImagePickerFromCamer:SSImagePickerModelImage];
    }
    
    //位置
    if (index == 12) {
        NSLog(@"位置");
        
        SSChatLocationController *vc = [SSChatLocationController new];
        vc.locationBlock = ^(MAPointAnnotation *annotation) {
            NSString *position = [NSString stringWithFormat:@"latitude=%f,longitude=%f,%@",annotation.coordinate.latitude,annotation.coordinate.longitude,annotation.title];
            NSDictionary *dict = @{@"Message":position,@"Type":@"Position"};
            [self sendMessage:dict messageType:SSChatMessageTypeMap];
            [self action_sendPositonWithDict:dict];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    //发起共享
    if (index == 13) {
        [self action_shareLocation];
    }
}

//发送消息
-(void)sendMessage:(NSDictionary *)dic messageType:(SSChatMessageType)messageType{

    CB_MessageModel *model = [[CB_MessageModel alloc] init];
    if (self.model) {
        model.GroupName = self.model.GroupName;
        model.SendUserUrl = self.model.SendUserUrl;
        model.SendPhotoUrl = self.model.SendPhotoUrl;
        model.SendName = self.model.SendName;
        model.SendId = self.model.SendId;
    }else{
        if (self.groupModel) {
            model.GroupName = self.groupModel.GroupName;
            model.SendUserUrl = self.groupModel.GroupHeadPhoto;
            model.SendPhotoUrl = self.groupModel.GroupHeadPhoto;
            model.SendName = @"";
            model.SendId = self.groupModel.GroupId;
        }else if (self.friendModel){
            model.GroupName = @"";
            model.SendUserUrl = self.friendModel.HeadPhotoURL;
            model.SendPhotoUrl = self.friendModel.HeadPhotoURL;
            model.SendName = self.friendModel.MemoName.length>0?self.friendModel.MemoName:self.friendModel.NickName;
            model.SendId = self.friendModel.Guid;
        }
    }
    
    model.PostDate = [AppGeneral getAccurateCurrentDate];
    model.Guid = [AppGeneral getNowTimeTimestamp3];
    model.ReadState = YES;
    model.Message = @"";
    if (messageType == 0) {
        model.Type = @"Text";
        model.Message = dic[@"Message"];
    }
    if (messageType == 1) {
        model.Type = @"Position";
    }
    if (messageType == 2) {
        model.Type = @"Photo";
    }
    if (messageType == 3) {
        model.Type = @"Audio";
    }
    if (messageType == 4) {
        model.Type = @"Video";
    }
    
    [CB_MessageManager action_saveAction:model];

    [SSChatDatas sendMessage:dic sessionId:_sessionId messageType:messageType messageBlock:^(SSChatMessagelLayout *layout, NSError *error, NSProgress *progress) {
        [self.datas addObject:layout];
        [self.mTableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath     indexPathForRow:self.datas.count-1 inSection:0];
        [self.mTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }];
}

#pragma SSChatBaseCellDelegate 点击图片 点击短视频
-(void)SSChatImageVideoCellClick:(NSIndexPath *)indexPath layout:(SSChatMessagelLayout *)layout{
    
    NSInteger currentIndex = 0;
    NSMutableArray *groupItems = [NSMutableArray new];
    
    for(int i=0;i<self.datas.count;++i){
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        SSChatBaseCell *cell = [_mTableView cellForRowAtIndexPath:ip];
        SSChatMessagelLayout *mLayout = self.datas[i];
        
        SSImageGroupItem *item = [SSImageGroupItem new];
        if(mLayout.message.messageType == SSChatMessageTypeImage){
            item.imageType = SSImageGroupImage;
            item.fromImgView = cell.mImgView;
            item.fromImage = mLayout.message.image;
        }else if (mLayout.message.messageType == SSChatMessageTypeVideo){
            item.imageType = SSImageGroupVideo;
            item.videoPath = mLayout.message.videoLocalPath;
            item.fromImgView = cell.mImgView;
            item.fromImage = mLayout.message.videoImage;
        }
        else continue;
        
        item.contentMode = mLayout.message.contentMode;
        item.itemTag = groupItems.count + 10;
        if([mLayout isEqual:layout])currentIndex = groupItems.count;
        [groupItems addObject:item];
    }
    
    SSImageGroupView *imageGroupView = [[SSImageGroupView alloc]initWithGroupItems:groupItems currentIndex:currentIndex];
    [self.navigationController.view addSubview:imageGroupView];
    
    __block SSImageGroupView *blockView = imageGroupView;
    blockView.dismissBlock = ^{
        [blockView removeFromSuperview];
        blockView = nil;
    };
    
    [self.mInputView SetSSChatKeyBoardInputViewEndEditing];
}

#pragma SSChatBaseCellDelegate 点击定位
-(void)SSChatMapCellClick:(NSIndexPath *)indexPath layout:(SSChatMessagelLayout *)layout{
    [self action_showActivityAlert:layout];
}

-(void)action_showActivityAlert:(SSChatMessagelLayout *)layout{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"选择进入方式" preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *chatAction = [UIAlertAction actionWithTitle:@"聊天进入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf action_goActivityWith:layout inWay:0];
    }];
    UIAlertAction *navAction = [UIAlertAction actionWithTitle:@"导航进入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf action_goActivityWith:layout inWay:1];
    }];
    [alert addAction:navAction];
    [alert addAction:chatAction];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

-(void)action_goActivityWith:(SSChatMessagelLayout *)layout inWay:(NSInteger)type{
    //聊天进入
    if (type == 0) {
        CB_ActivityController *page = [CB_ActivityController new];
        [self.navigationController pushViewController:page animated:YES];
    }
    //导航进入
    if (type == 1) {
        NSString *msgStr = layout.message.model.Message;
        NSArray *strArr = [msgStr componentsSeparatedByString:@","];
        CGFloat latitude = [[[strArr[0] componentsSeparatedByString:@"="] lastObject] floatValue];
        CGFloat longitude = [[[strArr[1] componentsSeparatedByString:@"="] lastObject] floatValue];
        __weak typeof(self) weakSelf = self;
        [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
            CB_MapRouteController *route = [CB_MapRouteController new];
            route.startCoordinate = location.coordinate;
            route.endCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
            [weakSelf.navigationController pushViewController:route animated:YES];
        }];
    }
}

#pragma mark - 发送消息

#pragma mark 文本消息
-(void)action_sendMsgwithDict:(NSDictionary *)dict{
    NSMutableArray *para = dict.mutableCopy;
    [para setValue:self.SendId forKey:@"ReceiveId"];
    [[NetWorkConnect manager] postDataWith:para.copy withUrl:CHAT_MESSAGE_SEND_MESSAGE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSLog(@"发送成功");
        }
    }];
}

-(void)action_sendPositonWithDict:(NSDictionary *)dict{
    NSMutableArray *para = dict.mutableCopy;
    [para setValue:self.SendId forKey:@"ReceiveId"];
    [[NetWorkConnect manager] postDataWith:para.copy withUrl:CHAT_MESSAGE_SEND_MESSAGE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSLog(@"发送成功");
        }
    }];
}

#pragma mark 语音消息
-(void)action_sendVoiceWith:(NSString *)voicepath withDict:(NSDictionary *)dict{
    NSMutableArray *para = dict.mutableCopy;
    [para setValue:self.SendId forKey:@"ReceiveId"];
    __block NSString *finalMp3path = [AppGeneral tempMp3UrlWithTime];
    [ConvertAudioFile conventToMp3WithCafFilePath:voicepath mp3FilePath:finalMp3path sampleRate:ETRECORD_RATE callback:^(BOOL result){
        if (result) {
            [[NetWorkConnect manager] postAudioWith:finalMp3path postDataWith:para.copy withUrl:CHAT_MESSAGE_SEND_MESSAGE withFileName:@"Audio" withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
                if (resultCode == 1) {
                    NSLog(@"发布音频成功");
                }
            }];
        }
    }];
}

#pragma mark 图片消息
-(void)action_sendImage:(UIImage *)image withDict:(NSDictionary *)dict{
    NSMutableArray *para = dict.mutableCopy;
    [para setValue:self.SendId forKey:@"ReceiveId"];
    NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
    [[NetWorkConnect manager] postImageWith:imgData postDataWith:para.copy withUrl:CHAT_MESSAGE_SEND_MESSAGE withFileName:@"Photo" withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSLog(@"发送照片成功");
        }
    }];
}

#pragma mark 视频消息
-(void)action_sendVideo:(NSString *)videoPath withDict:(NSDictionary *)dict{
    NSMutableArray *para = dict.mutableCopy;
    [para setValue:self.SendId forKey:@"ReceiveId"];
    [para setValue:@(4) forKey:@"Type"];
    [[NetWorkConnect manager] uploadVideoWithExportUrl:[NSURL fileURLWithPath:videoPath] with:CHAT_MESSAGE_SEND_MESSAGE WithDic:para.copy withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSLog(@"发送视频成功");
        }
    }];
}

#pragma mark 查看用户信息
-(void)action_lookUserInfoWithModel:(CB_MessageModel *)msgModel{
    if ([msgModel.SendUserId isEqualToString:[UserModel shareInstance].Guid]) {
        MyUserInfoController *page = [MyUserInfoController new];
        [self.navigationController pushViewController:page animated:YES];
    }else{
        ContrractUserInfoController *page = [ContrractUserInfoController new];
        CB_FriendModel *friendModel = [[CB_FriendModel alloc] init];
        friendModel.FriendId = msgModel.SendUserId;
        page.friendModel = friendModel;
        if (!msgModel.IsGroup) {
            page.isFromChatSignal = YES;
        }
        [self.navigationController pushViewController:page animated:YES];
    }
}

-(void)action_readAllMessageWithMessage:(NSArray *)messages{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.unreadAudioMessage removeAllObjects];
        for (int i = 0; i<messages.count; i++) {
            SSChatMessagelLayout *layout = messages[i];
            CB_MessageModel *mm = layout.message.model;
            if (!mm.ReadState) {
                if (![mm.Type isEqualToString:@"Audio"]) {
                    [self action_readMessage:mm];
                }else{
                    [self action_logUnreadAudioMessage:mm AtIndex:i];
                }
            }
        }
    });
}

//记录所有未读的语音消息
-(void)action_logUnreadAudioMessage:(CB_MessageModel *)model AtIndex:(NSInteger)index{
    if (!model.ReadState) {
        [self.unreadAudioMessage addObject:@(index)];
    }
}

-(void)action_readMessage:(CB_MessageModel *)model{
    if (!model) {
        return;
    }
    if (model.ReadState) {
        
        return;
    }
    
    for (int i = 0; i < self.datas.count; i++) {
        SSChatMessagelLayout *layout = self.datas[i];
        if ([layout.message.model.Guid isEqualToString:model.Guid]) {
            [self.unreadAudioMessage removeObject:@(i)];
//            [self.mTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }

    NSString *url = CHAT_MESSAGE_CHANGEISREAD;
    NSDictionary *para = @{@"SendId":model.SendId};
    //语音文件
    if ([model.Type isEqualToString:@"Audio"]) {
        url = CHAT_MESSAGE_READAUDIO;
        para =@{@"Guid":model.Guid};
    }
    [[NetWorkConnect manager] postDataWith:para withUrl:url withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSLog(@"消息设置已读");
            model.ReadState = YES;
            [CB_MessageManager action_saveAction:model];
        }
    }];
}

#pragma mark - 事件

-(void)action_showChat{
    
}

-(void)action_showMap{
    
}

-(void)action_showAll{
    
}


-(void)action_shareLocation{
    __weak typeof(self) weakSelf = self;
    [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
        
        NSString *position = [NSString stringWithFormat:@"latitude=%f,longitude=%f,%@",location.coordinate.latitude,location.coordinate.longitude,formattedAddress];
        NSDictionary *dict = @{@"Message":position,@"ReceiveId":weakSelf.SendId};
        [weakSelf action_shareLocationWithDict:dict];
    }];
}

-(void)action_shareLocationWithDict:(NSDictionary *)para{
    
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_MESSAGE_SHARE_LOCATION withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            
        }
    }];
}

-(void)action_playNext{
    
    if ([self.unreadAudioMessage containsObject:@(self.currPlayingIndex)]) {
        [self.unreadAudioMessage removeObject:@(self.currPlayingIndex)];
    }
    
    [self.mTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currPlayingIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

    if (!self.isContinue) {
        return;
    }
    
    NSInteger nextIndex = -1;
    for (int i = 0; i<self.unreadAudioMessage.count; i++) {
        NSInteger index = [self.unreadAudioMessage[i] integerValue];
        if (index>self.currPlayingIndex) {
            nextIndex = index;
            break;
        }
    }
    
    self.currPlayingIndex = nextIndex;
    
    if (nextIndex == -1) {
        self.isPlaying = NO;
        return;
    }
    [self.mTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nextIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    self.isPlaying = YES;
}

-(void)action_onNewMessage:(NSNotification *)notification{
    CB_MessageModel *model = notification.object;
    if ([model.SendId isEqualToString:self.model.SendId]) {
        SSChatMessagelLayout *layout = [SSChatDatas getMessageWithDic:[model dictionaryRepresentation]];
        [self.datas addObject:layout];
        [self.mTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        [self.mTableView reloadData];
        if (model.MessageType != SSChatMessageTypeVoice) {
            [self action_readMessage:model];
        }else{
            [self.unreadAudioMessage addObject:@(self.datas.count)];
            if (!self.isPlaying&&self.isAuto) {//当前没有播放音频，并且是自动播放
                [self action_playNext];
            }
        }
    }
    NSLog(@"");
}

-(void)action_showlongGesture:(SSChatMessagelLayout *)layout{
    NSMutableArray *titles = @[].mutableCopy;
    if (layout.message.model.Collect) {
        [titles addObject:@"取消收藏"];
    }else{
        [titles addObject:@"加入收藏"];
    }
    [titles addObject:@"收藏列表"];
    [titles addObject:@"转发"];
    [titles addObject:layout.message.model.SendPhone];
    
    CyActionSheet *alert = [[CyActionSheet alloc] initWithTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:titles];
    __weak typeof(self) weakSelf = self;
    [alert showActionSheet:^(id obj) {
        if ([obj isEqualToString:@"取消收藏"]) {
            NSDictionary *para = @{@"Guid":layout.message.model.Guid};
            [weakSelf action_sendCollectionToServer:para];
        }
        if ([obj isEqualToString:@"加入收藏"]) {
            [weakSelf action_collecteAction:layout];
        }
        if ([obj isEqualToString:@"收藏列表"]) {
            [weakSelf action_collectionList];
        }
        if ([obj isEqualToString:@"转发"]) {
            [weakSelf action_transWith:layout];
        }
        if ([obj isEqualToString:layout.message.model.SendPhone]) {
            [weakSelf action_callPhone:layout.message.model.SendPhone];
        }
    }];
}

-(void)action_transWith:(SSChatMessagelLayout *)layout{
    CB_MessageTransController *page = [CB_MessageTransController new];
    page.model = layout.message.model;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_callPhone:(NSString *)phoneStr{
    NSString *phone = [NSString stringWithFormat:@"tel:%@",phoneStr];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:phone]]];
    [self.view addSubview:callWebview];
}

//收藏列表
-(void)action_collectionList{
    CollectionlistController *page = [CollectionlistController new];
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_collecteAction:(SSChatMessagelLayout *)layout{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"收藏备注" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *textField = alertController.textFields.firstObject;
        NSDictionary *para = @{@"Guid":layout.message.model.Guid,@"Edit":@(YES),@"CollectName":textField.text};
        [self action_sendCollectionToServer:para];
    }]];
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入备注";
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)action_sendCollectionToServer:(NSDictionary *)para{
    [[NetWorkConnect manager] postDataWith:para withUrl:COLLECT_MESSAGE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        CB_MessageModel *mm = [CB_MessageModel modelWithDictionary:responseObject];
        [self action_refreshCollectStateWith:mm];
        if (para.allKeys.count == 3) {
            [AppGeneral showMessage:@"收藏成功" andDealy:1];
        }else{
            [AppGeneral showMessage:@"取消收藏成功" andDealy:1];
        }
    }];
}

-(void)action_refreshCollectStateWith:(CB_MessageModel *)model{
    NSMutableArray *arr = self.datas;
    for (int i = 0 ; i<arr.count; i++) {
        SSChatMessagelLayout *mLayout = arr[i];
        if ([mLayout.message.model.Guid isEqualToString:model.Guid]) {
            mLayout.message.model = model;
            [self.datas replaceObjectAtIndex:i withObject:mLayout];
            break;
        }
    }
}

@end
