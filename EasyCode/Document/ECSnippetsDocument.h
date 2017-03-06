//
//  ECSnippetsDocument.h
//  AirCode
//
//  Created by Loriya on 2017/3/1.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EditorWindowController.h"
@class EShortcutEntry;
@protocol ECSnippetsDocumentDelegate;

typedef NS_ENUM(NSInteger,ECSnippetActionType) {
    ECSnippetActionTypeCreate,
    ECSnippetActionTypeRetrieve,
    ECSnippetActionTypeUpdate,
    ECSnippetActionTypeDelete
};

@interface ECSnippetsDocument : NSDocument
@property (nonatomic, assign) EditorType                            editorType;
@property (nonatomic, strong,readonly) NSURL* itemURL;
@property (nonatomic,copy,readonly) NSArray<EShortcutEntry*>*                            entryList;
@property (nonatomic, weak) id<ECSnippetsDocumentDelegate> delegate;

-(instancetype)initWithEditorType:(EditorType)editorType;
-(instancetype)initWithItemURL:(NSURL*)itemURL;

//根据键查找片段
-(EShortcutEntry*)snippetForKey:(NSString*)key;
//插入片段
-(void)addSnippet:(EShortcutEntry*)entry;
//根据键删除片段
-(void)removeSnippetForKey:(NSString*)key;
//根据键更新片段
-(void)updateSnippet:(EShortcutEntry*)entry;
//保存文档
-(void)saveDocumentCompletionHandler:(void (^)(void))handler;
@end

@protocol ECSnippetsDocumentDelegate <NSObject>
-(void)snippetsDocument:(ECSnippetsDocument*)document performActionWithType:(ECSnippetActionType)actionType withSnippet:(EShortcutEntry*)entry;
@end


