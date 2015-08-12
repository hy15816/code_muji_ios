//
//  CallController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

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
#import <CoreText/CoreText.h>

static NSMutableArray *mLastAllRegularsMapArray;

@interface CallController ()<UITextFieldDelegate,ABUnknownPersonViewControllerDelegate,ABPersonViewControllerDelegate,ABNewPersonViewControllerDelegate,GetContactsDelegate,CallAndDivertDelegate>
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
    
    BOOL ish ;
    CallAndDivert *callDivert;
    NSString *searcherString;
    BOOL canAdd;
    NSMutableString *lengthString;//用于染色的length
}

@property (nonatomic,assign) ABAddressBookRef addressBook;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *callAnother;


- (IBAction)callAnotherPelple:(UIBarButtonItem *)sender;
@property (weak,nonatomic) UIAlertController *alertc;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;        //被选中
@property (strong,nonatomic) NSIndexPath *ccurrentIndexPath;    //当前被选中的
@end


@implementation CallController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL callaState = [[userDefaults valueForKey:CALL_ANOTHER_STATE] intValue];
    if (callaState) {
        [self.callAnother setImage:[UIImage imageNamed:@"call_another60_normal"]];
        
    }else{
        [self.callAnother setImage:[UIImage imageNamed:@"call_another60"]];
    }
    
    //textInput
    if([self respondsToSelector:@selector(inputTextDidChanged:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextDidChanged:) name:kInputCharNoti object:nil];
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
    
    CFErrorRef error = NULL;
    _addressBook  = ABAddressBookCreateWithOptions(nil, &error);
//    CFIndex nPeople = ABAddressBookGetPersonCount(_addressBook);
//    NSLog(@"People count：%ld",nPeople);

    //显示tabbar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
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
    
    
    
    ish = YES;
    self.title = @"电话";
    [self loadCallRecords];
    
    canAdd = YES;
    self.selectedIndexPath = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//tableview分割线
    //self.tableView.tableFooterView = [[UIView alloc] init];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    zzArray =[[NSMutableArray alloc] init];
    areaString = [[NSString alloc] init];
    opeareString = [[NSString alloc] init];
 
    callDivert =[[CallAndDivert alloc] init];
    mLastAllRegularsMapArray = [[NSMutableArray alloc] init];
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


#pragma mark -- 用户输入时（增加或退格）
-(void)inputTextDidChanged:(NSNotification*)notifi{
    //若结果集不为空，清空结果
    if (searchResault) {
        [searchResault removeAllObjects];
    }
    NSString *abcRegular = ZZExpression;
    NSMutableArray *tempRegularList = [[NSMutableArray alloc] init];//多个正则list
    NSMutableDictionary *tempNumsRegularsMap = [[NSMutableDictionary alloc] init];//存放键值对：数字串 - 多个正则list
    NSMutableArray *outMatchedContactList = [[NSMutableArray alloc] init];//返回的结果集：联系人列表
    //1.生成：正则表达式
    //1.1取出：当前的输入字符串 <- 对用户的输入进行归一化处理(* -> A, # ->B, + -> C)
    NSString *inUserInputsStr = [[notifi userInfo] valueForKey:InputFieldAllText];
    inUserInputsStr = [inUserInputsStr stringByReplacingOccurrencesOfString:@"*" withString:@"A"];
    inUserInputsStr = [inUserInputsStr stringByReplacingOccurrencesOfString:@"#" withString:@"B"];
    inUserInputsStr = [inUserInputsStr stringByReplacingOccurrencesOfString:@"+" withString:@"C"];
    NSString *tempCurrentChar;
    if (inUserInputsStr.length > 0) {
        tempCurrentChar = [inUserInputsStr substringFromIndex:(inUserInputsStr.length - 1)];
    }else{
        [mLastAllRegularsMapArray removeAllObjects];
        NSMutableArray *array = [sqlite searchInfoFromTable:CALL_RECORDS_TABLE_NAME];
        //排序
        CallRecords = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
        [self.tableView reloadData];
        return;
    }
    
    BOOL isAdd = [[[notifi userInfo] valueForKey:AddOrDelete] intValue];//是否输入

    searcherString = inUserInputsStr;//类变量赋值，后续。。。
    
    //1.2取出：上一次的正则表达式list <- 上一次的输入字符串 <- 当前的输入字符串
    NSString *keyForLastRegulars = [inUserInputsStr substringToIndex:(inUserInputsStr.length-1)];
    
    //如果是增加
    if (isAdd) {
        NSString *tempRegular = @"";//存放中间过程用到的正则表达式
        if (inUserInputsStr.length == 1) {//处理：第一个输入
            tempRegular = [NSString stringWithFormat: @"%@%@%@",ReplaceIdentifi,inUserInputsStr,abcRegular];
            [tempRegularList addObject:tempRegular];
        }else{//如果不是第一个，则：上一次的正则表达式list <- 上一次的输入字符串
            NSMutableArray *lastRegularsList = [[mLastAllRegularsMapArray lastObject] valueForKey:keyForLastRegulars];
            if(lastRegularsList == NULL){
                searchResault = outMatchedContactList;
                return;
            }
            //1.3生成：新的正则表达式list <- 上一次的正则表达式list (分裂)
            for (int k = 0; k < [lastRegularsList count]; k++) {
                /**
                 * 每一个表达式都可以分裂成两种新的表达式
                 * -....-5 [0-9,A,B,C]*
                 第一步：取出 -....-5
                 第一种：接在前面首字母之后：-....-5 4[0-9,A,B,C]*
                 第二种：另开一个首字母：-....-5 [0-9,A,B,C]*-4[0-9,A,B,C]*
                 */
                //取出list中，上一个正则表达式
                tempRegular = lastRegularsList[k];//-....-5 [0-9,A,B,C]*
                tempRegular = [tempRegular substringToIndex:(tempRegular.length - abcRegular.length)];//-....-5
                //第一种：接在前面首字母之后：-....-5 4 [0-9,A,B,C]*
                [tempRegularList addObject:[NSString stringWithFormat: @"%@%@%@",tempRegular,tempCurrentChar,abcRegular]];
                //第二种：另开一个首字母：-....-5 [0-9,A,B,C]* - 4 [0-9,A,B,C]*
                [tempRegularList addObject:[NSString stringWithFormat: @"%@%@%@%@%@",tempRegular,abcRegular,ReplaceIdentifi,tempCurrentChar,abcRegular]];
            }
        }
    }else{//1.3.1如果是退格，则取出上一次的正则表达式list
        [mLastAllRegularsMapArray removeObjectAtIndex:mLastAllRegularsMapArray.count-1];
        tempNumsRegularsMap = [mLastAllRegularsMapArray objectAtIndex:mLastAllRegularsMapArray.count-1];
        [self.tableView reloadData];
        NSLog(@"mLastAllRegularsMapArray-delete:%@",mLastAllRegularsMapArray);
    }
    
    if(isAdd){
        [tempNumsRegularsMap setObject:tempRegularList forKey:inUserInputsStr];
    }

    //2.匹配：结果 <- 正则表达式
    for (int i = 0 ; i <[[tempNumsRegularsMap valueForKey:inUserInputsStr] count ] ; i++) {//0,1

        NSString *regular = [[tempNumsRegularsMap valueForKey:inUserInputsStr] objectAtIndex:i];
        BOOL isRegular = FALSE;
        BOOL isNumRgular = FALSE;
        for (int k = 0; k < mutPhoneArray.count; k++) {//取出第k个元素
            NSMutableArray *nameNumArray = [mutPhoneArray[k]valueForKey:PersonNameNum];
             NSString *phoneNum = [mutPhoneArray[k]valueForKey:PersonTelNum];//第k个元素的号码
            for (NSString *nameNum in nameNumArray) {
                //匹配号码
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regular options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
                NSTextCheckingResult *result = [regex firstMatchInString:nameNum options:NSMatchingReportCompletion range:NSMakeRange(0, nameNum.length)];
                
                if (result) {
                    isRegular = true;
                    if (![searchResault containsObject:mutPhoneArray[k]]) {
                        [searchResault addObject:mutPhoneArray[k]];
                        
                    }
                    
                }else{
                    NSRange pRange = [phoneNum  rangeOfString:inUserInputsStr];
                    NSRange rRange = [regular  rangeOfString:inUserInputsStr];
                    if(pRange.length && rRange.length){//在正则式和数据源中都存在inUserInputsStr，添加到结果数组
                        isNumRgular = true;
                        if (![searchResault containsObject:mutPhoneArray[k]]) {
                            [searchResault addObject:mutPhoneArray[k]];
                        }
                        
                    }
                }

            }
            
        }
        
        //3.去重：对结果
        if (!isRegular && !isNumRgular) {
            
            [[tempNumsRegularsMap valueForKey:inUserInputsStr] removeObjectAtIndex:i];//去重之后，数组count减少，所以i = i-1
            i = i-1;
            
        }
    }
    
    if (isAdd) {
        
        [mLastAllRegularsMapArray addObject:tempNumsRegularsMap];
    }
    //获取标红的range
    /*
     9364 =     (
     "-9364\\w*",
     "-93\\w*-64\\w*"
     );
     
     -> 需要得到(9,
            96)
     */
#warning ++++++++++++++++++++++++++++未完
    if ([[tempNumsRegularsMap valueForKey:inUserInputsStr] count]>0) {
        /*
        NSMutableArray *rangeArr =[tempNumsRegularsMap valueForKey:inUserInputsStr];
        NSMutableArray *rangeA = [[NSMutableArray alloc] init];
        for (NSString *sa in rangeArr) {
            //NSString *a = [self getSpecailText:sa];
            [rangeA addObject:sa];
        }
        NSLog(@"rangeA:%@",rangeA);
        */
        NSArray *arr =[[[tempNumsRegularsMap valueForKey:inUserInputsStr] lastObject] componentsSeparatedByString:@"-"] ;
        lengthString = [[NSMutableString alloc] init];
        
        for (NSString *s in arr) {
            if (s.length>0) {
                [lengthString appendString:[s substringToIndex:1]];
            }
            
        }
        VCLog(@"lengthString:%@",lengthString);

    }
    
    [self.tableView reloadData];
    
    //NSLog(@"searchResault.count:%lu- %@",(unsigned long)searchResault.count,searchResault);
    //NSLog(@"匹配后mLastAllRegularsMapArray:%@",mLastAllRegularsMapArray);
    NSLog(@"tempNumsRegularsMap:%@",tempNumsRegularsMap);
   
    //输入的数字达到7个，且还没有结果时
    if (searchResault.count == 0 && searcherString.length >= 7) {
        
        areaString = [sqlite searchAreaWithHisNumber:[singleton.singletonValue substringToIndex:7]];
        VCLog(@"areaString:%@",areaString);
        opeareString = [singleton.singletonValue isMobileNumberWhoOperation];
        
    }

}

#pragma mark -- Table view
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    //隐藏tabbar和callBtn
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"AAAAA" object:self]];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
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

    /*  保存格式
     {
     name = @"啊一";
     namefcn = @"29";//ay
     }
     //匹配输入如：29,
     取出name；
     */

    //用户输入时
    if (searcherString.length > 0 &&searchResault.count > 0 ) {
        //Records *record = dataList[indexPath.row];
        cell.hisName.text = [[searchResault objectAtIndex:indexPath.row] valueForKey:PersonName];//;record.personName;
        
        //NSString *nameFirstChars = ;
        NSMutableArray *nameFirstCharsArray = [[searchResault objectAtIndex:indexPath.row] valueForKey:FirstNameChars];
        for (NSString *nameFirstChars in nameFirstCharsArray) {
            NSRange rangeName = [nameFirstChars rangeOfString:lengthString];
            if (rangeName.length > 0) {
                
                cell.hisName.attributedText = [self attributedStr:rangeName str:cell.hisName.text];
                
            }

        }
        
        cell.hisNumber.hidden = YES;
        cell.callDirection.hidden = YES;
        cell.callLength.hidden = YES;
        cell.callBeginTime.font = [UIFont systemFontOfSize:16];
        cell.callBeginTime.text = [[[searchResault objectAtIndex:indexPath.row] valueForKey:PersonTel] purifyString];
        NSRange rangeNumber  = [cell.callBeginTime.text rangeOfString:searcherString];
        if (rangeNumber.length > 0) {
            
            cell.callBeginTime.attributedText = [self attributedStr:rangeNumber str:cell.callBeginTime.text];;

        }
        cell.hisHome.hidden = YES;
        cell.hisOperator.hidden = YES;
    }
    
    //未输入，显示通话记录
    if(singleton.singletonValue.length <= 0 ) {
        
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
        cell.callBeginTime.font = [UIFont systemFontOfSize:12];
        cell.callBeginTime.text = aRecord.callBeginTime;
        cell.hisHome.text = aRecord.hisHome;
        cell.hisOperator.text = aRecord.hisOperator;
        
     
    }
    //有名字。显示为编辑图标
    if (cell.hisName.text.length>0) {
        [cell.PersonButton setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
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

-(NSMutableAttributedString *)attributedStr:(NSRange)range str:(NSString *)text{
    if (text.length<range.length) {
        range = NSMakeRange(0, text.length);
    }
    NSMutableAttributedString *attributeString =[[NSMutableAttributedString alloc] initWithString:text];
    [attributeString setAttributes:@{NSForegroundColorAttributeName : [UIColor redColor],   NSFontAttributeName : [UIFont systemFontOfSize:18]} range:range];
    return attributeString;
}

#pragma mark -- 按钮的跳转
-(void)CallButtonClick:(UIButton *)btn
{
    VCLog(@"callbtn click");
    //当前选中行
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSIndexPath *indexPath = self.ccurrentIndexPath;
    NSString *name;
    NSString *nber;
    ABRecordRef recordReff = NULL;
    if (searcherString.length>0) {//输入后
        NSDictionary *dict = [searchResault objectAtIndex:indexPath.row];
        name = [dict valueForKey:PersonName];
        nber = [dict valueForKey:PersonTel];
        recordReff = (__bridge ABRecordRef)([((__bridge NSArray *)(ABAddressBookCopyPeopleWithName(_addressBook, (__bridge CFStringRef)name))) lastObject]);//根据名字获取对象
    }
    if (searcherString.length<=0) {
        TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
        name = aRecord.hisName;
        nber = aRecord.hisNumber;
        recordReff = (__bridge ABRecordRef)([((__bridge NSArray *)(ABAddressBookCopyPeopleWithName(_addressBook, (__bridge CFStringRef)(aRecord.hisName)))) lastObject]);
    }
    
    ABRecordID abid = ABRecordGetRecordID(recordReff);
    NSString *contactId = [NSString stringWithFormat:@"%d",abid];
    
    //把姓名号码和id传过去
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"hisName",nber,@"hisNumber",contactId,@"hisContactId", nil];
    //点击callBtn
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCallingBtnClick object:self userInfo:dict]];
    
}

-(void)MsgButtonClick:(UIButton *)btn
{
    //自定键盘、callBtn,tabbar隐藏
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
    //当前选中行
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSIndexPath *indexPath = self.ccurrentIndexPath;
    TXData *mdata = [[TXData alloc] init];
    
    //获取归属地
    if (searcherString.length <= 0) {
        TXData *aRecord = [CallRecords objectAtIndex:indexPath.row];
        mdata.hisName = aRecord.hisName;
        mdata.hisNumber = aRecord.hisNumber;
        mdata.hisHome = aRecord.hisHome;
    }else{
        NSDictionary *dict = [searchResault objectAtIndex:indexPath.row];
        mdata.hisName = [dict valueForKey:PersonName];
        mdata.hisNumber = [dict valueForKey:PersonTel];
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
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kKeyboardAndTabViewHide object:self]];
    //当前选中行
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSIndexPath *indexPath = self.ccurrentIndexPath;
    TXData *aRecord;
    ABRecordRef recordReff;
    if (searcherString.length <= 0) {
        aRecord = [CallRecords objectAtIndex:indexPath.row];
        recordReff = (__bridge ABRecordRef)([((__bridge NSArray *)(ABAddressBookCopyPeopleWithName(_addressBook, (__bridge CFStringRef)(aRecord.hisName)))) lastObject]);//根据名字获取对象
        VCLog(@"==================hisname:%@",aRecord.hisName);
        if (aRecord.hisName.length==0 || [aRecord.hisName isEqualToString:@""] || aRecord.hisName ==nil) {
            //跳转到添加联系人
            
            [self showUnknownPersonViewController:[aRecord.hisNumber purifyString]];
            
            VCLog(@"show newPerson view");
        }else
        {
            //跳转 详情->编辑
            [self showPersonViewControllerWithRecordRefs:recordReff];
        }
    }else{
        NSDictionary *dict = [searchResault objectAtIndex:indexPath.row];
        NSString *name = [dict valueForKey:PersonName];
        recordReff = (__bridge ABRecordRef)([dict valueForKey:PersonRecordRef]);
        VCLog(@"==================hisname:%@",aRecord.hisName);
        if ([name length]==0 || [name isEqualToString:@""] || name ==nil) {
            //跳转到添加联系人
            
            [self showUnknownPersonViewController:[[dict valueForKey:PersonTel] purifyString]];
            
            VCLog(@"show newPerson view");
        }else
        {
            
            //跳转 详情->编辑
            [self showPersonViewControllerWithRecordRefs:recordReff];
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
    self.ccurrentIndexPath = indexPath;
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
        //self.callAnother.tintColor = [UIColor clearColor];
        [self.callAnother setImage:[UIImage imageNamed:@"callaa"]];
    }else{
        VCLog(@"close d");
        [self.callAnother setImage:[UIImage imageNamed:@"call_another60"]];
    }
    
}


#pragma mark -- 呼转Button
- (IBAction)callAnotherPelple:(UIBarButtonItem *)sender
{
    callDivert.divertDelegate = self;
    [callDivert isOrNotCallDivert:PhoneView];
    
}

#pragma mark -- 跳转到-添加到现有联系人或新建
/**
 *  跳转到add联系人
 */

-(void)showUnknownPersonViewController:(NSString *)number{
    
    ABRecordRef aContact = ABPersonCreate();
    CFErrorRef anError = NULL;
    //ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    //bool didAdd = ABMultiValueAddValueAndLabel(email, @"John-Appleseed@mac.com", kABOtherLabel, NULL);
    BOOL didAdds = ABMultiValueAddValueAndLabel(phone, (__bridge CFTypeRef)(number), kABPersonPhoneWorkFAXLabel, NULL);
    
    if (didAdds == YES )
    {
        //ABRecordSetValue(aContact, kABPersonEmailProperty, email, &anError);
        ABRecordSetValue(aContact, kABPersonEmailProperty, phone, &anError);
        if (anError == NULL)
        {
            ABUnknownPersonViewController *picker = [[ABUnknownPersonViewController alloc] init];
            picker.unknownPersonViewDelegate = self;
            picker.displayedPerson = aContact;
            picker.allowsAddingToAddressBook = YES;
            picker.allowsActions = YES;
            //picker.alternateName = @"John Appleseed2";
            //picker.title = @"John Appleseed3";
            //picker.message = @"Company, Inc";
            
            [self.navigationController pushViewController:picker animated:YES];
            
        }
        else
        {
            [SVProgressHUD showImage:nil status:@"*.*"];
            
        }
    }else
    {
        NSLog(@"x");
    }
    CFRelease(aContact);
}

#pragma mark -- unknow person
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    
    NSLog(@"un-id:%d,person:%@",property,person);
    
    return YES;
}

-(void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownCardViewController didResolveToPerson:(ABRecordRef)person{
    
    NSLog(@"person-un:%@",person);
    
    
}

#pragma mark --new person
-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark -- 跳转到编辑联系人
/**
 * @medoth 跳转到edit联系人
 * @pragma recordRef 联系人-地址
 */
-(void)showPersonViewControllerWithRecordRefs:(ABRecordRef)recordRef{
    
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    //ABRecordRef record = (__bridge ABRecordRef)([_addressBookEntryArray objectAtIndex:indexPath.row]);
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


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInputCharNoti object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeleteCharNoti object:nil];

    CFRelease(_addressBook);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
