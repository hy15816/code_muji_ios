//
//  TXKeyView.m
//  TXBox
//
//  Created by william on 15/1/3.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXKeyView.h"
#import "TXTelNumSingleton.h"


@interface TXKeyView()<UISearchBarDelegate>
{

    TXTelNumSingleton *singleton;
}
@end
@implementation TXKeyView
@synthesize textsearch;

-(void) drawRect:(CGRect)rect
{
    //self.backgroundColor = RGBACOLOR(201, 201, 201, 1);//键盘背景色
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *line =[[UILabel alloc] initWithFrame:CGRectMake(0, 50, rect.size.width, .1)];
    line.backgroundColor=[UIColor blackColor];
//    line.alpha=.8;
    [self addSubview:line];
    
    [self drawKeyBorad];
    [self addInputBox];
    
    //1.创建一个通知对象
    
    
    [self endEditing:YES];
    
    
}


#pragma mark --添加键盘按键
-(void) drawKeyBorad {

    
    
    for (int i=0; i<=11; i++) {
        
        NSString *icon = [[NSString alloc] initWithFormat:@"dial_num_%d.png",i+1];
        NSString *sicon = [[NSString alloc] initWithFormat:@"dial_num_%dselected.png",i+1];//dial_num_9selected
        
        int y = i/3;
        int x = i%3;
        //VCLog(@"%D",x);
        [self addKeyWithIcon:icon selectedIcon:sicon rectbg:CGRectMake(x*keyWidth, y*keyHeight+InputBoxView,keyWidth , keyHeight) tag:i];
        
    }

    
}

//设置按钮图片，frame，tag值
- (void)addKeyWithIcon:(NSString *)icon selectedIcon:(NSString *)selected rectbg:(CGRect)rectbg tag:(NSInteger )tag
{
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressKey:)];
    //longPress.numberOfTouchesRequired
    longPress.minimumPressDuration = 1;
    
    // 1.创建item
    UIButton *itembg = [[UIButton alloc] init];
    
    itembg.tag = tag+1;
    // 位置
    itembg.frame = rectbg;
    // 图标
    [itembg setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [itembg setImage:[UIImage imageNamed:selected] forState:UIControlStateHighlighted];
    
    // 监听item的点击
    [itembg addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    if (itembg.tag ==11) {
        [itembg addGestureRecognizer:longPress];
    }
    // 2.添加item
    [self addSubview:itembg];

}

#pragma mark --添加输入框
-(void)addInputBox{

    //输入框
    self.textsearch=[[UISearchBar alloc]init];
    self.textsearch.contentMode = UIViewContentModeCenter;
    self.textsearch.frame=CGRectMake(5, 5, DEVICE_WIDTH*.8, 44);
    [self.textsearch setPlaceholder:@"输入数字或拼音模糊搜索"];//NSLocalizedString(@"Please_enter_number_or_letter_of_fuzzy_search", nil)
    
    self.textsearch.returnKeyType = UIReturnKeyDefault;
    [textsearch resignFirstResponder];
    [self layoutSubviews];
    self.textsearch.delegate = self;
    
    [self addSubview:self.textsearch];
    
    
    //删除（退格）按钮
    UIButton *delBtn = [[UIButton alloc] init];
    delBtn.frame = CGRectMake(DEVICE_WIDTH-80, 5, 46, 44);
    [delBtn setImage:[UIImage imageNamed:@"com_Keyboard_Backspace"] forState:UIControlStateNormal];
    //[delBtn setImage:[UIImage imageNamed:@"com_Keyboard_Backspace"] forState:UIControlStateSelected];
        [delBtn addTarget:self action:@selector(del) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:delBtn];

    singleton = [TXTelNumSingleton sharedInstance];
   
}

#pragma mark 对searchbar的修改
-(void)layoutSubviews
{
    for(id aa in [self.textsearch subviews])
    {
        for (id bb in  [aa subviews]) {
            
            if([bb isKindOfClass:[UITextField class]])
            {
                UITextField *textField2 = (UITextField *)bb;
                //textField2.clipsToBounds = NO;
                //去掉放大镜
                textField2.leftView = nil;
                textField2.clearButtonMode  = UITextFieldViewModeNever;
                textField2.textAlignment = NSTextAlignmentCenter;
                textField2.font = [UIFont systemFontOfSize:16];
                break;
            }
            //去掉背景
            if ([bb isKindOfClass:NSClassFromString(@"UISearchBarBackground") ]) {
                [bb removeFromSuperview];
                break;
            }
 
        }
 
    }
    
    [super layoutSubviews];
    
}


#pragma mark 删除号码
-(void)del
{
    
    if (self.textsearch.text.length>0){
        
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[self.textsearch.text substringToIndex:self.textsearch.text.length-1],@"searchBarText",[self.textsearch.text substringWithRange:NSMakeRange(self.textsearch.text.length-1, 1)],@"lastChar", nil];
        
        //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[self.textsearch.text substringWithRange:NSMakeRange(self.textsearch.text.length-1, 1)],@"lastChar", nil];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDeleteCharNoti object:self userInfo:dict]];
        
        self.textsearch.text = [self.textsearch.text stringByReplacingCharactersInRange:NSMakeRange(textsearch.text.length-1, 1) withString:@""];
        singleton.singletonValue = self.textsearch.text;
    }
    
    [self.keyDelegate inputTextLength:self.textsearch.text];
    
}
#pragma mark 监听item点击
- (void)itemClick:(UIButton *)item
{

    NSString *text = self.textsearch.text;
    NSInteger tag = item.tag;
    //
    switch (tag) {
        case 10:
            self.textsearch.text = [NSString stringWithFormat:@"%@*",text];
            break;
        case 11:
            self.textsearch.text = [NSString stringWithFormat:@"%@0",text];
            break;
        case 12:
            self.textsearch.text = [NSString stringWithFormat:@"%@#",text];
            break;
        default:
            self.textsearch.text = [NSString stringWithFormat:@"%@%ld",text,tag];
            
            break;
    }

    //利用单利保存呼叫的号码
    singleton.singletonValue = self.textsearch.text;
    //VCLog(@"singletonValue: %@",singleton.singletonValue);

    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.textsearch.text ,@"searchBarText", nil];
    //2.通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kInputCharNoti object:self userInfo:dict]];
    if (self.textsearch.text.length>=1) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:ktextChangeNotify object:self]];
    }
    
}
-(void)longPressKey:(UITapGestureRecognizer*)tap{
    
    NSString *text = self.textsearch.text;
    self.textsearch.text = [NSString stringWithFormat:@"%@+",text];
    
    
}

//取消系统键盘弹出
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return NO;
}


@end
