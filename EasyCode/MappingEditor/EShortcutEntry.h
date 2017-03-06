//
//  EShortcutEntry.h
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EShortcutEntry : NSObject<NSCoding,NSCopying>
@property (nonatomic, copy) NSString* key;
@property (nonatomic, copy) NSString* code;
@property (nonatomic, copy) NSString* createAt;

+(instancetype)entryWithKey:(NSString*)key code:(NSString*)code;

-(void)updateBySnippet:(EShortcutEntry*)snippet;
@end
