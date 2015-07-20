//
//  MsgDetailController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//


#import "MsgDetailController.h"
#import "Message.h"
#import "MsgFrame.h"
#import "MsgDetailCell.h"
#import "TXSqliteOperate.h"
#import "EditView.h"
#import "TextViewInput.h"
#import "NewMsgController.h"
#import "ShareContentController.h"

@interface MsgDetailController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,EditViewDelegate,ChangeRightMarginDelegate,TextInputDelegate>
{
    TXSqliteOperate *txsqlite;
    UILongPressGestureRecognizer *longPress;
    EditView *editView;
    NSMutableArray *selectArray;
    NSMutableDictionary *selectDict;
    
    TextViewInput *textInput;
    CGFloat kHeight;
}
@property (strong, nonatomic) NSMutableArray *detailArray;
@property (strong, nonatomic) NSMutableArray *allMsgFrame;

@property (nonatomic,strong) UILabel *nameLabel;//姓名
@property (nonatomic,strong) UILabel *arearLabel;//号码归属地

@property (weak, nonatomic) IBOutlet UIBarButtonItem *callOutBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *contactsInfoBtn;

- (IBAction)callOutBtn:(UIBarButtonItem *)sender;
//- (IBAction)ContactsInfo:(UIBarButtonItem *)sender;

@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *resultArray;

@end

@implementation MsgDetailController
@synthesize datailDatas;


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.detailArray =[txsqlite searchARecordWithNumber:self.datailDatas.hisNumber fromTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:SELECT_A_CONVERSATION_SQL];
    
    VCLog(@"self.detailArray %@",self.detailArray);
    [self getResouce];
    [self jumpToLastRow];
    [self.tableview reloadData];
    [self initKeyBoardNotif];
    [self initInputView];
    
    
    //编辑时显示
    editView =[[EditView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 50)];
    editView.backgroundColor = [UIColor whiteColor];
    editView.delegate  =self;
    [self.view addSubview:editView];
}
#pragma mark - 键盘action
-(void)initKeyBoardNotif{
    //键盘显示消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotif:) name:UIKeyboardWillShowNotification object:nil];
    //键盘隐藏消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillHiddenNotif:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)keyboardWillShowNotif:(NSNotification*)notif{
    
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    //获取键盘高度
    NSValue *keyboardObject = [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [keyboardObject getValue:&keyboardRect];
    kHeight = keyboardRect.size.height;
    textInput.frame = CGRectMake(0, DEVICE_HEIGHT-textinputHeight-kHeight, DEVICE_WIDTH, textinputHeight);
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        
        CGRect rect = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.tableview.frame = CGRectMake(0,0 , DEVICE_WIDTH, DEVICE_HEIGHT-rect.size.height);//-rect.size.height
        [self jumpToLastRow];
    }];
    
}


//键盘隐藏
-(void)keyboardwillHiddenNotif:(NSNotification*)notif{
    self.tableview.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    
    kHeight = 0;
    textInput.frame = CGRectMake(0, DEVICE_HEIGHT-textinputHeight, DEVICE_WIDTH, textinputHeight);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    txsqlite =[[TXSqliteOperate alloc] init];
    self.detailArray = [[NSMutableArray alloc] init];
    selectArray = [[NSMutableArray alloc] init];
    selectDict = [[NSMutableDictionary alloc] init];
    VCLog(@"datailDatas:%@",self.datailDatas);
    
    // 显示左边按钮
    UIView *view = [[UIView alloc] init];
    view.userInteractionEnabled = YES;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, 150, 20)];
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    if (self.datailDatas.hisName.length>0) {
        self.nameLabel.text = self.datailDatas.hisName;
    }
    self.nameLabel.text = @"这里是名字";
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.arearLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 230, 20)];
    [self setArearLabelTitle];
    self.arearLabel.textColor = [UIColor whiteColor];
    
    [self.callOutBtn setImage:[UIImage imageNamed:@"actionbar_call_hub32"]];
    
    
    //注册手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(initMsgSwipeRecognizer:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.tableview addGestureRecognizer:swipe];
    [self.view addGestureRecognizer:swipe];

    //返回按钮
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(arearBtnClick:)];
    tap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:tap];
    
    [view addSubview:self.nameLabel];
    [view addSubview:self.arearLabel];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItem.title = @"";
    self.contactsInfoBtn.customView = view;
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-35)];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.allowsSelection = NO;//选中某一行cell时，不作任何显示
    [_tableview flashScrollIndicators ];
    
    [self.view addSubview:_tableview];
    
}
#pragma mark -- input view
-(void) initInputView
{
    textInput =[[TextViewInput alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT-textinputHeight, DEVICE_WIDTH, textinputHeight)];
    textInput.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"abcd"]];
    textInput.inputDelegate = self;
    textInput.textview.font = [UIFont systemFontOfSize:16];
    textInput.maxHeight = 110;
    textInput.rigBtnTitle = @"发送";
    [self.view addSubview:textInput];
    
}

-(CGFloat)getKeyBoradHeight{
    return kHeight;
}

-(void)changedFrame:(CGRect)rect{
    textInput.frame = rect;
}
-(void)rightButtonClick:(UIButton *)button{
    
    
    if (textInput.textview.text.length>0) {
        
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        NSDate *date = [NSDate date];
        fmt.dateFormat = @"yyyy/M/d HH:mm";
        NSString *time = [fmt stringFromDate:date];
        [self addMessageWithContent:textInput.textview.text time:time];
        
        //关闭键盘
        [textInput.textview resignFirstResponder];
        
        //保存到数据库
        TXData *txdata =  [[TXData alloc] init];
        txdata.msgSender = @"1";//self.datailDatas.hisNumber;//
        txdata.msgTime = time;
        txdata.msgContent = textInput.textview.text;
        txdata.msgAccepter = self.datailDatas.hisNumber;//@"1";//
        txdata.msgStates = @"0";//@"0"
        
        [txsqlite addInfo:txdata inTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:MESSAGE_RECORDS_ADDINFO_SQL];
        //self.detailArray =[txsqlite searchARecordWithNumber:self.datailDatas.hisNumber fromTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:SELECT_A_CONVERSATION_SQL];
        
    }
    textInput.textview.text = nil;
    
    [self jumpToLastRow];
    [self.tableview reloadData];
    //[SVProgressHUD showImage:nil status:@"click"];
}
-(void)initMsgSwipeRecognizer:(UISwipeGestureRecognizer*)swipe{
    [textInput.textview resignFirstResponder];
}


#pragma  mark --EditViewDelegate

-(void)buttonClickAndChanged:(UIButton *)button
{
    if (button.tag == 2000) {//拷贝
        NSIndexPath *path = [self.tableview indexPathForSelectedRow];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [self.detailArray[path.row] msgContent];
        VCLog(@"copys:pasteboard.string%@",pasteboard.string);
        [SVProgressHUD showImage:nil status:@"已copy"];
    }
    
    if (button.tag == 2001) {
        [self shareContent];
    }
    
    if (button.tag == 2002) {
        [self deleteButtonClick:button];
    }
}
//转发
-(void)shareContent
{
    /*
    NSIndexPath *path = [self.tableview indexPathForSelectedRow];
    //跳转到newMsg
    NewMsgController *newMsgVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"newMsgID"];

    ShareContentController *newvc = [[ShareContentController alloc] initWithNibName:@"ShareContentController" bundle:[NSBundle bundleWithIdentifier:@"ShareContentController"]];
    
    newMsgVC.msgContent = [[self.detailArray objectAtIndex:path.row] msgContent];
    UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:newvc];
        
    [self presentViewController:nav animated:YES completion:^{VCLog(@"share");}];
    */
    VCLog(@"share");
}

//删除所选
-(void)deleteButtonClick:(UIButton *)button
{
    //删除选中的条目
    //数据库
    /*
    for (NSArray *arr in selectArray) {
        [txsqlite deleteContacterWithNumber:arr[0] formTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME peopleId:arr[1] withSql:DELETE_MESSAGE_RECORD_SQL];
    }
    //重新获取数据
    self.detailArray =[txsqlite searchARecordWithNumber:self.datailDatas.hisNumber fromTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:SELECT_A_CONVERSATION_SQL];
    
    
    
    
    
    VCLog(@"self.detailArray:%@ ,allValues:%@",self.detailArray,[selectDict allValues]);
    
    [self.detailArray removeObjectsInArray:[selectDict allValues]];
    VCLog(@"allKeys:%@",[selectDict allKeys]);
    
    [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithArray:[selectDict allKeys]] withRowAnimation:UITableViewRowAnimationFade];
    
    */
    [self cancelCheckCell];
}

#pragma mark -- TableView select Rows
//
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //移除再次选中的
    if ([self.arearLabel.text isEqualToString:@"取消"]) {
        [selectDict removeObjectForKey:indexPath];
        
        if ([selectArray containsObject:indexPath]) {
            [selectArray removeObject:indexPath];
        }
    }

    VCLog(@"selectDict:%@",selectDict);
    VCLog(@"selectArray:%@",selectArray);
    if (selectArray.count <= 0) {
        [editView.copysButton setEnabled:NO];
        [editView.sharesButton setEnabled:NO];
        [editView.deleteButton setEnabled:NO];
        
    }
    
    VCLog(@"did deselect");
}

//选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取选中的数据
    //NSString *msgsender = [self.detailArray[indexPath.row] msgSender];
    //NSString *peopleId = [NSString stringWithFormat:@"%d",[self.detailArray[indexPath.row] peopleId]];
    //NSArray *checkDatas=[[NSArray alloc] initWithObjects:msgsender,peopleId, nil];
    
    //[selectArray addObject:checkDatas];
    //
    if ([self.arearLabel.text isEqualToString:@"取消"]) {
        VCLog(@"self.detailArray:%@",self.detailArray);
        [selectDict setObject:[self.detailArray objectAtIndex:indexPath.row] forKey:indexPath];
        if (![selectArray containsObject:indexPath]) {
            [selectArray addObject:indexPath];
        }
    }
    VCLog(@"selectDict:%@",selectDict);
    VCLog(@"selectArray:%@",selectArray);
    
    if (selectArray.count >0) {
        [editView.copysButton setEnabled:YES];
        [editView.sharesButton setEnabled:YES];
        [editView.deleteButton setEnabled:YES];

    }

}

-(void)setArearLabelTitle
{
    if (self.datailDatas.hisNumber.length>0 && self.datailDatas.hisHome.length==0) {
        self.arearLabel.text = [NSString stringWithFormat:@"%@",self.datailDatas.hisNumber];
    }else if(self.datailDatas.hisNumber.length>0 && self.datailDatas.hisHome.length>0)
    {
        self.arearLabel.text = [NSString stringWithFormat:@"%@%@",self.datailDatas.hisNumber,self.datailDatas.hisHome];
        
    }else
    {
        self.arearLabel.text = [NSString stringWithFormat:@"back"];
    }

}

-(void) getResouce
{
   
    self.allMsgFrame = [[NSMutableArray alloc] init];
    NSString *previousTime = nil;
    
    for (TXData *data in self.detailArray) {
        
        MsgFrame *messageFrame = [[MsgFrame alloc] init];
        messageFrame.delegate = self;
        Message *message = [[Message alloc] init];
        
        message.data = data;
        messageFrame.showTime = 1;//![previousTime isEqualToString:message.time];
        messageFrame.message = message;
        previousTime = message.time;
       
        [self.allMsgFrame addObject:messageFrame];
        
    }
    
    //[self.tableview reloadData];
}

#pragma --mark 给数据源增加内容-自己发送的内容
- (void)addMessageWithContent:(NSString *)content time:(NSString *)time{
    
    MsgFrame *mf = [[MsgFrame alloc] init];
    Message *msg = [[Message alloc] init];
    msg.content = content;
    msg.time = time;
    msg.type = MessageTypeMe;
    mf.message = msg;
    
    [self.allMsgFrame addObject:mf];
}





//返回上一层界面
-(void)arearBtnClick:(UIGestureRecognizer *)recognizer
{
    if ([self.arearLabel.text isEqualToString:@"取消"]) {
        
        [self cancelCheckCell];
        
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

//取消选中cell
-(void)cancelCheckCell
{
    [self.tableview setEditing:NO animated:YES];
    [self setArearLabelTitle];
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationCurve:.5];
    editView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 50);
    [UIView commitAnimations];
    
    [self.callOutBtn setImage:[UIImage imageNamed:@"actionbar_call_hub32"]];
    [self.callOutBtn setEnabled:YES];
    if (selectArray.count <= 0) {
        [editView.copysButton setEnabled:NO];
        [editView.sharesButton setEnabled:NO];
        [editView.deleteButton setEnabled:NO];
        
    }

    //[self.tableview reloadData];
}

#pragma mark -- UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allMsgFrame.count;
    //return _resultArray.count;
}


//cell行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return [self.allMsgFrame [indexPath.row] cellHeight];
}

//返回cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MsgDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[MsgDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        longPress =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        longPress.minimumPressDuration = 1.f;
        longPress.delegate = self;
    }
    
    NSInteger aa = indexPath.row;
    // 设置数据
    cell.msgFrame = self.allMsgFrame[aa];
    //VCLog(@"state:%@",[array[indexPath.row] msgState]);
    [cell.contentBtn addGestureRecognizer:longPress];
    return cell;
}
-(void)jumpToLastRow
{
    if (self.allMsgFrame.count>7) {
        //滚动到当前信息
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.detailArray.count-1 inSection:0];
        [self.tableview scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }else{
        return;
    }
    
}
#pragma mark - -changerightMargin delegate
-(CGFloat)changeRightMargin
{
    /*
    if (editView.frame.origin.y == DEVICE_HEIGHT-50) {
        return 30;
    }
     */
    return 0;
    
}

-(void)longPressAction:(UIGestureRecognizer *)recongizer
{
    [textInput.textview resignFirstResponder];
    if (recongizer.state == UIGestureRecognizerStateBegan) {
        VCLog(@"longPress");
        
        //
        [self.tableview setEditing:YES animated:YES];
        self.arearLabel.text = @"取消";
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationCurve:.5];
        editView.frame = CGRectMake(0, DEVICE_HEIGHT-50, DEVICE_WIDTH, 50);
        [UIView commitAnimations];
        
        [self.callOutBtn setImage:[UIImage imageNamed:@""]];
        [self.callOutBtn setTitle:@""];
        [self.callOutBtn setEnabled:NO];
    }
    [self getResouce];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;//默认没有编辑风格
    if ([tableView isEqual:self.tableview]) {
        //出现圈圈
        result  =  UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }
    
    return result;
}

//导航栏右边按钮拨-拨打电话
- (IBAction)callOutBtn:(UIBarButtonItem *)sender {
    
    if (self.datailDatas.hisName.length <=0) {
        self.datailDatas.hisName = @"";
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.datailDatas.hisName,@"hisName",self.datailDatas.hisNumber,@"hisNumber", nil];
    
    VCLog(@"dict:%@",dict);
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCallingBtnClick object:self userInfo:dict]];
    
}



/*
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //移除键盘显示和隐藏消息注册信息
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
