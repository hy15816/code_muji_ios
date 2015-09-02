//
//  ContactController.m
//  TXBoxNew
//
//  Created by Naron on 15/7/6.
//  Copyright (c) 2015年 playtime. All rights reserved.
//  通讯录主页

#define HeaderViewColor [[UIColor alloc]initWithRed:239/255.f green:239/255.f blue:240/255.f alpha:1];//sectionHeader 视图背景色
#define IsUpdateContacts @"iscontacts"
#define NAME @"people_name"
#define PHONE @"people_phone"
#define PID @"people_id"

#import "ContactController.h"
#import "ContactsTableViewCell.h"
#import <AddressBookUI/AddressBookUI.h>
#import "NSString+helper.h"
#import "MsgDetailController.h"
#import "DBDatas.h"
#import "DBHelper.h"
#import "pinyin.h"
#import "Cellview.h"
#import "ConBook.h"
#import "BATableViewKit/BATableView.h"

@interface ContactController ()<UISearchResultsUpdating,UISearchControllerDelegate,ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate,CellViewDelegate,BATableViewDelegate>
{
    
    UIView *hudview;
    UILabel *showString;
    NSMutableArray *Allphones;
    NSMutableArray *searchsArray;          //搜索后的结果数组
    BOOL showIcon;

}

@property (assign,nonatomic) ABAddressBookRef abAddressBookRef;
@property (strong,nonatomic) NSMutableArray *sectionArray;
@property (strong,nonatomic) NSMutableDictionary *sectionDict;
@property (strong,nonatomic) UISearchController *searchController;  //实现disPlaySearchBar
@property (strong,nonatomic) UITableViewController *searchVC;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中
@property (strong,nonatomic) NSIndexPath *currentIndexPath;
@property (strong,nonatomic) NSArray *sortedArray;

@property (strong,nonatomic) BATableView *baTableView;

-(IBAction)addNewContacts:(UIBarButtonItem *)sender;
@end

@implementation ContactController


-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if (![userDefaults boolForKey:IsUpdateContacts]) {
        [userDefaults setBool:YES forKey:IsUpdateContacts];
        [self getAllPeoples];
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
    showIcon = NO;
    
    [self authorizStatus];
    
    //self.tableView = (UITableView *)[[BATableView alloc] initWithFrame:self.view.frame];
    //self.tableView.delegate = self;
    //[self.view addSubview:self.baTableView];
    
    [userDefaults setBool:NO forKey:IsUpdateContacts];
    self.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //索引相关
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor grayColor];
    //    self.tableView.sectionFooterHeight = 18.f;
    self.tableView.sectionHeaderHeight = 18.f;
    //self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor alloc]initWithRed:227/255.f green:212/255.f blue:197/255.f alpha:1];
    [self initSearchController];
    
    
}
/**
 *  获取通讯录
 */
-(BOOL)authorizStatus{
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authStatus == kABAuthorizationStatusAuthorized){
        
        if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
            
            dispatch_semaphore_t sema=dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(_abAddressBookRef, ^(bool greanted, CFErrorRef error){
                dispatch_semaphore_signal(sema);
                if (error) {
                    NSLog(@"error:%@",error);
                    return ;
                }
            });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
        }

        return YES;
    }

    return NO;
}

/**
 *  获取所有联系人
 */
-(void)getAllPeoples{
    if ([self authorizStatus]) {
        //设置分组的key
        for (int i = 0; i < 26; i++){
            
            [_sectionDict setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'A'+i]];
        }
        [_sectionDict setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'~']];
        
        CFErrorRef error;
        _abAddressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
        if (ABAddressBookGetPersonCount(_abAddressBookRef) == 0) {
            [SVProgressHUD showImage:nil status:@"0位联系人"];
            return;
        }
        //取得本地所有联系人记录
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(_abAddressBookRef);
        CFMutableArrayRef mresults=CFArrayCreateMutableCopy(kCFAllocatorDefault,CFArrayGetCount(results),results);
        NSMutableArray *peoleArray = [[NSMutableArray alloc] init];
        for (int i=0; i<CFArrayGetCount(results); i++) {
            
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
            //获取联系人属性
            ABRecordRef record=CFArrayGetValueAtIndex(mresults,i);
            NSString *compositeName = (__bridge NSString *)ABRecordCopyCompositeName(record);
            NSString *cid = [NSString stringWithFormat:@"%d",(int)ABRecordGetRecordID(record)];
            ABMultiValueRef phoneNumber = ABRecordCopyValue(record, kABPersonPhoneProperty);
            NSString *phone;
            if (ABMultiValueGetCount(phoneNumber) > 0) {//取所有号码
                phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber,0));//获取一个号码
                [tempDic setObject:phone forKey:PHONE];
                
            }
            compositeName = compositeName.length>0?compositeName:phone;
            [tempDic setObject:compositeName.length>0?compositeName:@"1无名称" forKey:NAME];
            [tempDic setObject:cid forKey:PID];//
            
            [peoleArray addObject:tempDic];
        }
        Allphones = peoleArray;
        
        [self sortingRecordArray];
    }else{
        NSLog(@"no author");
        
        UIAlertView *a =[[UIAlertView alloc] initWithTitle:@"手机联系人" message:@"是否允许读取联系人？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
        [a show];
        
    }
    
}




//对数组元素排序
-(void)sortingRecordArray{
    
    NSString *sectionName;
    for (int i=0; i<Allphones.count; i++) {
        
        NSString *nameString = [Allphones[i] objectForKey:NAME];//名字的第一个字
        char firstChar = pinyinFirstLetter([nameString characterAtIndex:0]);//名字的第一个字的字母;
        if ((firstChar >='a' && firstChar<='z')||(firstChar>='A' && firstChar<='Z')) {
            
            sectionName = [[NSString stringWithFormat:@"%c",firstChar] uppercaseString];
            
        }else {
            sectionName=[[NSString stringWithFormat:@"%c",'~'] uppercaseString];
        }
        
        //把phoneArray[i]添加到sectionDic的key中
        [[_sectionDict objectForKey:sectionName] addObject:Allphones[i]];
        if (![_sectionArray containsObject:sectionName]) {
            [_sectionArray addObject:sectionName];
        }
        
    }
    
    _sortedArray =[_sectionArray sortedArrayUsingSelector:@selector(compare:)];//排序
    NSLog(@"book count%lu",(unsigned long)Allphones.count);
    //
    
}
-(void)initll{
    _sectionDict = [[NSMutableDictionary alloc] init];
    _sortedArray = [[NSArray alloc] init];
    _sectionArray = [[NSMutableArray alloc] init];
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

    return  [[_sectionDict objectForKey:key] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"ContactCell";
    
    ContactsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil){
        
        cell = [[ContactsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        Cellview *cellv = [[Cellview alloc] initWithFrame:CGRectMake(0, 40, cell.contentView.frame.size.width, 40)];
        cellv.delegate = self;
        cellv.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:cellv];
    }
    
    //取消cell 选中背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //搜索后
    if (self.searchController.active && searchsArray.count >0) {//显示searchArray数据
        cell.nameLabel.text = [[searchsArray objectAtIndex:indexPath.row] objectForKey:NAME];
        cell.numberLabel.text = [[searchsArray objectAtIndex:indexPath.row] objectForKey:PHONE];
        
    }else{
    NSString *key=[NSString stringWithFormat:@"%@",_sortedArray[indexPath.section]];
    NSMutableDictionary *dict = [[_sectionDict objectForKey:key]  objectAtIndex:indexPath.row];
    cell.nameLabel.text = [dict objectForKey:NAME];
    cell.numberLabel.text = [dict objectForKey:PHONE];
        //NSLog(@"cid:%@,%@",[dict objectForKey:PID],cell.nameLabel.text);
    }
    return cell;
    
}

-(void)cellviewActions:(UIButton *)btn{
    
    switch (btn.tag) {
        case 0:
            //
            [self callsBtnClick:btn];
            break;
        case 1:
            //
            [self msgsBtnClick:btn];
            break;
            
        default:
            [self editButtonClick:btn];
            break;
    }
    
    NSLog(@"cell-->%lu,%lu",self.currentIndexPath.section,self.currentIndexPath.row);
    
}
#pragma mark -- tableView..
//点击单元格
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndexPath = indexPath;
    if ([indexPath isEqual:self.selectedIndexPath] ) {
        
        self.selectedIndexPath = nil;
        //隐藏图标
        showIcon = NO;
    }else {
        self.selectedIndexPath = indexPath;
        //显示图标
        showIcon = YES;
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
    
    return _sortedArray;
}
 /*
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    if (self.searchController.active) {
        return nil;
    }
    
    return _sortedArray;
}
*/
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    [self.view.window addSubview:[self hudView:title]];
    if (hudview) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[hudview removeFromSuperview];
        });
    }
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
        NSMutableDictionary *dict = [searchsArray  objectAtIndex:indexPath.row];
        name = [dict objectForKey:NAME];
        phone = [dict objectForKey:PHONE];
        contactId = [dict objectForKey:PID];
    }else{
        NSString *key=[NSString stringWithFormat:@"%@",_sortedArray[indexPath.section]];
        NSMutableDictionary *dict = [[_sectionDict objectForKey:key]  objectAtIndex:indexPath.row];
        name = [dict objectForKey:NAME];
        phone = [dict objectForKey:PHONE];
        contactId =[dict objectForKey:PID];
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
    DBDatas *msgdata = [[DBDatas alloc] init];
    if (self.searchController.active) {
        NSMutableDictionary *dict = [searchsArray  objectAtIndex:indexPath.row];
        msgdata.hisName = [dict objectForKey:NAME];
        msgdata.hisNumber = [dict objectForKey:PHONE];
        msgdata.hisHome = [[DBHelper sharedDBHelper] getAreaWithNumber:[msgdata.hisNumber purifyString]];
        msgdata.contactID = [dict objectForKey:PID];
        msgDetail.datailDatas =msgdata;
        
    }else{
        NSString *key=[NSString stringWithFormat:@"%@",_sortedArray[indexPath.section]];
        NSMutableDictionary *dict = [[_sectionDict objectForKey:key]  objectAtIndex:indexPath.row];
        msgdata.hisName = [dict objectForKey:NAME];
        msgdata.hisNumber = [dict objectForKey:PHONE];
        msgdata.hisHome = [[DBHelper sharedDBHelper] getAreaWithNumber:[msgdata.hisNumber purifyString]];
        msgdata.contactID = [dict objectForKey:PID];
        msgDetail.datailDatas =msgdata;
        
    }
    [self.navigationController pushViewController:msgDetail animated:YES];
}


-(void)editButtonClick:(UIButton *)btn{
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideTabBarAndCallBtn object:self]];
    NSIndexPath *indexPath = self.currentIndexPath;
    
    if (self.searchController.active) {
        ABRecordID abid =[[[searchsArray objectAtIndex:indexPath.row] objectForKey:PID] intValue];
        ABRecordRef ref = [[ConBook sharBook] getRecordRefWithID:abid];
        [self showPersonViewControllerWithRecordRef:ref];
    }else{
        NSString *key=[NSString stringWithFormat:@"%@",_sortedArray[indexPath.section]];
        NSMutableDictionary *dict = [[_sectionDict objectForKey:key]  objectAtIndex:indexPath.row];
        ABRecordID abid = [[dict objectForKey:PID] intValue];
        ABRecordRef refd = [[ConBook sharBook] getRecordRefWithID:abid];
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
    //所有名字，号码，然后筛选
    for (NSMutableDictionary *dict in Allphones ) {
        NSString *name = [dict objectForKey:NAME];
        if (name.length>0) {
            if ([preicate evaluateWithObject:name] ) {
                if (![searchsArray containsObject:dict]) {
                    [searchsArray addObject:dict];
                }
                
            }
        }
        NSString *phone = [dict objectForKey:PHONE];
        if (phone.length>0) {
            if ([preicate evaluateWithObject:phone] ) {
                if (![searchsArray containsObject:dict]) {
                    [searchsArray addObject:dict];
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
        
        //ABAddressBookAddRecord(abBooksRef, person, &error);
        //ABAddressBookSave(abBooksRef, &error);
        
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
    /*
    // 保存/更新联系人到db
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int s=0; s<Allphones.count; s++) {
            DBDatas *datas = [[DBDatas alloc] init];
            datas.contactID = [Allphones[s] objectForKey:PID];
            datas.hisName = [Allphones[s] objectForKey:NAME];
            datas.hisNumber =  [[Allphones[s] objectForKey:PHONE] purifyString];
            if (![userDefaults boolForKey:@"issavecontacts"]) {
                [userDefaults setBool:YES forKey:@"issavecontacts"];
                [[DBHelper sharedDBHelper] saveContacts:datas];
            }else{
                [[DBHelper sharedDBHelper] updateContactsInfo:datas];
            }
        }
        [[DBHelper sharedDBHelper] getAllPeopleInfo];
    });
     */

}

@end
