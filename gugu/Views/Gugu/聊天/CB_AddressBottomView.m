//
//  CB_AddressBottomView.m
//  gugu
//
//  Created by Mike Chen on 2019/6/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_AddressBottomView.h"

#import "CB_BottomAddressCell.h"

static NSString *cellId = @"CB_BottomAddressCell";

@interface CB_AddressBottomView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) UIView *hlds_view_empty;
@property (nonatomic,assign) NSInteger currIndex;

@property (weak, nonatomic) IBOutlet UILabel *lbl_line_share;
@property (weak, nonatomic) IBOutlet UILabel *lbl_line_go;

@property (weak, nonatomic) IBOutlet UIView *view_content;

@end

@implementation CB_AddressBottomView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self.view_content addSubview:self.listView];
    
    self.currIndex = 0;
    [self initAction];
}


-(void)refreshData{
    //从r服务器获取地址
    if (self.currIndex == 0) {
        NSDictionary *para = @{@"SendId":self.sendId};
//        self.listView.refreshDic = para;
//        self.listView.refreshUrl = MESSAGE_LIST_LOCATION;
        [[NetWorkConnect manager] postDataWith:para withUrl:MESSAGE_LIST_LOCATION withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode ==1) {
                NSLog(@"");
                NSArray *items = responseObject[@"list"];
                self.dataSource = items.mutableCopy;
            }
        }];
    }else{
        //本地
        NSArray *arr = [CB_MessageManager action_findAllNaviAddress];
        self.dataSource = arr.mutableCopy;
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self addCornerRadius:10 cithCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
}


-(void)initAction{
    
    __weak typeof(self) weakSelf = self;
    self.listView.hlds_block_refresh = ^(NSDictionary *result) {
        NSArray *items = result[@"list"];
        weakSelf.dataSource = items.mutableCopy;
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

-(void)setDataSource:(NSMutableArray *)dataSource{
    _dataSource  = dataSource;
    if (dataSource.count>0) {
        self.listView.tableFooterView = [[UIView alloc] init];
    }else{
        self.listView.tableFooterView = self.hlds_view_empty;
    }
    [self.listView reloadData];
}

- (IBAction)action_chooseShare:(id)sender {
    self.currIndex  = 0;
    self.lbl_line_share.hidden = NO;
    self.lbl_line_go.hidden = YES;
    [self refreshData];
    
    
}

- (IBAction)action_choosego:(id)sender {
    self.currIndex  = 1;
    self.lbl_line_share.hidden = YES;
    self.lbl_line_go.hidden = NO;
    [self refreshData];
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CB_BottomAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[CB_BottomAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    id Object = self.dataSource[indexPath.row];
    CB_MessageModel *model = nil;
    if ([Object isKindOfClass:[CB_MessageModel class]]) {
        model = Object;
    }else{
        model = [CB_MessageModel modelWithDictionary:Object];
    }
    
    [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.SendPhotoUrlURL]];
    cell.lbl_time.text = [AppGeneral timePublish:model.PostDate];
    cell.lbl_address.text = model.AddressName;
    cell.lbl_brief.text = model.SubName;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id Object = self.dataSource[indexPath.row];
    CB_MessageModel *model = nil;
    if ([Object isKindOfClass:[CB_MessageModel class]]) {
        model = Object;
    }else{
        model = [CB_MessageModel modelWithDictionary:Object];
    }
    
    if (self.block_chooseAddress) {
        self.block_chooseAddress(model);
    }
    
}

-(HLDS_BaseListView *)listView{
    if (!_listView) {
        _listView = [[HLDS_BaseListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300) style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.rowHeight = 60;
        _listView.mj_footer = nil;
        _listView.backgroundColor = [UIColor clearColor];
        _listView.tableFooterView = [[UIView alloc] init];
        _listView.mj_header = nil;
        _listView.mj_footer = nil;
        [_listView registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
    }
    return _listView;
}

-(UIView *)hlds_view_empty{
    if (!_hlds_view_empty) {
        _hlds_view_empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        _hlds_view_empty.backgroundColor = [UIColor whiteColor];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((_hlds_view_empty.width-100)/2, (_hlds_view_empty.height-120)/2, 100, 120)];
        img.image = [UIImage imageNamed:@"yuyinbaol_sousuo_yybno_"];
        img.contentMode = UIViewContentModeScaleAspectFit;
        
        [_hlds_view_empty addSubview:img];
    }
    return _hlds_view_empty;
}

@end
