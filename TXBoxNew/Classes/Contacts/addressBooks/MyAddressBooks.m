//
//  MyAddressBooks.m
//  BLETest
//
//  Created by Naron on 15/7/29.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "MyAddressBooks.h"
#import "pinyin.h"

@interface MyAddressBooks ()
{BOOL isfinished;
}
@property (strong,nonatomic) NSMutableArray *AllPeopleRefArray;
@property (strong,nonatomic) NSMutableArray *conBooksArr;
@property (strong,nonatomic) NSMutableDictionary *sectionDict;
@property (strong,nonatomic) NSMutableArray *conBookArray;
@property (strong,nonatomic) NSMutableArray *sectionArray;
@property (strong,nonatomic) NSArray *sortArray;
@end

@implementation MyAddressBooks
@synthesize abAddressBookRef,delegate;


static MyAddressBooks *shareBooks = nil;

-(id)init{
    self = [super init];
    if (self) {
        //
        //abAddressBookRef = nil;
        _AllPeopleRefArray = [[NSMutableArray alloc] init];
        _conBooksArr = [[NSMutableArray alloc] init];
        _sectionDict = [[NSMutableDictionary alloc] init];
        _conBookArray = [[NSMutableArray alloc] init];
        _sectionArray = [[NSMutableArray alloc] init];
        _sortArray = [[NSArray alloc] init];
        isfinished = NO;
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
                    if ([self.delegate respondsToSelector:@selector(noAuthority:)]) {
                        [self.delegate noAuthority:error];
                    }
                    
                    return ;
                }
            });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
        }
        
        //[self getAllABRecordRefs];
        
        if (ABAddressBookGetPersonCount(abAddressBookRef) == 0) {
            if ([self.delegate respondsToSelector:@selector(sendNotify:)]) {
                [self.delegate sendNotify:kMyBooksNotifityStatusNoBody];
            }
            
        }
    }else{
        //if ([self.delegate respondsToSelector:@selector(sendNotify:)]) {
            [self.delegate sendNotify:kMyBooksNotifityStatusNoAuthority];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"NotifityStatusNoAuthority" object:self];
        //}
    }
}

-(void)getAllABRecordRefs{
    
    CFErrorRef error;
    abAddressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    _AllPeopleRefArray = (__bridge NSMutableArray *)(ABAddressBookCopyArrayOfAllPeople(abAddressBookRef));
    if (abAddressBookRef && _AllPeopleRefArray) {
        /*
        if ([self.delegate respondsToSelector:@selector(abAddressBooks:allRefArray:)]) {
            [self.delegate abAddressBooks:abAddressBookRef allRefArray:_AllPeopleRefArray];
        }
        */
        [self setSectionDicts];
    }else{
        if ([self.delegate respondsToSelector:@selector(sendNotify:)]) {
            [self.delegate sendNotify:kMyBooksNotifityStatusNoBody];
        }
        
    }
    
}
-(void)refReshContacts{
    [self getAllABRecordRefs];
}
//生成分组
-(void)setSectionDicts{
    
    //设置分组的key
    for (int i = 0; i < 26; i++){
        
        [_sectionDict setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'A'+i]];
    }
    [_sectionDict setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'~']];
    
    //设置联系人属性到ConBook
    _conBookArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<_AllPeopleRefArray.count; i++) {
        ABRecordRef record = (__bridge ABRecordRef)([_AllPeopleRefArray objectAtIndex:i]);
       
         ConBook *conBook = [[ConBook alloc] init];
         //获取联系人属性
         conBook.recordID = [NSString stringWithFormat:@"%d",(int)ABRecordGetRecordID(record)];
         conBook.prefixName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonPrefixProperty));
         conBook.lastName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonLastNameProperty));
         conBook.middleName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonMiddleNameProperty));;
         conBook.firstName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonFirstNameProperty));
         conBook.suffixName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonSuffixProperty));
         //号码
         ABMultiValueRef phoneNumber = ABRecordCopyValue(record, kABPersonPhoneProperty);
         NSMutableArray *pArray = [[NSMutableArray alloc] init];
         if (ABMultiValueGetCount(phoneNumber) > 0) {//取所有号码
         for (int k=0; k<ABMultiValueGetCount(phoneNumber); k++) {
         NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumber,k));
             [pArray addObject:phone.length>0?phone:@""];
         }
         
         }
         conBook.phoneNumberArray = pArray;
         conBook.fullName = [conBook AssemblyName];
         
         //获取联系人邮箱
         ABMutableMultiValueRef emailMulti = ABRecordCopyValue(record, kABPersonEmailProperty);
         NSMutableArray *emailArr = [[NSMutableArray alloc] init];
         for (int h = 0;h < ABMultiValueGetCount(emailMulti); h++)
         {
         NSString *emailAdress = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailMulti, h);
         [emailArr addObject:emailAdress];
         }
         conBook.emailArray = emailArr;
         [_conBookArray addObject:conBook];//改8.27
    }
    
    //NSLog(@"_conBooksArr:%@",_conBooksArr);
    [self sortingRecordArray];
    
}

//对数组元素排序
-(void)sortingRecordArray{
    
    NSString *sectionName;
    for (int i=0; i<_conBookArray.count; i++) {
        
        //NSString *nameString = [[ConBook sharBook] getNameWithAbid:[_conBookArray[i] intValue]];//名字的第一个字
        NSString *nameString = [_conBookArray[i] fullName];//名字的第一个字
        char firstChar = pinyinFirstLetter([nameString characterAtIndex:0]);//名字的第一个字的字母;
        if ((firstChar >='a' && firstChar<='z')||(firstChar>='A' && firstChar<='Z')) {
            
            sectionName = [[NSString stringWithFormat:@"%c",firstChar] uppercaseString];
            
        }else {
            sectionName=[[NSString stringWithFormat:@"%c",'~'] uppercaseString];
        }
        
        //把phoneArray[i]添加到sectionDic的key中
        [[_sectionDict objectForKey:sectionName] addObject:_conBookArray[i]];
        if (![_sectionArray containsObject:sectionName]) {
            [_sectionArray addObject:sectionName];
        }
        
    }
    
    _sortArray =[_sectionArray sortedArrayUsingSelector:@selector(compare:)];//排序
    isfinished = YES;
    NSLog(@"book count%lu",(unsigned long)_conBookArray.count);
    
}

-(void)loadFinish{
    if ([self.delegate respondsToSelector:@selector(sendNotify:)]) {
        [self.delegate sendNotify:kMyBooksNotifityStatusLoading];
    }
    
    [self performSelector:@selector(todoBacks) withObject:self afterDelay:1];
    
}

-(NSArray *)getSortArray{
    if (!isfinished) {
        [self loadFinish];
        
    }
    
    return _sortArray;
}

-(NSMutableDictionary *)getSecDicts{
    
    if (!isfinished) {
        [self loadFinish];
    }
    
    return _sectionDict;
}

-(void)todoBacks{
    if (!isfinished) {
        
        [self loadFinish];
    }else{
        
        if ([self.delegate respondsToSelector:@selector(sortArray:secDic:)]) {
            [self.delegate sortArray:_sortArray secDic:_sectionDict];
        }
        isfinished = YES;
        [SVProgressHUD dismiss];
    }
}

-(void)outToTimes{
    
    isfinished = YES;
}
@end
