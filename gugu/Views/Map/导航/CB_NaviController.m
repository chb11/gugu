//
//  CB_NaviController.m
//  gugu
//
//  Created by Mike Chen on 2019/5/26.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_NaviController.h"
#import "CB_NaviMapView.h"
#import "CB_GroupInfoController.h"
#import "AIRobotManager.h"
#import "SSChatKeyBoardInputView.h"
#import "SSAddImage.h"
#import "SSChatBaseCell.h"
#import "SSChatLocationController.h"
#import "SSImageGroupView.h"
#import "MyUserInfoController.h"
#import "ContrractUserInfoController.h"
#import "CyActionSheet.h"
#import "AIRobotManager.h"
#import "CB_MessageTransController.h"
#import "CollectionlistController.h"
#import "CB_GroupInfoController.h"
#import "SSChatVoiceCell.h"
#import "CB_TopUserListView.h"
#define ETRECORD_RATE 44100

typedef enum : NSUInteger {
    CB_CHAT_TYPE_ALL = 0,//所有
    CB_CHAT_TYPE_Chat,//聊天
    CB_CHAT_TYPE_MAP,//地图
    CB_CHAT_TYPE_Rect,//分屏
} CB_CHAT_TYPE;

@interface CB_NaviController ()<SSChatKeyBoardInputViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,SSChatBaseCellDelegate>
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

@property (nonatomic,assign) CB_CHAT_TYPE chatViewType;
@property (nonatomic,strong) CB_NaviMapView *mapView;
@property (nonatomic,assign) BOOL isFirstIn;

@property (nonatomic,strong) CB_ActivityGroupModel *activitGroupModel;
@property (nonatomic,strong) NSTimer *_timer;
@property (nonatomic,strong) NSTimer *checktimer;
@property (nonatomic,strong) CB_TopUserListView *userListView;

@property (nonatomic, strong) NSMutableArray *activityUsers;

/** 下拉菜单 */
@property (nonatomic,strong) FFDropDownMenuView *dropdownMenu;

@end

@implementation CB_NaviController

-(instancetype)init{
    if(self = [super init]){
        
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

    self.title = @"咕咕";
    [self initChatUI];
    self.mapView.routeType = self.routeType;
    self.mapView.strategy = self.strategy;
    self.mapView.startPoint = self.startPoint;
    self.mapView.endPoint = self.endPoint;
    self.mapView.rideManager = self.rideManager;
    self.mapView.walkManager = self.walkManager;
    [self.mapView action_startNavi];
    [self.view addSubview:self.mapView];
    if (self.isFromChat) {
        self.title = @"1人";
        [self initData];
        [self initAction];
//        [self action_readMessage:self.model];
        [self action_initActivity];
    }
    if (self.isFromChat &&self.isGroupNavi) {
        [self.view addSubview:self.userListView];
        self.mapView.frame = CGRectMake(0, self.userListView.height, SCREEN_WIDTH, self.mapView.height-self.userListView.height);
    }
    self.mapView.DriverRouteid = self.DriverouteID;
    [self action_needOnlyNavi:!self.isFromChat];
}

-(void)action_needOnlyNavi:(BOOL)isOnlyNavi{
    if (isOnlyNavi) {
        self.chatViewType = CB_CHAT_TYPE_MAP;
        [self action_configOnlyNaviButtons];
        
    }else{
        self.chatViewType = CB_CHAT_TYPE_Rect;
        [self action_configNavButtons];
    }
    [self setupDropDownMenu];
}

-(void)action_configOnlyNaviButtons{
    self.title = @"咕咕";
    self.btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn_back addTarget:self action:@selector(action_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_back setFrame:CGRectMake(0,0,22,40)];
    self.btn_back.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.btn_back.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.btn_back setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.btn_back];
    self.navigationItem.leftBarButtonItems  = @[backItem];
    
    self.btn_more = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn_more addTarget:self action:@selector(action_chooseHistory) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_more setImage:[UIImage imageNamed:@"huihua.png"] forState:UIControlStateNormal];
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
    self.navigationItem.rightBarButtonItems  = @[moreItem];
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
    if (@available(iOS 9.0, *)) {
        [self.btn_huanxing setFrame:CGRectMake(0,0,24,24)];
        [self.btn_huanxing.widthAnchor constraintEqualToConstant:24].active = YES;
        [self.btn_huanxing.heightAnchor constraintEqualToConstant:24].active = YES;
    } else {
        [self.btn_huanxing setFrame:CGRectMake(0,0,24,24)];
        self.btn_huanxing.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    [self.btn_huanxing setImage:[UIImage imageNamed:@"voice_off.png"] forState:UIControlStateNormal];
    [self.btn_huanxing setImage:[UIImage imageNamed:@"voice_on.png"] forState:UIControlStateSelected];
    self.btn_huanxing.tintColor = [UIColor whiteColor];
    UIBarButtonItem *hxItem = [[UIBarButtonItem alloc] initWithCustomView:self.btn_huanxing];
    self.navigationItem.leftBarButtonItems  = @[backItem,hxItem];
    
    self.btn_more = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn_more addTarget:self action:@selector(action_more) forControlEvents:UIControlEventTouchUpInside];
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
    
    if (!self.isGroupNavi) {
        UIButton *btnConvc = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnConvc addTarget:self action:@selector(action_chooseHistory) forControlEvents:UIControlEventTouchUpInside];
        [btnConvc setImage:[UIImage imageNamed:@"huihua.png"] forState:UIControlStateNormal];
        if (@available(iOS 9.0, *)) {
            [btnConvc setFrame:CGRectMake(0,0,24,24)];
            [btnConvc.widthAnchor constraintEqualToConstant:24].active = YES;
            [btnConvc.heightAnchor constraintEqualToConstant:24].active = YES;
        } else {
            btnConvc.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
            [btnConvc setFrame:CGRectMake(0,0,40,40)];
        }
        
        btnConvc.tintColor = [UIColor whiteColor];
        UIBarButtonItem *Convc = [[UIBarButtonItem alloc] initWithCustomView:btnConvc];
        self.navigationItem.rightBarButtonItems  = @[moreItem,Convc];
    }else{
        self.navigationItem.rightBarButtonItems  = @[moreItem];
    }

}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRecordin) name:@"map_startRecord" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedRecord) name:@"map_finishedRecord" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action_onNewMessage:) name:NOTIFICATION_SOCKET_MESSAGE_RECEIVED object:nil];
    if (self.isGroupNavi) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action_userPostitionUpdate:) name:NOTIFICATION_SOCKET_POSITION_RECEIVED object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action_playNext) name:NOTIFICATION_AUDIO_PLAY_FINISHED object:nil];
    if (self.isFromChat) {
        [self action_initActivity];
    }
    [self action_joinAndExitSession];
}

-(void)action_joinAndExitSession{
    if (self.SendId.length>0) {
        NSDictionary *para = @{@"UserId":[UserModel shareInstance].Guid,
                               @"SendId":self.SendId};
        [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_MESSAGE_CHANGEISREAD withResult:^(NSInteger resultCode, id responseObject, NSError *error) {

        }];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SOCKET_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_AUDIO_PLAY_FINISHED object:nil];
    [[AIRobotManager shareInstance] action_closeAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"map_startRecord" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"map_finishedRecord" object:nil];
    [self action_stopTimer];
    [self.mapView action_closeNavi];
    [[UUAVAudioPlayer sharedInstance] stopSound];
    [self action_joinAndExitSession];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     if (self.isFromChat) {
        if (self.isFirstIn) {
            if (self.mTableView.contentSize.height>0) {
            }else{
                [self.mTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
            }
            [self action_refreshHistory];
        }
     }
}

-(void)initChatUI{
    
    self.navigationItem.title = _titleString;
    self.view.backgroundColor = [UIColor whiteColor];
    self.unreadAudioMessage = @[].mutableCopy;

    _mInputView = [SSChatKeyBoardInputView new];
    _mInputView.delegate = self;
    _mInputView.isShowRealTime = NO;
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
    self.userListView.block_clickuser = ^(CB_MessageModel * _Nonnull model) {
        waekSelf.mapView.selectUserId = model.SendUserId;
        [waekSelf.mapView action_updateUserPosition];
    };
}


-(void)action_changeTargetToServerWith:(MAPointAnnotation * _Nonnull )annotaion{
    NSString *routeStr = [@{@"address":annotaion.title,@"latitude":@(annotaion.coordinate.latitude),@"longitude":@(annotaion.coordinate.longitude)} modelToJSONString];
    NSDictionary *para = @{@"Guid":self.activitGroupModel.Guid,@"Route":routeStr};
    [[NetWorkConnect manager] postDataWith:para withUrl:ACTIVITY_ACTIVITY_ROUTE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"已成功切换位置" andDealy:1];
        }
    }];
}


-(void)action_initActivity{
    if (self.model) {
        NSDictionary *para = @{@"MessageWithUserId":self.model.Guid};
        [[NetWorkConnect manager] postDataWith:para withUrl:ACTIVITY_EDIT_TEMP_ACTIVITY withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                self.activitGroupModel = [CB_ActivityGroupModel modelWithDictionary:responseObject];
                [self action_initTimer];
            }
        }];
    }
}

-(void)setActivitGroupModel:(CB_ActivityGroupModel *)activitGroupModel{
    _activitGroupModel = activitGroupModel;
    [self updateLocationToServer];
}

-(void)action_initTimer{
    [self action_stopTimer];
    if (self.isGroupNavi) {
        self._timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateLocationToServer) userInfo:nil repeats:YES];
        [self._timer fire];
        self.checktimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(action_checkUserOnline) userInfo:nil repeats:YES];
        [self.checktimer fire];
    }
}

-(void)action_stopTimer{
    if (self._timer) {
        [self._timer invalidate];
        self._timer = nil;
    }
    if (self.checktimer) {
        [self.checktimer invalidate];
        self.checktimer = nil;
    }
}

//像服务器更新位置
-(void)updateLocationToServer{
    
    [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
        NSDictionary *para = @{@"GroupId":self.activitGroupModel.Guid,
                               @"Lat":@(location.coordinate.latitude),
                               @"Lng":@(location.coordinate.longitude),
                               @"Message":self.mapView.currNaviInfo,
                               @"ClientIds":self.activitGroupModel.Guid,
                               };
         
        [[NetWorkConnect manager] postDataWith:para withUrl:ACTIVITY_JOIN_ACTIVITY withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                
            }
        }];
    }];
    
}


-(void)refreshWithItems:(NSArray *)items{
    if (items.count==0) {
        [AppGeneral showMessage:@"没有更多消息了" andDealy:1];
        return;
    }
    
    NSArray *newDatas = [SSChatDatas receiveMessages:[self sortedArrayFrom:items]];
    [self.datas insertObjects:newDatas atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newDatas.count)]];
    [self action_readAllMessageWithMessage:self.datas];
    
    [self.mTableView reloadData];
    /* 滚动指定段的指定row  到 指定位置*/
    [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:items.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

//更新活动中用户位置
-(void)action_userPostitionUpdate:(NSNotification *)notification{
    CB_MessageModel *msgModel = notification.object;
    if ([msgModel.ActivityId isEqualToString:self.activitGroupModel.Guid]) {
        
        NSArray *arr = self.activityUsers.copy;
        BOOL isExist = NO;
        for (int i =0;i<arr.count; i++) {
            CB_MessageModel *model = arr[i];
            if ([model.SendUserId isEqualToString:msgModel.SendUserId]) {
                isExist = YES;
                [self.activityUsers replaceObjectAtIndex:i withObject:msgModel];
                break;
            }
        }
        if (!isExist) {
            [self.activityUsers addObject:msgModel];
            CB_MessageModel *newMsgModel = [[CB_MessageModel alloc] init];
            newMsgModel.SendUserId = msgModel.SendUserId;
            newMsgModel.SendName = msgModel.SendName;
            newMsgModel.SendPhotoUrl = msgModel.SendPhotoUrl;
            newMsgModel.MessageType =SSChatMessageTypeText;
            newMsgModel.SenderType = SSChatMessageFromOther;
            newMsgModel.isTemp = YES;
            newMsgModel.PostDate = [AppGeneral getAccurateCurrentDate];
            newMsgModel.Message = [NSString stringWithFormat:@"%@进来了",msgModel.SendName];
            SSChatMessagelLayout *layout = [SSChatDatas getMessageWithDic:[AppGeneral dictionaryWithJsonString:newMsgModel.modelToJSONString]];
            [self.datas addObject:layout];
            [self.mTableView reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.datas.count-1 inSection:0];
            [self.mTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        self.mapView.activityUsers = self.activityUsers;
        self.userListView._dataSource = self.activityUsers;
        [self.mapView action_updateUserPosition];
        self.title = [NSString stringWithFormat:@"%ld人",self.activityUsers.count+1];
    }
}

-(void)action_checkUserOnline{
    NSMutableArray *m_arr = self.activityUsers.mutableCopy;
    
    NSMutableArray *leaveArr = @[].mutableCopy;
    for (int i = 0; i<self.activityUsers.count; i++) {
        CB_MessageModel *model = self.activityUsers[i];
        NSTimeInterval interval = [AppGeneral pleaseInsertStarTime:model.PostDate andInsertEndTime:[AppGeneral getAccurateCurrentDate]];
        if (interval>10) {
            [leaveArr addObject:model];
            [m_arr removeObject:model];
        }
    }
    self.activityUsers = m_arr;
    self.mapView.activityUsers = m_arr;
    [self.mapView action_updateUserPosition];
    self.userListView._dataSource = m_arr;
    
    if (leaveArr.count>0) {
        for (int i = 0; i<leaveArr.count; i++) {
            CB_MessageModel *model = leaveArr[i];
            model.MessageType =SSChatMessageTypeText;
            model.SenderType = SSChatMessageFromOther;
            model.isTemp = YES;
            model.PostDate = [AppGeneral getAccurateCurrentDate];
            model.Message = [NSString stringWithFormat:@"%@离开了",model.SendName];
            SSChatMessagelLayout *layout = [SSChatDatas getMessageWithDic:[AppGeneral dictionaryWithJsonString:model.modelToJSONString]];
            [self.datas addObject:layout];
            [self.mTableView reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.datas.count-1 inSection:0];
            [self.mTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
             self.title = [NSString stringWithFormat:@"%ld人",self.activityUsers.count+1];
        }
    }
    
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
    page.groupId = self.SendId;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)startRecordin{
    
    [self.mInputView beginRecordVoice:nil];
}
-(void)finishedRecord{
    [self.mInputView endRecordVoice:nil];
}

-(void)setChatViewType:(CB_CHAT_TYPE)chatViewType{
    _chatViewType = chatViewType;
    [_mInputView SetSSChatKeyBoardInputViewEndEditing];
    //所有
    if (chatViewType%4 == 0) {
        [self.view sendSubviewToBack:self.userListView];
        [self.view sendSubviewToBack:self.mapView];
        _mBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _mBackView.frame = CGRectMake(0, 0, SCREEN_Width, _backViewH);
        self.mTableView.frame = _mBackView.bounds;
        [self.view bringSubviewToFront:_mBackView];
        [self.view bringSubviewToFront:self.mInputView];
    }
    //聊天
    if (chatViewType%4 == 1) {
        [self.view sendSubviewToBack:self.userListView];
        [self.view sendSubviewToBack:self.mapView];
        [self.view bringSubviewToFront:_mBackView];
        [self.view bringSubviewToFront:self.mInputView];
        _mBackView.backgroundColor = SSChatCellColor;
        _mBackView.frame = CGRectMake(0, 0, SCREEN_Width, _backViewH);
        self.mTableView.frame = _mBackView.bounds;
    }
    //地图
    if (chatViewType%4 == 2) {
        [self.view bringSubviewToFront:self.userListView];
        [self.view bringSubviewToFront:self.mapView];
    }
    //分屏
    if (chatViewType%4 == 3) {
        [self.view sendSubviewToBack:self.userListView];
        [self.view sendSubviewToBack:self.mapView];
        _mBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _mBackView.frame = CGRectMake(0, _backViewH/2, SCREEN_Width, _backViewH/2);
        self.mTableView.frame = _mBackView.bounds;
        [self.view bringSubviewToFront:_mBackView];
        [self.view bringSubviewToFront:self.mInputView];
        //        [self action_showChat];
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
            self.mTableView.currPage = 0;
            NSArray *items = responseObject[@"list"];
            self.datas = [SSChatDatas receiveMessages:[self sortedArrayFrom:items]];
            [self action_readAllMessageWithMessage:self.datas];
            [self.mTableView reloadData];
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
    SSChatMessagelLayout *layout = (SSChatMessagelLayout *)_datas[indexPath.row];
    if (layout.message.messageType == SSChatMessageTypeImage) {
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:layout.message.model.FileUrlURL];
        CGFloat imgWidth  = CGImageGetWidth(image.CGImage);
        CGFloat imgHeight = CGImageGetHeight(image.CGImage);
        CGFloat imgActualHeight = SSChatImageMaxSize;
        CGFloat imgActualWidth =  SSChatImageMaxSize * imgWidth/imgHeight;
        if(imgActualWidth>SSChatImageMaxSize){
            imgActualWidth = SSChatImageMaxSize;
            imgActualHeight = imgActualWidth * imgHeight/imgWidth;
        }
        if(imgActualWidth<SSChatImageMaxSize*0.25){
            imgActualWidth = SSChatImageMaxSize * 0.25;
            imgActualHeight = SSChatImageMaxSize * 0.8;
        }
        
        return imgActualHeight+SSChatCellBottom+SSChatTimeTop+SSChatTimeBottom+SSChatTimeHeight;
    }
    return [(SSChatMessagelLayout *)_datas[indexPath.row] cellHeight];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SSChatMessagelLayout *layout = _datas[indexPath.row];
    SSChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:layout.message.cellString];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.redFlag.hidden = YES;
    cell.indexPath = indexPath;
    [self configCell:cell atIndex:indexPath];
    if (layout.message.model.MessageType != SSChatMessageTypeImage) {
        cell.layout = layout;
    }
    
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
    }else if (layout.message.model.MessageType == SSChatMessageTypeImage){
        SSChatMessage *message = layout.message;
        if (message.image) {
            cell.layout = layout;
            return cell;
        }
        NSString *imgURL = layout.message.model.FileUrlURL;
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgURL];
        if ( !cachedImage ) {
            [self downloadImage:imgURL forIndexPath:indexPath];
        }else{
            cell.layout = layout;
        }
    }
    return cell;
}

- (void)downloadImage:(NSString *)imageURL forIndexPath:(NSIndexPath *)indexPath {
    
    // 利用 SDWebImage 框架提供的功能下载图片
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        
        if (!image) {
            return ;
        }
        
        [[SDImageCache sharedImageCache] storeImage:image forKey:imageURL toDisk:YES completion:^{
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            SSChatMessagelLayout *layout = self.datas[indexPath.row];
            SSChatMessage *message = layout.message;
            message.image = image;
            SSChatMessagelLayout  *newlayout = [[SSChatMessagelLayout alloc] initWithMessage:message];
            [self.datas replaceObjectAtIndex:indexPath.row withObject:newlayout];
            [self.mTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            //            [self.mTableView reloadData];
        });
        
    }];
    
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
            [weakSelf action_seeUserInfoFromCardJson:layout.message.model.Message];
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
    [UIView animateWithDuration:changeTime animations:^{
        self.mBackView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -keyBoardHeight);
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
//        model.GroupName = self.model.GroupName;
//        model.SendUserUrl = self.model.SendUserUrl;
//        model.SendPhotoUrl = self.model.SendPhotoUrl;
//        model.SendName = self.model.SendName;
//        model.SendId = self.model.SendId;
//        model.GuUserId = self.model.GuUserId;
//        model.GuUserName = self.model.GuUserName;
//        model.GuUserHeadUrl = self.model.GuUserHeadUrl;
//        model.IsGroup = self.model.IsGroup;
        model = self.model;
    }else{
        if (self.groupModel) {
            model.GroupName = self.groupModel.GroupName;
            model.SendUserUrl = [UserModel shareInstance].HeadPhotoURL;
            model.SendPhotoUrl = [UserModel shareInstance].HeadPhotoURL;
            model.SendName = @"";
            model.GroupHeadPhoto = self.groupModel.GroupHeadPhoto;
            model.SendId = self.groupModel.GroupId;
            model.IsGroup = YES;
        }else if (self.friendModel){
            model.GroupName = @"";
            model.SendUserUrl = self.friendModel.HeadPhotoURL;
            model.SendPhotoUrl = self.friendModel.HeadPhotoURL;
            model.SendName = self.friendModel.MemoName.length>0?self.friendModel.MemoName:self.friendModel.NickName;
            model.SendId = self.friendModel.Guid;
            model.GuUserId = self.friendModel.Guid;
            model.GuUserName = model.SendName;
            model.GuUserHeadUrl = self.friendModel.HeadPhotoURL;
        }
    }
    
    model.PostDate = [AppGeneral getAccurateCurrentDate];
    model.Guid = [AppGeneral getNowTimeTimestamp3];
    model.ReadState = YES;
    model.Message = @"";
    if (messageType == 0) {
        model.Type = @"Text";
        model.Message = dic[@"Message"];
        model.Abbr = dic[@"Message"];
    }
    if (messageType == 1) {
        model.Type = @"Position";
        model.Message = dic[@"Message"];
        model.Abbr = @"[位置]";
    }
    if (messageType == 2) {
        model.Type = @"Photo";
        model.image = dic[@"image"];
        model.Abbr = @"[图片]";
    }
    if (messageType == 3) {
        model.Type = @"Audio";
        model.voicrData = dic[@"voicrData"];
        model.Duration = [dic[@"Duration"] floatValue];
        model.Abbr = [NSString stringWithFormat:@"语音 %ds",[dic[@"Duration"] intValue]];
    }
    if (messageType == 4) {
        model.Type = @"Video";
    }
    if (model.IsGroup) {
        model.Abbr = [NSString stringWithFormat:@"%@:%@",[UserModel shareInstance].UserName,model.Abbr];
    }
    [CB_MessageManager action_saveAction:model];
    NSMutableDictionary *m_dict = [AppGeneral dictionaryWithJsonString:[model modelToJSONString]].mutableCopy;
    if (messageType == 3) {
        [m_dict setValue:dic[@"voicrData"] forKey:@"voicrData"];
        [m_dict setValue:dic[@"Duration"] forKey:@"Duration"];
    }
    
    [SSChatDatas sendMessage:m_dict withImage:model.image sessionId:_SendId messageType:messageType messageBlock:^(SSChatMessagelLayout *layout, NSError *error, NSProgress *progress) {
        [self.datas addObject:layout];
        [self.mTableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.datas.count-1 inSection:0];
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
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"选择进入方式" preferredStyle:UIAlertControllerStyleAlert];
    //
    //    __weak typeof(self) weakSelf = self;
    //    UIAlertAction *chatAction = [UIAlertAction actionWithTitle:@"聊天进入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        [weakSelf action_goActivityWith:layout inWay:0];
    //    }];
    //    UIAlertAction *navAction = [UIAlertAction actionWithTitle:@"导航进入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        [weakSelf action_goActivityWith:layout inWay:1];
    //    }];
    //    [alert addAction:navAction];
    //    [alert addAction:chatAction];
    //    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

/** 初始化下拉菜单 */
- (void)setupDropDownMenu {
    NSArray *modelsArray = [self getMenuModelsArray];
    self.dropdownMenu = [FFDropDownMenuView ff_DefaultStyleDropDownMenuWithMenuModelsArray:modelsArray menuWidth:90 eachItemHeight:35 menuRightMargin:FFDefaultFloat triangleRightMargin:18];
    //如果有需要，可以设置代理（非必须）
    self.dropdownMenu.ifShouldScroll = NO;
    [self.dropdownMenu setup];
}

/** 获取菜单模型数组 */
- (NSArray *)getMenuModelsArray {
    __weak typeof(self) weakSelf = self;
    
    //菜单模型0
//    FFDropDownMenuModel *menuModel0 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"重叠" menuItemIconName:@"pop_chat_cd"  menuBlock:^{
//        weakSelf.chatViewType = CB_CHAT_TYPE_ALL;
//    }];
    
    //菜单模型1
    FFDropDownMenuModel *menuModel1 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"聊天" menuItemIconName:@"pop_chat_only" menuBlock:^{
        
        weakSelf.chatViewType = CB_CHAT_TYPE_Chat;
    }];
    //菜单模型1
    FFDropDownMenuModel *menuModel2 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"分屏" menuItemIconName:@"pop_chat_fp" menuBlock:^{
        weakSelf.chatViewType = CB_CHAT_TYPE_Rect;
    }];
    //菜单模型1
    FFDropDownMenuModel *menuModel3 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"地图" menuItemIconName:@"pop_chat_map" menuBlock:^{
        weakSelf.chatViewType = CB_CHAT_TYPE_MAP;
    }];
    //菜单模型1
    FFDropDownMenuModel *menuModel4 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"详情" menuItemIconName:@"pop_chat_dt" menuBlock:^{
        [weakSelf action_seeInfo];
    }];
    //菜单模型1
    FFDropDownMenuModel *menuModel5 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"取消" menuItemIconName:@"quxiao" menuBlock:^{
        [weakSelf action_cancelConversation];
    }];
    NSArray *menuModelArr = @[];
    if (self.isGroupNavi) {
        menuModelArr = @[menuModel1,menuModel2,menuModel3,menuModel4];
    }else{
        menuModelArr = @[menuModel1,menuModel2,menuModel3,menuModel4,menuModel5];
    }
    
    return menuModelArr;
}

-(void)action_cancelConversation{
    
    [self action_needOnlyNavi:YES];
}

-(void)action_more{
    [self.dropdownMenu showMenu];
}

-(void)action_seeInfo{
    if (self.model.IsGroup||self.groupModel) {
        CB_GroupInfoController *page = [CB_GroupInfoController new];
        page.groupId = self.SendId;
        [self.navigationController pushViewController:page animated:YES];
    }else{
        ContrractUserInfoController *page = [ContrractUserInfoController new];
        CB_FriendModel *friendModel = [[CB_FriendModel alloc] init];
        friendModel.FriendId = self.SendId;
        page.friendModel = friendModel;
        if (!self.model.IsGroup) {
            page.isFromChatSignal = YES;
        }
        [self.navigationController pushViewController:page animated:YES];
    }
}

-(void)action_seeUserInfoFromCardJson:(NSString *)json{
    CB_UserCardModel *model = [CB_UserCardModel modelWithJSON:json];
    ContrractUserInfoController *page = [ContrractUserInfoController new];
    CB_FriendModel *friendModel = [[CB_FriendModel alloc] init];
    friendModel.FriendId = model.Guid;
    page.friendModel = friendModel;
    [self.navigationController pushViewController:page animated:YES];
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
    
    [self.unreadAudioMessage removeAllObjects];
    for (int i = 0; i<messages.count; i++) {
        SSChatMessagelLayout *layout = messages[i];
        CB_MessageModel *mm = layout.message.model;
        if (!mm.ReadState) {
            if (![mm.Type isEqualToString:@"Audio"]) {
//                [self action_readMessage:mm];
            }else{
                [self action_logUnreadAudioMessage:mm AtIndex:i];
            }
        }
    }
    
}

//记录所有未读的语音消息
-(void)action_logUnreadAudioMessage:(CB_MessageModel *)model AtIndex:(NSInteger)index{
    if (!model.ReadState) {
        [self.unreadAudioMessage addObject:@(index)];
    }
}

-(void)action_readMessage:(CB_MessageModel *)model{
    if (!model||!model.SendId) {
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
    
    NSString *url = @"";
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

-(void)action_chooseHistory{
    
    CB_MessageTransController *page = [CB_MessageTransController new];
    __weak typeof(self) weakSelf = self;
    page.block_chooseConvertion = ^(NSString *sendid, id  _Nonnull modelObject) {
        weakSelf.SendId = sendid;
        weakSelf.isFromChat = YES;
        if ([modelObject isKindOfClass:[CB_MessageModel class]]) {
            weakSelf.model = modelObject;
        }
        if ([modelObject isKindOfClass:[CB_GroupModel class]]) {
            weakSelf.groupModel = modelObject;
        }
        if ([modelObject isKindOfClass:[CB_FriendModel class]]) {
            weakSelf.friendModel = modelObject;
        }
        [weakSelf initData];
        [weakSelf initAction];
        [weakSelf action_refreshHistory];
        [weakSelf action_needOnlyNavi:NO];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:page];
    [self presentViewController:nav animated:YES completion:nil];
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
    
    if (nextIndex >= self.datas.count) {
        self.currPlayingIndex = -1;
        self.isPlaying = NO;
        return;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        CB_MessageModel *model = notification.object;
        if ([model.SendId isEqualToString:self.model.SendId]) {
            SSChatMessagelLayout *layout = [SSChatDatas getMessageWithDic:[model dictionaryRepresentation]];
            [self.datas addObject:layout];
            [self.mTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
            [self.mTableView reloadData];
            if (model.MessageType != SSChatMessageTypeVoice) {
//                [self action_readMessage:model];
            }else{
                [self.unreadAudioMessage addObject:@(self.datas.count)];
                if (!self.isPlaying&&self.isAuto) {//当前没有播放音频，并且是自动播放
                    [self action_playNext];
                }
            }
        }
    });
    NSLog(@"");
}

-(void)action_showlongGesture:(SSChatMessagelLayout *)layout{
    NSMutableArray *titles = @[].mutableCopy;

    if (!layout.message.model.isTemp) {
        if (layout.message.model.Collect) {
            [titles addObject:@"取消收藏"];
        }else{
            [titles addObject:@"加入收藏"];
        }
        [titles addObject:@"收藏列表"];
        [titles addObject:@"转发"];
        [titles addObject:layout.message.model.SendPhone];
    }else{
        [titles addObject:@"收藏列表"];
    }
    [titles addObject:@"举报"];

    if ([layout.message.model.SendId isEqualToString:[UserModel shareInstance].Guid]) {
        [titles addObject:@"删除"];
    }

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
        if ([obj isEqualToString:@"举报"]) {
            [weakSelf action_jubao];
        }
        if ([obj isEqualToString:@"删除"]) {
            [weakSelf aciton_deleteMessage:layout];
        }
        if ([obj isEqualToString:layout.message.model.SendPhone]) {
            [weakSelf action_callPhone:layout.message.model.SendPhone];
        }
    }];
}

-(void)aciton_deleteMessage:(SSChatMessagelLayout *)layout{
    NSDictionary *para = @{@"Guid":layout.message.model.Guid};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_MESSAGE_DELETE_SELF withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        [self.datas removeObject:layout];
        [self.mTableView reloadData];
    }];
}
-(void)action_jubao{
    CB_ReportController *page = [CB_ReportController new];
    [self.navigationController pushViewController:page animated:YES];
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
    page.sendId = self.SendId;
    page.sendUserId = [UserModel shareInstance].Guid;
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

-(CB_NaviMapView *)mapView{
    if (!_mapView) {
        _mapView = [[CB_NaviMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight)];
    }
    return _mapView;
}

-(CB_TopUserListView *)userListView{
    if (!_userListView) {
        _userListView = [[CB_TopUserListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];

    }
    return _userListView;
}

-(NSMutableArray *)activityUsers{
    if (!_activityUsers) {
        _activityUsers = @[].mutableCopy;
    }
    return _activityUsers;
}

@end
