//
//  AppDelegate.m
//  EasyCode
//
//  Created by gao feng on 2016/10/15.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import "AppDelegate.h"
#import "EditorWindowController.h"
#import "ESharedUserDefault.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *useicloudBtn;
@property (nonatomic, strong) EditorWindowController*                 editorOC;
@property (nonatomic, strong) EditorWindowController*                 editorSwift;
//icloud
@property (nonatomic, strong) id ubiquityToken;
@property (nonatomic, strong) NSURL *ubiquityURL;
@end

@implementation AppDelegate
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUbiquityIdentityDidChangeNotification object:nil];
}

- (void)ubiquityIdentityChanged:(NSNotification *)notification
{
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (token == nil)
    {
        NSAlert *warningAlert = [[NSAlert alloc] init];
        warningAlert.messageText = NSLocalizedString(@"Logged_Out_Message", nil);
        [warningAlert addButtonWithTitle:NSLocalizedString(@"OK_Button_Title", nil)];
        warningAlert.informativeText = NSLocalizedString(@"Logged_Out_Message_Explain", nil);
        warningAlert.alertStyle = NSWarningAlertStyle;
        [warningAlert runModal];
    } else {
        if ([self.ubiquityToken isEqual:token])
        {
            NSLog(@"user has stayed logged in with same account");
        }
        else
        {
            // user logged in with a different account
            NSLog(@"user logged in with a new account");
        }

        // store off this token to compare later
        self.ubiquityToken = token;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _useicloudBtn.state = [_UD boolForKey:KeyUseiCloudSync];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _ubiquityURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ubiquityIdentityChanged:)
                                                 name:NSUbiquityIdentityDidChangeNotification
                                               object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    _ubiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (IBAction)showEditorWindowForOC:(id)sender
{
    if (self.editorOC == nil) {
        self.editorOC = [[EditorWindowController alloc] initWithWindowNibName:@"EditorWindowController"];
        [_editorOC initEditorWindow:EditorTypeOC];
    }
    [_editorOC showWindow:self];
}

- (IBAction)showEditorWindowForSwift:(id)sender
{
    if (self.editorSwift == nil) {
        self.editorSwift = [[EditorWindowController alloc] initWithWindowNibName:@"EditorWindowController"];
        [_editorSwift initEditorWindow:EditorTypeSwift];
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

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        return NO;
    }
    else
    {
        [self.window makeKeyAndOrderFront:self];
        return YES;
    }
}

@end
