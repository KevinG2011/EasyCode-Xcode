//
//  DetailWindowController.m
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import "DetailWindowController.h"

@interface DetailWindowController () <NSTextFieldDelegate, NSWindowDelegate, NSControlTextEditingDelegate>
@property (nonatomic, strong) ECSnippetEntry*                 curSnippet;

@end

@implementation DetailWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self updateEntryDisplay];
    self.window.delegate = self;
    [self.window center];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (_delegate) {
        if (_editMode == DetailEditorModeUpdate) {
            [_delegate onSnippetUpdated:_curSnippet];
        }
        else if(_editMode == DetailEditorModeInsert)
        {
            [_delegate onSnippetInserted:_curSnippet];
        }
    }
}

- (void)initWithSnippet:(ECSnippetEntry*)snippet
{
    self.curSnippet = snippet;
    [self updateEntryDisplay];
}

- (void)updateEntryDisplay
{
    self.window.title = [NSString stringWithFormat:@"Create New"];
    if (_curSnippet.key.length > 0) {
        self.window.title = [NSString stringWithFormat:@"Edit %@", _curSnippet.key];
    }
    
    [self.txtKey setStringValue:@""];
    if (_curSnippet.key.length > 0) {
        [self.txtKey setStringValue:_curSnippet.key];
    }

    [self.txtCode setStringValue:@""];
    if (_curSnippet.code.length > 0) {
        [self.txtCode setStringValue:_curSnippet.code];
    }
    
    _txtKey.delegate = self;
    _txtCode.delegate = self;
    
    [_txtKey becomeFirstResponder];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    
    if (textField == _txtKey) {
        _curSnippet.key = [textField stringValue];
    }
    else if(textField == _txtCode)
    {
        _curSnippet.code = [textField stringValue];
    }
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;

    if (control == _txtCode) {
        if (commandSelector == @selector(insertNewline:))
        {
            [textView insertNewlineIgnoringFieldEditor:self];
            result = YES;
        }
        else if (commandSelector == @selector(insertTab:))
        {
            [textView insertTabIgnoringFieldEditor:self];
            result = YES;
        }
    }
    
    return result;
}

- (void)setEditMode:(DetailEditorMode)editMode {
    _editMode = editMode;
    if (_editMode == DetailEditorModeUpdate) {
        [_txtCode becomeFirstResponder];
    } else {
        [_txtKey becomeFirstResponder];
    }
}
@end
