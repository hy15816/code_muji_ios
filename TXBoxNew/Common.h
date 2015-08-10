


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

// 设备版本
#define IOS_DEVICE_VERSION [[UIDevice currentDevice].systemVersion floatValue]

// 设备宽度,高度
#define DEVICE_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define DEVICE_HEIGHT ([UIScreen mainScreen].bounds.size.height)



// =================数据库==============//
#define DB_NAME @"txboxSecond.sqlite"
#define DB_PHONE_AREAR_NAME @"PhoneArea.db"
#define SELECT_ALL_SQL @"select *from %@"


// =================通话记录表===========//
#define CALL_RECORDS_TABLE_NAME @"CALL_RECORDS8_6_2"
//创建通话记录表的sql语句
#define CALL_RECORDS_CREATE_TABLE_SQL @"create table if not exists %@(tel_id integer primary key AUTOINCREMENT,hisName text,hisNumber text,callDirection text,callLength text,callBeginTime text,hisHome text,hisOperator text,contactid,text)"
//添加call——records
#define CALL_RECORDS_ADDINFO_SQL @"insert into %@(hisName ,hisNumber ,callDirection ,callLength,callBeginTime ,hisHome ,hisOperator,contactid ) values(?,?,?,?,?,?,?,?)"
//删除一条通话记录
#define DELETE_CALL_RECORD_SQL @"delete from %@ where hisNumber=%@"


//===================信息表=============//
#define MESSAGE_RECEIVE_RECORDS_TABLE_NAME @"MESSAGE_RECORDS8_7_1"
//创建d短信记录表的sql语句
#define MESSAGE_RECEIVE_RECORDS_CREATE_TABLE_SQL  @"create table if not exists %@(peopleId integer primary key AUTOINCREMENT,msgSender text,msgTime text,msgContent text,msgAccepter text,msgState text)"
//添加msg记录
#define MESSAGE_RECORDS_ADDINFO_SQL @"insert into %@(msgSender,msgTime,msgContent,msgAccepter,msgState) values(?,?,?,?,?)"
//删除单条短信记录
#define DELETE_MESSAGE_RECORD_SQL @"delete from %@ where msgSender=%@ and peopleId = %@"
//删除整个短信会话
#define DELETE_MESSAGE_RECORD_CONVERSATION_SQL  @"delete from %@ where msgSender=%@ or msgAccepter = %@"

//查询某一次整个会话
#define SELECT_A_CONVERSATION_SQL @"select *from %@ where msgSender=%@ or msgAccepter = %@"
//查询某一次会话的最后一条
#define SELECT_A_LAST_MESSAGE_RECORDS @"select *from %@ where msgSender=%@ or msgAccepter=%@"

//查询所有短信联系人,不需要重复显示
#define SELECT_ALL_MSG_CONTACTER_SQL @"select msgAccepter from %@ "

//查询所有与输入匹配的短信内容
#define SELECT_ALL_COINTENT_FROM_MSG @"select *from %@ where msgSender LIKE '%@' or msgAccepter LIKE '%@' or msgContent LIKE '%@' "

//===================================//
//保存联系人的数据库
#define CONTACTS_TABLE_NAME @"CONTACTS_TABLE"
#define CREATE_CONTACTS_TABLE_SQL @"create table if not exists %@(contacterId integer primary key AUTOINCREMENT,contactName text,contactNumber text)"
#define CONTACTS_TABLE_ADDINFO_SQL @"insert into %@(contactName,contactNumber) values(?,?)"
#define SELECT_NAME_FROM_NUMBER @"select contacterName from %@ where contacterNumber=%@"
#define SELECT_NUMBER_FROM_NAME @"select contacterNumber from %@ where contacterName=%@"


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
#define table_total_duration_call_transfer @"total_duration_call_transfer"  //NSNumber

//发送给设备蓝牙的数据长度
#define kByte_count   20//数据长度
#define keyWriteChc @"writeChc"//
#define keyReadChc  @"readChc"

#define userDefaults [NSUserDefaults standardUserDefaults]
#define yyyy_M_d_HH_mm @"yyyy/M/d HH:mm"

#define isRead @"isRead"
#define isRecordRef @"isRecordRef"

//keyView
#define InputFieldAllText @"textFieldAllText"
#define AddOrDelete @"addOrDelete"

//about 正则
//#define ZZExpression @"[0-9,A,B,C]*"
#define ZZExpression @"\\w*"
#define ReplaceIdentifi @"-"

//联系人
#define FirstNameChars @"firstNameChars"
#define PersonName @"personName"
#define PersonNameNum @"personNameNum"
#define PersonTel   @"personTel"
#define PersonTelNum @"personTelNum"
#define PersonRecordRef @"recordRef"
/*
//联系人dict格式：{
 personName = "",
 personNameNum = "",
 personTel = "",
 personTelNum,
 recordRef = ""
 
}
*/



