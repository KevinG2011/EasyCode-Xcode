//
//  ECSnippet.h
//  EasyCode
//
//  Created by lijia on 07/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSnippetEntry.h"

@interface ECSnippet : NSObject <NSCopying,NSCoding>
@property (nonatomic, copy) NSString* version;
@property (nonatomic, copy) NSArray<ECSnippetEntry*>* entries;
@end
