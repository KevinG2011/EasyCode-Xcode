//
//  ECMainWindowController.m
//  EasyCode
//
//  Created by lijia on 02/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import "ECMainWindowController.h"
#import "EditorWindowController.h"

NSString *const ECiCloudSyncChangedNotification = @"ECiCloudSyncChangedNotification";

@interface ECMainWindowController ()
@property (nonatomic, assign) BOOL useiCloud;
@property (nonatomic, weak)   IBOutlet NSButton *useicloudBtn;
@property (nonatomic, strong) EditorWindowController* editorOC;
@property (nonatomic, strong) EditorWindowController* editorSwift;
@end

@implementation ECMainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    _useicloudBtn.state = [[NSUserDefaults standardUserDefaults] boolForKey:KeyUseiCloudSync];
}

- (IBAction)showEditorWindowForOC:(id)sender {
    if (self.editorOC == nil) {
        self.editorOC = [[EditorWindowController alloc] initEditorWindowForType:EditorTypeOC];
    }
    [_editorOC showWindow:self];
}

- (IBAction)showEditorWindowForSwift:(id)sender {
    if (self.editorSwift == nil) {
        self.editorSwift = [[EditorWindowController alloc] initEditorWindowForType:EditorTypeSwift];
    }
    [_editorSwift showWindow:self];
}

- (IBAction)useiCloudCheck:(NSButton*)sender {
    _useiCloud = (sender.state == NSOnState);
    [[NSUserDefaults standardUserDefaults] setBool:_useiCloud forKey:KeyUseiCloudSync];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:ECiCloudSyncChangedNotification object:nil];
}

- (IBAction)showHowToUse:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://github.com/music4kid/EasyCode-Xcode"]];
}


@end
