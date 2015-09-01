//
//  MessageController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//  短信页面


#import "MessageController.h"
#import "MessageCell.h"
#import "MsgDetailController.h"
#import "BLEOperation.h"
#import "DBDatas.h"
#import "NSString+helper.h"
#import "MyAddressBooks.h"

@interface MessageController ()<UISearchResultsUpdating,UISearchControllerDelegate,MyAddressBooksDelegate>
{
    NSString *inputString;
}

@property (strong,nonatomic) NSMutableArray *dataArray;     //短信信息
@property (strong,nonatomic) UISearchController *searchController;  //实现disPlaySearchBar
@property (strong,nonatomic) UITableViewController *tableViewController;
@property (strong,nonatomic) NSMutableArray *searchsArray;          //搜索后的结果数组
@property (strong,nonatomic) NSMutableArray *contactsArray;     //短信联系人

@end

@implementation MessageController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.contactsArray || self.dataArray) {
        [self.dataArray removeAllObjects];
        [self.contactsArray removeAllObjects];
    }
    
    //显示会话的所有联系人，重复的只取一个
    NSMutableArray *aa = [[DBHelper sharedDBHelper] getAllMessages];
    for (DBDatas *d in aa) {
        NSString *accp = d.msgHisNum;
        
        if (![self.contactsArray containsObject:accp]) {
            [self.contactsArray addObject:accp];
        }
    }
    VCLog(@"self.contactsArray:%@",self.contactsArray);
    
    [self searchLastMsgRecord];
    
    [self.tableView reloadData];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
}

/**
 *  根据某个number查询某个会话的最后一条记录
 */
-(void)searchLastMsgRecord
{
    DBDatas *dd = [[DBDatas alloc] init];
    for (int i=0 ;i<self.contactsArray.count;i++) {
    
        dd = [[DBHelper sharedDBHelper] getLastMsgRecord:self.contactsArray[i] ];
        if (self.dataArray.count>=self.contactsArray.count) {
            [self.dataArray removeAllObjects];
            
        }
        if (![self.dataArray containsObject:dd]) {
            [self.dataArray  addObject:dd];
            
        }
        
    }
    self.contactsArray = (NSMutableArray *)[[self.contactsArray reverseObjectEnumerator] allObjects];
    self.dataArray = (NSMutableArray *)[[self.dataArray reverseObjectEnumerator] allObjects];
    
    VCLog(@"self.dataArray:%@",self.dataArray);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [[NSMutableArray alloc] init];
    self.searchsArray = [[NSMutableArray alloc] init];
    self.contactsArray = [[NSMutableArray alloc] init];
    
    [self initSearchController];
    inputString = [[NSString alloc] init];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
}


/**
 *  初始化搜索控制器
 */
-(void) initSearchController
{
    //需要初始化一下UISearchController:
    // 创建出搜索使用的表示图控制器
    self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.tableViewController.tableView.dataSource = self;
    self.tableViewController.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.tableViewController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.frame = CGRectMake(0, 64, DEVICE_WIDTH, 44.0);
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;//输入时显示状态栏，
    //[self changedSearchBarCancel];
    
}
/*
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
*/
#pragma mark -- searchController 协议方法
//返回搜索结果
-(void) updateSearchResultsForSearchController:(UISearchController *)searchController
{
    inputString = searchController.searchBar.text;
    if (self.searchsArray!= nil) {
        [self.searchsArray removeAllObjects];
    }
    if (self.searchController.searchBar.text.length >=1) {
        self.searchsArray = [[DBHelper sharedDBHelper] getAllMsgFromInput:inputString];
    }
    VCLog(@"self.searchsArray :%@",self.searchsArray);
    //刷新表格
    [self.tableViewController.tableView reloadData];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //sections
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //rows
    if (self.searchController.active) {
        return self.searchsArray.count;
    }
    return self.contactsArray.count;
}

// tableViewcell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"messageCellId";
    MessageCell *cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        //加载cell-xib
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil] objectAtIndex:0];
        
    }
    //取消cell 选中背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //VCLog(@"self.dataArray:%@",self.dataArray);
    DBDatas *ddata = [self.dataArray objectAtIndex:indexPath.row];
    if (self.searchController.active) {
        DBDatas *sdata = [self.searchsArray objectAtIndex:indexPath.row];
        cell.contactsLabel.text =sdata.msgHisName.length>0?sdata.msgHisName:sdata.msgHisNum ; //sdata.msgAccepter;
        cell.contactsLabel.attributedText = [self getAttributedStr:inputString str:cell.contactsLabel.text];
        cell.contentsLabel.text = sdata.msgContent;
        cell.contentsLabel.attributedText = [self getAttributedStr:inputString str:cell.contentsLabel.text];
        cell.dateLabel.text = sdata.msgTime;
        cell.dateLabel.attributedText = [self getAttributedStr:inputString str:cell.dateLabel.text];
    }else{
        cell.contactsLabel.text = ddata.msgHisName.length>0?ddata.msgHisName:ddata.msgHisNum;
        cell.contentsLabel.text = ddata.msgContent;
        cell.dateLabel.text = ddata.msgTime;
    }
  
    return cell;
}

//获取染色后的字
-(NSMutableAttributedString *)getAttributedStr:(NSString *)inString str:(NSString *)textStr{
    NSRange range = [textStr rangeOfString:inString];
    if (textStr.length<range.length) {
        range = NSMakeRange(0, textStr.length);
    }
    NSMutableAttributedString *attributeString =[[NSMutableAttributedString alloc] initWithString:textStr];
    [attributeString setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:range];//NSFontAttributeName:[UIFont systemFontOfSize:14]//不加字体大小，会保持原来的
    return attributeString;
}

//选中某行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //传值，hisName,hisNumber,hisHome，hisContactId
    
    DBDatas *detaildata = [[DBDatas alloc] init];//传值data
    
    if (self.searchController.active) {
        DBDatas *searchdata = [self.searchsArray objectAtIndex:indexPath.row];//搜索后
        detaildata.hisName =searchdata.msgHisName.length>0?searchdata.msgHisName:searchdata.msgHisNum;
        detaildata.hisNumber = searchdata.msgHisNum;
        detaildata.hisHome = [[DBHelper sharedDBHelper] getAreaWithNumber:[detaildata.hisNumber purifyString]];
        detaildata.contactID = searchdata.contactID;
    }else{
        DBDatas *deta = [self.dataArray objectAtIndex:indexPath.row];
        detaildata.hisName = deta.msgHisName.length>0?deta.msgHisName:deta.msgHisNum;
        detaildata.hisNumber = deta.msgHisNum;
        detaildata.hisHome = [[DBHelper sharedDBHelper] getAreaWithNumber:[deta.msgHisNum purifyString]];
        detaildata.contactID = deta.contactID;
    }
    MsgDetailController *DetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"msgDetail"];
    DetailVC.datailDatas = detaildata;
    
    [self.navigationController pushViewController:DetailVC animated:YES];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active) {
        return 60;
    }
    return 60;
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
        
        //删除数据库数据,整个会话
        NSString *hisNumbers = [self.contactsArray objectAtIndex:indexPath.row];
        [[DBHelper sharedDBHelper] deleteAConversation:hisNumbers];
        
        //删除数组
        [self.dataArray removeObjectAtIndex:indexPath.row];//移除数组的元素
        [self.contactsArray removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //CFRelease(_addressBooks);
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}
@end
