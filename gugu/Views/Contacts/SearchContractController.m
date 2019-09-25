//
//  SearchContractController.m
//  
//
//  Created by Mike Chen on 2019/3/5.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "SearchContractController.h"
#import "HLDS_BaseListView.h"
#import "CB_UserContactCell.h"
#import "ContrractUserInfoController.h"
#import "MyUserInfoController.h"

static NSString *cellId = @"CB_UserContactCell";
@interface SearchContractController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITextField *txt_search;
@property (nonatomic,strong) NSString *keyWords;
@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;

@property (nonatomic,strong) NSMutableArray *totalArr;

@end

@implementation SearchContractController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    [self initData];
    [self initAction];
    
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.txt_search becomeFirstResponder];
    [self action_refresh];
}

-(void)initUI{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.txt_search];
    [self addItemWithTitle:@"取消" imageName:@"" selector:@selector(action_cancel) left:NO];
    
    [self.view addSubview:self.listView];
}

-(void)initData{
    NSDictionary *para = @{@"KeyWord":@"%"};
    self.listView.refreshUrl = CHAT_FRIEND_ALL_FRIEND;
    self.listView.refreshDic = para;
    self.keyWords = @"";
}

-(void)action_refresh{
    NSString *searchStr = @"%";
    searchStr = [searchStr stringByAppendingString:self.keyWords];
    NSDictionary *para = @{@"KeyWord":searchStr};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_FRIEND_ALL_FRIEND withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSDictionary *dict = responseObject;
            NSArray *arr = dict[@"list"];
            self.dataSource = arr.mutableCopy;
            self.totalArr = arr.mutableCopy;
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
    self.listView.hlds_block_loadMore = ^(NSDictionary *result) {
        NSArray *items = result[@"list"];
        [weakSelf action_loadMoreWith:items];
    };
}

-(void)action_loadMoreWith:(NSArray *)items{
    if (items.count>0) {
        NSMutableArray *m_arr = self.dataSource;
        [m_arr addObjectsFromArray:items];
        self.dataSource = m_arr;
    }
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

-(void)closeKeyboard{
    [self.txt_search resignFirstResponder];
}

-(void)action_cancel{
    [self.navigationController popViewControllerAnimated:NO];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self action_doSearch];
    return YES;
}

-(void)action_doSearch{
    
//    if ([self.keyWords isEqualToString:@""]) {
//        [AppGeneral showMessage:@"请输入想要搜索的内容" andDealy:1];
//        return;
//    }

    self.keyWords = self.txt_search.text;
    [self.txt_search resignFirstResponder];

    NSMutableArray *m_arr = @[].mutableCopy;
    for (NSDictionary *dict in self.totalArr) {
        CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
        if (self.keyWords.length==0||[model.FriendUserName containsString:self.keyWords]) {
            [m_arr addObject:dict];
        }
    }
    self.dataSource = m_arr;
    [self.listView reloadData];

}

-(void)textFieldChanged:(UITextField *)textfield{
    if ([textfield.text isEqualToString:@""]) {
        
    }
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
    CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
    cell.lbl_name.text = model.FriendUserName;
    [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
    
    if ([model.FriendId isEqualToString:[UserModel shareInstance].Guid]) {
        MyUserInfoController *page = [MyUserInfoController new];
        [self.navigationController pushViewController:page animated:YES];
        return;
    }
    
    
    ContrractUserInfoController *page = [ContrractUserInfoController new];
    page.friendModel = model;
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
    
}


#pragma mark - 懒加载

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

-(UITextField *)txt_search{
    if (!_txt_search) {
        _txt_search = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-80, 30)];
        _txt_search.font = [UIFont systemFontOfSize:16];
        _txt_search.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
        [_txt_search addlayerRadius:10];
        _txt_search.delegate = self;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
        view.backgroundColor = [UIColor clearColor];
        _txt_search.leftView = view;
        _txt_search.leftViewMode = UITextFieldViewModeAlways;
        _txt_search.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txt_search.returnKeyType = UIReturnKeySearch;
        [_txt_search addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _txt_search;
}

-(NSMutableArray *)totalArr{
    if (!_totalArr) {
        _totalArr = @[].mutableCopy;
    }
    return _totalArr;
}

@end
