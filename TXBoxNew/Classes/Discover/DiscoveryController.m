//
//  DiscoveryController.m
//  TXBoxNew
//
//  Created by Naron on 15/5/29.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "DiscoveryController.h"
#import "NSString+helper.h"
#import "PopView.h"
#import <ImageIO/ImageIO.h>
#import "LoginController.h"
#import "TXSqliteOperate.h"
#import <AVOSCloud/AVOSCloud.h>
#import "BLEmanager.h"
#import "CallAndDivert.h"

@interface DiscoveryController ()<PopViewDelegate,UIAlertViewDelegate,BLEmanagerDelegate,CallAndDivertDelegate>
{
    NSUserDefaults *defaults;
  
    UIView *shadeView;  //遮罩层
    PopView *popview;   //提示框
    
    UIImageView *con_imgv;  //
    UIImageView *ble_imgv;  //蓝牙图片
    TXSqliteOperate *txsqlite;
    BOOL isConnecting;
    
    CBPeripheral *currentPeripheral;    //当前外设
    NSMutableArray *peripheralArray;
    CBCentralManagerState managerState;
    BLEmanager *bleManage;
    
    float animationtimes;
    CallAndDivert *callAndDivert;
    UIWebView *dwebView;
}

@property (strong, nonatomic) IBOutlet UIImageView *firstImageView;
@property (strong, nonatomic) IBOutlet UIImageView *secondImageView;

//label
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;//本机号码
@property (weak, nonatomic) IBOutlet UILabel *mujiNumber;//拇机号码

//静态图片
@property (weak, nonatomic) IBOutlet UIView *BLEView;//蓝牙
@property (weak, nonatomic) IBOutlet UIView *connectView;//通讯
@property (strong, nonatomic) IBOutlet UIImageView *callAnotherImgView;//呼转
@property (strong, nonatomic) IBOutlet UIImageView *callingImgView;//来电

//gif图
@property (weak, nonatomic) IBOutlet UIView *BLEgifView;//蓝牙
@property (weak, nonatomic) IBOutlet UIView *connectGifView;//通讯

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
    
    //通知显示tabBar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    
    [self initLoginAndConfigButtons];
    [self refreshBindButton];
    [self isOrNotUpdateVersion];
    
    //初始化蓝牙
    bleManage = [BLEmanager sharedInstance];
    bleManage.managerDelegate = self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    txsqlite = [[TXSqliteOperate alloc] init];
    callAndDivert = [[CallAndDivert alloc] init];
    dwebView = [[UIWebView alloc] init];
    animationtimes = 0.25f;
    self.tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    
    //self.firstImageView的背景
    UIImage *rawEntryBackground = [UIImage imageNamed:@"NodeBkg"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    self.firstImageView.image = entryBackground;
    //self.secondImageView
    self.secondImageView.layer.borderWidth = .3;
    self.secondImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.secondImageView.layer.cornerRadius = 4;
    
    //静态图
    con_imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 23)];
    ble_imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 23)];
    ble_imgv.image = [UIImage imageNamed:@"flow_ble"];
    con_imgv.image = [UIImage imageNamed:@"flow_phone"];
    
    [self.BLEView addSubview:ble_imgv];
    [self.connectView addSubview:con_imgv];
    
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
    if (DEVICE_HEIGHT-PopViewHeight-endRect.size.height< endRect.size.height) {
        [UIView animateWithDuration:0.15 animations:^{
            popview.alpha = 1.0;
            popview.frame = CGRectMake((DEVICE_WIDTH-PopViewWidth)/2, DEVICE_HEIGHT-PopViewHeight-endRect.size.height-10, PopViewWidth, PopViewHeight);
        }];
    }
    
    //VCLog(@"·······%f",endRect.size.height);
    
}
-(void)disvViewDidShow:(NSNotification *)notifi
{
    [self initLoginAndConfigButtons];
    [self refreshBindButton];
}


#pragma mark -- 检测版本
-(void)isOrNotUpdateVersion
{
    //APP版本,检测本地版本，与最新版本比较
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //获取服务器版本号
    //NSURL *url = [NSURL URLWithString:@"http://car0.autoimg.cn/upload/spec/9579/u_20120110174805627264.jpg"];
    
    //NSString *str = [[NSString alloc] initWithFormat:@"1.2"];
    
    //获取当前程序版本号
    //NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //NSString *str2 = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    // 回到主线程，显示提示框
    //dispatch_async(dispatch_get_main_queue(), ^{
    BOOL a = [[defaults valueForKey:@"versionSSSd"] intValue];
    if (!a) {//[str2 floatValue] != [str floatValue]
        
        UIAlertView *atView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"检测到有新版本，是否更新？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
        atView.tag = 1005;
        atView.delegate = self;
        [atView show];
        
        // 显示更新
        self.isFirmwareVersion.hidden = NO;
    }else {
        self.isFirmwareVersion.hidden = YES;
    }
    
    
    
    //});
    //});
    
}

#pragma mark --AlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1005) {
        if (buttonIndex == 0) {
            [defaults setValue:@"1" forKey:@"versionSSSd"];
        }
        
    }
    
    
    [self initLoginAndConfigButtons];
    
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
    
    if (loginState) {//已登录
        self.phoneNumber.hidden = NO;
        [self.loginButton setTitle:@"  退出  " forState:UIControlStateNormal];
        [self.loginButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];
        self.phoneNumber.text = [defaults valueForKey:CurrentUser];
    }else{
        self.phoneNumber.hidden = YES;
        [self.loginButton setTitle:@"  登录  " forState:UIControlStateNormal];
        [self.loginButton setBackgroundColor:RGBACOLOR(25, 180, 8, 1)];
        self.connectGifView.hidden = YES;
        self.connectView.hidden = NO;
    }
    
    if (configState) {//已配置
        [self.configureButton setTitle:@"  修改  " forState:UIControlStateNormal];
        [self.configureButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];
        self.mujiNumber.hidden = NO;
        self.mujiNumber.text = [defaults valueForKey:muji_bind_number];
        
        //显示gif图片
        if (loginState) {
            self.connectView.hidden = YES;
            [self initAnimatedWithFileName:@"phone_connect" andType:@"gif" view:self.connectGifView];
        }else {
            self.connectGifView.hidden = YES;
            self.connectView.hidden = NO;
        }
        
    }else{
        
        //显示静态图片
        self.connectView.hidden = NO;
        self.connectGifView.hidden = YES;

        [self.configureButton setTitle:@"  配置  " forState:UIControlStateNormal];
        [self.configureButton setBackgroundColor:RGBACOLOR(25, 180, 8, 1)];
        self.mujiNumber.hidden = YES;
        
    }
    
    //呼转
    if (callState) {
        [self.callAnotherButton setTitle:@"  取消  " forState:UIControlStateNormal];
        [self.callAnotherButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];
        self.callAnotherImgView.image = [UIImage imageNamed:@"callAnother_light"];
        
    }else{
        [self.callAnotherButton setTitle:@"  呼转  " forState:UIControlStateNormal];
        self.callAnotherImgView.image = [UIImage imageNamed:@"callAnother_gray"];
        [self.callAnotherButton setBackgroundColor:RGBACOLOR(25, 180, 8, 1)];
    }
    
    
}

//button-控制
-(void)refreshBindButton
{
    BOOL bindState = [[defaults valueForKey:BIND_STATE] intValue];
    if (bindState) {//已绑定
        [self.bindButton setTitle:@"  解除  " forState:UIControlStateNormal];
        [self.bindButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];//ble_connect
        self.BLEView.hidden = YES;
        self.BLEgifView.hidden = NO;
        
        //显示gif图片
        [self initAnimatedWithFileName:@"ble_connect" andType:@"gif" view:self.BLEgifView];
        
    }else{
        //显示静态图片
        self.BLEView.hidden = NO;
        self.BLEgifView.hidden = YES;
        
        [self.bindButton setTitle:@"  控制  " forState:UIControlStateNormal];
        [self.bindButton setBackgroundColor:RGBACOLOR(25, 180, 8, 1)];
        
    }
}

#pragma mark -- 加载gif图片
-(void)initAnimatedWithFileName :(NSString *)fileName andType:(NSString *)type view:(UIView *)vview
{
    //解码图片
    NSString *imagePath =[[NSBundle mainBundle] pathForResource:fileName ofType:type];
    CGImageSourceRef  cImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
    //读取动画的每一帧
    size_t imageCount = CGImageSourceGetCount(cImageSource);
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSMutableArray *times = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSMutableArray *keyTimes = [[NSMutableArray alloc] initWithCapacity:imageCount];
    
    //显示时间
    float totalTime = 0;
    CGSize size;
    for (size_t i = 0; i < imageCount; i++) {
        CGImageRef cgimage= CGImageSourceCreateImageAtIndex(cImageSource, i, NULL);
        [images addObject:(__bridge id)cgimage];
        CGImageRelease(cgimage);
        
        NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(cImageSource, i, NULL);
        NSDictionary *gifProperties = [properties valueForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
        NSString *gifDelayTime = [gifProperties valueForKey:(__bridge NSString* )kCGImagePropertyGIFDelayTime];
        [times addObject:gifDelayTime];
        totalTime += [gifDelayTime floatValue];
        
        size.width = [[properties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
        size.height = [[properties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
    }
    
    float currentTime = 0;
    for (size_t i = 0; i < times.count; i++) {
        float keyTime = currentTime / totalTime;
        [keyTimes addObject:[NSNumber numberWithFloat:keyTime]];
        currentTime += [[times objectAtIndex:i] floatValue];
    }
    
    //执行CAKeyFrameAnimation动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setValues:images];
    [animation setKeyTimes:keyTimes];
    animation.duration = totalTime;
    animation.repeatCount = HUGE_VALF;
    
    [vview.layer addAnimation:animation forKey:@"gifAnimation"];

}

#pragma mark -- hide popView
-(void)hideShadeAndPopView{
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
    [self.view.window addSubview:popview];
    
    
    if (mujiNumber.length>0) {
        [popview initWithTitle:@"修改拇机号码信息:" label:@"拇机号码" cancelButtonTitle:@"不OK" otherButtonTitles:@"OK"];
        popview.secondField.text = mujiNumber;
    }else{
        [popview initWithTitle:@"呼叫转移需要配置拇机号码信息:" label:@"拇机号码" cancelButtonTitle:@"不OK" otherButtonTitles:@"OK"];
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
    //取消
    if (button.tag == 0) {
        
        //[self hideShadeAndPopView];
        [sfield resignFirstResponder];
    }
    //sure按钮
    if (button.tag == 1) {
        if ( number.length<=0 || ![number isValidateMobile:number]) {
            //创建提醒对话框
            UIAlertView *malertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please_enter_the_correct_info", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Sure", nil) otherButtonTitles:nil, nil];
            [malertView show];
            //malertView.delegate = self;
            //[malertView textFieldAtIndex:0];//获取输入框，在UIAlertViewStyle -> input模式
        }else
        {
            //本地保存数据
            [defaults setValue:number forKey:muji_bind_number];
            
            //上传到服务器
            /*
            ^(BOOL suc,NSError *error){
             
             if (suc) {
             VCLog(@"sign suc");
             }else{
             VCLog(@"reg error-code:%ld errorInfo:%@",(long)error.code,error.localizedDescription);
             UIAlertView *alert =[[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:self cancelButtonTitle:@"是" otherButtonTitles:nil, nil];
             alert.delegate = self;
             [alert show];
             }
             }];
             */
            [defaults setValue:@"1" forKey:CONFIG_STATE];
            //
            [self.configureButton setTitle:@"  修改  " forState:UIControlStateNormal];
            [self.configureButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];
            
            VCLog(@"save-->number:%@",number);
            [sfield resignFirstResponder];
        }
    }
    
    [self initLoginAndConfigButtons];
}

#pragma mark -- 呼转 & 取消
- (IBAction)callAnotherButtonClick:(UIButton *)sender {
    
    callAndDivert.divertDelegate = self;
    [callAndDivert isOrNotCallDivert];
    
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
            UIAlertView *configAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"想【修改】拇机号码？请先【登录】" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [configAlert show];
        }
        
    }else{//配置0
        
        BOOL loginState = [[defaults valueForKey:LOGIN_STATE] intValue];
        if (loginState) {//登录1
            
            //配置
            [self addShadeAndAlertViewWithNumber:nil];
            
        }else{
            //提示登录
            UIAlertView *configAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"想【配置】拇机号码？请先【登录】" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [configAlert show];
        }

        
        
    }
    
    

    
}

#pragma mark -- 登录 & 退出
- (IBAction)loginButtonClick:(UIButton *)sender {
    
    BOOL loginstate = [[defaults valueForKey:LOGIN_STATE] intValue];
    if (loginstate) {
        [self loginOut];
        //[defaults setValue:@"0" forKey:LOGIN_STATE];
        //[defaults setValue:@"0" forKey:CONFIG_STATE];
        self.connectGifView.hidden = YES;
        
        [self initLoginAndConfigButtons];
    }else
    {
        VCLog(@"11");
        //添加login页面
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginController *loginview = [board instantiateViewControllerWithIdentifier:@"loginVCIdentity"];
        [self.navigationController pushViewController:loginview animated:YES];
         
    }
    
}

-(void)loginOut
{
    [AVUser logOut];
    [userDefaults setValue:@"0" forKey:LOGIN_STATE];
    [userDefaults setValue:@"0" forKey:CONFIG_STATE];

}

#pragma mark -- 控制 & 解除
- (IBAction)bindButtonClick:(UIButton *)sender {
    
    BOOL bstate = [[defaults valueForKey:BIND_STATE] intValue];
    if (bstate) {
        [defaults setObject:@"0" forKey:BIND_STATE];
        //断开蓝牙连接
        [self cutConnectperipheral];
    }else{//没绑定
        
        if (managerState == CBCentralManagerStatePoweredOn) {
            
            [SVProgressHUD showWithStatus:@"匹配中..." maskType:SVProgressHUDMaskTypeNone];
            //查找外设
            [self scanPeripheral];
            
            [self performSelector:@selector(dismissSvp) withObject:nil afterDelay:15];//扫描外设时间
        }else{
            UIAlertView *atv=[[UIAlertView alloc] initWithTitle:@"需要打开蓝牙" message:@"是否打开蓝牙？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
            atv.tag = 1993;
            [atv show];
        }
        
        
        
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
#pragma mark -- managerDelegate
-(void)systemBLEState:(CBCentralManagerState)state {
    
    managerState = state;
    NSLog(@"state:%ld",(long)state);
    
}
-(void)managerConnectedPeripheral:(CBPeripheral *)peripheral connect:(BOOL)isConnect
{
    isConnecting = isConnect;
    if (isConnecting) {
        [defaults setObject:@"1" forKey:BIND_STATE];
        currentPeripheral = peripheral;
    }else{
        [defaults setObject:@"0" forKey:BIND_STATE];
    }
    [self refreshBindButton];
    //连接成功
    if (isConnect == YES) {
        [SVProgressHUD showErrorWithStatus:@"连接成功!"];
        [bleManage.centralManager stopScan];
        //[SVProgressHUD dismiss];
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
