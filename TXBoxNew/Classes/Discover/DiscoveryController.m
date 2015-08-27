//
//  DiscoveryController.m
//  TXBoxNew
//
//  Created by Naron on 15/5/29.
//  Copyright (c) 2015年 playtime. All rights reserved.
//  发现主页

#define RedColor    [UIColor colorWithRed:244/255.0f green:55/255.0f blue:57/255.0f alpha:1.f]

#define TagToLoginAlert     4000
#define TagWithShowAlert    4001
#define TagToConfigAlert    4002
#define TagToOpenBLE        4003
#define TagToControlAlert   4004


#import "DiscoveryController.h"
#import "NSString+helper.h"
#import "PopView.h"
#import <ImageIO/ImageIO.h>
#import "LoginController.h"
#import "BLEmanager.h"
#import "CallAndDivert.h"

@interface DiscoveryController ()<PopViewDelegate,UIAlertViewDelegate,BLEmanagerDelegate,CallAndDivertDelegate>
{
    NSUserDefaults *defaults;
  
    UIView *shadeView;  //遮罩层
    PopView *popview;   //提示框
    
    UIImageView *con_imgv;  //
    UIImageView *ble_imgv;  //蓝牙图片
    BOOL isConnecting;
    
    CBPeripheral *currentPeripheral;    //当前外设
    NSMutableArray *peripheralArray;
    BOOL isState;
    CBCentralManagerState managerState;
    BLEmanager *bleManage;
    
    float animationtimes;
    CallAndDivert *callAndDivert;
    UIWebView *dwebView;

    AVObject *avobj;
    UIView *showAlertView;
}

@property (strong, nonatomic) IBOutlet UIImageView *firstImageView;
@property (strong, nonatomic) IBOutlet UIImageView *secondImageView;

//label
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;//本机号码
@property (weak, nonatomic) IBOutlet UILabel *mujiNumber;//拇机号码

//静态图片
@property (weak, nonatomic) IBOutlet UIImageView *BLEView;//蓝牙
@property (weak, nonatomic) IBOutlet UIImageView *connectView;//通讯
@property (strong, nonatomic) IBOutlet UIImageView *callAnotherImgView;//呼转
@property (strong, nonatomic) IBOutlet UIImageView *callingImgView;//来电

//button
@property (strong, nonatomic) IBOutlet UIButton *callAnotherButton;//呼转
@property (weak, nonatomic) IBOutlet UIButton *loginButton;//登录
@property (weak, nonatomic) IBOutlet UIButton *bindButton;//控制
@property (weak, nonatomic) IBOutlet UIButton *configureButton;//配置

//button action
- (IBAction)callAnotherButtonClick:(UIButton *)sender;
- (IBAction)loginButtonClick:(UIButton *)sender;
- (IBAction)bindButtonClick:(UIButton *)sender;
- (IBAction)configureButtonClick:(UIButton *)sender;

//版本
@property (weak, nonatomic) IBOutlet UIButton *isAppVersion;//app版本
@property (weak, nonatomic) IBOutlet UIButton *isFirmwareVersion;//固件版本

@end

@implementation DiscoveryController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //键盘活动  键盘出现时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disvViewDidShow:) name:KRefreshDisvView object:nil];

    [self initLoginAndConfigButtons];
    [self refreshBindButton];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [userDefaults setBool:NO forKey:@"al"];
    isState = NO;
    defaults = [NSUserDefaults standardUserDefaults];
    callAndDivert = [[CallAndDivert alloc] init];
    callAndDivert.divertDelegate = self;
    dwebView = [[UIWebView alloc] init];
    animationtimes = 0.25f;

    avobj = [AVObject objectWithClassName:@"User"];
    self.tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    
    //self.firstImageView的背景
    UIImage *upImg = [UIImage imageNamed:@"xuxianUp"];
    //UIImage *upBackground = [upImg stretchableImageWithLeftCapWidth:10 topCapHeight:9];
    self.firstImageView.image = upImg;
    //self.secondImageView
    UIImage *downImg = [UIImage imageNamed:@"xuxianDown"];
    self.secondImageView.image = downImg;
    
    //隐藏号码
    self.phoneNumber.hidden = YES;
    self.mujiNumber.hidden = YES;
    
    [self.isAppVersion setTitle:@"v1.0" forState:UIControlStateNormal];
    self.isAppVersion.enabled = YES;
    self.isFirmwareVersion.hidden = YES;
    
    self.callAnotherButton.layer.cornerRadius = 13;
    self.loginButton.layer.cornerRadius = 13;
    self.configureButton.layer.cornerRadius = 13;
    self.bindButton.layer.cornerRadius = 13;
    
    UILabel *footv =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_HEIGHT, 1)];
    footv.backgroundColor = [UIColor grayColor];
    footv.alpha = .3;
    //self.tableView.tableFooterView = footv;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //通知显示tabBar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    //自动登录
    //缓存当前用户
    
    AVUser *currentUser = [AVUser currentUser];
    if (currentUser != nil) {
        //[usDefaults setValue:@"0" forKey:CALL_ANOTHER_STATE];//呼转状态
        //[usDefaults setValue:@"0" forKey:LOGIN_STATE];//登录状态
        
        //[usDefaults setValue:@"0" forKey:@"opstate"];
        //[usDefaults setValue:@"0" forKey:BIND_STATE];
    }else{//提示登录
        
    }
    
}

#pragma mark -- notify
- (void)keyboardWasShow:(NSNotification*)aNotification{
    
    NSDictionary* info = [aNotification userInfo];
    
    /*
     NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
     VCLog(@"duration:%@",duration);
     CGRect beginRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
     */
    
    CGRect endRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //if (DEVICE_HEIGHT-PopViewHeight-endRect.size.height< endRect.size.height) {
        [UIView animateWithDuration:0.15 animations:^{
            popview.alpha = 1.0;
            popview.frame = CGRectMake((DEVICE_WIDTH-PopViewWidth)/2, DEVICE_HEIGHT-PopViewHeight-endRect.size.height-10, PopViewWidth, PopViewHeight);
        }];
    //}
    
    //VCLog(@"·······%f",endRect.size.height);
    
}
-(void)disvViewDidShow:(NSNotification *)notifi
{
    [self initLoginAndConfigButtons];
    [self refreshBindButton];
}

#pragma mark -- Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    return 0;
}
/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        return 0;
    }
    return @"配置信息";
}
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
            
        }
        if (indexPath.row == 1) {
            //设备固件版本
            if (self.isFirmwareVersion.hidden == NO) {
                VCLog(@"更新");
            }else{
                VCLog(@"已经是最新了");
            }
        }
    }
    
    VCLog(@"x");
}
#pragma mark -- 初始化login config callState
-(void)initLoginAndConfigButtons{
    
    BOOL loginState = [[defaults valueForKey:LOGIN_STATE] intValue];
    BOOL configState = [[defaults valueForKey:CONFIG_STATE] intValue];
    BOOL callState = [[defaults valueForKey:CALL_ANOTHER_STATE] intValue];
    
    VCLog(@"ls:%d cs:%d calls:%d",loginState,configState,callState);
    
    if (loginState) {//已登录
        self.phoneNumber.hidden = NO;
        [self.loginButton setTitle:@"  退出  " forState:UIControlStateNormal];
        [self.loginButton setBackgroundColor:RedColor];
        NSString *pnum = [defaults valueForKey:CurrentUser];
        self.phoneNumber.text = [NSString stringWithFormat:@"%@****%@",[pnum substringToIndex:3],[pnum substringWithRange:NSMakeRange(pnum.length -4, 4)]];
    }else{
        self.phoneNumber.hidden = YES;
        [self.loginButton setTitle:@"  登录  " forState:UIControlStateNormal];
        [self.loginButton setBackgroundColor:LightColor];
    }
    
    if (configState) {//已配置
        [self.configureButton setTitle:@"  修改  " forState:UIControlStateNormal];
        [self.configureButton setBackgroundColor:RedColor];
        self.mujiNumber.hidden = NO;
        NSString *pnum = [defaults valueForKey:muji_bind_number];
        self.mujiNumber.text = [NSString stringWithFormat:@"%@****%@",[pnum substringToIndex:3],[pnum substringWithRange:NSMakeRange(pnum.length -4, 4)]];
        
    }else{
        
        [self.configureButton setTitle:@"  配置  " forState:UIControlStateNormal];
        [self.configureButton setBackgroundColor:LightColor];
        self.mujiNumber.hidden = YES;
        
    }
    
    //呼转
    if (callState) {
        [self.callAnotherButton setTitle:@"  取消  " forState:UIControlStateNormal];
        [self.callAnotherButton setBackgroundColor:RedColor];
        self.callAnotherImgView.image = [UIImage imageNamed:@"callAnother_light"];
        
    }else{
        [self.callAnotherButton setTitle:@"  呼转  " forState:UIControlStateNormal];
        self.callAnotherImgView.image = [UIImage imageNamed:@"callAnother_gray"];
        [self.callAnotherButton setBackgroundColor:LightColor];
    }
    
    
}

//button-控制
-(void)refreshBindButton
{
    BOOL controlState = [[defaults valueForKey:CONTROL_STATE] intValue];
    if (controlState) {//已绑定
        [self.bindButton setTitle:@"  解除  " forState:UIControlStateNormal];
        [self.bindButton setBackgroundColor:RedColor];//ble_connect
        
        //显示亮色图片
        self.BLEView.image = [UIImage imageNamed:@"flow_ble_HL"];
        
    }else{
        //显示灰色图片
        self.BLEView.image = [UIImage imageNamed:@"flow_ble"];
        [self.bindButton setTitle:@"  控制  " forState:UIControlStateNormal];
        [self.bindButton setBackgroundColor:LightColor];
        
    }
}

#pragma mark -- hide popView
-(void)hideShadeAndPopView{
    [popview.secondField resignFirstResponder];
    [UIView animateWithDuration:animationtimes animations:^{
        
        shadeView.alpha = 0;
        popview.alpha=0.5;
        popview.frame = CGRectMake((DEVICE_WIDTH-PopViewWidth)/2, -PopViewHeight, PopViewWidth, PopViewHeight);
        
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationtimes * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [shadeView removeFromSuperview];
        [popview removeFromSuperview];
    });
}
//recognizer tap
-(void)shadeViewTap:(UIGestureRecognizer *)recongnizer
{
    
    [self hideShadeAndPopView];
    
}

#pragma mark -- show popView
-(void)addShadeAndAlertViewWithNumber:(NSString *)mujiNumber
{
    //透明层
    shadeView =[[UIView alloc] initWithFrame:self.view.window.bounds];
    shadeView.backgroundColor = [UIColor grayColor];//self.view.window.bounds
    shadeView.alpha = .4;
    [self.view.window addSubview:shadeView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadeViewTap:)];
    tap.numberOfTapsRequired = 1;
    [shadeView addGestureRecognizer:tap];
    
    //pop
    popview = [[PopView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-PopViewWidth)/2, -PopViewHeight, PopViewWidth, PopViewHeight)];
    popview.alpha = 0.5;
    popview.delegate = self;
    NSLog(@"popview:%f%f%f%f",popview.frame.origin.x,popview.frame.origin.y, popview.frame.size.width,popview.frame.size.height);
    [self.view.window addSubview:popview];
    
    if ([[userDefaults valueForKey:CONFIG_STATE] intValue]) {
        [popview initWithTitle:@"修改拇机号码信息:" label:@"拇机号码" cancelButtonTitle:@"OK" otherButtonTitles:@"不OK"];
        popview.secondField.text = mujiNumber;
    }else{
        [popview initWithTitle:@"呼叫转移需要配置拇机号码信息:" label:@"拇机号码" cancelButtonTitle:@"OK" otherButtonTitles:@"不OK"];
    }
    
    
}

#pragma mark-- popView delegate
-(void)hideThisView{
    
    [self hideShadeAndPopView];
}


-(void)resaultsButtonClick:(UIButton *)button  textField:(UITextField *)sfield;
{
    //获取输入的text
    NSString *number = [sfield.text trimOfString];
    if (![number isEqualToString:[userDefaults valueForKey:muji_bind_number]]) {
        //拇机号码上传到服务器
        
        [avobj setObject:number forKey:@"mujiphone"];
        [avobj saveInBackgroundWithBlock:^(BOOL isSuc,NSError *error){
            if (error) {
                NSLog(@"save mujiphone error:%@",error.localizedDescription);
            }else
            {
                NSLog(@"save mujiphone succ");
                
            }
        }];
    }
    
    //取消
    if (button.tag == 1) {
        
        //[self hideShadeAndPopView];
        [sfield resignFirstResponder];
    }
    //sure按钮
    if (button.tag == 0) {
        if ( number.length<=0 || ![number isValidateMobile:number]) {
            //创建提醒对话框
            UIAlertView *malertView = [[UIAlertView alloc] initWithTitle:nil message:@"号码不规范" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [malertView show];
            //malertView.delegate = self;
            //[malertView textFieldAtIndex:0];//获取输入框，在UIAlertViewStyle -> input模式
        }else
        {
            //本地保存数据
            [defaults setValue:number forKey:muji_bind_number];
            
            [defaults setValue:@"1" forKey:CONFIG_STATE];
            //
            [self.configureButton setTitle:@"  修改  " forState:UIControlStateNormal];
            [self.configureButton setBackgroundColor:RedColor];
            
            VCLog(@"save-->number:%@",number);
            [sfield resignFirstResponder];
        }
    }
    
    [self initLoginAndConfigButtons];
    
    
}

#pragma mark -- 呼转 & 取消
- (IBAction)callAnotherButtonClick:(UIButton *)sender {
    /*
    BOOL callst=[[userDefaults valueForKey:CALL_ANOTHER_STATE] intValue];
    NSString *amujiNumber = [userDefaults valueForKey:muji_bind_number];
    if (callst) {
        UIAlertView *hh=[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"取消到 %@ 的呼转？",amujiNumber] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
        hh.tag = 3006;
        [hh show];
        return;
    }
     */
    
    [callAndDivert isOrNotCallDivert:DiscoveryView];
    
}
#pragma mark -- CallAndDivert Delegate
-(void)hasNotLogin{
    [self loginButtonClick:nil];
}

-(void)hasNotConfig{
    [self configureButtonClick:nil];
}

-(void)openOrCloseCallDivertState:(CallDivertState)state number:(NSString *)number{
    
    if (number.length>0) {
        // 呼叫
        // 不要将webView添加到self.view，如果添加会遮挡原有的视图
        if (dwebView == nil) {
            dwebView = [[UIWebView alloc] init];
        }
        
        NSURL *url = [NSURL URLWithString:number];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [dwebView loadRequest:request];
        VCLog(@"calloutNumber:%@",number);
        [self initLoginAndConfigButtons];
    }
    if (state == OpenDivert) {
        VCLog(@"open d");
    }else{
        VCLog(@"close d");
    }
}

#pragma mark -- 配置 & 修改
- (IBAction)configureButtonClick:(UIButton *)sender {
    //是否配置
    BOOL conState = [[defaults valueForKey:CONFIG_STATE] intValue];
    if (conState) {//配置1
        //是否登录
        BOOL loginState = [[defaults valueForKey:LOGIN_STATE] intValue];
        if (loginState) {//登录1
            
            //已配置，修改
            [self addShadeAndAlertViewWithNumber:[defaults valueForKey:muji_bind_number]];
            
        }else{
            //提示登录
            UIAlertView *configAlert = [[UIAlertView alloc] initWithTitle:@"想【修改】拇机号码？" message:@"请先【登录】" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
            configAlert.tag = TagToLoginAlert;
            [configAlert show];
        }
        
    }else{//配置0
        
        BOOL loginState = [[defaults valueForKey:LOGIN_STATE] intValue];
        if (loginState) {//登录1
            
            //配置
            [self addShadeAndAlertViewWithNumber:nil];
            
        }else{
            //提示登录
            UIAlertView *configAlert = [[UIAlertView alloc] initWithTitle:@"想【配置】拇机号码？" message:@"请先【登录】" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
            configAlert.tag = TagToLoginAlert;
            [configAlert show];
        }

        
        
    }

}

#pragma mark -- 登录 & 退出
- (IBAction)loginButtonClick:(UIButton *)sender {
    
    BOOL loginstate = [[defaults valueForKey:LOGIN_STATE] intValue];
    if (loginstate) {
        [self loginOut];
        
        //更新ui
        [self initLoginAndConfigButtons];
        [self cutConnectperipheral];//断开蓝牙连接，
        [self refreshBindButton];
        
        //呼转？
#warning ??????????????????????
    }else
    {
        [self jumpToLoginView];
         
    }
    
}

-(void)jumpToLoginView{
    //添加login页面
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginController *loginview = [board instantiateViewControllerWithIdentifier:@"loginVCIdentity"];
    [self.navigationController pushViewController:loginview animated:YES];
}

-(void)loginOut
{
    [AVUser logOut];
    [userDefaults setValue:@"0" forKey:LOGIN_STATE];
    [userDefaults setValue:@"0" forKey:CONFIG_STATE];
    [userDefaults setValue:@"0" forKey:CONTROL_STATE];
    [userDefaults setValue:@"0" forKey:CALL_ANOTHER_STATE];
    
}

#pragma mark -- 控制 & 解除
- (IBAction)bindButtonClick:(UIButton *)sender {
    
    if (![userDefaults boolForKey:@"al"]) {
        //初始化蓝牙
        bleManage = [BLEmanager sharedInstance];
        bleManage.managerDelegate = self;
        [userDefaults setBool:YES forKey:@"al"];
    }
    
        // 汇总结果
        BOOL loginstate = [[defaults valueForKey:LOGIN_STATE] intValue];
        if (loginstate) {
            BOOL configsState = [[userDefaults valueForKey:CONFIG_STATE] intValue];
            if (configsState) {//已配置
                BOOL bstate = [[defaults valueForKey:CONTROL_STATE] intValue];
                if (bstate) {
                    [defaults setObject:@"0" forKey:CONTROL_STATE];
                    //断开蓝牙连接
                    [self cutConnectperipheral];
                }else{//没绑定

                    if (managerState == CBCentralManagerStatePoweredOn ) {
                        
                        [SVProgressHUD showWithStatus:@"匹配中..." maskType:SVProgressHUDMaskTypeNone];
                        //查找外设
                        [self scanPeripheral];
                        
                        [self performSelector:@selector(dismissSvp) withObject:nil afterDelay:15];//扫描外设时间
                    }else{//蓝牙是非打开状态
                        if (isState) {
                            UIAlertView *atv=[[UIAlertView alloc] initWithTitle:@"需要打开蓝牙" message:@"是否打开蓝牙？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
                            atv.tag = TagToOpenBLE;
                            
                            [atv show];
                        }
                    }
                }
            }else{//未配置
                //提示配置
                UIAlertView *configAlert = [[UIAlertView alloc] initWithTitle:@"想通过手机【控制】拇机?" message:@"请先【配置】拇机号码" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
                configAlert.tag = TagToConfigAlert;
                [configAlert show];
            }
            
        }else{//未登录
            //isState = NO;
            //提示登录
            UIAlertView *controlAlert = [[UIAlertView alloc] initWithTitle:@"想通过手机【控制】拇机?" message:@"请先【登录，然后【配置】拇机号码" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
            controlAlert.tag = TagToLoginAlert;
            [controlAlert show];
        }
        
        
        [self refreshBindButton];
    
}

-(void)dismissSvp
{
    if (!isConnecting) {
    
        [SVProgressHUD showErrorWithStatus:@"未找到设备!"];
        [bleManage.centralManager stopScan];
    }
    
    //[SVProgressHUD dismiss];
}

//扫描
-(void)scanPeripheral
{
    [bleManage.centralManager scanForPeripheralsWithServices:nil options:nil];

}
-(void)cutConnectperipheral
{
    if (currentPeripheral !=nil) {
        [bleManage.centralManager cancelPeripheralConnection:currentPeripheral];
        
        currentPeripheral = nil;
        //查找
        //[bleManage.centralManager scanForPeripheralsWithServices:nil options:0];
        
    }
    
}

#pragma mark --AlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3006) {
        if (buttonIndex == 0) {//确认取消
            [userDefaults setValue:@"0" forKey:CALL_ANOTHER_STATE];
        }
        
    }
    //打开蓝牙？
    if (alertView.tag == TagToOpenBLE) {
        if (buttonIndex == 0) {//ok
            //
            // ios8之后可用
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            
        }else{
            
        }
        
    }
    
    if (alertView.tag == TagToLoginAlert) {
        if (buttonIndex == 0) {
            //
            [self jumpToLoginView];
        }
    }
    
    if (alertView.tag == TagToConfigAlert) {
        if (buttonIndex == 0) {
            //
            [self configureButtonClick:nil];
        }
    }
    
    
    if (alertView.tag == TagWithShowAlert) {
        if (buttonIndex == 0) {
            //取消呼转
            [callAndDivert isOrNotCallDivert:DiscoveryView ];
        }
    }
        
    [self initLoginAndConfigButtons];
    
}

#pragma mark -- managerDelegate
-(void)systemBLEState:(CBCentralManagerState)state {
    
    managerState = state;
    NSLog(@"------------------state:%ld",(long)state);
    
    if (state != CBCentralManagerStatePoweredOn) {
        isState = YES;
    }
    
    
}
-(void)managerConnectedPeripheral:(CBPeripheral *)peripheral connect:(BOOL)isConnect
{
    isConnecting = isConnect;
    if (isConnecting) {
        [defaults setObject:@"1" forKey:CONTROL_STATE];
        currentPeripheral = peripheral;
    }else{
        [defaults setObject:@"0" forKey:CONTROL_STATE];
    }
    [self refreshBindButton];
    //连接成功
    if (isConnect == YES) {
        [SVProgressHUD showSuccessWithStatus:@"连接成功!"];
        [bleManage.centralManager stopScan];
        //[SVProgressHUD dismiss];
        
        //判断是否需要显示提示？
        if (!showAlertView && [[userDefaults valueForKey:CALL_ANOTHER_STATE] intValue]) {
            //
            [callAndDivert isOrNotCallDivert:DiscoveryView ];
            showAlertView = [[UIView alloc] init];
            
        }
        
        
        
    }
    
}

-(void)searchedPeripheral:(NSMutableArray *)peripArray
{
    [bleManage.centralManager stopScan];
    //连接第一个
    [bleManage.centralManager connectPeripheral:peripArray[0] options:nil];
    
    //return currentPeripheral;
}

//是否断线重连
-(BOOL)managerDisConnectedPeripheral:(CBPeripheral *)peripheral
{
    return NO;
}

//是否监听特征
-(BOOL)managerSetNotifyValue
{
    return NO;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (bleManage.centralManager) {
        [bleManage.centralManager stopScan];
    }
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //bleManage.managerDelegate = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
