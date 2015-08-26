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
#import "EditView.h"
#import "NewMsgController.h"
#import "ShareContentController.h"
#import "HPGrowingTextView.h"
#import "BLEmanager.h"
#import "BLEHelper.h"
#import "Messages.h"
#import "NSString+helper.h"


@interface MsgDetailController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,EditViewDelegate,HPGrowingTextViewDelegate,BLEmanagerDelegate>
{
    UILongPressGestureRecognizer *longPress;
    EditView *editView;
    NSMutableArray *selectArray;
    NSMutableDictionary *selectDict;
    
    HPGrowingTextView *textInput;
    UIView *contentView;
    CGFloat kHeight;
    BLEmanager *bManager;
    NSMutableArray *mutDataArray;
    NSMutableData *mutData;
}


@property (strong, nonatomic) NSMutableArray *detailArray;
@property (strong, nonatomic) NSMutableArray *allMsgFrame;

@property (nonatomic,strong) UILabel *nameLabel;//姓名
@property (nonatomic,strong) UILabel *arearLabel;//号码归属地

@property (weak, nonatomic) IBOutlet UIBarButtonItem *callOutBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *contactsInfoBtn;

- (IBAction)callOutBtn:(UIBarButtonItem *)sender;

@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *resultArray;

@end

@implementation MsgDetailController
@synthesize datailDatas;


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.detailArray = [[DBHelper sharedDBHelper] getAConversation:self.datailDatas.hisNumber];
    
    VCLog(@"self.detailArray %@",self.detailArray);
    [self getResouce];
    [self jumpToLastRow];
    [self.tableview reloadData];
    [self initKeyBoardNotif];
    [self initInputView];
    
    [self cancelCheckCell];
    //编辑时显示
    editView =[[EditView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 50)];
    editView.backgroundColor = [UIColor whiteColor];
    editView.delegate  =self;
    [self.view addSubview:editView];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    textInput.text = [userDefaults valueForKey:[self.datailDatas.hisNumber purifyString]];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
}
#pragma mark - 键盘action
-(void)initKeyBoardNotif{
    //键盘显示消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotif:) name:UIKeyboardWillShowNotification object:nil];
    //键盘隐藏消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillHiddenNotif:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)keyboardWillShowNotif:(NSNotification*)notif{
    /*
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    //获取键盘高度
    NSValue *keyboardObject = [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [keyboardObject getValue:&keyboardRect];
    */
    CGRect keyboardBounds;
    [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    CGRect rect = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect containerFrame = contentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        contentView.frame = containerFrame;
        self.tableview.frame = CGRectMake(0,0 , DEVICE_WIDTH, DEVICE_HEIGHT-rect.size.height);//-rect.size.height
        [self jumpToLastRow];

    }];

}


//键盘隐藏
-(void)keyboardwillHiddenNotif:(NSNotification*)notif{
    
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect containerFrame = contentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        contentView.frame = containerFrame;
        self.tableview.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        [self jumpToLastRow];
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.detailArray = [[NSMutableArray alloc] init];
    selectArray = [[NSMutableArray alloc] init];
    selectDict = [[NSMutableDictionary alloc] init];
    mutData = [[NSMutableData alloc] init];
    mutDataArray = [[NSMutableArray alloc] init];
    VCLog(@"datailDatas:%@",self.datailDatas);
    
    // 显示左边按钮
    UIView *view = [[UIView alloc] init];
    view.userInteractionEnabled = YES;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(-20, -18, 150, 20)];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    if (self.datailDatas.hisName.length>0) {
        self.nameLabel.text = self.datailDatas.hisName;
    }
    //self.nameLabel.text = @"这里是名字";
    self.nameLabel.textColor = LightColor;
    
    self.arearLabel = [[UILabel alloc] initWithFrame:CGRectMake(-20, -2, 230, 20)];
    self.arearLabel.font =[UIFont systemFontOfSize:14];
    [self setArearLabelTitle];
    self.arearLabel.textColor = LightColor;
    
    [self.callOutBtn setImage:[UIImage imageNamed:@"actionbar_call_hub32"]];
    
    
    //注册手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(initMsgSwipeRecognizer:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.tableview addGestureRecognizer:swipe];
    [self.view addGestureRecognizer:swipe];
    
    [view addSubview:self.nameLabel];
    [view addSubview:self.arearLabel];
    self.navigationItem.leftItemsSupplementBackButton = YES;//显示返回按钮
    
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
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, DEVICE_WIDTH, 40)];
    contentView.backgroundColor=[UIColor grayColor];
    
    textInput = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, DEVICE_WIDTH-75, 40)];
    textInput.isScrollable = NO;
    textInput.layer.cornerRadius = 5;
    textInput.layer.borderWidth = .5;
    textInput.layer.borderColor =[UIColor blackColor].CGColor;
    textInput.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textInput.minNumberOfLines = 1;
    textInput.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textInput.returnKeyType = UIReturnKeyGo; //just as an example
    textInput.font = [UIFont systemFontOfSize:15.0f];
    textInput.delegate = self;
    textInput.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textInput.backgroundColor = [UIColor whiteColor];
    textInput.placeholder = @"信息";
    
    [self.view addSubview:contentView];
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    imageView.backgroundColor =[UIColor groupTableViewBackgroundColor];
    
    textInput.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [contentView addSubview:imageView];
    [contentView addSubview:textInput];
        
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(contentView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn setTitle:@"发送" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(sendButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:doneBtn];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
}

#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = contentView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    contentView.frame = r;
}

-(void)sendButtonClicks:(UIButton *)btn{
    bManager = [BLEmanager sharedInstance];
    bManager.managerDelegate = self;
    [self sendData:btn];
    
}
-(void)sendData:(UIButton *)button{
    
    
    if (textInput.text.length>0) {
        
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        NSDate *date = [NSDate date];
        fmt.dateFormat = yyyy_M_d_HH_mm;
        NSString *time = [fmt stringFromDate:date];
        [self addMessageWithContent:textInput.text time:time];
        
        //关闭键盘
        //[textInput resignFirstResponder];
        
        //保存到数据库
        DBDatas *txdata =  [[DBDatas alloc] init];
        txdata.msgHisNum = self.datailDatas.hisNumber;//
        txdata.msgTime = time;
        txdata.msgContent = textInput.text;
        txdata.msgState = @"0";//@"0"
        txdata.contactID = self.datailDatas.contactID;
        
        textInput.text = nil;
        
        [self jumpToLastRow];
        [self.tableview reloadData];
        //[SVProgressHUD showImage:nil status:@"click"];
        
        //同时需要发送给设备
        Messages *msgs = [[Messages alloc] init];
        msgs.number = [self.nameLabel.text purifyString];
        msgs.content = textInput.text;
        [[BLEHelper shareHelper] requestTransmit:msgs withBLE:bManager];
        [[DBHelper sharedDBHelper] addDatasToMsgRecord:txdata];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // something
                self.detailArray =[[DBHelper sharedDBHelper] getAConversation:self.datailDatas.hisNumber];
        });
        
    
    }

    
    
    //发送失败
    //[userDefaults setValue:textInput.text forKey:[self.datailDatas.hisName purifyString]];
}

-(void)initMsgSwipeRecognizer:(UISwipeGestureRecognizer*)swipe{
    [textInput resignFirstResponder];
}

#pragma mark -- BLEManager delegate
-(void)managerConnectedPeripheral:(CBPeripheral *)peripheral connect:(BOOL)isConnect;{}

/**
 *  是否断线重连
 *  @param peripheral 当前外设
 *  @return YES是, NO否
 */
-(BOOL)managerDisConnectedPeripheral :(CBPeripheral *)peripheral;{return NO;}

/**
 *  返回蓝牙接收到的值
 *  @param data              data
 *  @param hexString         16进制string
 *  @param curCharacteristic 当前特征
 */
-(void)managerReceiveDataPeripheralData:(NSData *)data toHexString:(NSString *)hexString fromCharacteristic:(CBCharacteristic *)curCharacteristic;{
    //接收到数据之后
    [self reciveActionWithData:data];
}


-(void)reciveActionWithData:(NSData *)data{
    Byte *byte = (Byte *)[data bytes];
    //是否接收透传,取前5位判断
    if ([[BLEHelper shareHelper] willAccept:data by:0x5B]) {//对方接受
        //发送数据
        Messages *msgs = [[Messages alloc] init];
        msgs.number = [self.nameLabel.text purifyString];
        msgs.content = textInput.text;
        [[BLEHelper shareHelper] sendDataWithMessage:msgs withBLE:bManager];
        return;
    }else if ([[BLEHelper shareHelper] willAccept:data by:0x5A]){//己方接收对方的透传
        [bManager writeDatas:[[BLEHelper shareHelper] confirmHisTouchuan:byte[3] ]];
        return;
    }else{//接收到的短包<5a1900[0,0xEF]类型...>
        [[BLEHelper shareHelper] didHappendActionWithData:data];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"string:%@",string);
    }
    
    //如果是5a05...,那么接受所有数据到Array
    if ([self isByte:data]) {
        if (byte[2] <= 0x01) {//第一个子包
            NSLog(@"receive:%@",data);
        }else{//第二个子包开始，添加到数组
            NSData *tempData = [data subdataWithRange:NSMakeRange(3, data.length-3)];
            if (![mutDataArray containsObject:tempData]) {//不存在则添加
                [mutDataArray addObject:tempData];
            }
            if (byte[2] == 0xFF || byte[2] == 0xEF) {
                for (NSData *dt in mutDataArray) {
                    [mutData appendData:dt];
                }
                NSLog(@"mutData:%@",mutData);
                NSLog(@"dataStr:%@",[[NSString alloc] initWithData:mutData encoding:NSUTF8StringEncoding]);
                [mutDataArray removeAllObjects];
                
            }
        }
    }
    
    //
    
    
}

-(BOOL)isByte:(NSData *)d{
    Byte *byte = (Byte *)[d bytes];
    
    if (byte[0] == 0x5a && byte[1] == 0x05) {
        
        return YES;
    }
    
    
    return NO;
}

/**
 *  扫描到的所有外设并返回当前连接的哪一个
 *  @param pArray 所有外设
 *
 */
-(void)searchedPeripheral:(NSMutableArray *)peripArray;{}

-(void)systemBLEState:(CBCentralManagerState)state{}
-(void)showAlertView{}


#pragma  mark --EditViewDelegate
-(void)buttonClickAndChanged:(UIButton *)button
{
    if (button.tag == 2000) {//拷贝
        NSIndexPath *path = [self.tableview indexPathForSelectedRow];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [self.detailArray[path.row] msgContent];
        VCLog(@"copys:pasteboard.string%@",pasteboard.string);
        [SVProgressHUD showSuccessWithStatus:@"已复制"];
        [self cancelCheckCell];
        //[self.tableview setEditing:NO animated:YES];
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
    
    NSIndexPath *path = [self.tableview indexPathForSelectedRow];
    //跳转到newMsg
    NewMsgController *newMsgVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"newMsgID"];
    
    newMsgVC.msgContent = [[self.detailArray objectAtIndex:path.row] msgContent];
    UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:newMsgVC];
        
    [self presentViewController:nav animated:YES completion:^{VCLog(@"share");}];
    
}

//删除所选
-(void)deleteButtonClick:(UIButton *)button
{
    //删除选中的条目
    //数据库
    for (NSIndexPath *index in selectArray) {
        //NSString *number =[NSString stringWithFormat:@"%@",[self.detailArray[index.row] msgHisNum]];
        int peopleId = [self.detailArray[index.row] peopleId];
        
        [[DBHelper sharedDBHelper] deleteAMsgRecord:peopleId];
        
    }
    
    //重新获取数据
    self.detailArray =[[DBHelper sharedDBHelper] getAConversation:self.datailDatas.hisNumber];
    
    VCLog(@"self.detailArray:%@ ",self.detailArray);
    
    //[self.detailArray removeObjectsInArray:[selectDict allValues]];
    VCLog(@"allKeys:%@",[selectDict allKeys]);
    
    
    [self getResouce];
    [self cancelCheckCell];
}

#pragma mark -- TableView select Rows
//
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //移除再次选中的
    if ([self.callOutBtn.title isEqualToString:@"取消"]) {
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
    if ([self.callOutBtn.title isEqualToString:@"取消"]) {
        VCLog(@"self.detailArray:%@",self.detailArray);
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
    
    for (DBDatas *data in self.detailArray) {
        
        MsgFrame *messageFrame = [[MsgFrame alloc] init];
        Message *message = [[Message alloc] init];
        message.data = data;
        messageFrame.showTime = 1;//![previousTime isEqualToString:message.time];
        messageFrame.message = message;
        previousTime = message.time;
       
        [self.allMsgFrame addObject:messageFrame];
        
    }
    
    [self.tableview reloadData];
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

//取消选中cell
-(void)cancelCheckCell
{
    [self.tableview setEditing:NO animated:YES];
    [selectArray removeAllObjects];
    [self setArearLabelTitle];
    [UIView animateWithDuration:.25 animations:^{
        editView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 50);
    }];
    
    [self.callOutBtn setImage:[UIImage imageNamed:@"actionbar_call_hub32"]];
    //[self.callOutBtn setEnabled:YES];
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
/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
}
 */
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
    if (self.detailArray.count>0) {
        //滚动到当前信息
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.detailArray.count-1 inSection:0];
        [self.tableview scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }else{
        return;
    }
    
}



-(void)longPressAction:(UIGestureRecognizer *)recongizer
{
    [textInput resignFirstResponder];
    if (recongizer.state == UIGestureRecognizerStateBegan) {
        VCLog(@"longPress");
        //
        [self.tableview setEditing:YES animated:YES];
        [UIView animateWithDuration:.25 animations:^{
            editView.frame = CGRectMake(0, DEVICE_HEIGHT-50, DEVICE_WIDTH, 50);
        }];
        
        [self.callOutBtn setImage:[UIImage imageNamed:@""]];
        [self.callOutBtn setTitle:@"取消"];

    }
    //[self getResouce];
    
    
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
    
    if ([self.callOutBtn.title isEqualToString:@"取消"]) {
        [self cancelCheckCell];
    }else{
        if (self.datailDatas.hisName.length <=0) {
            self.datailDatas.hisName = @"";
        }
        
        
        
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.datailDatas.hisName,@"hisName",self.datailDatas.hisNumber,@"hisNumber",self.datailDatas.contactID,@"hisContactId", nil];
        
        VCLog(@"dict:%@",dict);
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCallingBtnClick object:self userInfo:dict]];

    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (textInput.text.length > 0) {
        [userDefaults setValue:textInput.text forKey:[self.datailDatas.hisNumber purifyString]];
    }
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
