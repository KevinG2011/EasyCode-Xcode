//
//  ECSnippetEntrysDocument.h
//  AirCode
//
//  Created by Loriya on 2017/3/1.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EditorWindowController.h"
@class ECSnippetEntry;
@protocol ECSnippetEntrysDocumentDelegate;

EC_EXTERN NSString *const ECDocumentLoadedNotification;

typedef NS_ENUM(NSInteger,ECSnippetEntryActionType) {
    ECSnippetEntryActionTypeCreate,
    ECSnippetEntryActionTypeRetrieve,
    ECSnippetEntryActionTypeUpdate,
    ECSnippetEntryActionTypeDelete
};

@interface ECSnippetEntrysDocument : NSDocument
@property (nonatomic, assign)           EditorType                              editorType;
@property (nonatomic, strong,readonly)  NSURL*                                  itemURL;
@property (nonatomic, copy,readonly)    NSArray<ECSnippetEntry*>*               snippetList;
@property (nonatomic, weak)             id<ECSnippetEntrysDocumentDelegate>          delegate;

-(instancetype)initWithFileURL:(NSURL*)itemURL editorType:(EditorType)type;
-(NSInteger)snippetCount;
//根据键查找片段
-(ECSnippetEntry*)snippetForKey:(NSString*)key;
//插入片段
-(void)addSnippet:(ECSnippetEntry*)snippet;
//根据键删除片段
-(void)removeSnippetForKey:(NSString*)key;
//根据键更新片段
-(void)updateSnippet:(ECSnippetEntry*)snippet;
//保存文档
-(void)saveDocumentCompletionHandler:(void (^)(void))handler;
@end

@protocol ECSnippetEntrysDocumentDelegate <NSObject>
-(void)snippetsDocument:(ECSnippetEntrysDocument*)document performActionWithType:(ECSnippetEntryActionType)actionType withSnippet:(ECSnippetEntry*)snippet;
@end


