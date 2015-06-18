//
//  BLEPeripheral.m
//  TXBoxNew
//
//  Created by Naron on 15/6/18.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "BLEPeripheral.h"

@implementation BLEPeripheral
@synthesize peripDelegate;
-(id)init
{
    if ((self = [super init])) {
        self.periIdentifier = @"";
        self.periLocaName   = @"";
        self.periName       = @"";
        self.periRSSI       = 0;
        self.periServices   = 0;
    }
    
    return self;
}
@end
