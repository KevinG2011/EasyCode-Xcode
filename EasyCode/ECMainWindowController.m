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

@interface ECMainWindowController () <NSAlertDelegate>
@property (nonatomic, weak)   IBOutlet NSButton *useicloudBtn;
@property (nonatomic, strong) EditorWindowController* editorOC;
@property (nonatomic, strong) EditorWindowController* editorSwift;
@end

@implementation ECMainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    _useicloudBtn.state = [ESharedUserDefault boolForKey:KeyUseiCloudSync];
}

- (IBAction)showEditorWindowForOC:(id)sender {
    if (self.editorOC == nil) {
        self.editorOC = [[EditorWindowController alloc] initEditorWindowForType:ECSourceTypeOC];
    }
    [_editorOC showWindow:self];
}

- (IBAction)showEditorWindowForSwift:(id)sender {
    if (self.editorSwift == nil) {
        self.editorSwift = [[EditorWindowController alloc] initEditorWindowForType:ECSourceTypeSwift];
    }
    [_editorSwift showWindow:self];
}

- (IBAction)useiCloudCheck:(NSButton*)sender {
    BOOL useiCloud = (sender.state == NSOnState);
    if (useiCloud) {
        id ubiq = [[NSFileManager defaultManager] ubiquityIdentityToken];
        if (ubiq) {
            [ESharedUserDefault setBool:YES forKey:KeyUseiCloudSync];
            [[NSNotificationCenter defaultCenter] postNotificationName:ECiCloudSyncChangedNotification object:nil];
        } else {
            [ESharedUserDefault setBool:NO forKey:KeyUseiCloudSync];
            sender.state = NSOffState;
            //Alert Note
        }
    } else {
        id ubiq = [[NSFileManager defaultManager] ubiquityIdentityToken];
        if (ubiq) {
            NSAlert *warningAlert = [[NSAlert alloc] init];
            [warningAlert addButtonWithTitle:NSLocalizedString(@"OK_Button_Title", nil)];
            [warningAlert addButtonWithTitle:NSLocalizedString(@"Cancel_Button_Title", nil)];
            warningAlert.messageText = NSLocalizedString(@"iCloud_Attention", nil);
            warningAlert.informativeText = NSLocalizedString(@"iCloud_Attention_Message", nil);
            warningAlert.alertStyle = NSWarningAlertStyle;
            [warningAlert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertFirstButtonReturn) { //OK
                    [ESharedUserDefault setBool:NO forKey:KeyUseiCloudSync];
                    [[NSNotificationCenter defaultCenter] postNotificationName:ECiCloudSyncChangedNotification object:nil];
                }
            }];
        } else {
            [ESharedUserDefault setBool:NO forKey:KeyUseiCloudSync];
        }
    }
}

- (IBAction)showHowToUse:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://github.com/music4kid/EasyCode-Xcode"]];
}


@end
