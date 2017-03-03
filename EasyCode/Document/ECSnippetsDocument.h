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

@interface ECSnippetsDocument : NSDocument
@property (nonatomic, strong) NSMutableArray<EShortcutEntry*>*                            entryList;
@property (nonatomic, assign) EditorType                            editorType;
@property (nonatomic, strong,readonly) NSURL* itemURL;
-(instancetype)initWithEditorType:(EditorType)editorType;
-(instancetype)initWithItemURL:(NSURL*)itemURL;
@end

