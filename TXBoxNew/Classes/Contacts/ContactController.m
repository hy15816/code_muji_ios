//
//  ContactController.m
//  TXBoxNew
//
//  Created by Naron on 15/7/6.
//  Copyright (c) 2015年 playtime. All rights reserved.
//
#define HeaderViewColor [[UIColor alloc]initWithRed:239/255.f green:239/255.f blue:240/255.f alpha:1];
#define IsUpdateContacts @"iscontacts"

#import "ContactController.h"
#import "ContactsTableViewCell.h"
#import <AddressBookUI/AddressBookUI.h>
#import "NSString+helper.h"
#import "MsgDetailController.h"
#import "TXData.h"
#import "TXSqliteOperate.h"
#import "MyAddressBooks.h"
#import "ConBook.h"

@interface ContactController ()<UISearchResultsUpdating,UISearchControllerDelegate,ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate,MyAddressBooksDelegate>
{
    
    TXData *msgdata;
    TXSqliteOperate *txsql;
    UIView *hudview;
    UILabel *showString;
    
    ABAddressBookRef abBooksRef;
    NSMutableArray *peopleArray;
    NSMutableDictionary *sectionDict;
    NSMutableArray *sectionArray;
    NSMutableArray *dataArray;
                 //排序后的数组
    NSMutableArray *nameNumberArray;//
    NSMutableArray *Allphones;
    NSMutableArray *searchsArray;          //搜索后的结果数组
    NSMutableArray *conBookArray;
}

@property (strong,nonatomic) UISearchController *searchController;  //实现disPlaySearchBar
@property (strong,nonatomic) UITableViewController *searchVC;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中
@property (strong,nonatomic) NSIndexPath *currentIndexPath;
@property (strong,nonatomic) NSArray *sortedArray;

-(IBAction)addNewContacts:(UIBarButtonItem *)sender;
@end

@implementation ContactController


-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if (![userDefaults boolForKey:IsUpdateContacts]) {
        [userDefaults setBool:YES forKey:IsUpdateContacts];
        [[MyAddressBooks sharedAddBooks] refReshContacts];//刷新联系人
        [self.tableView reloadData];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    [self changedTableViewIndex];//改变索引属性
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initll];
    
    [MyAddressBooks sharedAddBooks].delegate = self;
    [[MyAddressBooks sharedAddBooks] CreateAddressBooks];//第一次获取通讯录
    conBookArray = [[NSMutableArray alloc] init];
    
    [userDefaults setBool:NO forKey:IsUpdateContacts];
    self.title = @"通讯录";
    
    
    self.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //索引相关
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor grayColor];
    //    self.tableView.sectionFooterHeight = 18.f;
    self.tableView.sectionHeaderHeight = 18.f;
    //self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor alloc]initWithRed:227/255.f green:212/255.f blue:197/255.f alpha:1];
    [self initSearchController];
    
    
}

-(void)initll{
    peopleArray = [[NSMutableArray alloc] init];
    sectionArray = [[NSMutableArray alloc] init];
    sectionDict = [[NSMutableDictionary alloc] init];
    _sortedArray = [[NSArray alloc] init];
    dataArray = [[NSMutableArray alloc] init];
    msgdata = [[TXData alloc] init];
    txsql=[[TXSqliteOperate alloc] init];
    nameNumberArray = [[NSMutableArray alloc] init];
    Allphones =[[NSMutableArray alloc] init];
    searchsArray = [[NSMutableArray alloc] init];
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

#pragma mark -- MyAddressBooks Delegate
-(void)sendNotify:(MyBooksNotifity)noti{
    
    if (noti == kMyBooksNotifityStatusNoAuthority) {
        UIAlertView *a =[[UIAlertView alloc] initWithTitle:@"手机联系人" message:@"是否允许读取联系人？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
        [a show];
    }

}

-(void)noAuthority:(CFErrorRef)error{
    NSLog(@"error:%@",error);
}
-(void)abAddressBooks:(ABAddressBookRef)bookRef allRefArray:(NSMutableArray *)array{
    //NSLog(@"bookRef:%@ array:%@,conut:%lu",bookRef,array,(unsigned long)array.count);
    peopleArray = array;
    abBooksRef = bookRef;
    
}

-(void)SectionDicts:(NSMutableDictionary *)sectionDicts sortedArray:(NSArray *)sortedArray conbookArray:(NSMutableArray *)conbook{
    
    sectionDict = sectionDicts;
    _sortedArray = sortedArray;
    conBookArray = conbook;
    
    VCLog(@"conbook:%@",conbook);
    
}

#pragma mark --alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view 
//will 拖动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (hudview) {
        [hudview removeFromSuperview];
    }
}
//否则返回分区个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    //是搜索后的tableView
    if (self.searchController.active) {
        return 1;
    }
    return _sortedArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.searchController.active) {
        return searchsArray.count;
    }
    
    //返回sectionDic的 key里有值的value的个数
    NSString *key=[NSString stringWithFormat:@"%@",_sortedArray[section]];

    return  [[sectionDict objectForKey:key] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"CellID";
    ContactsTableViewCell *cell = (ContactsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        //加载cell-xib
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactsTableViewCell" owner:self options:nil] objectAtIndex:0];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//取消cell 选中背景色
    
    if (!self.searchController.active) {
        [searchsArray removeAllObjects];
    }
    
    //搜索后
    if (self.searchController.active && searchsArray.count >0) {//显示searchArray数据
        cell.nameLabel.text = [[searchsArray objectAtIndex:indexPath.row] fullName];
        cell.numberLabel.text = [[[searchsArray objectAtIndex:indexPath.row] phoneNumberArray] firstObject];
        
    }else{
        
        NSString *key=[NSString stringWithFormat:@"%@",_sortedArray[indexPath.section]];
        cell.nameLabel.text = [[[sectionDict objectForKey:key] objectAtIndex:indexPath.row] fullName];
        cell.numberLabel.text = [[[[sectionDict objectForKey:key] objectAtIndex:indexPath.row] phoneNumberArray] firstObject];
        //VCLog(@"name:%@,number:%@",cell.nameLabel.text,cell.numberLabel.text);
        
    }
    [cell.callBtns addTarget:self action:@selector(callsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.msgsBtn addTarget:self action:@selector(msgsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.editBtn addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
#pragma mark -- tableView..
//点击单元格
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.currentIndexPath = indexPath;
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
    
    if (hudview) {
        [hudview removeFromSuperview];
    }
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        //
        NSMutableArray *array = [[ NSMutableArray alloc ] init ];
        [array addObject: indexPath];
        
        //移除数组的元素
        
        //删除联系人
        
        //删除单元格
        [ self.tableView deleteRowsAtIndexPaths: array withRowAnimation: UITableViewRowAnimationLeft];
        
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
    
    return _sortedArray;
}


-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    [self.view.window addSubview:[self hudView:title]];
    
    return index;
}

-(UIView *)hudView:(NSString *)string{
    if (!hudview) {
        hudview =[[UIView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-DEVICE_WIDTH*.25f)/2, (DEVICE_HEIGHT-50)/2, DEVICE_WIDTH*.25f, DEVICE_WIDTH*.25f)];
        hudview.layer.cornerRadius = 3;
        hudview.userInteractionEnabled = YES;
        hudview.backgroundColor = [UIColor grayColor];
        hudview.alpha = .8f;
        showString = [[UILabel alloc] initWithFrame:CGRectMake(0, (DEVICE_WIDTH*.25f-30)/2, DEVICE_WIDTH*.25f, 30)];
        
        showString.textAlignment = NSTextAlignmentCenter;
        showString.textColor =[UIColor whiteColor];
        showString.font =[UIFont systemFontOfSize:16 weight:.2];
        
        [hudview addSubview:showString];
    }
    showString.text = string;
    
    return hudview;
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
    title.text = [_sortedArray objectAtIndex:section];
    
    [headerView addSubview:title];
    
    return headerView;
}
//call
-(void)callsBtnClick:(UIButton *)btn{
    
    NSIndexPath *indexPath = self.currentIndexPath;
    NSString *name;
    NSString *phone;
    NSString *contactId;

    if (self.searchController.active) {
        name = [[searchsArray objectAtIndex:indexPath.row] fullName];
        phone = [[[searchsArray objectAtIndex:indexPath.row] phoneNumberArray] firstObject];
        contactId = [[searchsArray objectAtIndex:indexPath.row] recordID];
    }else{
        NSString *key=[NSString stringWithFormat:@"%@",_sortedArray[indexPath.section]];
        name = [[[sectionDict objectForKey:key] objectAtIndex:indexPath.row] fullName];
        phone = [[[[sectionDict objectForKey:key] objectAtIndex:indexPath.row] phoneNumberArray] firstObject];
        contactId =[[[sectionDict objectForKey:key] objectAtIndex:indexPath.row] recordID] ;
    }
    
    //把姓名号码传过去
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"hisName",phone,@"hisNumber",contactId,@"hisContactId", nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCallingBtnClick object:self userInfo:dict]];
    
}

-(void)msgsBtnClick:(UIButton *)btn
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self ]];
    //进入msgDetail
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MsgDetailController *msgDetail = [board instantiateViewControllerWithIdentifier:@"msgDetail"];
    
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSIndexPath *indexPath = self.currentIndexPath;
    
    if (self.searchController.active) {
        
        msgdata.hisName = [[searchsArray objectAtIndex:indexPath.row] fullName];
        msgdata.hisNumber = [[[searchsArray objectAtIndex:indexPath.row] phoneNumberArray] firstObject];
        if (msgdata.hisNumber.length >=7) {
            msgdata.hisHome = [txsql searchAreaWithHisNumber:[msgdata.hisNumber substringToIndex:7]];
        }else{msgdata.hisHome = @"";}
        msgDetail.datailDatas =msgdata;
    }else{
        NSString *key=[NSString stringWithFormat:@"%@",_sortedArray[indexPath.section]];
        msgdata.hisName = [[[sectionDict objectForKey:key] objectAtIndex:indexPath.row] fullName];
        msgdata.hisNumber = [[[[sectionDict objectForKey:key] objectAtIndex:indexPath.row] phoneNumberArray] firstObject];
        if (msgdata.hisNumber.length >=7) {
            msgdata.hisHome = [txsql searchAreaWithHisNumber:[msgdata.hisNumber substringToIndex:7]];
        }else{msgdata.hisHome = @"";}
        msgDetail.datailDatas =msgdata;
        
    }
    [self.navigationController pushViewController:msgDetail animated:YES];
}


-(void)editButtonClick:(UIButton *)btn{
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideTabBarAndCallBtn object:self]];
    NSIndexPath *indexPath = self.currentIndexPath;
    
    if (self.searchController.active) {
        ABRecordID abid =[[[searchsArray objectAtIndex:indexPath.row] recordID] intValue];
        
        ABRecordRef ref = ABAddressBookGetPersonWithRecordID(abBooksRef, abid);
        [self showPersonViewControllerWithRecordRef:ref];
    }else{
        NSString *key=[NSString stringWithFormat:@"%@",_sortedArray[indexPath.section]];
        ABRecordID abid = [[[[sectionDict objectForKey:key] objectAtIndex:indexPath.row] recordID] intValue];
        ABRecordRef refd = ABAddressBookGetPersonWithRecordID(abBooksRef, abid);
        [self showPersonViewControllerWithRecordRef:refd];
    }
    
    
}
#pragma mark -- 跳转到编辑联系人
//跳转到edit联系人
-(void)showPersonViewControllerWithRecordRef:(ABRecordRef)recordRef{

    [userDefaults setBool:NO forKey:IsUpdateContacts];
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    personViewController.personViewDelegate = self;
    personViewController.displayedPerson = recordRef;
    personViewController.allowsEditing = YES;
    personViewController.allowsActions = NO;
    [self.navigationController pushViewController:personViewController animated:YES];
    
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
    
    if (searchsArray!= nil) {
        [searchsArray removeAllObjects];
    }
    
    NSString *searchString = [self.searchController.searchBar text];
    
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF contains [c]  %@",searchString ];
    for (ConBook *con in conBookArray) {
        if (con.fullName.length>0) {
            if ([preicate evaluateWithObject:con.fullName] ) {
                if (![searchsArray containsObject:con]) {
                    [searchsArray addObject:con];
                }
                
            }
        }
        
        if (con.phoneNumberArray.count>0) {
            if ([preicate evaluateWithObject:con.phoneNumberArray[0]] ) {
                if (![searchsArray containsObject:con]) {
                    [searchsArray addObject:con];
                }
            }
        }
        
    }
    
    VCLog(@"searchArray :%@",searchsArray);
    //VCLog(@"preicate :%@",preicate);
    
    //刷新表格
    [self.searchVC.tableView reloadData];
    [self.tableView reloadData];
    
}

#pragma mark -- 新增联系人
-(IBAction)addNewContacts:(UIBarButtonItem *)sender
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    
    ABNewPersonViewController *newPerson =[[ABNewPersonViewController alloc] init];
    newPerson.newPersonViewDelegate = self;
    [self.navigationController pushViewController:newPerson animated:YES];
    
}

//返回
-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    VCLog(@"add new people:%@",person);
    
    if (person) {
        CFErrorRef error = NULL;
        
        ABAddressBookAddRecord(abBooksRef, person, &error);
        ABAddressBookSave(abBooksRef, &error);
        
        if (error != NULL) {
            NSLog(@"An error occurred");
        }
    }
    
    [userDefaults setBool:NO forKey:IsUpdateContacts];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

//改变tableView 的索引属性
-(void)changedTableViewIndex{
    for (UIView* subview in [self.tableView subviews])
    {
        if ([subview isKindOfClass:NSClassFromString(@"UITableViewIndex")])
        {
            if([subview respondsToSelector:@selector(setFont:)])
            {
                [subview performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:14 weight:.1]];
            }
            
            if ([subview respondsToSelector:@selector(setFrame:)]) {
                [subview setFrame:CGRectMake(DEVICE_WIDTH-20, (DEVICE_HEIGHT-480)/2, 20, 480)];
                
                [subview performSelector:@selector(setFrame:) withObject:subview];
            }
            
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (hudview) {
        [hudview removeFromSuperview];
    }
    
    
    
}

@end
