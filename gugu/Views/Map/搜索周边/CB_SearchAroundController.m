//
//  CB_SearchAroundController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/27.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_SearchAroundController.h"
#import "CB_SearchTypeCell.h"
#import "CB_SearchOpenView.h"
#import "CB_SearchAroundByText.h"

#define home_item_width (SCREEN_WIDTH-50)/5

static NSString *cellid = @"CB_SearchTypeCell";
static NSString *openid = @"CB_SearchOpenView";

@interface CB_SearchAroundController ()<AMapSearchDelegate,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) AMapSearchAPI *search;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *datasource;
@property (nonatomic,strong) UITextField *txt_search;
@property (nonatomic,strong) UIButton *btn_doSearch;
@property (nonatomic,strong) CB_SearchAroundByText *searchView;
@property (nonatomic,strong) NSMutableArray *openArray;

@end

@implementation CB_SearchAroundController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    [self initData];
    [self initAction];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.txt_search becomeFirstResponder];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeKeyboard];
}

-(void)initUI{
    self.title = @"全部分类";
    [self.view addSubview:self.txt_search];
    [self.view addSubview:self.btn_doSearch];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.searchView];
    
    if (@available(ios 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    [self addItemWithTitle:@"" imageName:@"back.png" selector:@selector(action_back) left:YES];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(textFieldTextDidChange:)
     name:UITextFieldTextDidChangeNotification
     object:self.txt_search];
}

-(void)initData{
    [[NetWorkConnect manager] postDataWith:@{} withUrl:OTHER_MAP_ALLTYPE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            self.datasource = responseObject[@"list"];
            [self.collectionView reloadData];
        }
    }];
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf initData];
    }];
}

-(void)action_back{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)closeKeyboard{
    [self.txt_search resignFirstResponder];
}

-(void)action_searchWithString:(NSString *)type{
    if (self.block_selectType) {
        self.block_selectType(self.mapGeoPoint,type);
    }
}

/* 根据中心点坐标来搜周边的POI. */
-(void)action_doSearch{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location            = self.mapGeoPoint;
    request.keywords            = self.txt_search.text;
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.requireExtension    = YES;
    [self.search AMapPOIAroundSearch:request];
    
    [HYActivityIndicator startActivityAnimation:[UIApplication sharedApplication].keyWindow];
    
}

-(void)textFieldTextDidChange:(NSNotification *)notification{
    
    UITextField *textfield=[notification object];
    if (textfield.text.length==0) {
        self.searchView.hidden = YES;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self closeKeyboard];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.datasource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSDictionary *list = self.datasource[section];
    NSArray *types = list[@"arrays"];
    
    NSString *indexStr = [NSString stringWithFormat:@"%ld",section];
    if ([self.openArray containsObject:indexStr]) {//打开
        return types.count;
    }else{
        if (types.count > 8) {
            return 8;
        }
    }
    return types.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CB_SearchTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
    
    NSDictionary *list = self.datasource[indexPath.section];
    NSArray *types = list[@"arrays"];
    NSDictionary *nameDic = types[indexPath.row];
    NSString *nameStr = nameDic[@"name"];
    cell.lbl_title.text = nameStr;
    return cell;
}

#pragma mark  定义每个UICollectionView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(home_item_width,40);
}

#pragma mark  定义整个CollectionViewCell与整个View的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//（上、左、下、右）
}

#pragma mark  定义每个UICollectionView的横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

#pragma mark  定义每个UICollectionView的纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSDictionary *list = self.datasource[indexPath.section];
    NSArray *types = list[@"arrays"];
    NSDictionary *nameDic = types[indexPath.row];
    NSString *nameStr = nameDic[@"name"];
    [self action_searchWithString:nameStr];
    [self action_back];
}

//这个方法是返回 Header的大小 size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 60);
}

//这个也是最重要的方法 获取Header的 方法。
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        //从缓存中获取 Headercell
        CB_SearchOpenView *header = (CB_SearchOpenView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:openid forIndexPath:indexPath];
        
        header.btn_open.selected = NO;
        NSString *indexStr = [NSString stringWithFormat:@"%ld",indexPath.section];
        if ([self.openArray containsObject:indexStr]) {//打开
            header.isOpen = YES;
        }else{
            header.isOpen = NO;
        }
        NSDictionary *dict = self.datasource[indexPath.section];
        header.lbl_title.text = dict[@"name"];
        
        __weak typeof(self) weakSelf = self;
        header.block_open = ^(BOOL isopen) {
            if (isopen) {
                [weakSelf.openArray addObject:indexStr];
            }else{
                if ([weakSelf.openArray containsObject:indexStr]) {
                    [weakSelf.openArray removeObject:indexStr];
                }
            }
            [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        };
        
        return header;
    }
    return nil;
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    [AppGeneral showMessage:@"当前网络不稳定，请稍后重试" andDealy:1];
    [HYActivityIndicator stopActivityAnimation];
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [HYActivityIndicator stopActivityAnimation];
    self.searchView.dataSource = response.pois.mutableCopy;
    self.searchView.hidden = NO;
    [self.txt_search resignFirstResponder];
}

#pragma mark - 懒加载
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        //设置CollectionView的属性
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight-50) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerNib:[UINib nibWithNibName:cellid bundle:nil] forCellWithReuseIdentifier:cellid];
        [_collectionView registerNib:[UINib nibWithNibName:openid bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:openid];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
    }
    return _collectionView;
}

-(NSMutableArray *)datasource{
    if (!_datasource) {
        _datasource = @[].mutableCopy;
    }
    return _datasource;
}

-(NSMutableArray *)openArray{
    if (!_openArray) {
        _openArray = @[].mutableCopy;
    }
    return _openArray;
}

-(UITextField *)txt_search{
    if (!_txt_search) {
        _txt_search = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-80, 30)];
        _txt_search.delegate = self;
        _txt_search.placeholder = @"请输入关键字";
        [_txt_search addborderColor:[UIColor colorWithHexString:@"f8f8f8"] borderWith:1 layerRadius:5];
        _txt_search.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _txt_search;
}

-(UIButton *)btn_doSearch{
    if (!_btn_doSearch) {
        _btn_doSearch = [[UIButton alloc] initWithFrame:CGRectMake(self.txt_search.mj_x+self.txt_search.mj_w+10, self.txt_search.mj_y, 50, 30)];
        [_btn_doSearch addlayerRadius:5];
        _btn_doSearch.titleLabel.font = [UIFont systemFontOfSize:15];
        _btn_doSearch.backgroundColor = [UIColor colorWithHexString:@"1c91f6"];
        [_btn_doSearch setTitle:@"搜索" forState:UIControlStateNormal];
        [_btn_doSearch addTarget:self action:@selector(action_doSearch) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btn_doSearch;
}

-(CB_SearchAroundByText *)searchView{
    if (!_searchView) {
        _searchView = [[CB_SearchAroundByText alloc] initWithFrame:self.collectionView.frame];
        _searchView.hidden = YES;
        __weak typeof(self) weakSelf = self;
        _searchView.block_selectPoi = ^(AMapPOI * _Nonnull poi) {
            [weakSelf action_selectPOI:poi];
        };
        
    }
    return _searchView;
}

-(void)action_selectPOI:(AMapPOI *)poi{
    if (self.block_selectPOI) {
        self.block_selectPOI(self.mapGeoPoint, poi);
    }
    [self action_back];
}

@end
