//
//  MyAddressBooks.m
//  BLETest
//
//  Created by Naron on 15/7/29.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "MyAddressBooks.h"

@interface MyAddressBooks ()

@property (strong,nonatomic) NSMutableArray *AllPeopleRefArray;
@end

@implementation MyAddressBooks
@synthesize abAddressBookRef,delegate;


static MyAddressBooks *shareBooks = nil;

-(id)init{
    self = [super init];
    if (self) {
        //
        abAddressBookRef = nil;
        _AllPeopleRefArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+(MyAddressBooks *)sharedAddBooks{
    
    if (shareBooks == nil) {
        shareBooks = [[super allocWithZone:nil] init];
    }
    return shareBooks;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [self sharedAddBooks];
}

- (id) copyWithZone:(NSZone *) zone
{
    return self;
}
-(void)CreateAddressBooks{
    
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authStatus == kABAuthorizationStatusAuthorized){
    
        if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
            
            dispatch_semaphore_t sema=dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(abAddressBookRef, ^(bool greanted, CFErrorRef error){
                dispatch_semaphore_signal(sema);
                if (error) {
                    [self.delegate noAuthority:error];
                    return ;
                }
            });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
        }
        
        [self getAllABRecordRefs];
        
        if (ABAddressBookGetPersonCount(abAddressBookRef) == 0) {
            [self.delegate sendNotify:kMyBooksNotifityStatusNoBody];
        }
    }else{
        [self.delegate sendNotify:kMyBooksNotifityStatusNoAuthority];
    }
}

-(void)getAllABRecordRefs{
    
    CFErrorRef error;
    abAddressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    _AllPeopleRefArray = (__bridge NSMutableArray *)(ABAddressBookCopyArrayOfAllPeople(abAddressBookRef));
    if (abAddressBookRef && _AllPeopleRefArray) {
        [self.delegate abAddressBooks:abAddressBookRef allRefArray:_AllPeopleRefArray];
    }else{
        [self.delegate sendNotify:kMyBooksNotifityStatusNoBody];
    }
    
}
-(void)refReshContacts{
    [self getAllABRecordRefs];
}

@end
