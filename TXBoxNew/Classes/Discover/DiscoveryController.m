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

@interface DiscoveryController ()<PopViewDelegate>
{
    NSUserDefaults *defaults;
    BOOL loginState;
    BOOL bindState;
    BOOL configState;
    
    UIView *shadeView;  //遮罩层
    PopView *popview;   //提示框
    
    CGImageSourceRef gif; // 保存gif动画
    NSDictionary *gifProperties; // 保存gif动画属性
    size_t index; // gif动画播放开始的帧序号
    size_t count; // gif动画的总帧数
    NSTimer *gifViewTimer; // 播放gif动画所使用的timer
    
    UIImageView *con_imgv;  //
    UIImageView *ble_imgv;  //蓝牙图片
    
}
//label
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *mujiNumber;
@property (weak, nonatomic) IBOutlet UILabel *connectNumber;
//
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *mujiButton;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

//gif图
@property (weak, nonatomic) IBOutlet UIView *BLEView;
@property (weak, nonatomic) IBOutlet UIView *connectView;
//
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
- (IBAction)bindButtonClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *configureButton;
- (IBAction)configureButtonClick:(UIButton *)sender;
//版本
@property (weak, nonatomic) IBOutlet UIButton *isAppVersion;
@property (weak, nonatomic) IBOutlet UIButton *isFirmwareVersion;

@end

@implementation DiscoveryController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //通知显示tabBar
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowCusotomTabBar object:self]];
    loginState = [[defaults valueForKey:LOGIN_STATE] intValue];
    bindState = [[defaults valueForKey:BIND_STATE] intValue];
    configState = [[defaults valueForKey:CONFIG_STATE] intValue];
    
    
    [self initButtons];
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    con_imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 23)];
    ble_imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 23)];
    
    self.phoneNumber.hidden = YES;
    self.mujiNumber.hidden = YES;
    self.connectNumber.hidden = YES;
    
    
    [self.isAppVersion setTitle:@"v1.0" forState:UIControlStateNormal];
    self.isAppVersion.enabled = YES;
    
    self.isFirmwareVersion.hidden = YES;
    
    self.loginButton.layer.cornerRadius = 13;
    self.configureButton.layer.cornerRadius = 13;
    self.bindButton.layer.cornerRadius = 13;
    
    
    UILabel *footv =[[UILabel alloc] initWithFrame:CGRectMake(15, 0, DEVICE_HEIGHT, 1)];
    footv.backgroundColor = [UIColor grayColor];
    footv.alpha = .3;
    self.tableView.tableFooterView = footv;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    return 2;
}


-(void)initButtons{
    
    if (loginState) {//已登录
        self.phoneNumber.hidden = NO;
        [self.loginButton setTitle:@"  退出  " forState:UIControlStateNormal];
        [self.loginButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];
        self.phoneNumber.text = [defaults valueForKey:CurrentUser];
    }
    
    if (configState) {//已配置
        [self.configureButton setTitle:@"  修改  " forState:UIControlStateNormal];
        [self.configureButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];
        self.mujiNumber.hidden = NO;
        self.mujiNumber.text = [defaults valueForKey:muji_bind_number];
        self.connectNumber.hidden = NO;
        self.connectNumber.text = @"运营商";
        
        //显示gif图片
        [self initWithGifFrame:CGRectMake(0, 0, 0, 0) filePath:[[NSBundle mainBundle] pathForResource:@"phone_connect" ofType:@"gif"]];
    }else{
        //显示静态图片
        con_imgv.image = [UIImage imageNamed:@"flow_phone"];
        [self.connectView addSubview:con_imgv];
    }
    
    if (bindState) {//已绑定
        [self.bindButton setTitle:@"  解绑  " forState:UIControlStateNormal];
        [self.bindButton setBackgroundColor:RGBACOLOR(252, 57, 59, 1)];//ble_connect
        //显示gif图片
        [self initWithGifFrame:CGRectMake(0, 0, 0, 0) filePath:[[NSBundle mainBundle] pathForResource:@"ble_connect" ofType:@"gif"]];
        
    }else{
        //显示静态图片
        ble_imgv.image = [UIImage imageNamed:@"flow_ble"];
        [self.BLEView addSubview:ble_imgv];
    }
    
    
}

//加载gif
- (void)initWithGifFrame:(CGRect)frame filePath:(NSString *)filePath
{
    NSDictionary *gifLoopCount = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    
    gifProperties = [NSDictionary dictionaryWithObject:gifLoopCount forKey:(NSString *)kCGImagePropertyGIFDictionary] ;
    
    gif = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:filePath], (CFDictionaryRef)gifProperties);
    
    count =CGImageSourceGetCount(gif);
    
    gifViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playGif) userInfo:nil repeats:YES];
    [gifViewTimer fire];
    
}

//开始动画
-(void)playGif
{
    index ++;
    index = index%count;
    CGImageRef ref = CGImageSourceCreateImageAtIndex(gif, index, (CFDictionaryRef)gifProperties);
    if (configState) {
        self.connectView.layer.contents = (__bridge id)ref;;
    }
    if (bindState) {
        self.BLEView.layer.contents = (__bridge id)ref;
    }
    
    CFRelease(ref);
}
//停止定时器
-(void)timerHasOver
{
    [gifViewTimer invalidate];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self timerHasOver];
    gifViewTimer = nil;
}

#pragma mark -- 弹出框
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
    popview = [[PopView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-PopViewWidth)/2, DEVICE_HEIGHT-PopViewHeight-220, PopViewWidth, PopViewHeight)];
    popview.delegate = self;
    
    if (mujiNumber.length>0) {
        [popview initWithTitle:@"修改拇机号码信息:" label:@"拇机号码" cancelButtonTitle:@"OK" otherButtonTitles:@"不OK"];
        popview.secondField.text = mujiNumber;
    }else{
        [popview initWithTitle:@"呼叫转移需要配置拇机号码信息:" label:@"拇机号码" cancelButtonTitle:@"OK" otherButtonTitles:@"不OK"];
    }
    
    [self.view.window addSubview:popview];
}

-(void)shadeViewTap:(UIGestureRecognizer *)recongnizer
{
    VCLog(@"-------tap");
    
    [shadeView removeFromSuperview];
    [popview removeFromSuperview];
}

#pragma mark-- popview delegate
-(void)resaultsButtonClick:(UIButton *)button  textField:(UITextField *)sfield;
{
    //获取输入的text
    NSString *number = [sfield.text trimOfString];
    //取消
    if (button.tag == 1) {
        
        [shadeView removeFromSuperview];
        [popview removeFromSuperview];
    }
    //sure按钮
    if (button.tag == 0) {
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
            [shadeView removeFromSuperview];
            [popview removeFromSuperview];
            
        }
    }
    
    
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -- 绑定

- (IBAction)bindButtonClick:(UIButton *)sender {
    
    
}

#pragma mark -- 配置
- (IBAction)configureButtonClick:(UIButton *)sender {
    
    if (loginState) {
        VCLog(@"pz");
        BOOL conState = [defaults valueForKey:CONFIG_STATE];
        if (conState) {
            //已配置，修改
            [self addShadeAndAlertViewWithNumber:[defaults valueForKey:muji_bind_number]];
        }else{
            //配置
            [self addShadeAndAlertViewWithNumber:nil];
        
        }
        
    }
    
    else{
        //提示登录
        UIAlertView *configAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"想【配置】拇机号码？请先【登录】" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [configAlert show];
    }
    
}

-(void)loginOut
{
    [AVUser logOut];
}

- (IBAction)loginButtonClick:(UIButton *)sender {
    
    BOOL loginstate = [[defaults valueForKey:LOGIN_STATE] intValue];
    if (loginstate) {
        [self loginOut];
        [defaults setValue:@"0" forKey:LOGIN_STATE];
        [self initButtons];
    }else
    {
        VCLog(@"11");
    }
    
}
@end
