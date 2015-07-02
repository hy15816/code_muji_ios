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

@interface NewMsgController ()<UITextViewDelegate,UITextFieldDelegate,HPGrowingTextViewDelegate>
{
    TXSqliteOperate *txsqlite;
}


- (IBAction)disMissButton:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UITextField *hisNumber;
@property (weak, nonatomic) IBOutlet UILabel *hisname;

@property (strong, nonatomic)  UIView *inputView;
@property (strong, nonatomic)  UIButton *sendMsgBtn;
@property (strong,nonatomic) HPGrowingTextView *textMsgView;



@end


@implementation NewMsgController

-(IBAction)doSomethingDidSegue:(UIStoryboardSegue *)sender{
    
    ShowContactsController *thisViewController = [sender sourceViewController];
    ShowContacts *showcs = thisViewController.selectContacts;
    
    NSString *string = [[NSString alloc] init];
    for (NSString *s in showcs.mmutArray) {
        string = [NSString stringWithFormat:@"%@,%@",string,s];
    }
    
    
    self.hisNumber.text = string;
    
    
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
}

#pragma mark - 键盘显示响应函数
-(void)keyboardWillShowNotif:(NSNotification*)notif{
    
    CGRect keyboardBounds;
    
    [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    //NSNumber *curve = [notif.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGRect containerFrame = self.inputView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    //[UIView setAnimationCurve:[curve intValue]];
    
    self.inputView.frame = containerFrame;
    
    //CGRect rect = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //self.tableview.frame = CGRectMake(0,0 , DEVICE_WIDTH, DEVICE_HEIGHT-rect.size.height);//-rect.size.height
    
    [UIView commitAnimations];
    
}


#pragma mark - 键盘隐藏响应函数
-(void)keyboardHiddenNotif:(NSNotification*)notif{
    
    
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notif.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    CGRect containerFrame = self.inputView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    //self.tableview.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    self.inputView.frame = containerFrame;
    
    [UIView commitAnimations];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"New_Msg", nil);
    txsqlite = [[TXSqliteOperate alloc] init];
    //输入收件人
    self.hisNumber.delegate =self;
    self.hisNumber.contentMode = UIViewContentModeTopLeft;
    
    
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
    [self.textMsgView resignFirstResponder];
}

-(void) initNewMsgInputView
{
    self.inputView = [[UIView alloc] init];
    self.inputView.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    self.inputView.frame = CGRectMake(0, DEVICE_HEIGHT-40, DEVICE_WIDTH, 40);
    //self.inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    self.textMsgView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5, 4, DEVICE_WIDTH*.8f, 40)];
    self.textMsgView.delegate = self;
    self.textMsgView.minNumberOfLines = 1;
    self.textMsgView.maxNumberOfLines = 6;//最大伸缩行数
    self.textMsgView.font = [UIFont systemFontOfSize:14.0f];
    self.textMsgView.placeholder = NSLocalizedString(@"Message", nil);
    
    //textView的背景
    UIImage *rawEntryBackground = [UIImage imageNamed:@"msg_textView_bg"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, DEVICE_WIDTH*.8f, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //inputView的bgImg
    UIImage *rawBackground = [UIImage imageNamed:@"msg_inputView_bg"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.inputView.frame.size.width, self.inputView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.sendMsgBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.sendMsgBtn.frame = CGRectMake(DEVICE_WIDTH-50, 0, 30, 40);
    [self.sendMsgBtn setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [self.sendMsgBtn addTarget:self action:@selector(sendNewMsgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.inputView];
    [self.inputView addSubview:imageView];
    
    
    [self.inputView addSubview:self.textMsgView];
    [self.inputView addSubview:entryImageView];
    [self.inputView addSubview:self.sendMsgBtn];
    
    
    
}
/**
 *  发送数据
 *  @param btn button
 */
-(void)sendNewMsgBtnClick:(UIButton *)btn
{
    //保存发送的数据
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate date];
    fmt.dateFormat = @"yy/M/d HH:mm"; // @"yyyy-MM-dd HH:mm:ss"
    NSString *time = [fmt stringFromDate:date];

    TXData *txdata =  [[TXData alloc] init];
    txdata.msgSender = @"1";
    txdata.msgTime = time;
    txdata.msgContent = self.textMsgView.text;
    txdata.msgAccepter = self.hisNumber.text;
    txdata.msgStates = @"0";
    
    if (self.textMsgView.text.length > 0 && self.hisNumber.text.length > 7) {
        [txsqlite addInfo:txdata inTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:MESSAGE_RECORDS_ADDINFO_SQL];
        
        
        //跳转到信息detail页面
        //传值，hisName,hisNumber,hisHome
        txdata.hisName = self.hisNumber.text;
        txdata.hisNumber = self.hisNumber.text;//data.msgSender;
        txdata.hisHome = [txsqlite searchAreaWithHisNumber:[[self.hisNumber.text purifyString] substringToIndex:7]];//@"hisHome"
        
        MsgDetailController *DetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"msgDetail"];
        DetailVC.datailDatas = txdata;
        [SVProgressHUD showImage:nil status:@"已发送"];
        [self.navigationController pushViewController:DetailVC animated:YES];
    }else{
        [SVProgressHUD showImage:nil status:@"收件人不能为空!"];
    }
    
    
}

- (void)idReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
