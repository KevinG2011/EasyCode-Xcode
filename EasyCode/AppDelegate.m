//
//  AppDelegate.m
//  EasyCode
//
//  Created by gao feng on 2016/10/15.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import "AppDelegate.h"
#import "ECMainWindowController.h"
#import "NSWindowController+Additions.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+(instancetype)sharedInstance {
    AppDelegate* appDelegate = [NSApplication sharedApplication].delegate;
    return appDelegate;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUbiquityIdentityDidChangeNotification object:nil];
}

- (void)ubiquityIdentityChanged:(NSNotification *)notification
{
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (token == nil) {
        NSAlert *warningAlert = [NSAlert ec_alertWithStyle:NSWarningAlertStyle
                                               messageText:NSLocalizedString(@"Logged_Out_Message", nil)
                                           informativeText:NSLocalizedString(@"Logged_Out_Message_Explain", nil)
                                               buttonTitle:NSLocalizedString(@"Button_OK_Title", nil),
                                 nil];
        [warningAlert runModal];
    } else {
        if ([self.ubiquityToken isEqual:token]) {
            NSLog(@"user has stayed logged in with same account");
        } else {
            NSLog(@"user logged in with a new account");
        }
        self.ubiquityToken = token;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _ubiquityURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ubiquityIdentityChanged:)
                                                 name:NSUbiquityIdentityDidChangeNotification
                                               object:nil];
    _mainController = [[ECMainWindowController alloc] initWithWindowNibName:@"ECMainWindowController"];
    [_mainController ec_makeWindowFront];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    _ubiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    return YES;
}

@end
