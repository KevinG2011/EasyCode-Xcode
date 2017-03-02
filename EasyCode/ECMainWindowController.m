//
//  ECMainWindowController.m
//  EasyCode
//
//  Created by lijia on 02/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import "ECMainWindowController.h"
#import "EditorWindowController.h"
#import "ESharedUserDefault.h"

@interface ECMainWindowController ()
@property (nonatomic, assign) BOOL useiCloud;
@property (nonatomic, weak)   IBOutlet NSButton *useicloudBtn;
@property (nonatomic, strong) EditorWindowController* editorOC;
@property (nonatomic, strong) EditorWindowController* editorSwift;
@end

@implementation ECMainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    _useicloudBtn.state = [_UD boolForKey:KeyUseiCloudSync];
}

- (IBAction)showEditorWindowForOC:(id)sender {
    if (self.editorOC == nil) {
        self.editorOC = [[EditorWindowController alloc] initWithWindowNibName:@"EditorWindowController"];
        [_editorOC initEditorWindowForType:EditorTypeOC];
    }
    [_editorOC showWindow:self];
}

- (IBAction)showEditorWindowForSwift:(id)sender {
    if (self.editorSwift == nil) {
        self.editorSwift = [[EditorWindowController alloc] initWithWindowNibName:@"EditorWindowController"];
        [_editorSwift initEditorWindowForType:EditorTypeSwift];
    }
    [_editorSwift showWindow:self];
}

- (IBAction)useiCloudCheck:(NSButton*)sender {
    _useiCloud = (sender.state == NSOnState);
    [_UD setBool:_useiCloud forKey:KeyUseiCloudSync];
}

- (IBAction)showHowToUse:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://github.com/music4kid/EasyCode-Xcode"]];
}


@end
