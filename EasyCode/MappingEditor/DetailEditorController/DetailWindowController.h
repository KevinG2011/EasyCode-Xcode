//
//  DetailWindowController.h
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ECSnippet.h"

typedef enum : NSUInteger {
    DetailEditorModeUpdate,
    DetailEditorModeInsert,
} DetailEditorMode;

@protocol DetailWindowEditorDelegate <NSObject>

- (void)onEntryUpdated:(ECSnippet*)snippet;
- (void)onEntryInserted:(ECSnippet*)snippet;

@end


@interface DetailWindowController : NSWindowController

- (void)initWithMappingEntry:(ECSnippet*)snippet;

@property (nonatomic, weak) id<DetailWindowEditorDelegate>         delegate;
@property (nonatomic, assign) DetailEditorMode                     editMode;


@property (nonatomic, strong) IBOutlet NSTextField*                txtKey;
@property (nonatomic, strong) IBOutlet NSTextField*                txtCode;

@end
