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
    if ([_sharedUD objectForKey:KeyCurrentUDVersion] == nil) {
        [_sharedUD setObject:ValueCurrentUDVersion forKey:KeyCurrentUDVersion];
    }
}

+ (void)setBool:(BOOL)value forKey:(NSString*)defaultName
{
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    [shareUD setBool:value forKey:defaultName];
    [shareUD synchronize];
}

+ (BOOL)boolForKey:(NSString*)defaultName
{
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    return [shareUD boolForKey:defaultName];
}

+ (void)setObject:(NSObject*)value forKey:(NSString*)defaultName
{
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    [shareUD setObject:value forKey:defaultName];
    [shareUD synchronize];
}

+ (id)objectForKey:(NSString*)defaultName
{
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    return [shareUD objectForKey:defaultName];
}

+ (void)setObjects:(NSArray*)values forKey:(NSArray*)defaultNames
{
    if (defaultNames.count != values.count) {
        return;
    }
    
    NSUserDefaults* shareUD = [[ESharedUserDefault sharedInstance] sharedUD];
    [defaultNames enumerateObjectsUsingBlock:^(NSString*  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        [shareUD setObject:values[idx] forKey:key];
    }];
    [shareUD synchronize];
}
@end
