//
//  ESharedUserDefault.h
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESharedUserDefault : NSObject
+ (void)setBool:(BOOL)value forKey:(NSString*)key;
+ (BOOL)boolForKey:(NSString*)key;

+ (void)setObject:(NSObject*)value forKey:(NSString*)key;
+ (id)objectForKey:(NSString*)key;

+ (void)setObjects:(NSArray*)values forKeys:(NSArray*)keys;
@end
