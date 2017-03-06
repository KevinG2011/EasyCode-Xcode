//
//  ECSnippetsDocument.h
//  AirCode
//
//  Created by Loriya on 2017/3/1.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EditorWindowController.h"
@class ECSnippet;
@protocol ECSnippetsDocumentDelegate;

EC_EXTERN NSString *const ECDocumentLoadedNotification;

typedef NS_ENUM(NSInteger,ECSnippetActionType) {
    ECSnippetActionTypeCreate,
    ECSnippetActionTypeRetrieve,
    ECSnippetActionTypeUpdate,
    ECSnippetActionTypeDelete
};

@interface ECSnippetsDocument : NSDocument
@property (nonatomic, assign)           EditorType                              editorType;
@property (nonatomic, strong,readonly)  NSURL*                                  itemURL;
@property (nonatomic, copy,readonly)    NSArray<ECSnippet*>*               snippetList;
@property (nonatomic, weak)             id<ECSnippetsDocumentDelegate>          delegate;

-(instancetype)initWithFileURL:(NSURL*)itemURL editorType:(EditorType)type;
-(NSInteger)snippetCount;
//根据键查找片段
-(ECSnippet*)snippetForKey:(NSString*)key;
//插入片段
-(void)addSnippet:(ECSnippet*)snippet;
//根据键删除片段
-(void)removeSnippetForKey:(NSString*)key;
//根据键更新片段
-(void)updateSnippet:(ECSnippet*)snippet;
//保存文档
-(void)saveDocumentCompletionHandler:(void (^)(void))handler;
@end

@protocol ECSnippetsDocumentDelegate <NSObject>
-(void)snippetsDocument:(ECSnippetsDocument*)document performActionWithType:(ECSnippetActionType)actionType withSnippet:(ECSnippet*)snippet;
@end


