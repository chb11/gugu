//
//  UrgencyContactController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "UrgencyContactController.h"
#import "CB_UserContactCell.h"

static NSString *cellId = @"CB_UserContactCell";

@interface UrgencyContactController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;

@end

@implementation UrgencyContactController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initAction];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.listView.mj_header beginRefreshing];
    
}

-(void)initUI{
    if (self.isUrgencyList) {
        self.title = @"紧急联系人";
        [self addItemWithTitle:@"新增" imageName:@"" selector:@selector(hlds_action_add) left:NO];
    }else{
        self.title = @"选择联系人";
    }
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    
    [self.view addSubview:self.listView];
}

-(void)initData{
    NSDictionary *para = @{@"UserId":[UserModel shareInstance].Guid};
    if (self.isUrgencyList) {
        self.listView.refreshUrl = OTHER_MY_CONTACT;
        self.listView.refreshDic = para;
    }else{
        self.listView.refreshUrl = CHAT_FRIEND_ALL_FRIEND;
        self.listView.refreshDic = @{@"KeyWord":@"%"};
    }
    
    

}

-(void)action_refresh{
    NSDictionary *para = @{@"UserId":[UserModel shareInstance].Guid};
    [[NetWorkConnect manager] postDataWith:para withUrl:OTHER_MY_CONTACT withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSDictionary *dict = responseObject;
            NSArray *arr = dict[@"list"];
            self.dataSource = arr.mutableCopy;
        }
    }];
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self.listView.hlds_block_refresh = ^(NSDictionary *result) {
        NSArray *items = result[@"list"];
        weakSelf.dataSource = items.mutableCopy;
        [weakSelf.listView reloadData];
    };
}



- (void)setDataSource:(NSMutableArray *)dataSource{
    _dataSource  = dataSource;
    if (dataSource.count>0) {
        self.listView.tableFooterView = [[UIView alloc] init];
    }else{
        self.listView.tableFooterView = self.hlds_view_empty;
    }
    [self.listView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CB_UserContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[CB_UserContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];
//    cell.model = [CB_ContactModel modelWithDictionary:dict];
    
    if (self.isUrgencyList) {
        CB_ContactModel *model = [CB_ContactModel modelWithDictionary:dict];
        cell.lbl_name.text = model.FrendNickName?model.FrendNickName:model.UserName;
        [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    }else{
        CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
        cell.lbl_name.text = model.FriendUserName;
        [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.isUrgencyList) {
        NSDictionary *dict = self.dataSource[indexPath.row];
        CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
        [self action_addToUrgencyList:model];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //第二组可以左滑删除
    if (self.isUrgencyList) {
        return YES;
    }
    
    return NO;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.isUrgencyList) {
            NSDictionary *dict = self.dataSource[indexPath.row];
            CB_ContactModel *model = [CB_ContactModel modelWithDictionary:dict];
            [self action_deleteUrgency:model];
        }
    }
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

-(void)action_deleteUrgency:(CB_ContactModel *)model{
    
    [AppGeneral action_showAlertWithTitle:@"是否删除" andConfirmBlock:^{
        NSDictionary *para = @{@"Guid":model.Guid};
        [[NetWorkConnect manager] postDataWith:para withUrl:OTHER_DELETE_MY_CONTACT withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"删除成功" andDealy:1];
                [self action_refresh];
            }
        }];
    }];
    
   
}

//添加为紧急联系人
-(void)action_addToUrgencyList:(CB_FriendModel *)model{
    
    [AppGeneral action_showAlertWithTitle:@"是否添加为紧急联系人" andConfirmBlock:^{
        NSDictionary *para = @{@"ConsumerId":model.FriendId};
        [[NetWorkConnect manager] postDataWith:para withUrl:OTHER_EDIT_MY_CONTACT withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"新增成功" andDealy:1];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
}

-(void)hlds_action_add{
    UrgencyContactController *page = [UrgencyContactController new];
    page.isUrgencyList = NO;
    [self.navigationController pushViewController:page animated:YES];
}

-(HLDS_BaseListView *)listView{
    if (!_listView) {
        _listView = [[HLDS_BaseListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight) style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.backgroundColor = [UIColor clearColor];
        _listView.tableFooterView = [[UIView alloc] init];
        [_listView registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        _listView.rowHeight = 80;
        _listView.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.mj_header.tintColor = [UIColor whiteColor];
        _listView.mj_footer = nil;
    }
    return _listView;
}

-(UIView *)hlds_view_empty{
    if (!_hlds_view_empty) {
        _hlds_view_empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        _hlds_view_empty.backgroundColor = [UIColor clearColor];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((_hlds_view_empty.width-100)/2, (_hlds_view_empty.height-100)/2-20, 100, 100)];
        img.image = [UIImage imageNamed:@"empty.png"];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [_hlds_view_empty addSubview:img];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake((_hlds_view_empty.width-100)/2, img.mj_y+img.height+10, 100, 30)];
        lbl.textColor = [UIColor colorWithHexString:@"bfbfbf"];
        lbl.text = @"暂无内容";
        lbl.textAlignment = NSTextAlignmentCenter;
        [_hlds_view_empty addSubview:lbl];
    }
    return _hlds_view_empty;
}


@end
