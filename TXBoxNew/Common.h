


// 判断是否为iPhone5
#define iPhone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define iPhone4s ([UIScreen mainScreen].bounds.size.height == 480)

// dock（customTabbar） 高度
#define kDockHeight 49
#define TXNavigationHeight 44
// 通知
#define ktextChangeNotify @"textChangeNotification"//输入文本时，显示callBtn
#define kCallingBtnClick @"callingBtnClick"     //点击callBtn
#define kCustomKeyboardHide @"customKeyboardHide"//自定键盘隐藏
#define kKeyboardAndTabViewHide @"keyboardAndTabBarHide"//自定键盘、callBtn,tabbar隐藏
#define kHideCusotomTabBar @"hideCustomTabBar"//隐藏自定tabbar
#define kShowCusotomTabBar @"showCustomTabBar"//显示自定tabbar
#define kHideTabBarAndCallBtn @"hideTabBarAndCallBtn" //隐藏tabbar和callBtn
#define kShowValueToMsgDetail @"showValue"

// custom键盘高宽
#define keyWidth DEVICE_WIDTH/3.f
#define keyHight keyWidth/2.f

// 颜色
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)/1.f]

// 设备版本
#define IOS_DEVICE_VERSION [[UIDevice currentDevice].systemVersion floatValue]

// 设备宽度,高度
#define DEVICE_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define DEVICE_HEIGHT ([UIScreen mainScreen].bounds.size.height)

// 字符串-数据库名
#define DB_NAME @"txbox.sqlite"
#define SELECT_ALL_SQL @"select *from %@"

// ==========通话记录表
#define CALL_RECORDS_TABLE_NAME @"CALL_RECORDS"
#define CALL_RECORDS_CREATE_TABLE_SQL @"create table if not exists %@(tel_id integer primary key AUTOINCREMENT,hisName text,hisNumber text,callDirection text,callLength text,callBeginTime text,hisHome text,hisOperator text)" //创建通话记录表的sql语句
#define CALL_RECORDS_ADDINFO_SQL @"insert into %@(hisName ,hisNumber ,callDirection ,callLength,callBeginTime ,hisHome ,hisOperator ) values(?,?,?,?,?,?,?)"    //添加call——records

#define DELETE_CALL_RECORD_SQL @"delete from %@ where hisNumber=%@"//删除一条通话记录

//===========信息表
#define MESSAGE_RECEIVE_RECORDS_TABLE_NAME @"MESSAGE_RECORDS"
#define MESSAGE_RECEIVE_RECORDS_CREATE_TABLE_SQL  @"create table if not exists %@(peopleId integer primary key AUTOINCREMENT,msgSender text,msgTime text,msgContent text,msgAccepter text)" //创建d短信记录表的sql语句
#define MESSAGE_RECORDS_ADDINFO_SQL @"insert into %@(msgSender,msgTime,msgContent,msgAccepter) values(?,?,?,?)"    //添加msg
#define DELETE_MESSAGE_RECORD_SQL @"delete from %@ where msgSender=%@ and msgTime = %@" //删除单条短信记录

#define DELETE_MESSAGE_RECORD_CONVERSATION_SQL  @"delete from %@ where hisNumber=%@ or msgAccepter = %@"    //删除整个短信会话

//查询某一次会话
#define SELECT_A_CONVERSATION_SQL @"select msgTime,msgContent,msgAccepter  from %@ where msgSender=%@"//or msgAccepter = %@




// 首页输入框的view
#define InputBoxView 50.f

// searchBar高度
#define kSearchH 44.f

// 表格高度
#define kCellHeight   40.0f

// cell中图标width
#define cellIconWidth 320/3.f

// slider的宽高
#define SliderHeight 5
#define SliderWidth 200

// 号码归属地的网址
#define TelNumAddress @"http://virtual.paipai.com/extinfo/GetMobileProductInfo?mobile=%@&amount=10000&callname=getPhoneNumInfoExtCallback"

// 其它
#define OtherNumber NSLocalizedString(@"Other", nil)

// 状态栏高度 默认20
#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

// tabBar高度 默认49
#define  TabBarHeight self.tabBarController.tabBar.frame.size.height
// 导航栏高度 默认44
#define NaviBarHeight self.navigationController.navigationBar.frame.size.height

// 邮箱和拇机号码
#define email_number @"e_mail_number"
#define muji_bind_number @"muji_bind_number"
// 呼转状态
#define call_divert @"call_divert"
// window窗口
#define WINDOW  [[UIApplication sharedApplication]keyWindow]

#define PopViewHeight 170   //弹出框高度
#define PopViewWidth 200    //弹出框宽度




