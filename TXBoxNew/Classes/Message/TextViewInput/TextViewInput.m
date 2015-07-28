//
//  TextViewInput.m
//  BLETest
//
//  Created by Naron on 15/7/8.
//  Copyright (c) 2015年 playtime. All rights reserved.
//
#define DEVICE_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define DEVICE_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#import "TextViewInput.h"

@interface TextViewInput ()
@property (strong,nonatomic) UIImageView *imgbgView;
@property (strong,nonatomic) UIButton *rightButton;
@end

@implementation TextViewInput
@synthesize maxHeight,rigBtnTitle;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createTextView:frame];
        [self createRightButton:frame];
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    
    self.backgroundColor = [UIColor clearColor];
    UILabel *la=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, .5)];
    la.alpha = .5;
    la.backgroundColor =[UIColor blackColor];
    [self addSubview:la];
    /*
    _imgbgView = [[UIImageView alloc] initWithFrame:rect];
    _imgbgView.userInteractionEnabled = YES;
    _imgbgView.backgroundColor = [UIColor clearColor];
    _imgbgView.image = [UIImage imageNamed:_bgvName];
    [self addSubview:_imgbgView];
    */
    
    
}
-(void)createRightButton:(CGRect)rect{
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(DEVICE_WIDTH-60, rect.size.height/2-25/2, 50, 25);
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _rightButton.layer.borderWidth = .5;
    _rightButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _rightButton.layer.cornerRadius = 5;
    [_rightButton setTitle:rigBtnTitle forState:UIControlStateNormal];
    //rigBtn.backgroundColor =[UIColor greenColor];
    [_rightButton addTarget:self action:@selector(rigBtnTitleClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightButton];
}
-(void)rigBtnTitleClick:(UIButton *)button{
    
    [self.inputDelegate rightButtonClick:button];
}
-(void)createTextView:(CGRect)rect{
    
    _textview =[[UITextView alloc] initWithFrame:CGRectMake(5, 5, DEVICE_WIDTH-70, rect.size.height-10)];
    _textview.textAlignment = NSTextAlignmentLeft;
    _textview.contentMode = UIViewContentModeTopLeft;
    _textview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _textview.delegate = self;
    _textview.font = [UIFont systemFontOfSize:16];
    _textview.layer.borderWidth = .5;
    _textview.layer.borderColor = [UIColor blackColor].CGColor;
    _textview.layer.cornerRadius = 3;
    _textview.scrollEnabled = YES;
    _textview.contentInset = UIEdgeInsetsMake(0 , 5,0, 5);
    _textview.returnKeyType = UIReturnKeyDefault;
    _textview.keyboardType = UIKeyboardTypeDefault;
    _textview.editable = YES;
    _textview.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    _textview.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    [self addSubview:_textview];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    CGSize size = [_textview.text boundingRectWithSize:CGSizeMake(self.frame.size.width, maxHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_textview.font} context:nil ].size;
    NSLog(@"size.height:%f",size.height);
    _rightButton.frame = CGRectMake(DEVICE_WIDTH-60, self.frame.size.height/2-25/2, 50, 25);
    //_textview.frame = CGRectMake(0, DEVICE_HEIGHT-252- size.height, self.frame.size.width, size.height+15);
    //_imgbgView.frame = CGRectMake(0, DEVICE_HEIGHT-252- size.height-10, DEVICE_WIDTH, size.height+15+10);
    
    CGFloat keyboradHieght =  [self.inputDelegate getKeyBoradHeight];
    if (textView.text.length >=3) {
        [self.inputDelegate changedFrame:CGRectMake(0, DEVICE_HEIGHT-keyboradHieght- (size.height+15), self.frame.size.width, size.height+15)];
    }
    
    
    
    
    return YES;
    
}

-(void)resignFirstResponders{
    
    [_textview resignFirstResponder];
}


@end
