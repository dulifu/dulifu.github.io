//
//  ViewController.m
//  webTableDemo
//
//  Created by dulf on 2019/1/7.
//  Copyright © 2019 galanz. All rights reserved.
//

//   思路是用一个大的scrollview _controlScrollView来包含web和table,设置web与table本身不可滚动，加载时更新table与web的contentsize

#import "ViewController.h"
#import "Masonry.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
/*外层ScrollView **/
@property (nonatomic, strong) UIScrollView *controlScrollView;

@property (nonatomic, strong)WKWebView *webview;

@property (nonatomic, strong)UITableView *table;
/*列表数组 **/
@property (nonatomic, strong)NSMutableArray *marr;

@end

@implementation ViewController

#pragma getter

- (UIScrollView *)controlScrollView{
    if (!_controlScrollView) {
        _controlScrollView = [[UIScrollView alloc] init];
        _controlScrollView.scrollEnabled = YES;
        _controlScrollView.delegate = self;
        _controlScrollView.showsVerticalScrollIndicator = YES;
        _controlScrollView.alwaysBounceVertical = YES;
    }
    return _controlScrollView;
}

- (WKWebView *)webview {
    if (!_webview) {
        _webview = [[WKWebView alloc]init];
        _webview.scrollView.showsVerticalScrollIndicator = NO;
        _webview.scrollView.bounces = NO;
        _webview.scrollView.scrollEnabled = NO;
        _webview.scrollView.delegate = self;
        _webview.UIDelegate = self;
        _webview.navigationDelegate = self;
        _webview.scrollView.showsVerticalScrollIndicator = YES;
    }
    return _webview;
}

- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _table.dataSource = self;
        _table.showsVerticalScrollIndicator = NO;
        _table.delegate = self;
        _table.bounces = NO;
        _table.scrollEnabled = NO;
        _table.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    }
    return _table;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    
    self.marr = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",nil];
    
    //controlScrollView添加table与webview
    if (@available(iOS 11, *)) {
        self.controlScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.controlScrollView addSubview:self.webview];
    [self.controlScrollView addSubview:self.table];
    [self.view addSubview:self.controlScrollView];
    
    //设置约束
    [self.controlScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available (iOS 11, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else{
            make.top.mas_equalTo(self.view);
        }
        make.left.right.mas_equalTo(self.view);
        if (@available (iOS 11, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }else{
            make.bottom.mas_equalTo(self.view);
        }
        
    }];
    
    [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.width.top.mas_equalTo(self.controlScrollView);
//        make.height.mas_greaterThanOrEqualTo(0);
        //当网页最终高度小于一屏是会有一定空白
        make.height.mas_greaterThanOrEqualTo(self.controlScrollView);
    }];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.width.mas_equalTo(self.controlScrollView);
        make.top.mas_equalTo(self.webview.mas_bottom);
        make.bottom.mas_equalTo(self.controlScrollView);
    }];
    
    
    
    //kvo
    [self addObserver];
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://paper.people.com.cn/rmrb/html/2019-01/07/nw.D110000renmrb_20190107_3-01.htm"]]];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.marr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = @"GPCommentTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = self.marr[indexPath.row];
    return cell;
    
}

- (void)addObserver {
    [self.webview addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.table addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"scrollView.contentSize"]) {
        [self.webview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo([change[NSKeyValueChangeNewKey] CGSizeValue].height);
        }];
    }else if ([keyPath isEqualToString:@"contentSize"]){
        [self.table mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo([change[NSKeyValueChangeNewKey] CGSizeValue].height);
        }];
    }
}

- (void)dealloc {
    //移除kvo
    [self.webview removeObserver:self forKeyPath:@"scrollView.contentSize"];
    [self.table removeObserver:self forKeyPath:@"contentSize"];
}



@end
