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

#define KeySharedContainerGroup         @"3KAP4AA829.group.com.yingxiang.easycode"
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
    NSString* UIVersion = [_sharedUD objectForKey:KeyCurrentUDVersion];
    if (UIVersion == nil) {
        [_sharedUD setObject:ValueCurrentUDVersion forKey:KeyCurrentUDVersion];
    }
}

+ (void)setBool:(BOOL)value forKey:(NSString*)key
{
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    [shareUD setBool:value forKey:key];
    [shareUD synchronize];
}

+ (BOOL)boolForKey:(NSString*)key
{
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    return [shareUD boolForKey:key];
}

+ (void)setObject:(NSObject*)value forKey:(NSString*)key
{
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    [shareUD setObject:value forKey:key];
    [shareUD synchronize];
}

+ (id)objectForKey:(NSString*)key
{
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    return [shareUD objectForKey:key];
}

+ (void)setObjects:(NSArray*)values forKeys:(NSArray*)keys
{
    if (keys.count != values.count) {
        return;
    }
    
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    [keys enumerateObjectsUsingBlock:^(NSString*  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        [shareUD setObject:values[idx] forKey:key];
    }];
    BOOL success = [shareUD synchronize];
    if (!success) {
        NSLog(@"synchronize error");
    }
}
@end
