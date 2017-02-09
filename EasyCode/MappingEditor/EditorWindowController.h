//
//  EditorWindowController.h
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    EditorTypeOC,
    EditorTypeSwift,
} EditorType;

@interface EditorWindowController : NSWindowController
@property (weak) IBOutlet NSWindow *toastPanel;
@property (weak) IBOutlet NSTextField *toastText;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *filterColumn;

- (void)initEditorWindow:(EditorType)editorType;

@end
