//
//  ESharedUserDefault.h
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESharedUserDefault : NSObject
+ (void)setBool:(BOOL)value forKey:(NSString*)defaultName;
+ (BOOL)boolForKey:(NSString*)defaultName;

+ (void)setObject:(NSObject*)value forKey:(NSString*)defaultName;
+ (id)objectForKey:(NSString*)defaultName;

+ (void)setObjects:(NSArray*)values forKey:(NSArray*)defaultNames;
@end
