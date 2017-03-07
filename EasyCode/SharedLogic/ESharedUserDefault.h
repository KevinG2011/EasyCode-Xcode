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

@interface ESharedUserDefault : NSObject

+ (instancetype)sharedInstance;
- (void)setBool:(BOOL)value forKey:(NSString*)defaultName;
- (BOOL)boolForKey:(NSString*)defaultName;
@end
