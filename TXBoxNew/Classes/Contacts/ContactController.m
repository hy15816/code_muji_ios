//
//  ContactController.m
//  TXBoxNew
//
//  Created by Naron on 15/7/6.
//  Copyright (c) 2015年 playtime. All rights reserved.
//
#define HeaderViewColor [[UIColor alloc]initWithRed:239/255.f green:239/255.f blue:240/255.f alpha:1];

#import "ContactController.h"
#import "ContactsCell.h"
#import "SVProgressHUD.h"
#import <AddressBookUI/AddressBookUI.h>
#import "pinyin.h"
#import "Records.h"
#import "NSString+helper.h"
#import "MsgDetailController.h"
#import "TXData.h"
#import "GetAllContacts.h"
#import "TXSqliteOperate.h"

@interface ContactController ()<UISearchResultsUpdating,UISearchControllerDelegate,ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate,GetContactsDelegate>
{
    NSMutableDictionary *sectionDicty;    //sections数据
    NSMutableDictionary *phoneDicty;      //同一个人的手机号码dic，
    NSMutableArray *cphoneArray;         //联系人({name:@"",tel:@""},{name:@"",tel:@""})
    NSArray *sortedArray;               //排序后的数组
    TXData *msgdata;
    TXSqliteOperate *txsql;
}

@property (strong,nonatomic) UISearchController *searchController;  //实现disPlaySearchBar
@property (strong,nonatomic) UITableViewController *searchVC;
@property (strong,nonatomic) NSMutableArray *searchsArray;          //搜索后的结果数组
@property (retain,nonatomic) NSArray *dataList;                     //存放数据模型数组
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中
-(IBAction)addNewContacts:(UIBarButtonItem *)sender;
@end

@implementation ContactController

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    //[self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通讯录";
    sectionDicty= [[NSMutableDictionary alloc] init];
    phoneDicty=[[NSMutableDictionary alloc] init];
    cphoneArray = [[NSMutableArray alloc] init];
    sortedArray = [[NSArray alloc] init];
    msgdata = [[TXData alloc] init];
    txsql=[[TXSqliteOperate alloc] init];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //索引相关
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor grayColor];
//    self.tableView.sectionFooterHeight = 18.f;
    self.tableView.sectionHeaderHeight = 18.f;
    //self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor alloc]initWithRed:227/255.f green:212/255.f blue:197/255.f alpha:1];
    [self initSearchController];
    [self loadcContacts];
    [self PacketSequencing];
}

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
    self.searchController.searchBar.frame = CGRectMake(0, 64, self.view.frame.size.width, 44.0);
    self.searchController.dimsBackgroundDuringPresentation = YES;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;//输入时显示状态栏，
    
}

// 导入通讯录
-(void)loadcContacts
{
    GetAllContacts *cont=[[GetAllContacts alloc] init];
    cont.getContactsDelegate = self;
    [cont getContacts];
    
}
-(void)getAllPhoneArray:(NSMutableArray *)array SectionDict:(NSMutableDictionary *)sDict PhoneDict:(NSMutableDictionary *)pDict
{
    cphoneArray = array;
    sectionDicty = sDict;
    phoneDicty = pDict;
    
    //数据模型
    [self setModel];
}

#pragma mark-对所有联系人进行分组排序
-(void)PacketSequencing{
    
    //分区title数组
    NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
    NSString *sectionName;  //分区title，如A,B,C,D,~
    for (int i=0; i<cphoneArray.count; i++) {
        
        //取出phoneArray中的“personName”，的第0个字符
        char firstChar = pinyinFirstLetter([[cphoneArray[i] objectForKey:@"personName"] characterAtIndex:0]);
        //  若firstChar再 a~z 之间，顺序排列
        if ((firstChar >='a' && firstChar<='z')||(firstChar>='A' && firstChar<='Z')) {
            
            sectionName = [[NSString stringWithFormat:@"%c",firstChar] uppercaseString];
            
        }
        else {
            sectionName=[[NSString stringWithFormat:@"%c",'~'] uppercaseString];
        }
        //把phoneArray[i]添加到sectionDic的key中
        [[sectionDicty objectForKey:sectionName] addObject:cphoneArray[i]];
        
        //字符在数组中不存在，则加入
        if (![sectionArray containsObject:sectionName]) {
            
            [sectionArray addObject:sectionName];
        }
        
    }
    
    //对数组排序
    sortedArray =[sectionArray sortedArrayUsingSelector:@selector(compare:)];
    
    VCLog(@"sectionDicty :%@",sectionDicty );
    VCLog(@"sortedArray :%@",sortedArray);
}

//数据模型
-(void)setModel{
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *dict in cphoneArray) {
        
        Records *record = [[Records alloc] init];
        // 给record赋值
        [record setValuesForKeysWithDictionary:dict];//record:<Records: 0x7fa2f27207c0,personTel: 888-555-1212,personName: John Appleseed>
        [arrayM addObject:record];
        
    }
    VCLog(@"arrayM:%@",arrayM);
    self.dataList = arrayM;
    //VCLog(@"arrayM-0:%@",[[arrayM objectAtIndex:0] valueForKey:@"personTel"]);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //是搜索后的tableView
    if (self.searchController.active) {
        return 1;
    }
    return sortedArray.count;//否则返回索引个数
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.searchController.active) {
        return self.searchsArray.count;
    }
    
    //返回sectionDic的 key里有值的value的个数
    NSString *key=[NSString stringWithFormat:@"%@",sortedArray[section]];
    
    return  [[sectionDicty objectForKey:key] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"CellID";
    
    ContactsCell *cell = (ContactsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        //加载cell-xib
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactsCell" owner:self options:nil] objectAtIndex:0];
        
    }
    //取消cell 选中背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    //搜索后
    if (self.searchController.active) {
        //把searchArray根据每行显示
        Records *record = self.searchsArray[indexPath.row];
        cell.nameLabel.text = record.personName;
        cell.numberLabel.text = record.personTel;
        
    }
    else{
        //原生表
        NSString *key=[NSString stringWithFormat:@"%@",sortedArray[indexPath.section]];
        
        NSMutableArray *persons=[sectionDicty objectForKey:key];
        
        cell.nameLabel.text = [[persons objectAtIndex:indexPath.row] objectForKey:@"personName"];
        //cell.numberLabel.text = [[persons objectAtIndex:indexPath.row] objectForKey:@"personTel"];
        cell.numberLabel.text = [[[[persons objectAtIndex:indexPath.row] objectForKey:@"personTel"] purifyString] insertStr];
        //VCLog(@"name:%@,number:%@",cell.nameLabel.text,cell.numberLabel.text);
        
        
    }
    [cell.msgsBtn addTarget:self action:@selector(msgsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.editBtn addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
#pragma mark -- tableView..
//点击单元格
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath isEqual:self.selectedIndexPath] ) {
        
        self.selectedIndexPath = nil;
        
    }else {
        
        self.selectedIndexPath = indexPath;
    }
    
    [tableView beginUpdates];
    [tableView endUpdates];
    
    if (self.searchController.active) {
        //关闭键盘
        [self.searchController.searchBar resignFirstResponder];
        
    }
    
    
}

//设置cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath isEqual:self.selectedIndexPath]) {
        
        return kCellHeight + 40;
    }
    
    return kCellHeight;
    
}


//索引
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (self.searchController.active) {
        return nil;
    }
    
    return sortedArray;
}


-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    [SVProgressHUD showImage:nil status:title];
    
    return index;
}

//section视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.searchController.active) {
        return nil;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-20, 18)];
    headerView.backgroundColor = HeaderViewColor;
    
    
    UILabel *title = [[UILabel alloc] init];
    title.backgroundColor = [UIColor clearColor];
    //title.textColor = [UIColor redColor];
    title.frame = CGRectMake(20, 0, 30, 18);
    title.font = [UIFont systemFontOfSize:15 weight:.3];
    title.text = [sortedArray objectAtIndex:section];
    
    [headerView addSubview:title];
    
    return headerView;
}



-(void)msgsBtnClick:(UIButton *)btn
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self ]];
    //进入msgDetail
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MsgDetailController *msgDetail = [board instantiateViewControllerWithIdentifier:@"msgDetail"];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString *key=[NSString stringWithFormat:@"%@",sortedArray[indexPath.section]];
    NSMutableArray *persons;
    if (self.searchController.active) {
        
        Records *record = self.searchsArray[indexPath.row];
        msgdata.hisName = record.personName;
        msgdata.hisNumber = record.personTel;
        if (msgdata.hisNumber.length >=7) {
            msgdata.hisHome = [txsql searchAreaWithHisNumber:[record.personTel substringToIndex:7]];
        }else{msgdata.hisHome = @"";}
    }else{
        persons=[sectionDicty objectForKey:key];
        msgdata.hisName = [[persons objectAtIndex:indexPath.row] objectForKey:@"personName"];
        msgdata.hisNumber = [[[persons objectAtIndex:indexPath.row] objectForKey:@"personTel"] purifyString];
        if (msgdata.hisNumber.length >=7) {
            msgdata.hisHome = [txsql searchAreaWithHisNumber:[msgdata.hisNumber substringToIndex:7]];
        }else{msgdata.hisHome = @"";}
    }
    
    msgDetail.datailDatas =msgdata;
    [self.navigationController pushViewController:msgDetail animated:YES];
    
    //VCLog(@"msgsclick");
}


-(void)editButtonClick:(UIButton *)btn{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideTabBarAndCallBtn object:self]];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString *key=[NSString stringWithFormat:@"%@",sortedArray[indexPath.section]];
    
    NSMutableArray *persons=[sectionDicty objectForKey:key];
    NSString *name;
    if (self.searchController.active) {
        Records *record = self.searchsArray[indexPath.row];
        name = record.personName;
    }else{
        name = [[persons objectAtIndex:indexPath.row] objectForKey:@"personName"];
    }
    
    [self showPersonViewControllerWithName:name];
}
#pragma mark -- 跳转到编辑联系人
//跳转到edit联系人
-(void)showPersonViewControllerWithName:(NSString *)string{
    CFStringRef name = (__bridge CFStringRef)string;
    //CFErrorRef *error;
    //  获取通讯录
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL) ;//ABAddressBookCreate()
    //  查找名字为Appleseed的联系人
    NSArray *people = (__bridge NSArray *)ABAddressBookCopyPeopleWithName(addressBook,name);//
    // 若找到了，显示其信息
    if ((people != nil) && [people count])
    {
        ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
        ABPersonViewController *picker = [[ABPersonViewController alloc] init];
        picker.personViewDelegate = self;
        picker.displayedPerson = person;
        picker.allowsEditing = YES;//是否显示编辑按钮
        picker.allowsActions = NO;//是否显示可以打电话发信息
        [self.navigationController pushViewController:picker animated:YES];
        
    }
    else
    {
        // 提示找不到联系人
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not find %@",string] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        //[alert show];
        [self.tableView reloadData];
        
    }
    
    CFRelease(addressBook);
    
}

#pragma mark --ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property. 不允许用户执行默认行为如拨电话号码，当他们选择一个联系人。
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return NO;
}

#pragma mark -- searchController 协议方法
//返回搜索结果
-(void) updateSearchResultsForSearchController:(UISearchController *)searchController
{
    //tempString = searchController.searchBar.text;
    
    if (self.searchsArray!= nil) {
        [self.searchsArray removeAllObjects];
    }
    
    NSString *numberInputString = [searchController.searchBar.text pinyinTrimIntNumber];
    VCLog(@"numberInputString:%@",numberInputString);
    
    //NSString *AlastChar = [self.searchController.searchBar.text substringWithRange:NSMakeRange(self.searchController.searchBar.text.length-1, 1)];
    //NSString *inputStrings = [NSString stringWithFormat:@"-%@[0-9,A,B,C]*",AlastChar];
    
    //连续输入
    //[self ContactsZZStringAndArrayInputchar:inputStrings aChar:AlastChar];
    
    //删除
    
    
    
    
    
    NSString *searchString = [self.searchController.searchBar text];
    //NSPredicate *preicate = [NSPredicate predicateWithFormat:@"(SELF.personName CONTAINS[c] %@) OR (SELF.personTel contains [c] %@)", searchString];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"(SELF.personName CONTAINS[c] %@) or (self.personTel contains[c] %@)", searchString,searchString ];
    
    //过滤数据
    self.searchsArray= [NSMutableArray arrayWithArray:[_dataList filteredArrayUsingPredicate:preicate]];
    VCLog(@"searchArray :%@",self.searchsArray);
    VCLog(@"preicate :%@",preicate);
    
    //[self removeTableViewFootView];
    //刷新表格
    [self.searchVC.tableView reloadData];
    [self.tableView reloadData];
    
}

#pragma mark -- 新增联系人
-(IBAction)addNewContacts:(UIBarButtonItem *)sender
{
    
    ABNewPersonViewController *newPerson =[[ABNewPersonViewController alloc] init];
    newPerson.newPersonViewDelegate = self;
    [self.navigationController pushViewController:newPerson animated:YES];
    
}

//返回
-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    VCLog(@"add new people:%@",person);
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
