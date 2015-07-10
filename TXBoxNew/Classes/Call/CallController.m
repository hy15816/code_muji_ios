//
//  CallController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define kRemoveZZArray @"removeZZArray"

#import "CallController.h"
#import "TXSqliteOperate.h"
#import <AddressBookUI/AddressBookUI.h>
#import "NSString+helper.h"
#import "MsgDetailController.h"
#import "TXTelNumSingleton.h"
#import "Records.h"
#import "DiscoveryController.h"
#import "GetAllContacts.h"
#import "CallAndDivert.h"

@interface CallController ()<UITextFieldDelegate,ABPersonViewControllerDelegate,ABNewPersonViewControllerDelegate,GetContactsDelegate,CallAndDivertDelegate>
{
    NSMutableArray *CallRecords;
    TXSqliteOperate *sqlite;
    
    UIWebView *webView;
    NSUserDefaults *defaults;
    NSMutableArray *mutPhoneArray;
    NSMutableDictionary *phoneDic;      //同一个人的手机号码dic

    TXTelNumSingleton *singleton;   //获取输入的号码
    NSMutableArray *searchResault;
    NSArray *dataList;
    DiscoveryController *discoveryCtrol;
    
    NSMutableArray *zzArray;
    NSString *areaString;
    NSString *opeareString;
    
    
    CallAndDivert *callDivert;
    NSString *searcherString;
    BOOL canAdd;
}

- (IBAction)callAnotherPelple:(UIBarButtonItem *)sender;
@property (weak,nonatomic) UIAlertController *alertc;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中
@end


@implementation CallController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    
    //textInput
    if([self respondsToSelector:@selector(inputTextDidChanged:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextDidChanged:) name:kInputCharNoti object:nil];
    }
    // delete
    if([self respondsToSelector:@selector(deleteTextDidChanged:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTextDidChanged:) name:kDeleteCharNoti object:nil];
    }
    
    if([self respondsToSelector:@selector(callviewWillRefresh)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callviewWillRefresh) name:kCallViewReloadData object:nil];
    }
    
    //查询数据库获取通话记录
    NSMutableArray *array = [sqlite searchInfoFromTable:CALL_RECORDS_TABLE_NAME];
    //排序
    CallRecords = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
    //VCLog(@"int max:%i",INT_MAX);
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //获取联系人数据#pragma mark-- 获取通讯录联系人
    [self loadContacts];
}

-(void)loadContacts{
    GetAllContacts *contacts = [[GetAllContacts alloc] init];
    contacts.getContactsDelegate = self;
    [contacts getContacts];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"电话";
    [self loadCallRecords];
    
    canAdd = YES;
    self.selectedIndexPath = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//tableview分割线
    //self.tableView.tableFooterView = [[UIView alloc] init];
    
    zzArray =[[NSMutableArray alloc] init];
    areaString = [[NSString alloc] init];
    opeareString = [[NSString alloc] init];
 
    callDivert =[[CallAndDivert alloc] init];
   
    NSMutableString *s =[[NSMutableString alloc] initWithString:@"-1.*"];
    [s insertString:@"GG" atIndex:s.length-2];
    VCLog(@"s:%@",s);
    
}

#pragma mark -- getContacts Delegate
-(void)getAllPhoneArray:(NSMutableArray *)array SectionDict:(NSMutableDictionary *)sDict PhoneDict:(NSMutableDictionary *)pDict
{
    mutPhoneArray = array;
    //VCLog(@"mutPhoneArray:%@",array);
}

//初始化
- (void) loadCallRecords{
    
    //创建data对象的数组
    CallRecords = [[NSMutableArray alloc] init];
    mutPhoneArray =[[NSMutableArray alloc] init];
    phoneDic = [[NSMutableDictionary alloc] init];
    sqlite = [[TXSqliteOperate alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
    singleton = [TXTelNumSingleton sharedInstance];
    searchResault = [[NSMutableArray alloc] init];
    
}

-(void)callviewWillRefresh
{
    //[self.tableView reloadData];
}

#pragma mark -- 用户退格输入时
-(void)deleteTextDidChanged:(NSNotification*)notifi{
    NSString *lastChar = [[notifi userInfo] valueForKey:@"lastChar"];
    NSString *searchText = [[notifi userInfo] valueForKey:@"searchBarText"];
    searcherString = searchText;
    //退格
    [self deleteCharWithLastinput:lastChar];
    [self predictaeDataWithState:0];
    
}
#pragma mark -- 用户增加输入时
-(void)inputTextDidChanged:(NSNotification*)notifi{
    
    NSString *searchText = [[notifi userInfo] valueForKey:@"searchBarText"];
    searcherString = searchText;
    NSString *lastChar = [searchText substringWithRange:NSMakeRange(searchText.length-1, 1)];
    //NSString *testString = [NSString stringWithFormat:@"-%@[0-9,A,B,C].*",lastChar];
    
    NSString *inputString = [NSString stringWithFormat:@"-%@[0-9,A,B,C].*",lastChar];
    //生成zz表达式
    [self zzStringAndArrayInputchar:inputString aChar:lastChar];
    
    [self predictaeDataWithState:1];
}

/**
 *  @pragma state 输入状态，删除0，增加输入1，
 */
-(void)predictaeDataWithState:(int)state{
    
    
    if (searchResault.count != 0) {
        [searchResault removeAllObjects];
    }
    //NSMutableArray *arrayZZMut = [[NSMutableArray alloc] init];
    
    //过滤数据
    for (NSMutableString *str in zzArray) {
        NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
        for (NSDictionary *dict in mutPhoneArray) {
            //匹配姓名
            NSString *pnameNum = [dict valueForKey:@"personNameNum"];
            //VCLog(@"pnameNum:%@ ",pnameNum);
            //VCLog(@"regextestcm-str:%@ ",str);
            if ([regextestcm evaluateWithObject:pnameNum]) {
                if (![searchResault containsObject:dict]) {
                    [searchResault addObject:dict];
                }
               
            }
            //匹配号码
            NSString *phoneNum = [dict valueForKey:@"personTelNum"];
            if ([regextestcm evaluateWithObject:phoneNum]) {
                if (![searchResault containsObject:dict]) {
                    [searchResault addObject:dict];
                }

            }
            
        }
    }
    
    
    [self setModel];
     //VCLog(@"searchResault:%@",searchResault);
    
    //输入的数字达到7个，且还没有结果时
    if (searchResault.count == 0 && searcherString.length >= 7) {
        
        areaString = [sqlite searchAreaWithHisNumber:[singleton.singletonValue substringToIndex:7]];
        VCLog(@"areaString:%@",areaString);
        opeareString = [singleton.singletonValue isMobileNumberWhoOperation];
        
    }
    
    if (state == 0 && singleton.singletonValue.length == 1) {
        [zzArray removeAllObjects];
    }
    
    [self.tableView reloadData];
    
    if (searcherString.length <= 0) {
        //重新获取数据库获取通话记录
        NSMutableArray *array = [sqlite searchInfoFromTable:CALL_RECORDS_TABLE_NAME];
        //排序
        CallRecords = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
        [self.tableView reloadData];
    }
    
    
}


//数据模型
-(void)setModel{
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *dict in searchResault) {
        
        Records *record = [[Records alloc] init];
        // 给record赋值
        [record setValuesForKeysWithDictionary:dict];//record:<Records: 0x7fa2f27207c0,personTel: 888-555-1212,personName: John Appleseed>
        [arrayM addObject:record];
        
    }
    //VCLog(@"arrayM:%@",arrayM);
    dataList = arrayM;
    //VCLog(@"arrayM-0:%@",[[arrayM objectAtIndex:0] valueForKey:@"personTel"]);
    
}
/**
 *  增加输入时生成的zz表达式
 *  @param inputChar 输入的串
 *  @param achar     输入的最后一个字
 */
-(void)zzStringAndArrayInputchar:(NSString *)inputChar aChar:(NSString *)achar
{
    
    if (zzArray.count <1) {
        NSMutableString *mstring = [[NSMutableString alloc] initWithFormat:@"-%@.*",achar];
        [zzArray addObject:mstring];
    }
    
    NSMutableArray *latterArray = [[NSMutableArray alloc] init];
    
    if (singleton.singletonValue.length>1  ) {
        if (canAdd) {
            
            for (NSMutableString *sss in zzArray) {
                //-1.* -> -1.*-2[0-9].*
                NSMutableString *str1 = [NSMutableString stringWithFormat:@"%@%@",sss,inputChar];
                
                //-1.* -> -12[0-9].*
                if (sss.length <=14 ) {
                    VCLog(@"ssss.length:%lu",(unsigned long)sss.length);
                    [sss insertString:achar atIndex:sss.length-2];
                }else{
                    [sss insertString:achar atIndex:sss.length-12];
                }
                
                
                [latterArray addObject:str1];
                [latterArray addObject:sss];
            }
            
            zzArray =latterArray;
        }
        
    }
    
    
    VCLog(@"zzArray:%@",zzArray);
    
}
/**
 *  删除操作时生成的zz表达式
 *  @pragma lastinput 输入的最后一个字
 */
-(void)deleteCharWithLastinput:(NSString *)lastinput{
    
    NSMutableArray *lArray = [[NSMutableArray alloc] init];
    if (zzArray.count >1) {
        
        for (int i= 0; i<zzArray.count; i++) {
            if (i%2==0) {
                NSMutableString *sas = zzArray[i];
                NSMutableString *zzs = (NSMutableString *)[sas substringToIndex:sas.length-15];
                if(![lArray containsObject:zzs])
                    [lArray addObject:zzs];
            }
            
        }
        
        zzArray = lArray;
        VCLog(@"lArray:%@",lArray);
    }
    
    
}


#pragma mark -- Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    /*
    if (searchResault.count == 0 && singleton.singletonValue.length>=7) {
        return 1;
    }
    */
    
    if (searchResault.count == 0 && searcherString.length >= 7) {
        return 1;
    }
    if (searcherString.length > 0 && searchResault.count>0 )  {
        return searchResault.count;
    }else{
        return [CallRecords count];
    }
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //用CallRecordsCell做初始化
    CallRecordsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (searchResault.count == 0 && searcherString.length >= 7) {
        cell.hisName.text = [singleton.singletonValue insertStr];
        cell.callBeginTime.text =[NSString stringWithFormat:@"%@ %@",areaString,opeareString] ;
        cell.hisNumber.hidden = YES;
        cell.callDirection.hidden = YES;
        cell.callLength.hidden = YES;
        cell.hisOperator.hidden = YES;
        cell.hisHome.hidden = YES;
    }

    //用户输入时
    if (searcherString.length > 0 &&searchResault.count > 0 ) {
        Records *record = dataList[indexPath.row];
        cell.hisName.text = record.personName;
        cell.hisNumber.hidden = YES;
        cell.callDirection.hidden = YES;
        cell.callLength.hidden = YES;
        cell.callBeginTime.text = record.personTel;
        cell.hisHome.hidden = YES;
        cell.hisOperator.hidden = YES;
    }
    
        //未输入，显示通话记录
    if(searcherString.length <= 0 ) {
        
        //VCLog(@"CallRecords:%@,indexPath.row:%lu",CallRecords,indexPath.row);
        TXData *aRecord  = [CallRecords objectAtIndex:indexPath.row];

        
        cell.callDirection.hidden = NO;
        cell.callLength.hidden = NO;
        cell.hisNumber.hidden = NO;
        cell.hisHome.hidden = NO;
        cell.hisOperator.hidden = NO;
        cell.hisName.text = aRecord.hisName;
        cell.hisNumber.text = [[aRecord.hisNumber purifyString] insertStr];
        cell.callDirection.image = [self imageForRating:[aRecord.callDirection intValue]];
        cell.callLength.text = aRecord.callLength;
        cell.callBeginTime.text = aRecord.callBeginTime;
        cell.hisHome.text = aRecord.hisHome;
        cell.hisOperator.text = aRecord.hisOperator;
        //没有名字。显示为编辑图标
        if (cell.hisName.text.length>0) {
            [cell.PersonButton setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
        }
     
    }
    
    
    [cell.CallButton addTarget:self action:@selector(CallButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.MsgButton addTarget:self action:@selector(MsgButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.PersonButton addTarget:self action:@selector(PersonButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}
//选择图标
- (UIImage *)imageForRating:(int)rating
{
    switch (rating)
    {
        case 0: return [UIImage imageNamed:@"icon_call_in.png"];
        case 1: return [UIImage imageNamed:@"icon_call_out.png"];
        case 2: return [UIImage imageNamed:@"icon_call_missed.png"];
    }
    return nil;
}

#pragma mark -- 按钮的跳转
-(void)CallButtonClick:(UIButton *)btn
{
    VCLog(@"callbtn click");
}

-(void)MsgButtonClick:(UIButton *)btn
{
    //自定键盘、callBtn,tabbar隐藏
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
    //当前选中行
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    TXData *mdata = [[TXData alloc] init];
    
    //获取归属地
    

    
    if (searcherString.length <= 0) {
        TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
        mdata.hisName = aRecord.hisName;
        mdata.hisNumber = aRecord.hisNumber;
        mdata.hisHome = aRecord.hisHome;
    }else{
        NSDictionary *dict = [searchResault objectAtIndex:indexPath.row];
        mdata.hisName = [dict valueForKey:@"personName"];
        mdata.hisNumber = [dict valueForKey:@"personTel"];
        if (mdata.hisNumber.length >=7) {
            mdata.hisHome  = [sqlite searchAreaWithHisNumber:[[mdata.hisNumber purifyString] substringToIndex:7]];
        }else{mdata.hisHome =   @"";}
        
    }
    
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MsgDetailController *controller = [board instantiateViewControllerWithIdentifier:@"msgDetail"];
    controller.datailDatas = mdata;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}
//
-(void)PersonButtonClick:(UIButton *)btn
{
    //隐藏tabbar和callBtn
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideTabBarAndCallBtn object:self]];
    //当前选中行
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    TXData *aRecord;
    if (searcherString.length <= 0) {
        aRecord = [CallRecords objectAtIndex:indexPath.row];
        VCLog(@"==================hisname:%@",aRecord.hisName);
        if (aRecord.hisName.length==0 || [aRecord.hisName isEqualToString:@""] || aRecord.hisName ==nil) {
            //跳转到添加联系人
            
            [self showAddperson];
            
            VCLog(@"show newPerson view");
        }else
        {
            //跳转 详情->编辑
            [self showPersonViewControllerWithName:aRecord.hisName];
        }
    }else{
        NSDictionary *dict = [searchResault objectAtIndex:indexPath.row];
        NSString *name = [dict valueForKey:@"personName"];
        VCLog(@"==================hisname:%@",aRecord.hisName);
        if ([name length]==0 || [name isEqualToString:@""] || name ==nil) {
            //跳转到添加联系人
            
            [self showAddperson];
            
            VCLog(@"show newPerson view");
        }else
        {
            //跳转 详情->编辑
            [self showPersonViewControllerWithName:name];
        }
        
    }
    
    
}

#pragma mark -- tableView delegate
//设置cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        if ([indexPath isEqual:self.selectedIndexPath]) {
            
            return 50 + 50;
        }
        
        return 50;
    
}

//单元格可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


//可编辑样式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete)
        
    {
        //删除数据库的数据
        TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];

        [sqlite deleteContacterWithNumber:[aRecord.hisNumber purifyString] formTable:CALL_RECORDS_TABLE_NAME peopleId:nil withSql:DELETE_CALL_RECORD_SQL];
        
        NSMutableArray *array = [ [ NSMutableArray alloc ] init ];
        [array addObject: indexPath];
        
        //移除数组的元素
        [CallRecords removeObjectAtIndex:indexPath.row];
        //删除单元格
        [ self.tableView deleteRowsAtIndexPaths: array withRowAnimation: UITableViewRowAnimationLeft];
        
    }

}

/*改变删除按钮的text*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

//样式--删除
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//选中cell时
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.selectedIndexPath] ) {
        
        self.selectedIndexPath = nil;
        
    }else {
        
        self.selectedIndexPath = indexPath;
    }
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

#pragma mark --callDivert Delegate
-(void)hasNotLogin{
    //VCLog(@"hasNotLogin");
    [self jumpToDiscoveryCtrol];
    
    
}
-(void)hasNotConfig{
    [self jumpToDiscoveryCtrol];
    //VCLog(@"hasNotConfig");
}

-(void)jumpToDiscoveryCtrol{
    //tab到发现
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kJumptoDiscoeryView object:self]];
}

//是否呼转，开OR关
-(void)openOrCloseCallDivertState:(CallDivertState)state number:(NSString *)number{
    
    if (number.length>0) {
        // 呼叫
        // 不要将webView添加到self.view，如果添加会遮挡原有的视图
        if (webView == nil) {
            webView = [[UIWebView alloc] init];
        }
        
        NSURL *url = [NSURL URLWithString:number];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [webView loadRequest:request];
        VCLog(@"calloutNumber:%@",number);
    }
    if (state == OpenDivert) {
        VCLog(@"open d");
    }else{
        VCLog(@"close d");
    }
    
}


#pragma mark -- 呼转Button
- (IBAction)callAnotherPelple:(UIBarButtonItem *)sender
{
    callDivert.divertDelegate = self;
    [callDivert isOrNotCallDivert:PhoneView];
    
}

#pragma mark -- 跳转到添加联系人
/**
 *  跳转到add联系人
 */
-(void)showAddperson
{
    ABNewPersonViewController *newPerson = [[ABNewPersonViewController alloc]init];
    newPerson.newPersonViewDelegate=self;
    newPerson.title = @"添加联系人";
    [self.navigationController pushViewController:newPerson animated:YES];
}
#pragma mark --new person
-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark -- 跳转到编辑联系人
/**
 *  跳转到edit联系人
 *  @pragma string name
 */
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInputCharNoti object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeleteCharNoti object:nil];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
