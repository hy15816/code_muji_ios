//
//  NewMsgController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/26.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define INPUT_HEIGHT 49.f
#define RIDRecord   @"recordIdHistory"

#import "NewMsgController.h"
#import "ShowContactsController.h"
#import "MsgDetailController.h"
#import "NSString+helper.h"
#import "BLEmanager.h"
#import "HPGrowingTextView.h"
#import "ConBook.h"
#import "MsgModel.h"


@interface NewMsgController ()<UITextViewDelegate,UITextFieldDelegate,BLEmanagerDelegate,HPGrowingTextViewDelegate>
{

    BLEmanager *bmanagers;
    
    HPGrowingTextView *putViews;
    CGFloat tempHeight;
    ABRecordID reID;
    UIView *containerView;
    BOOL isSend;
    
    NSMutableArray *mutIDArray;
    
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *disMissBtn;

- (IBAction)disMissButton:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UITextField *hisNumber;
@property (weak, nonatomic) IBOutlet UILabel *hisname;


@end


@implementation NewMsgController
@synthesize msgContent;



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //_originalTableViewContentInset = self.ta.contentInset;
    //键盘显示消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotif:) name:UIKeyboardWillShowNotification object:nil];
    //键盘隐藏消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHiddenNotif:) name:UIKeyboardWillHideNotification object:nil];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRecordRef:) name:@"refkkknoti" object:nil];
    });

    
     [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    self.tabBarController.tabBar.hidden = YES;
    
    putViews.text = msgContent.length>0?msgContent:nil;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (isSend == NO) {
        if (msgContent.length <=0 ) {
            putViews.text = [userDefaults valueForKey:@"textInput"];
        }
        
    }
}
-(void)changeRecordRef:(NSNotification *)noti{
    
    /**
     *  1.selectVC通过通知每次发送一个id，
     *  2.newVC 接收，保存到userDefaults
     *      1）得到名字号码，数组
     *
     *
     */
    
    NSString *currID = [[noti userInfo] valueForKey:isRecordID];//当次选择的联系人ID
    NSString *lastID = [userDefaults valueForKey:RIDRecord];//取出上一次的ID串
    if (lastID.length <= 0) {
        [userDefaults setValue:[NSString stringWithFormat:@"-%@",currID] forKey:RIDRecord];
    }else{
        [userDefaults setValue:[NSString stringWithFormat:@"%@-%@",lastID,currID] forKey:RIDRecord];
        }
    
    NSString *ridString = [userDefaults valueForKey:RIDRecord];//id字符串:-1-2-45
    if ([userDefaults valueForKey:isRead]) {
        NSMutableArray *array = (NSMutableArray *)[ridString componentsSeparatedByString:@"-"];//以-分割成为数组
        for (int i=0; i<array.count; i++) {
            if ([array[i] length] == 0) {
                [array removeObjectAtIndex:i];
            }
        }
        [mutIDArray removeAllObjects];
        for (NSString *sid in array) {
            if (sid.length <= 0) {
                self.hisNumber.text =@"";
            }else{
                MsgModel *model = [[MsgModel alloc] init];
                model.rid = sid;
                model.name = [[ConBook sharBook] getNameWithAbid:[sid intValue]];
                model.phone= [[ConBook sharBook] getFirstNumber:[sid  intValue]];
                
                [mutIDArray addObject:model];
            }
            
        }
        NSMutableString *nameString = [[NSMutableString alloc] initWithString:@""];//名字
        for (MsgModel *msg in mutIDArray) {
            [nameString appendFormat:@"%@;",msg.name.length>0?msg.name:msg.phone];//没有名字取号码当做名字
        }
        self.hisNumber.text = nameString;
        
        [userDefaults setBool:NO forKey:isRead];
        //[userDefaults setValue:[NSString stringWithFormat:@"-%@",currID] forKey:RIDRecord];
        
    }
    
    [self.hisNumber becomeFirstResponder];
    VCLog(@" name:%@",self.hisNumber.text);
    
}
#pragma mark -- 键盘显示响应函数
-(void)keyboardWillShowNotif:(NSNotification*)notif{
    CGRect keyboardBounds;
    [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        containerView.frame = containerFrame;
    }];
    

}

#pragma mark -- 键盘隐藏响应函数
-(void)keyboardHiddenNotif:(NSNotification*)notif{
    
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        containerView.frame = containerFrame;
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [userDefaults setValue:@"" forKey:RIDRecord];
    isSend = NO;
    
    self.disMissBtn.enabled = YES;
    mutIDArray = [[NSMutableArray alloc] init];
    
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
    [self initNewMsgInputView];
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
    //底栏=输入框+发送
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, DEVICE_WIDTH, 40)];
    containerView.backgroundColor=[UIColor grayColor];
    
    //输入框
    putViews = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, DEVICE_WIDTH-75, 40)];
    putViews.isScrollable = NO;
    putViews.layer.cornerRadius = 5;
    putViews.layer.borderWidth = .5;
    putViews.layer.borderColor =[UIColor blackColor].CGColor;
    putViews.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    putViews.minNumberOfLines = 1;
    putViews.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    putViews.returnKeyType = UIReturnKeyGo; //just as an example
    putViews.font = [UIFont systemFontOfSize:15.0f];
    putViews.delegate = self;
    
    putViews.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    putViews.backgroundColor = [UIColor whiteColor];
    putViews.placeholder = @"信息";

    
    [self.view addSubview:containerView];
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    imageView.backgroundColor =[UIColor groupTableViewBackgroundColor];
    
    putViews.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:putViews];

    //发送
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn setTitle:@"发送" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

-(void)sendButtonClick:(UIButton *)btn{
    
    [self rightButtonClick:btn];
}
#pragma mark -- HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
}


#pragma mark -- send 消息
-(void)rightButtonClick:(UIButton *)button{
    
    bmanagers = [BLEmanager sharedInstance];
    bmanagers.managerDelegate = self;
    
    //保存发送的数据
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate date];
    fmt.dateFormat = yyyy_M_d_HH_mm;
    NSString *time = [fmt stringFromDate:date];
    
    DBDatas *txdata =  [[DBDatas alloc] init];
    txdata.msgTime = time;
    txdata.msgContent = putViews.text;
    txdata.msgState = @"0";
    for (int i=0; i<mutIDArray.count; i++) {
        MsgModel *mmodel = mutIDArray[i];
        txdata.msgHisName = mmodel.name;
        NSString *firstNumber = [[ConBook sharBook] getFirstNumber:[mmodel.rid intValue]];
        txdata.msgHisNum = [firstNumber purifyString];
        txdata.contactID = mmodel.rid;
        [self sendWithData:txdata];
    }
    
}

-(void)sendWithData:(DBDatas *)txdata {
    
    /*
     BOOL connect = [[userDefaults valueForKey:BIND_STATE] intValue];
     if (!connect) {
     [userDefaults setValue:self.hisNumber.text forKey:@"HEHE"];
     [userDefaults setValue:self.textMsgView.text forKey:@"MEME"];
     [SVProgressHUD showImage:nil status:@"请先连接蓝牙!"];
     return;
     }
     */
    //BOOL ismobile = [[phoneNumberString purifyString] isMobileNumber:[phoneNumberString purifyString]];
    if (putViews.text.length > 0 && txdata.msgHisNum.length >= 11) {
        
        //向蓝牙发送信息
        //[bmanager writeDatas:[self getdata]];
        BOOL senderSuc = YES;
        if (senderSuc) {
            //保存到本地
            [[DBHelper sharedDBHelper] addDatasToMsgRecord:txdata];
            
            [userDefaults setValue:@"" forKey:@"HEHE"];
            [userDefaults setValue:@"" forKey:@"MEME"];
            [SVProgressHUD showImage:nil status:@"已发送"];
            [userDefaults setValue:@"" forKey:@"textInput"];
            self.title = [self.hisNumber.text purifyString];
            self.disMissBtn.enabled = NO;
            [self disMissButton:nil];
            isSend = YES;
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


#pragma mark -- Table view
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

//取消
- (IBAction)disMissButton:(UIBarButtonItem *)sender {
    
    [putViews resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark -- BLEManager delegate
-(void)systemBLEState:(CBCentralManagerState)state{
    
    NSLog(@"new msg ble state:%ld",(long)state);
    
}
-(void)managerConnectedPeripheral:(CBPeripheral *)peripheral connect:(BOOL)isConnect;
{
    
}
-(BOOL)managerDisConnectedPeripheral :(CBPeripheral *)peripheral;
{
    return NO;
}

-(void)managerReceiveDataPeripheralData:(NSData *)data toHexString:(NSString *)hexString fromCharacteristic:(CBCharacteristic *)curCharacteristic;
{
    
}
-(void)searchedPeripheral:(NSMutableArray *)peripArray;
{

}
-(void)showAlertView;
{

}

#pragma mark ---------^.^---------
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (isSend ==NO ) {

        [userDefaults setValue:putViews.text forKey:@"textInput"];
    }
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    
    
    [putViews resignFirstResponder];
}
- (void)idReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
