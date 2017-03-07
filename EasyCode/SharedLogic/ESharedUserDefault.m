//
//  ESharedUserDefault.m
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import "ESharedUserDefault.h"
#import "ECMappingForObjectiveC.h"
#import "ECMappingForSwift.h"

#define KeySharedContainerGroup         @"2WQE6AU5PD.group.com.yingxiang.easycode"

#define KeyCurrentUDVersion             @"KeyCurrentUDVersion"
#define ValueCurrentUDVersion           @"1"

@interface ESharedUserDefault ()
@property (nonatomic, strong) NSUserDefaults*                   sharedUD;
@end

@implementation ESharedUserDefault

+ (instancetype)sharedInstance
{
    static ESharedUserDefault* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ESharedUserDefault new];
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSharedUD];
    }
    return self;
}

- (void)initSharedUD
{
    self.sharedUD = [[NSUserDefaults alloc] initWithSuiteName:KeySharedContainerGroup];
    if ([_sharedUD objectForKey:KeyCurrentUDVersion] == nil) {
        [_sharedUD setObject:ValueCurrentUDVersion forKey:KeyCurrentUDVersion];
    }
}

- (void)setBool:(BOOL)value forKey:(NSString*)defaultName
{
    [_sharedUD setBool:value forKey:defaultName];
    [_sharedUD synchronize];
}

- (BOOL)boolForKey:(NSString*)defaultName
{
    return [_sharedUD boolForKey:defaultName];
}

@end
