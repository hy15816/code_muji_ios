//
//  MessageController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "MessageController.h"
#import "MessageCell.h"
#import "MsgDatas.h"
#import "MsgDetailController.h"
#import "TXBLEOperation.h"
#import "TXSqliteOperate.h"
#import "TXData.h"

@interface MessageController ()<UISearchResultsUpdating,UISearchControllerDelegate>
{
    TXSqliteOperate *txsqlite;
}
@property (strong,nonatomic) NSMutableArray *dataArray;
@property (strong,nonatomic) UISearchController *searchController;  //实现disPlaySearchBar
@property (strong,nonatomic) UITableViewController *searchVC;
@property (strong,nonatomic) NSMutableArray *searchsArray;          //搜索后的结果数组


@end

@implementation MessageController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    
    //这里只需查询某个会话的最后一条记录
    self.dataArray = [txsqlite searchConversationFromtable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME hisNumber:@"13322224444" wihtSqlString:SELECT_A_LAST_MESSAGE_RECORDS];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Message", nil);
    
    self.dataArray = [[NSMutableArray alloc] init];
    self.searchsArray = [[NSMutableArray alloc] init];
    
    [self initSearchController];
    
    txsqlite = [[TXSqliteOperate alloc] init];
    //获取信息的号码
    
    
    
    
}

//searchController
-(void) initSearchController
{
    //需要初始化一下UISearchController:
    // 创建出搜索使用的表示图控制器
    self.searchVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.searchVC.tableView.dataSource = self;
    self.searchVC.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchVC];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.frame = CGRectMake(0, 64, DEVICE_WIDTH, 44.0);
    self.tableView.tableHeaderView = self.searchController.searchBar;
//    self.definesPresentationContext = YES;
    [self changedSearchBarCancel];
    
}
//将SearchBar上"Cancel"按钮改为”取消“
-(void)changedSearchBarCancel
{
    
    UIButton *cancelButton;
    UIView *topView = self.searchController.searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton *)subView;
            //设置文本和颜色
            [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
            [cancelButton setTitleColor:RGBACOLOR(0, 103, 255, 1) forState:UIControlStateNormal];//蓝色
            cancelButton.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:15];
            
        }
    }
    
}

#pragma mark -- searchController 协议方法
//返回搜索结果
-(void) updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSString *searchString = [self.searchController.searchBar text];
    
    //NSPredicate *preicate = [NSPredicate predicateWithFormat:@"(SELF.personName CONTAINS[c] %@) OR (SELF.personTel contains [c] %@)", searchString];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"(SELF.personName CONTAINS[c] %@) or (self.personTel contains[c] %@)", searchString,searchString ];
    
    if (self.searchsArray!= nil) {
        [self.searchsArray removeAllObjects];
    }
    
    //过滤数据
    //self.searchsArray= [NSMutableArray arrayWithArray:[_dataList filteredArrayUsingPredicate:preicate]];
    //VCLog(@"searchArray :%@",self.searchsArray);
    VCLog(@"preicate :%@",preicate);
    
    //刷新表格
    //[self.searchVC.tableView reloadData];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //sections
    //是搜索后的tableView
    if (self.searchController.active) {
        return 1;
    }
    return 1;//否则返回索引个数
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //rows
    if (self.searchController.active) {
        return self.searchsArray.count;
    }
    return self.dataArray.count;
}

// tableViewcell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCells" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TXData *ddata = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.contactsLabel.text = @"13322224444";//ddata.msgSender;
    cell.contentsLabel.text = ddata.msgContent;
    cell.dateLabel.text = ddata.msgTime;
    // Configure the cell...
    
  
    return cell;
}
//选中某行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //传值，hisName,hisNumber,hisHome
    TXData *data = [self.dataArray objectAtIndex:indexPath.row];
    data.hisName = data.hisName;
    data.hisNumber = @"13322224444";//data.msgSender;
    data.hisHome = data.hisHome;//@"hisHome"
    
    MsgDetailController *DetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"msgDetail"];
    DetailVC.datailDatas = data;
    
    [self.navigationController pushViewController:DetailVC animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// 允许编辑
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *array = [ [ NSMutableArray alloc ] init ];
        
        [ array addObject: indexPath];
        
        [self.dataArray removeObjectAtIndex:indexPath.row];//移除数组的元素
        
        
        [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}



@end
