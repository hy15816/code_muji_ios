//
//  AppDelegate.m
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define canUpdate @"canUpdate"
#define APPURL @"http://itunes.apple.com/lookup?id=901293133"

#import "AppDelegate.h"
#import "TXSqliteOperate.h"


@interface AppDelegate ()<UIAlertViewDelegate>
{
    NSString *appTrackViewURL;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //leanCloud 服务器
    [AVOSCloud setApplicationId:@"85m0pvb0vv1iluti5sk0xsou1mkftzn06a3f1ompvza9xc7z" clientKey:@"orluh89ufnpvl773b68w5gcdk4dxfrahzwaahz7c46ettn44"];

    
    if ([[userDefaults valueForKey:muji_bind_number] length] >0 ) {
        [userDefaults setValue:@"1" forKey:CONFIG_STATE];
    }else{
        [userDefaults setValue:@"0" forKey:CONFIG_STATE];
    }
    
    
    
    //创建数据库-和表
    TXSqliteOperate *sqlite = [[TXSqliteOperate alloc] init];
    [sqlite createTable:CALL_RECORDS_TABLE_NAME withSql:CALL_RECORDS_CREATE_TABLE_SQL];
    [sqlite createTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:MESSAGE_RECEIVE_RECORDS_CREATE_TABLE_SQL];
    
    //修改导航栏的sytle
    [self changeNavigationBarStyle];
    
    
    if ([[UIApplication sharedApplication]currentUserNotificationSettings].types!=UIUserNotificationTypeNone) {
        //[self addLocalNotification];
    }else{
        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    }
    
    [self isOrNotUpdateVersion];
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    
    if (notificationSettings.types!=UIUserNotificationTypeNone) {
        //[self addLocalNotification];
    }
}

-(void)addLocalNotification{
    //定义本地通知对象
    UILocalNotification *notification=[[UILocalNotification alloc]init];
    //设置调用时间
    //notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:10.0];//通知触发的时间，10s以后
    
    notification.repeatInterval=2;//通知重复次数
    //notification.repeatCalendar=[NSCalendar currentCalendar];//当前日历，使用前最好设置时区等信息以便能够自动同步时间
    
    //设置通知属性
    notification.alertBody=@"最近添加了诸多有趣的特性，是否立即体验？"; //通知主体
    notification.applicationIconBadgeNumber=1;//应用程序图标右上角显示的消息数
    notification.alertAction=@"查看详情"; //待机界面的滑动动作提示
    notification.alertLaunchImage=@"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
    //notification.soundName=UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
    notification.soundName=@"msg.caf";//通知声音
    
    //设置用户信息
    notification.userInfo=@{@"id":@1,@"user":@"Kenshin Cui"};//绑定到通知上的其他附加信息
    
    //调用通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
-(void)removeNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
-(void) changeNavigationBarStyle
{
    //背景颜色
    [[UINavigationBar appearance] setBarTintColor:RGBACOLOR(35, 35, 35, 1)];
    //背景图片
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
    
    //设置返回按钮字体颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //设置返回按钮图片
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back_btn.png"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back_btn.png"]];
    
    
    /**
     * 可以使用导航栏的titleTextAttributes属性来定制导航栏的文字风格。
     * 在text attributes字典中使用如下一些key，可以指定字体、文字颜色、文字阴影色以及文字阴影偏移量：
     * UITextAttributeFont – 字体key
     * UITextAttributeTextColor – 文字颜色key
     * UITextAttributeTextShadowColor – 文字阴影色key
     * UITextAttributeTextShadowOffset – 文字阴影偏移量key
     */
    
    //修改导航栏标题的字体
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes:  [NSDictionary dictionaryWithObjectsAndKeys:                                                         [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,   shadow, NSShadowAttributeName,[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
    //修改导航栏标题为图片
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appcoda-logo.png"]];
    
    /**
     * 1.修改状态栏的风格
     *   在Info表中插入一个新的key
     *   名字为View controller-based status bar appearance，并将其值设置为NO
     *   [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     * 2.直接在每个需要的viewContor中 -(UIStatusBarStyle)preferredStatusBarStyle {    return UIStatusBarStyleLightContent;   }
     */
    
    //修改状态栏的风格
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //隐藏状态栏
    /**
     - (BOOL)prefersStatusBarHidden{
        
     return YES;
     }
     
     */
}
//挂起状态
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
//程序进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {

    
    
}


//进入前景
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //VCLog(@"x2");
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];//进入前台取消应用消息图标
    [self removeNotification];
}

//程序成为活动的
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];//进入前台取消应用消息图标
    //[self removeEnterbgView];
    //VCLog(@"x");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KRefreshDisvView object:self]];

}

/*
-(void)removeEnterbgView{
    
    if (enterbgView) {
        [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            enterbgView.alpha = 0;
            [enterbgView removeFromSuperview];
        } completion:^(BOOL isfinsh){if(isfinsh)VCLog(@"is b a");}];
    }
}
*/
#pragma warning 退出程序时
- (void)applicationWillTerminate:(UIApplication *)application {
    //控制为否
    [userDefaults setValue:@"0" forKey:BIND_STATE];
    [userDefaults setValue:@"0" forKey:LOGIN_STATE];
    AVUser *currentUser = [AVUser currentUser];
    if (currentUser) {
        currentUser =nil;
    }
}

#pragma mark -- 检测版本
-(void)isOrNotUpdateVersion
{
    if ([self whatAreWeekDayTaday] == 2 ) {//星期一检测
        //[userDefaults setBool:NO forKey:canUpdate];
        //获取本地版本
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
        //获取itunes上的版本
        NSString *URL = APPURL;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:URL]];
        [request setHTTPMethod:@"POST"];
        NSHTTPURLResponse *urlResponse = nil;
        NSError *error = nil;
        NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
        NSDictionary *infoDicts = [NSJSONSerialization JSONObjectWithData:recervedData options:NSJSONReadingMutableLeaves error:&error];
        
        NSArray *infoArray = [infoDicts objectForKey:@"results"];
        
        if ([infoArray count] && ![userDefaults boolForKey:canUpdate]) {
            
            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
            NSString *lastVersion = [releaseInfo objectForKey:@"version"];
            
            if ([lastVersion floatValue ] > [currentVersion floatValue]) {
                appTrackViewURL = [releaseInfo objectForKey:@"trackViewUrl"];
                UIAlertView *atView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"检测到有新版本，是否更新？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
                atView.tag = 3005;
                atView.delegate = self;
                [atView show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alert.tag = 10001;
                [alert show];
            }
            
            
        }
    
    }
    
    
}

/**
 *  获取当前日期是，星期几
 *  @return  NSInteger 星期几，
 */
- (NSInteger)whatAreWeekDayTaday
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitDay fromDate:now];
    
    // 得到星期几
    // 1->7，(星期天)->(星期一)->(星期六)
    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    
    NSLog(@"weekDay:%ld   day:%ld",weekDay,day);
    
    return weekDay;
}

#pragma  mark --alertView  Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 3005) {
        if (buttonIndex == 0) {
            //跳转到store 更新页面
            UIApplication *application = [UIApplication sharedApplication];
            [application openURL:[NSURL URLWithString:appTrackViewURL]];
        }
        
        [userDefaults setBool:YES forKey:canUpdate];
        
    }
    
    
    
    
}

@end
