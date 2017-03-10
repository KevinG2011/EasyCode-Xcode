//
//  ECDefine.h
//  EasyCode
//
//  Created by lijia on 07/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef ECDefine_H
#define ECDefine_H

#define KeyUseiCloudSync                @"KeyUseiCloudSync"

typedef NS_ENUM(NSInteger,ECSourceType) {
    ECSourceTypeOC,
    ECSourceTypeSwift
};

#define APP_OBJ                 [NSApplication sharedApplication]
#define APP_DELEGATE            ((AppDelegate *)[APP_OBJ delegate])

#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
if(block){\
block();\
}\
}\
else {\
if(block){\
dispatch_sync(dispatch_get_main_queue(), block);\
}\
}
#endif

#ifndef dispatch_async_safe
#define dispatch_async_safe(block) \
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#endif



#endif /* ECDefine_H */


