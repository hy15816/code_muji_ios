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
#import "pinyin.h"
#import "NSString+helper.h"
#import "MsgDetailController.h"
#import "TXData.h"
#import "TXSqliteOperate.h"
#import "MyAddressBooks.h"

@interface ContactController ()<UISearchResultsUpdating,UISearchControllerDelegate,ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate,MyAddressBooksDelegate>
{
    
    TXData *msgdata;
    TXSqliteOperate *txsql;
    UIView *hudview;
    UILabel *showString;
    
    MyAddressBooks *abAddressBooks;
    ABAddressBookRef abBooksRef;
    NSMutableArray *peopleArray;
    NSMutableDictionary *sectionDict;
    NSMutableArray *sectionArray;
    NSMutableArray *dataArray;
                 //排序后的数组
    NSMutableArray *nameNumberArray;//
    NSMutableArray *Allphones;
    NSMutableArray *searchsArray;          //搜索后的结果数组
    ABRecordID abrecordID;
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
    
    [self initll];
    
    //第一次获取通讯录
    if (![userDefaults boolForKey:IsUpdateContacts]) {
        [userDefaults setBool:YES forKey:IsUpdateContacts];
        [abAddressBooks CreateAddressBooks];
        [self sectionDicts];
        [self setNameAndNumberDicts];
        [self.tableView reloadData];
    }
    
    //[self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    [self changedTableViewIndex];//改变索引属性
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedIndexPath = nil;
    
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
    abAddressBooks = [MyAddressBooks sharedAddBooks];
    abAddressBooks.delegate = self;
    sectionArray = [[NSMutableArray alloc] init];
    sectionDict = [[NSMutableDictionary alloc] init];
    self.sortedArray = [[NSArray alloc] init];
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

//生成分组
-(void)sectionDicts{
    
    for (int i = 0; i < 26; i++){
        
        [sectionDict setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'A'+i]];
    }
    [sectionDict setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'~']];
    
    [self sortingRecordArray];
    
}

//对数组元素排序
-(void)sortingRecordArray{
    
    NSString *sectionName;
    for (int i=0; i<peopleArray.count; i++) {
        ABRecordRef record = (__bridge ABRecordRef)([peopleArray objectAtIndex:i]);
        
        NSString *nameString = [self getShowNameText:record];
        
        char firstChar = pinyinFirstLetter([nameString characterAtIndex:0]);// [name characterAtIndex:0];
        if ((firstChar >='a' && firstChar<='z')||(firstChar>='A' && firstChar<='Z')) {
            
            sectionName = [[NSString stringWithFormat:@"%c",firstChar] uppercaseString];
            
        }else {
            sectionName=[[NSString stringWithFormat:@"%c",'~'] uppercaseString];
        }
        
        //把phoneArray[i]添加到sectionDic的key中
        [[sectionDict objectForKey:sectionName] addObject:(__bridge id)(record)];
        if (![sectionArray containsObject:sectionName]) {
            [sectionArray addObject:sectionName];
        }
        
    }
    
    self.sortedArray =[sectionArray sortedArrayUsingSelector:@selector(compare:)];
    
    NSLog(@"sectionDict:%@",sectionDict);
    NSLog(@"dataArray:%@",dataArray);
}

-(void)setNameAndNumberDicts{
    
    for (int i=0; i<peopleArray.count; i++) {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
        ABRecordRef record = (__bridge ABRecordRef)(peopleArray[i]);
        ABRecordID recordID = ABRecordGetRecordID(record);
        //NSLog(@"recordID:%d",recordID);
        //ABRecordRef ref = ABAddressBookGetPersonWithRecordID(abBooksRef , recordID);
        NSString *name;
        NSString  *firstName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString  *lastName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonLastNameProperty));
        
        if (firstName.length == 0) {
            firstName = @"";
        }
        if (lastName.length == 0) {
            lastName = @"";
        }
        
        name = [NSString stringWithFormat:@"%@%@",firstName,lastName];
        
        NSString *phone;

        //获取号码
        ABMultiValueRef phoneNumber = ABRecordCopyValue(record, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumber) > 0) {//取第一个号码
            phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber,0));

        }
        if (name.length >0 && phone.length >0) {
            [dict setValue:[NSString stringWithFormat:@"%d",recordID] forKey:phone];
        }else if(name.length<=0 && phone.length>0 ){
            [dict setValue:[NSString stringWithFormat:@"%d",recordID] forKey:phone];
            
        }else{
            [dict setValue:[NSString stringWithFormat:@"%d",recordID] forKey:name];
        }
        [nameNumberArray addObject:dict];
    
    }
    
    for (NSMutableDictionary *dicts in nameNumberArray) {
        for (NSString *keys in dicts) {
            [Allphones addObject:keys];
        }
    }
    
    NSLog(@"--%@",[nameNumberArray[0] valueForKey:@"186-7569-2900"]);
    NSLog(@"Allphones:%@",Allphones);
    NSLog(@"nameNumberArray:%@",nameNumberArray);
    
}

//获取应该显示的text
-(NSString *)getShowNameText:(ABRecordRef)record{
    
    NSString *name;
    NSString  *firstName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonFirstNameProperty));
    NSString  *lastName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonLastNameProperty));
    
    if (firstName.length == 0) {
        firstName = @"";
    }
    if (lastName.length == 0) {
        lastName = @"";
    }
    
    name = [NSString stringWithFormat:@"%@%@",firstName,lastName];
    if (name.length <= 0) {
        //获取号码
        ABMultiValueRef phoneNumber = ABRecordCopyValue(record, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumber) > 0) {
            NSString *phone = [NSString stringWithFormat:@"%@",ABMultiValueCopyValueAtIndex(phoneNumber,0)];
            //NSLog(@"phone:%@",phone);
            name = phone;
            if (![dataArray containsObject:name]) {
                [dataArray addObject:name];
            }
            
            return name;
        }
        
    }
    
    if (![dataArray containsObject:name]) {
        [dataArray addObject:name];
    }
    return name;
}

//获取该Record的号码数组
-(NSMutableArray *)getShowPhoneText:(ABRecordRef)record{
    
    NSMutableArray *phonesArray = [[NSMutableArray alloc] init];
    NSString *phone;
    //获取号码
    ABMultiValueRef phoneNumber = ABRecordCopyValue(record, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumber) > 0) {
        for (int i=0 ; i<ABMultiValueGetCount(phoneNumber); i++) {
            phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber,i));
            
            [phonesArray addObject:phone];
        }
        //NSLog(@"phonesArray:%@",phonesArray);
        return phonesArray;
    }else{
        [phonesArray addObject:@""];
    }
    return phonesArray;
}


#pragma mark -- MyAddressBooks Delegate
-(void)sendNotify:(MyBooksNotifity)noti{
    
    if (noti == kMyBooksNotifityStatusNoAuthority) {
        UIAlertView *a =[[UIAlertView alloc] initWithTitle:@"a" message:@"权限已关闭,是否打开？" delegate:self cancelButtonTitle:@"0" otherButtonTitles:@"1", nil];
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
    
    //联系人名字与对应的id
    /*
    for (int i=0;i<peopleArray.count ;i++   ) {
        
        ABRecordRef abf = (__bridge ABRecordRef)(peopleArray[i]);
        NSString *name;
        NSString  *firstName = (__bridge NSString *)(ABRecordCopyValue(abf, kABPersonFirstNameProperty));
        NSString  *lastName = (__bridge NSString *)(ABRecordCopyValue(abf, kABPersonLastNameProperty));
        
        if (firstName.length == 0) {
            firstName = @"";
        }
        if (lastName.length == 0) {
            lastName = @"";
        }
        
        name = [NSString stringWithFormat:@"%@%@",firstName,lastName];
        ABRecordID abid = ABRecordGetRecordID(abf);
        NSLog(@"%@------%d",name,abid);
        
    }
     */
}

#pragma mark --alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        NSLog(@"0");
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }else{
        NSLog(@"1");
        
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //是搜索后的tableView
    if (self.searchController.active) {
        return 1;
    }
    return self.sortedArray.count;//否则返回索引个数
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.searchController.active) {
        return searchsArray.count;
    }
    
    //返回sectionDic的 key里有值的value的个数
    NSString *key=[NSString stringWithFormat:@"%@",self.sortedArray[section]];
    //NSLog(@"sec:%ld,conut:%lu",(long)section,(unsigned long)[[sectionDict objectForKey:key] count]);
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
    //取消cell 选中背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.searchController.active) {
        [searchsArray removeAllObjects];
    }
    
    //搜索后
    if (self.searchController.active && searchsArray.count >0) {
        //把searchArray根据每行显示
        ABRecordRef ref = (__bridge ABRecordRef)([searchsArray objectAtIndex:indexPath.row]);
        cell.nameLabel.text = [self getShowNameText:ref];
        cell.numberLabel.text = [[self getShowPhoneText:ref] firstObject];
        
    }else{
        
        NSString *key=[NSString stringWithFormat:@"%@",self.sortedArray[indexPath.section]];
        ABRecordRef ref = (__bridge ABRecordRef)([[sectionDict objectForKey:key] objectAtIndex:indexPath.row]);
        abrecordID  = ABRecordGetRecordID(ref);
        cell.nameLabel.text = [self getShowNameText:ref];
        cell.numberLabel.text = [[self getShowPhoneText:ref] firstObject];
        //cell.numberLabel.text = [[[[persons objectAtIndex:indexPath.row] objectForKey:@"personTel"] purifyString] insertStr];
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
    
    return self.sortedArray;
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
    title.text = [self.sortedArray objectAtIndex:section];
    
    [headerView addSubview:title];
    
    return headerView;
}

-(void)callsBtnClick:(UIButton *)btn{
    
    NSIndexPath *indexPath = self.currentIndexPath;
    //ABRecordRef ref = (__bridge ABRecordRef)([searchsArray objectAtIndex:indexPath.row]);
    NSString *name;
    NSString *phone;
    NSString *contactId;

    if (self.searchController.active) {
        
        ABRecordRef ref = (__bridge ABRecordRef)([searchsArray objectAtIndex:indexPath.row]);
        name = [self getShowNameText:ref];
        phone = [[self getShowPhoneText:ref] firstObject];
        contactId = [NSString stringWithFormat:@"%d",ABRecordGetRecordID(ref)];
    }else{
        NSString *key=[NSString stringWithFormat:@"%@",self.sortedArray[indexPath.section]];
        ABRecordRef refd = (__bridge ABRecordRef)([[sectionDict objectForKey:key] objectAtIndex:indexPath.row]);
        name = [self getShowNameText:refd];
        phone = [[self getShowPhoneText:refd] firstObject];
        contactId = [NSString stringWithFormat:@"%d",ABRecordGetRecordID(refd)];
        
    }
    
    //把姓名号码传过去
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"hisName",phone,@"hisNumber",contactId,@"contactId", nil];
    
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
        
        ABRecordRef ref = (__bridge ABRecordRef)([searchsArray objectAtIndex:indexPath.row]);
        msgdata.hisName = [self getShowNameText:ref];
        msgdata.hisNumber = [[self getShowPhoneText:ref] firstObject];
        if (msgdata.hisNumber.length >=7) {
            msgdata.hisHome = [txsql searchAreaWithHisNumber:[msgdata.hisNumber substringToIndex:7]];
        }else{msgdata.hisHome = @"";}
        msgDetail.datailDatas =msgdata;
    }else{
        NSString *key=[NSString stringWithFormat:@"%@",self.sortedArray[indexPath.section]];
        ABRecordRef refd = (__bridge ABRecordRef)([[sectionDict objectForKey:key] objectAtIndex:indexPath.row]);
        msgdata.hisName = [self getShowNameText:refd];
        msgdata.hisNumber = [[self getShowPhoneText:refd] firstObject];
        if (msgdata.hisNumber.length >=7) {
            msgdata.hisHome = [txsql searchAreaWithHisNumber:[msgdata.hisNumber substringToIndex:7]];
        }else{msgdata.hisHome = @"";}
        msgDetail.datailDatas =msgdata;
        
    }
    [self.navigationController pushViewController:msgDetail animated:YES];
}


-(void)editButtonClick:(UIButton *)btn{
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideTabBarAndCallBtn object:self]];
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSIndexPath *indexPath = self.currentIndexPath;
    
    if (self.searchController.active) {
        ABRecordRef ref = (__bridge ABRecordRef)([searchsArray objectAtIndex:indexPath.row]);
        [self showPersonViewControllerWithRecordRef:ref];
    }else{
        NSString *key=[NSString stringWithFormat:@"%@",self.sortedArray[indexPath.section]];
        ABRecordRef refd = (__bridge ABRecordRef)([[sectionDict objectForKey:key] objectAtIndex:indexPath.row]);
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
    
    NSString *numberInputString = [searchController.searchBar.text pinyinTrimIntNumber];
    VCLog(@"numberInputString:%@",numberInputString);
    
    
    NSString *searchString = [self.searchController.searchBar text];
    //NSPredicate *preicate = [NSPredicate predicateWithFormat:@"(SELF.personName CONTAINS[c] %@) OR (SELF.personTel contains [c] %@)", searchString];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF contains [c]  %@",searchString ];
    NSMutableArray *nameP =[NSMutableArray arrayWithArray:[dataArray filteredArrayUsingPredicate:preicate]];
    NSMutableArray *phoneP = [NSMutableArray arrayWithArray:[Allphones filteredArrayUsingPredicate:preicate]];
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    //过滤数据
    for (NSString *s in nameP) {
        if (![mArray containsObject:s]) {
            NSArray *array = (__bridge NSArray *)(ABAddressBookCopyPeopleWithName(abBooksRef,(__bridge CFStringRef)s));//若已有名字号码，只能用名字查找
            ABRecordRef recordRef = (__bridge ABRecordRef)([array lastObject]);
            if (![searchsArray containsObject:(__bridge id)(recordRef)]) {
                [searchsArray addObject:(__bridge id)(recordRef)];
            }
            
        }
        
    }
    
    for (NSString *s in phoneP) {
        int  i = 0 ;
        for (NSMutableDictionary *dcit in nameNumberArray) {
            if ([[dcit valueForKey:s] length] > 0) {
                //NSLog(@"%@",[dcit valueForKey:s]);
                i = [[dcit valueForKey:s] intValue];
            }
        }
        //根据号码-> id -> ref ->判断使用名字还是号码
        ABRecordID rid = i;
        ABRecordRef reff = ABAddressBookGetPersonWithRecordID(abBooksRef, rid);
        NSString *name = [self getShowNameText:reff];
        
        NSArray *array = (__bridge NSArray *)(ABAddressBookCopyPeopleWithName(abBooksRef,(__bridge CFStringRef)name));//若已有名字号码，只能用名字查找
        ABRecordRef recordRef = (__bridge ABRecordRef)([array lastObject]);
        if (![searchsArray containsObject:(__bridge id)(recordRef)]) {
            [searchsArray addObject:(__bridge id)(recordRef)];
        }
    }
    
    
    VCLog(@"searchArray :%@",searchsArray);
    VCLog(@"preicate :%@",preicate);
    
    //[self removeTableViewFootView];
    //刷新表格
    [self.searchVC.tableView reloadData];
    //[self.tableView reloadData];
    
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
