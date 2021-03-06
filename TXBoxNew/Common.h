


// 判断是否为iPhone5
#define iPhone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define iPhone4s ([UIScreen mainScreen].bounds.size.height == 480)

// dock（customTabbar） 高度
#define kTabBarHeight 49
#define kNavgHeight 44
// 通知
#define ktextChangeNotify @"textChangeNotification"//输入文本时，显示callBtn
#define kCallingBtnClick @"callingBtnClick"     //点击callBtn
#define kCustomKeyboardHide @"customKeyboardHide"//自定键盘隐藏和callbtn
#define kKeyboardAndTabViewHide @"keyboardAndTabBarHide"//自定键盘、callBtn,tabbar隐藏
#define kHideCusotomTabBar @"hideCustomTabBar"//隐藏自定tabbar
#define kShowCusotomTabBar @"showCustomTabBar"//显示自定tabbar
#define kHideTabBarAndCallBtn @"hideTabBarAndCallBtn" //隐藏tabbar和callBtn
#define kJumptoDiscoeryView @"jumptodiscoveryVC" //跳转到discv
#define kShowValueToMsgDetail @"showValue"
#define KRefreshDisvView @"KrefreshDisvView"

#define kDeleteCharNoti @"deleteCharNoti"
#define kInputCharNoti @"inputCharNoti"

#define kCallViewReloadData @"callViewReloadData"
// custom键盘高宽
#define keyWidth DEVICE_WIDTH/3.f
#define keyHeight keyWidth/2.6f

// 颜色
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)/1.f]
#define LightColor  [UIColor colorWithRed:29/255.0f green:169/255.0f blue:240/255.0f alpha:1.f]//青蓝色


// 设备版本
#define IOS_DEVICE_VERSION [[UIDevice currentDevice].systemVersion floatValue]

// 设备宽度,高度
#define DEVICE_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define DEVICE_HEIGHT ([UIScreen mainScreen].bounds.size.height)


//===================================//
// 首页输入框的view
#define InputBoxViewHeight 50.f

// searchBar高度
#define kSearchH 44.f

// 表格高度
#define kCellHeight   40.0f

// cell中图标width
#define cellIconWidth 320/3.f

// slider的宽高
#define SliderHeight 5
#define SliderWidth 200

// 其它
#define OtherNumber @"其它"

// 状态栏高度
#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define textinputHeight 40 //短信输入框
// tabBar高度
#define  TabBarHeight self.tabBarController.tabBar.frame.size.height
// 导航栏高度 
#define NaviBarHeight self.navigationController.navigationBar.frame.size.height

// 邮箱和拇机号码
#define email_number @"e_mail_number"
#define muji_bind_number @"muji_bind_number"

// window窗口
#define WINDOW  [[UIApplication sharedApplication]keyWindow]

#define PopViewHeight 145   //弹出框高度
#define PopViewWidth 0.9*DEVICE_WIDTH    //弹出框宽度

#define China_Mobile @"China Mobile"
#define China_Unicom @"China Unicom"
#define China_Telecom @"China Telecom"
#define China_TieTong @"China Tietong"




#define CallForwardStartTime @"CallForwardStartTime"
#define CallForwardEndTime @"CallForwardEndTime"
//状态
#define LOGIN_STATE @"loginState"
#define CONTROL_STATE @"controlState"
#define CONFIG_STATE @"configState"
#define CALL_ANOTHER_STATE @"callAnotherState"

#define CurrentUser @"currentUser"

//用户佩戴时长表
#define USER_SPORT_INFO @"user_sport_info"
//字段
#define table_username @"username"  //NSString
#define table_total_duration_call_transfer @"total_duration_call_transfer"  //NSNumber(单次时长)
#define TotalTime @"totalTime"

//发送给设备蓝牙的数据长度
#define kByte_count   20//数据长度，单个分包的字节长度
#define keyWriteChc @"writeChc"//
#define keyReadChc  @"readChc"

#define userDefaults [NSUserDefaults standardUserDefaults]
#define yyyy_M_d_HH_mm @"yyyy/M/d HH:mm"

#define isRead @"isRead"
#define isRecordID @"isRecordID"

//keyView
#define InputFieldAllText @"textFieldAllText"
#define AddOrDelete @"addOrDelete"

//about 正则
//#define ZZExpression @"[0-9,A,B,C]*"
#define ZZExpression @"\\w*"
#define ReplaceIdentifi @"-"




