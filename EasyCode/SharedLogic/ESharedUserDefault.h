//
//  ESharedUserDefault.h
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _UD [ESharedUserDefault sharedInstance]

#define KeyCodeShortcutForObjectiveC    @"KeyCodeShortcutForObjectiveC"
#define KeyCodeShortcutForSwift         @"KeyCodeShortcutForSwift"
#define KeyUseiCloudSync                @"KeyUseiCloudSync"

@interface ESharedUserDefault : NSObject

+ (instancetype)sharedInstance;
- (void)setBool:(BOOL)value forKey:(NSString*)defaultName;
- (BOOL)boolForKey:(NSString*)defaultName;

- (NSDictionary*)readMappingForOC;
- (void)saveMappingForOC:(NSDictionary*)mapping;

- (NSDictionary*)readMappingForSwift;
- (void)saveMappingForSwift:(NSDictionary*)mapping;

- (void)clearMapping;


@end
