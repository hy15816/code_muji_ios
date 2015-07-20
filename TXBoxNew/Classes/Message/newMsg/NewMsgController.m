//
//  NewMsgController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/26.
//  Copyright (c) 2015年 playtime. All rights reserved.
//


#import "NewMsgController.h"
#import "ShowContactsController.h"
#import "TXSqliteOperate.h"
#import "MsgDetailController.h"
#import "NSString+helper.h"
#import "ShowContacts.h"
#import "BLEmanager.h"
#import "TextViewInput.h"

@interface NewMsgController ()<UITextViewDelegate,UITextFieldDelegate,BLEmanagerDelegate,TextInputDelegate>
{
    TXSqliteOperate *txsqlite;
    BLEmanager *bmanager;
    
    TextViewInput *textvInput;
    CGFloat tempHeight;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *disMissBtn;

- (IBAction)disMissButton:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UITextField *hisNumber;
@property (weak, nonatomic) IBOutlet UILabel *hisname;


@end


@implementation NewMsgController
@synthesize msgContent;

-(IBAction)doSomethingDidSegue:(UIStoryboardSegue *)sender{
    
    ShowContactsController *thisViewController = [sender sourceViewController];
    ShowContacts *showcs = thisViewController.selectContacts;
    
    NSString *string = [[NSString alloc] init];
    //for (int i=0 ;i<1 ;  i++) {
        string = [NSString stringWithFormat:@"%@,%@",string,[showcs.mmutArray lastObject]];
    //}
    
    self.hisNumber.text = [string substringFromIndex:1];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //键盘显示消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotif:) name:UIKeyboardWillShowNotification object:nil];
    //键盘隐藏消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHiddenNotif:) name:UIKeyboardWillHideNotification object:nil];
     [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    self.tabBarController.tabBar.hidden = YES;
    [self initNewMsgInputView];
}

#pragma mark - 键盘显示响应函数
-(void)keyboardWillShowNotif:(NSNotification*)notif{
    
    NSValue *keyboardObject = [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [keyboardObject getValue:&keyboardRect];
    tempHeight = keyboardRect.size.height;
    textvInput.frame = CGRectMake(0, DEVICE_HEIGHT-textinputHeight-tempHeight, DEVICE_WIDTH, textinputHeight);
}

#pragma mark - 键盘隐藏响应函数
-(void)keyboardHiddenNotif:(NSNotification*)notif{
    
    tempHeight = 0;
    textvInput.frame = CGRectMake(0, DEVICE_HEIGHT-textinputHeight, DEVICE_WIDTH, textinputHeight);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bmanager = [BLEmanager sharedInstance];
    bmanager.managerDelegate = self;
    
    
    self.title = @"新信息";
    self.disMissBtn.enabled = YES;
    txsqlite = [[TXSqliteOperate alloc] init];
    //输入收件人
    self.hisNumber.delegate =self;
    self.hisNumber.contentMode = UIViewContentModeTopLeft;
    self.hisNumber.keyboardType = UIKeyboardTypeNumberPad;
    if ([[userDefaults valueForKey:@"HEHE"] length]>0) {
        self.hisNumber.text = [userDefaults valueForKey:@"HEHE"];
    }
    
    //注册手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(initSwipeRecognizer:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipe];
    
}
/**
 *  swipe手势
 *  @param swipe swipe
 */
-(void)initSwipeRecognizer:(UISwipeGestureRecognizer *)swipe
{
    [self.hisNumber resignFirstResponder];
}

-(void) initNewMsgInputView
{
    
    textvInput =[[TextViewInput alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT-TabBarHeight-35, DEVICE_WIDTH, 35)];
    textvInput.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"abcd"]];
    textvInput.inputDelegate = self;
    if (msgContent.length>0) {
        textvInput.textview.text = msgContent;
    }
    textvInput.textview.font = [UIFont systemFontOfSize:15];
    textvInput.maxHeight = 100;
    textvInput.rigBtnTitle = @"发送";
    [self.view addSubview:textvInput];
    
}

-(CGFloat)getKeyBoradHeight{
    return tempHeight;
}

-(void)changedFrame:(CGRect)rect{
    textvInput.frame = rect;
}
-(void)rightButtonClick:(UIButton *)button{
    
    //保存发送的数据
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate date];
    fmt.dateFormat = @"yyyy/M/d HH:mm";
    NSString *time = [fmt stringFromDate:date];
    
    TXData *txdata =  [[TXData alloc] init];
    txdata.msgSender = @"1";
    txdata.msgTime = time;
    txdata.msgContent = textvInput.textview.text;
    txdata.msgAccepter = [self.hisNumber.text purifyString];
    txdata.msgStates = @"0";
    /*
     BOOL connect = [[userDefaults valueForKey:BIND_STATE] intValue];
     if (!connect) {
     [userDefaults setValue:self.hisNumber.text forKey:@"HEHE"];
     [userDefaults setValue:self.textMsgView.text forKey:@"MEME"];
     [SVProgressHUD showImage:nil status:@"请先连接蓝牙!"];
     return;
     }
     */
    BOOL ismobile = [[self.hisNumber.text purifyString] isMobileNumber:[self.hisNumber.text purifyString]];
    
    if (textvInput.textview.text.length > 0 && ismobile && self.hisNumber.text.length >= 11) {
        
        //向蓝牙发送信息
        //[bmanager writeDatas:[self getdata]];
        BOOL senderSuc = YES;
        if (senderSuc) {
            //保存到本地
            [txsqlite addInfo:txdata inTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:MESSAGE_RECORDS_ADDINFO_SQL];
            
            [userDefaults setValue:@"" forKey:@"HEHE"];
            [userDefaults setValue:@"" forKey:@"MEME"];
            [SVProgressHUD showImage:nil status:@"已发送"];
            self.title = [self.hisNumber.text purifyString];
            self.disMissBtn.enabled = NO;
            [self disMissButton:nil];
        }else{
            [SVProgressHUD showImage:nil status:@"发送失败"];
            self.disMissBtn.enabled = YES;
        }
        
    }else{
        [SVProgressHUD showImage:nil status:@"收件人不能为空!"];
        self.disMissBtn.enabled = YES;
    }
    
}

-(NSData *)getdata{
    
    Byte data[20];
    for (int i=0; i<kByte_count; i++) {
        data[i] = 0x00;
    }
    
    data[0]  = 0x5A;//发送方
    data[1]  = 0x10;
    
    
    NSData * myData = [NSData dataWithBytes:&data length:sizeof(data)];
    return myData;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else{
        for (UIView *cellView in cell.subviews){
            [cellView removeFromSuperview];
        }
    }
    
    return cell;
}

- (IBAction)disMissButton:(UIBarButtonItem *)sender {
    
    [textvInput.textview resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)idReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
