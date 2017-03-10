//
//  ECSnippet.h
//  EasyCode
//
//  Created by lijia on 07/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSnippetEntry.h"
#import "ECDefine.h"

@interface ECSnippet : NSObject <NSCopying,NSCoding>
@property (nonatomic, copy) NSNumber* version;
@property (nonatomic, copy) NSNumber* type;
@property (nonatomic, copy) NSArray<ECSnippetEntry*>* entries;

-(instancetype)initWithSourceType:(ECSourceType)sourceType entries:(NSArray<ECSnippetEntry*>*)entries;

//排序
-(void)sortedEntry;
//条目数量
-(NSInteger)entryCount;
//根据键查找片段
-(ECSnippetEntry*)entryForKey:(NSString*)key;
//插入片段
-(void)addEntry:(ECSnippetEntry*)entry;
//根据键删除片段
-(ECSnippetEntry*)removeEntryForKey:(NSString*)key;
//根据键更新片段
-(void)updateEntry:(ECSnippetEntry*)entry;

@end
