//
//  EditorWindowController.m
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import "EditorWindowController.h"
#import "ECMainWindowController.h"
#import "DetailWindowController.h"
#import "ESharedUserDefault.h"
#import "ECSnippetEntry.h"
#import "ECSnippetsDocument.h"
#import "NSWindow+Additions.h"
#import "NSString+Additions.h"
#import "NSFileManager+Additions.h"
#import "ECSnippetHelper.h"

@interface EditorWindowController ()<NSWindowDelegate,NSTableViewDataSource,NSTabViewDelegate,
                                    DetailWindowEditorDelegate,NSSearchFieldDelegate,
                                    ECSnippetEntrysDocumentDelegate>
@property (nonatomic, weak) IBOutlet NSWindow                       *toastPanel;
@property (nonatomic, weak) IBOutlet NSTextField                    *toastText;
@property (nonatomic, weak) IBOutlet NSScrollView                   *scrollView;
@property (nonatomic, weak) IBOutlet NSTableView                    *tableView;
@property (nonatomic, weak) IBOutlet NSTableColumn                  *filterColumn;
@property (nonatomic, weak) IBOutlet NSSearchField                  *searchField;
@property (nonatomic, strong) NSImage*                              imgEdit;
@property (nonatomic, strong) NSImage*                              imgAdd;
@property (nonatomic, strong) NSImage*                              imgRemove;

@property (nonatomic, assign) ECSourceType                          sourceType;
@property (nonatomic, strong) NSArray<ECSnippetEntry*>*             filteringList;
@property (nonatomic, strong) NSArray<ECSnippetEntry*>*             matchingList;

@property (nonatomic, strong) DetailWindowController*               detailEditor;
@property (nonatomic, strong) ECSnippetDocument*                    snippetDoc;
@property (nonatomic, copy)   NSString*                             searchKey;
@property (nonatomic, copy)   NSString*                             dirname;
@property (nonatomic, strong) NSMetadataQuery*                      query;
@property (nonatomic, strong) NSMetadataItem*                       dataItem;
@end

@implementation EditorWindowController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initEditorWindowForType:(ECSourceType)sourceType {
    self = [super initWithWindowNibName:@"EditorWindowController"];
    if (self) {
        _sourceType = sourceType;
    }
    return self;
}

- (void)setupData {
    self.dirname = [ECSnippetHelper directoryForSourceType:_sourceType];
    self.window.title = self.dirname;
    
    self.imgEdit = [NSImage imageNamed:@"edit"];
    self.imgAdd = [NSImage imageNamed:@"add"];
    self.imgRemove = [NSImage imageNamed:@"remove"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDocumentLoaded:)
                                                 name:ECDocumentLoadedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUbiquityIdentityChanged:)
                                                 name:NSUbiquityIdentityDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(oniCloudSyncChanged:)
                                                 name:ECiCloudSyncChangedNotification
                                               object:nil];
}

- (void)setupView {
    [_tableView setDoubleAction:@selector(onHandleDoubleClick:)];
    [_tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    
    _searchField.delegate = self;
    _toastPanel.backgroundColor = [NSColor colorWithWhite:0 alpha:0.5];
    [_toastPanel setCornRadius:12];
    [_toastPanel orderOut:self];
    
    self.window.delegate = self;
    [self.window center];
}


- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupData];
    [self setupView];
    [self loadDocument];
}

- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (void)onDocumentLoaded:(NSNotification*)notification {
    _snippetDoc = [notification object];
    _snippetDoc.delegate = self;
    [_snippetDoc saveDocumentCompletionHandler:^{
        [self reloadData];
    }];
}

- (void)onUbiquityIdentityChanged:(NSNotification*)notification {
    [self loadDocument];
}

- (void)oniCloudSyncChanged:(NSNotification*)notification {
    BOOL useiCloud = [ESharedUserDefault boolForKey:kUseiCloudSync];
    NSURL* baseURL = [[NSFileManager defaultManager] localURL];
    if (useiCloud) {
        baseURL = [[NSFileManager defaultManager] ubiquityURL];
    }
    NSURL* destURL = [baseURL URLByAppendingPathComponent:_dirname];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* error = nil;
        BOOL success = [[NSFileManager defaultManager] setUbiquitous:useiCloud itemAtURL:_snippetDoc.fileURL destinationURL:destURL error:&error];
        if (!success) {
            NSLog(@"ubiquitous move error :%@",[error localizedDescription]);
        }
        [self loadDocument];
    });
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:nil];
    [self loadDataWithQuery:query];
    _query = nil;
}

- (void)loadDocument {
    id<NSObject, NSCopying, NSCoding> ubiq = [[NSFileManager defaultManager] ubiquityIdentityToken];
    BOOL useiCloud = [ESharedUserDefault boolForKey:kUseiCloudSync];
    if (ubiq && useiCloud) { //iCloud Enabled and Checked
        _query = [[NSMetadataQuery alloc] init];
        _query.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey,_dirname];
        [_query setPredicate:pred];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(queryDidFinishGathering:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:_query];
        [_query startQuery];
    } else { //iCloud Disabled
        [self loadDataWithQuery:nil];
    }
}

- (void)loadDataWithQuery:(NSMetadataQuery*)query {
    NSURL* fileURL = [[NSFileManager defaultManager] localSnippetsURLWithFilename:_dirname];
    if (query) {
        //load from remote
        if ([query resultCount] >= 1) {
            _dataItem = [query resultAtIndex:0];
            fileURL = [_dataItem valueForAttribute:NSMetadataItemURLKey];
        } else {
            fileURL = [[NSFileManager defaultManager] ubiquitySnippetsURLWithFilename:_dirname];
        }
    }
    _snippetDoc = [[ECSnippetDocument alloc] initWithFileURL:fileURL sourceType:_sourceType];
    _snippetDoc.delegate = self;
}

- (void)onFireSearchRequest {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* cloneList = _snippetDoc.snippet.entries;
        if (_searchKey.length > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key contains[cd] %@", _searchKey];
            cloneList = [cloneList filteredArrayUsingPredicate:predicate];
        }
        _filteringList = cloneList;
        [self reloadData];
    });
}

- (void)queueSearchRequest {
    _searchKey = [_searchField.stringValue trimWhiteSpace];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onFireSearchRequest) object:nil];
    [self performSelector:@selector(onFireSearchRequest) withObject:nil afterDelay:0.2f];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    [self queueSearchRequest];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) { //pressed enter
        [self queueSearchRequest];
    }
    return NO;
}

- (void)focusSearchField:(id)sender {
    [_searchField selectText:self];
    [[_searchField currentEditor] setSelectedRange:NSMakeRange(_searchField.stringValue.length, 0)];
}

- (void)keyDown:(NSEvent *)event {
    if (([event modifierFlags] & NSCommandKeyMask) == NSCommandKeyMask){
        if ([event keyCode] == 3) { //Command + F
            [self focusSearchField:nil];
        }
    }
}

- (void)pasteShortcutWithEntry:(ECSnippetEntry*)snippet {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    BOOL success = [pasteboard writeObjects:@[snippet.key]];
    if (success) {
        _toastText.stringValue = snippet.key;
        [_toastPanel fadeInAnimated:NO];
        [_toastPanel fadeOutAnimated:YES afterDelay:3];
    }
}

- (void)onHandleDoubleClick:(id)sender {
    if (_tableView.clickedColumn > 1) {
        return;
    }
    
    ECSnippetEntry* snippet = _matchingList[_tableView.clickedRow];
    if (_tableView.clickedColumn == 0) { //clicked shortcut key
        [self pasteShortcutWithEntry:snippet];
    } else {
        [self presentDetailEditorWithEntry:snippet];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger selectedRow = [_tableView selectedRow];
    NSTableRowView *myRowView = [_tableView rowViewAtRow:selectedRow makeIfNecessary:NO];
    [myRowView setEmphasized:NO];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([_searchKey isNotEmpty]) {
        _matchingList = _filteringList;
    } else {
        _matchingList = _snippetDoc.snippet.entries;
    }
    return [_matchingList count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    ECSnippetEntry* snippet = _matchingList[row];
    
    if( [tableColumn.identifier isEqualToString:@"cShortcut"] )
    {
        cellView.textField.stringValue = snippet.key;
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:@"cCode"] )
    {
        cellView.textField.stringValue = snippet.code;
        cellView.textField.textColor = [NSColor colorWithWhite:0.5 alpha:1];
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:@"cEditCode"] )
    {
        NSButton* btn = (NSButton*)cellView;
        btn.image = _imgEdit;
        [btn setTarget:self];
        [btn setAction:@selector(onEditCodeClick:)];
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:@"cAdd"] )
    {
        NSButton* btn = (NSButton*)cellView;
        btn.image = _imgAdd;
        [btn setTarget:self];
        [btn setAction:@selector(onAddEntryClick:)];
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:@"cRemove"] )
    {
        NSButton* btn = (NSButton*)cellView;
        btn.image = _imgRemove;
        [btn setTarget:self];
        [btn setAction:@selector(onRemoveEntryClick:)];
        return cellView;
    }
    
    return cellView;
}

- (void)presentDetailEditorWithEntry:(ECSnippetEntry*)snippet {
    if (snippet == nil) {
        return;
    }
    
    [self.detailEditor initWithEntry:snippet];
    self.detailEditor.editMode = DetailEditorModeUpdate;
    [self.detailEditor showWindow:self];
}

- (void)onEditCodeClick:(id)sender
{
    NSButton* btn = sender;
    NSInteger row = [_tableView rowForView:btn];
    ECSnippetEntry* snippet = _matchingList[row];
    [self presentDetailEditorWithEntry:snippet];
}

- (void)onAddEntryClick:(id)sender
{
    ECSnippetEntry* entry = [ECSnippetEntry new];
    [self.detailEditor initWithEntry:entry];
    self.detailEditor.editMode = DetailEditorModeInsert;
    [self.detailEditor showWindow:self];
}

- (void)onRemoveEntryClick:(id)sender
{
    NSButton* btn = sender;
    NSInteger row = [_tableView rowForView:btn];
    ECSnippetEntry* snippet = _matchingList[row];
    [self onEntryRemoved:snippet];
}

- (DetailWindowController*)detailEditor
{
    if (_detailEditor == nil) {
        _detailEditor = [[DetailWindowController alloc] initWithWindowNibName:@"DetailWindowController"];
        _detailEditor.delegate = self;
    }
    return _detailEditor;
}

#pragma mark - DetailWindowEditorDelegate
- (void)snippetsDocument:(ECSnippetDocument*)document performActionWithType:(ECSnippetEntryActionType)actionType withEntry:(ECSnippetEntry*)entry {
    [self reloadData];
}

#pragma mark - DetailWindowEditorDelegate
- (void)onSnippetInserted:(ECSnippetEntry*)entry {    
    [_snippetDoc addSnippetEntry:entry];
}

- (void)onEntryRemoved:(ECSnippetEntry*)snippet {
    [_snippetDoc removeSnippetEntryForKey:snippet.key];
}

- (void)onSnippetUpdated:(ECSnippetEntry*)snippet {
    if ([_detailEditor hasEdited]) {
        [_snippetDoc updateSnippetEntry:snippet];        
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    [_snippetDoc saveDocumentCompletionHandler:NULL];
}

@end
