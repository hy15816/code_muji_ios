//
//  TXKeyView.m
//  TXBox
//
//  Created by william on 15/1/3.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXKeyView.h"
#import "TXTelNumSingleton.h"


@interface TXKeyView()<UITextFieldDelegate>
{

    TXTelNumSingleton *singleton;
    UITextField *textFieldh;
    UIView *hudv;
}
@end
@implementation TXKeyView

-(void) drawRect:(CGRect)rect
{
    //self.backgroundColor = RGBACOLOR(201, 201, 201, 1);//键盘背景色
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *line =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, .1)];
    line.backgroundColor=[UIColor blackColor];
    line.alpha=.5;
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
        NSString *sicon = [[NSString alloc] initWithFormat:@"dial_num_%d.png",i+1];//dial_num_9selected
        
        int y = i/3;
        int x = i%3;

        //VCLog(@"w:%f,h:%f",keyWidth,keyHeight);
        [self addKeyWithIcon:icon selectedIcon:sicon rectbg:CGRectMake(x*keyWidth, y*keyHeight+InputBoxViewHeight,keyWidth , keyHeight) tag:i];
        
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
    
    UIImageView *imgv =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    imgv.backgroundColor =[UIColor grayColor];
    
    
    // 图标
    [itembg setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [itembg setImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];
    
    // 监听item的点击
    [itembg addTarget:self action:@selector(itemClickChangeView:) forControlEvents:UIControlEventTouchDown];
    [itembg addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    [itembg addTarget:self action:@selector(itemClickChangecanel:) forControlEvents:UIControlEventTouchDragExit];
    if (itembg.tag ==11) {
        [itembg addGestureRecognizer:longPress];
    }
    // 2.添加item
    [self addSubview:itembg];

}

#pragma mark --添加输入框
-(void)addInputBox{

    //输入框
    textFieldh = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, DEVICE_WIDTH*.8f, 44)];
    textFieldh.textAlignment = NSTextAlignmentCenter;
    textFieldh.font = [UIFont systemFontOfSize:17];
    textFieldh.placeholder = @"输入数字或拼音模糊搜索";
    textFieldh.contentMode = UIViewContentModeCenter;
    textFieldh.delegate = self;
    [textFieldh resignFirstResponder];
    //[self layoutSubviews];
    
    [self addSubview:textFieldh];
    
    //删除（退格）按钮
    UIButton *delBtn = [[UIButton alloc] init];
    delBtn.frame = CGRectMake(DEVICE_WIDTH-80, 5, 46, 44);
    [delBtn setImage:[UIImage imageNamed:@"com_Keyboard_Backspace"] forState:UIControlStateNormal];

    [delBtn addTarget:self action:@selector(del:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dleLongPressKey:)];
    
    longPress.minimumPressDuration = 1;
    [delBtn addGestureRecognizer:longPress];
    [self addSubview:delBtn];

    singleton = [TXTelNumSingleton sharedInstance];
   
}


#pragma mark 删除号码
-(void)del:(UIButton *)delBtnn
{
    //防止按钮快速点击造成多次响应
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(todoSomething:) object:delBtnn];
    [self performSelector:@selector(todoSomething:) withObject:delBtnn afterDelay:0.05f];
    
}

-(void)todoSomething:(UIButton *)btn{
    if (textFieldh.text.length>0){
        NSString *allText = [textFieldh.text substringToIndex:textFieldh.text.length-1];//删除之后的
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              allText,InputFieldAllText,
                              @"0",AddOrDelete, nil];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kInputCharNoti object:self userInfo:dict]];
        textFieldh.text = [textFieldh.text substringToIndex:textFieldh.text.length-1];
        singleton.singletonValue = textFieldh.text;
    }
    if (textFieldh.text.length <=0) {
        textFieldh.font = [UIFont systemFontOfSize:17];
        
    }
    textFieldh.placeholder = @"";
    [self.keyDelegate inputTextLength:textFieldh.text];
}

#pragma mark 监听item点击
//touch up inside
- (void)itemClick:(UIButton *)item
{
    
        NSString *text = textFieldh.text;
    NSInteger tag = item.tag;
    //
    switch (tag) {
        case 10:
            textFieldh.text = [NSString stringWithFormat:@"%@*",text];
            break;
        case 11:
            textFieldh.text = [NSString stringWithFormat:@"%@0",text];
            break;
        case 12:
            textFieldh.text = [NSString stringWithFormat:@"%@#",text];
            break;
        default:
            textFieldh.text = [NSString stringWithFormat:@"%@%ld",text,tag];
            
            break;
    }

    //利用单利保存呼叫的号码
    singleton.singletonValue = textFieldh.text;
    if (hudv) {
        [hudv removeFromSuperview];
    }

    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          textFieldh.text , InputFieldAllText,
                          @"1",           AddOrDelete,nil];
    //2.通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kInputCharNoti object:self userInfo:dict]];
    
    
    
    if (textFieldh.text.length>=1) {
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:ktextChangeNotify object:self]];
        
        textFieldh.font = [UIFont systemFontOfSize:22];
        textFieldh.placeholder = @"";
    }
    
    

    
}

//touch down
-(void)itemClickChangeView:(UIButton *)button{
    if (!hudv) {
        hudv = [[UIView alloc] initWithFrame:CGRectMake(1, 1, button.frame.size.width-2, button.frame.size.height-2)];
        hudv.backgroundColor =[UIColor grayColor];
        hudv.alpha = .4;
    }
    hudv.layer.cornerRadius = 3;
    
    [button addSubview:hudv];
    
}

-(void)removeHudv{
    if (hudv) {
        [hudv removeFromSuperview];
    }
    
}

-(void)itemClickChangecanel:(UIButton *)b{
    
    if (hudv) {
        [hudv removeFromSuperview];
    }

    
    
}



#pragma mark -- longPress
-(void)longPressKey:(UILongPressGestureRecognizer*)longPress{
    
    NSString *text = textFieldh.text;
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        textFieldh.text = [NSString stringWithFormat:@"%@+",text];
        if (hudv) {
            [hudv removeFromSuperview];
        }
        
    }
    
}

-(void)dleLongPressKey:(UILongPressGestureRecognizer*)longPress{
    
    //NSString *text = self.textsearch.text;
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        textFieldh.text = nil;
    }
    if (longPress.state == UIGestureRecognizerStateEnded) {
        
        if (hudv) {
            [hudv removeFromSuperview];
        }
        textFieldh.font = [UIFont systemFontOfSize:17];
    }
}

#pragma mark -- textField delegate
//取消系统键盘弹出
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}




@end
