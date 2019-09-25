//
//  CB_SearchKeywordController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/27.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_SearchKeywordController.h"
#import "CB_SearchHistoryView.h"
#import "CB_NewTagView.h"
#import "CB_SearchKeywordCell.h"

static NSString *cellId = @"CB_SearchKeywordCell";
static NSString *map_searchHistoryKey = @"map_searchHistoryKey";
static NSString *sepetateKey = @"#/#*";
@interface CB_SearchKeywordController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,AMapSearchDelegate>
@property (nonatomic,strong) UITextField *txt_search;
@property (nonatomic,strong) UITableView *_tableview;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) CB_SearchHistoryView *historyView;
@property (nonatomic,strong) AMapSearchAPI *search;
@property (nonatomic,strong) UIView *hlds_view_empty;
@end

@implementation CB_SearchKeywordController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [self.view addSubview:self._tableview];
    
    if (@available(ios 11.0, *)) {
        self._tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.txt_search];
    [self addItemWithTitle:@"取消" imageName:@"" selector:@selector(action_back) left:NO];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}

-(void)initData{
    NSString *history =  [[NSUserDefaults standardUserDefaults] valueForKey:map_searchHistoryKey];
    NSArray *arr_history = [history componentsSeparatedByString:sepetateKey];
    if (arr_history.count>0 && ![arr_history[0] isEqualToString:@""]) {
        
        for (UIView *subView in self.historyView.view_content.subviews) {
            [subView removeFromSuperview];
        }
        
        CB_NewTagView *tagv = [[CB_NewTagView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-30, 20)];
        tagv.itemMargin = 8;
        tagv.itemRadio = 5;
        tagv.itemHeight = 30;
        tagv.itemWidth = 50;
        tagv.itemFont = 16;
        tagv.itemBorderColorArray = @[@"9A9A9A"];
        tagv.types = arr_history;
        
        __weak typeof(self) weakSelf = self;
        tagv.block_select = ^(NSString *title) {
            weakSelf.txt_search.text = title;
            [weakSelf action_doSearch];
        };
        
        CGFloat height = [CB_NewTagView heightWithTags:arr_history withFont:16 withitemHeight:30 withWidth:SCREEN_WIDTH-30];
        self.historyView.frame = CGRectMake(0, 0, SCREEN_WIDTH, height+75);
        [self.historyView.view_content addSubview:tagv];

        self._tableview.tableHeaderView = self.historyView;
    }else{
        self._tableview.tableHeaderView = [[UIView alloc] init];
    }
    
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self.historyView.block_delete = ^{
        [weakSelf action_deleteHistory];
    };
    
}

-(void)action_deleteHistory{
    
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:map_searchHistoryKey];
    [self initData];
}

-(void)closeKeyboard{
    [self.txt_search resignFirstResponder];
}

-(void)action_doSearch{

    if ([self.txt_search.text isEqualToString:@""]) {
        [AppGeneral showMessage:@"请输入想要搜索的内容" andDealy:1];
        return;
    }
    [self.txt_search resignFirstResponder];
    [HYActivityIndicator startActivityAnimation:[UIApplication sharedApplication].keyWindow];
    
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = self.txt_search.text;
    request.requireSubPOIs      = YES;
    request.requireExtension = YES;
    request.offset = 50;
    [self.search AMapPOIKeywordsSearch:request];
   
    NSString *history =  [[NSUserDefaults standardUserDefaults] valueForKey:map_searchHistoryKey];
    if (history.length>0) {
        NSArray *historyArr = [history componentsSeparatedByString:sepetateKey];
        NSMutableArray *arr_history = historyArr.mutableCopy;
        for (int i = 0; i<historyArr.count; i++) {
            NSString *h_str = historyArr[i];
            if ([h_str isEqualToString:self.txt_search.text]) {
                [arr_history removeObjectAtIndex:i];
                break;
            }
        }
        [arr_history insertObject:self.txt_search.text atIndex:0];
       
        NSString *str_history = @"";
        for (int i = 0; i<arr_history.count; i++) {
            
            NSString *str = arr_history[i];
            if (str.length>0) {
                if (i == 0) {
                    str_history = str;
                }else{
                    str_history = [NSString stringWithFormat:@"%@%@%@",str_history,sepetateKey,str];
                }
            }
        }
        [[NSUserDefaults standardUserDefaults] setValue:str_history forKey:map_searchHistoryKey];
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:self.txt_search.text forKey:map_searchHistoryKey];
    }
    [self initData];
    
}


-(void)action_back{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CB_SearchKeywordCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cellId = [[[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil] lastObject];
    }
    AMapPOI *poi = self.dataSource[indexPath.row];
    cell.lbl_title.text = poi.name;
    cell.lbl_discribe.text = poi.address;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMapPOI *poi = self.dataSource[indexPath.row];
    if (self.block_select) {
        self.block_select(poi);
    }
    [self action_back];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self closeKeyboard];
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    NSLog(@"");

    self.dataSource = response.pois.mutableCopy;
    if (self.dataSource.count == 0) {
        self._tableview.tableFooterView = self.hlds_view_empty;
    }else{
        self._tableview.tableFooterView = [[UIView alloc] init];
    }
    [self._tableview reloadData];
    [HYActivityIndicator stopActivityAnimation];
}

-(void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [HYActivityIndicator stopActivityAnimation];
        [AppGeneral showMessage:@"搜索失败，请稍后重试" andDealy:1];
    });
 
}




#pragma mark - 懒加载
-(UITableView *)_tableview{
    if (!__tableview) {
        __tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-50-BottomPadding) style:UITableViewStylePlain];
        [__tableview registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        __tableview.tableFooterView = [[UIView alloc] init];
        __tableview.backgroundColor = [UIColor clearColor];
        __tableview.rowHeight = 60;
        __tableview.delegate = self;
        __tableview.dataSource = self;
        __tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        __tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return __tableview;
}

-(CB_SearchHistoryView *)historyView{
    if (!_historyView) {
        _historyView = [[[NSBundle mainBundle] loadNibNamed:@"CB_SearchHistoryView" owner:self options:nil] firstObject];
        
    }
    return _historyView;
}

-(UITextField *)txt_search{
    if (!_txt_search) {
        _txt_search = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-80, 36)];
        _txt_search.font = [UIFont systemFontOfSize:16];
        _txt_search.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
        [_txt_search addlayerRadius:4];
        _txt_search.delegate = self;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
        view.backgroundColor = [UIColor clearColor];
        _txt_search.leftView = view;
        _txt_search.leftViewMode = UITextFieldViewModeAlways;
        _txt_search.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txt_search.returnKeyType = UIReturnKeySearch;
        _txt_search.placeholder = @"请输入关键字";

    }
    return _txt_search;
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self action_doSearch];
    return YES;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

@end
