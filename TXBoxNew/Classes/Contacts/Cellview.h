//
//  Cellview.h
//  TXBoxNew
//
//  Created by Naron on 15/8/27.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellViewDelegate <NSObject>

-(void)cellviewActions:(UIButton *)btn;

@end
@interface Cellview : UIView

@property (assign,nonatomic) id<CellViewDelegate> delegate;

@end
