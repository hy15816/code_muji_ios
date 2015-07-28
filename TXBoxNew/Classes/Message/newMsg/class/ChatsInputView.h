//
//  ChatsInputView.h
//  GrowingTextViewExample
//
//  Created by Naron on 15/7/28.
//
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@protocol ChatsInputViewDelegate <NSObject>

-(void)changs;

@end
@interface ChatsInputView : UIView<HPGrowingTextViewDelegate>
{
    HPGrowingTextView *textView;
    UIView *containerView;
}
@property (strong,nonatomic) HPGrowingTextView *textView;
@property (assign,nonatomic) id<ChatsInputViewDelegate> delegate;

@end
