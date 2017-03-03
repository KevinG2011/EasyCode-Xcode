//
//  EShortcutEntry.h
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EShortcutEntry : NSObject<NSCoding,NSCopying>
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSString* code;
+(instancetype)entryWithKey:(NSString*)key code:(NSString*)code;
@end
