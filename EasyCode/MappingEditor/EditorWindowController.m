//
//  EditorWindowController.m
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import "EditorWindowController.h"
#import "ESharedUserDefault.h"
#import "EShortcutEntry.h"
#import "DetailWindowController.h"
#import "ECSnippetsDocument.h"
#import "NSWindow+Additions.h"
#import "NSString+Additions.h"
#import "NSFileManager+Additions.h"

#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
if(block){\
block();\
}\
}\
else {\
if(block){\
dispatch_sync(dispatch_get_main_queue(), block);\
}\
}
#endif

#ifndef dispatch_async_safe
#define dispatch_async_safe(block) \
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#endif

@interface EditorWindowController () <NSWindowDelegate,NSTableViewDataSource,NSTabViewDelegate,
DetailWindowEditorDelegate,NSSearchFieldDelegate>
@property (nonatomic, weak) IBOutlet NSWindow *toastPanel;
@property (nonatomic, weak) IBOutlet NSTextField *toastText;
@property (nonatomic, weak) IBOutlet NSScrollView *scrollView;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSTableColumn *filterColumn;

@property (nonatomic, strong) NSMutableDictionary*                  mappingDic;
@property (nonatomic, strong) NSMutableArray<EShortcutEntry*>*                       mappingList;
@property (nonatomic, assign) EditorType                            editorType;

@property (nonatomic, strong) NSImage*                              imgEdit;
@property (nonatomic, strong) NSImage*                              imgAdd;
@property (nonatomic, strong) NSImage*                              imgRemove;

@property (nonatomic, strong) DetailWindowController*               detailEditor;
@property (nonatomic, strong) IBOutlet NSSearchField*               searchField;
@property (nonatomic, strong) NSString*                             searchKey;
@property (nonatomic, strong) NSArray*                              filteringList;
@property (nonatomic, weak)   NSArray*                              matchingList;
@property (nonatomic, strong) ECSnippetsDocument*                   snippetDoc;
@property (nonatomic, strong) NSMetadataQuery*                      query;
@end

@implementation EditorWindowController

- (instancetype)initEditorWindowForType:(EditorType)editorType {
    self = [super initWithWindowNibName:@"EditorWindowController"];
    if (self) {
        self.editorType = editorType;
        
        self.imgEdit = [NSImage imageNamed:@"edit"];
        self.imgAdd = [NSImage imageNamed:@"add"];
        self.imgRemove = [NSImage imageNamed:@"remove"];
        
//        self.mappingList = @[].mutableCopy;
//        
//        if (_editorType == EditorTypeOC) {
//            self.mappingDic = [_UD readMappingForOC].mutableCopy;
//            self.window.title = @"Objective-C";
//        }
//        else if(_editorType == EditorTypeSwift) {
//            self.mappingDic = [_UD readMappingForSwift].mutableCopy;
//            self.window.title = @"Swift";
//        }
//        
//        NSArray* keys = self.mappingDic.allKeys;
//        keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//            NSString* str1 = obj1;
//            NSString* str2 = obj2;
//            return [str1 compare:str2];
//        }];
//        for (NSString* key in keys) {
//            EShortcutEntry* entry = [EShortcutEntry new];
//            entry.key = key;
//            entry.code = _mappingDic[key];
//            [_mappingList addObject:entry];
//        }
//        [self sortMappingList];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self loadDocument];
    [self loadView];
}

- (void)queryDidStartGathering:(NSNotification *)notification {
    
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:nil];
    [self loadSnippetsData:query];
    _query = nil;
}

- (void)loadDocument {
    _query = [[NSMetadataQuery alloc] init];
    _query.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey,FileOCName];
    [_query setPredicate:pred];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:nil];

    [_query startQuery];
}

- (void)loadSnippetsData:(NSMetadataQuery*)query {
    if ([query resultCount] == 1) { //load from remote
        NSMetadataItem* dataItem = [query resultAtIndex:0];
        NSURL* itemURL = [dataItem valueForAttribute:NSMetadataItemURLKey];
        NSError* error = nil;
        _snippetDoc = [[ECSnippetsDocument alloc] initWithContentsOfURL:itemURL ofType:@"ec" error:&error];
        _mappingList = _snippetDoc.entryList;
    } else { //load from local
        NSURL* itemURL = [[NSFileManager defaultManager] localOCSnippetsURL];
        NSError* error = nil;
        _snippetDoc = [[ECSnippetsDocument alloc] initWithContentsOfURL:itemURL ofType:@"ec" error:&error];
        _mappingList = _snippetDoc.entryList;
    }
    [self.tableView reloadData];    
}

- (void)loadView {
    _searchField.delegate = self;
    _toastPanel.backgroundColor = [NSColor colorWithWhite:0 alpha:0.5];
    [_toastPanel setCornRadius:12];
    [_toastPanel orderOut:self];
    
    _tableView.allowsColumnSelection = NO;
    [_tableView setDoubleAction:@selector(onHandleDoubleClick:)];
    [_tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
    
    self.window.delegate = self;
    [self.window center];
}


- (void)onFireSearchRequest {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* cloneList = [_mappingList copy];
        if (_searchKey.length > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key contains[cd] %@", _searchKey];
            cloneList = [cloneList filteredArrayUsingPredicate:predicate];
        }
        _filteringList = cloneList;
        
        dispatch_main_sync_safe(^{
            [_tableView reloadData];
        });
    });
}

- (void)queueSearchRequest {
    _searchKey = [_searchField.stringValue trimWhiteSpace];
//    NSLog(@"searchText :%@",_searchKey);
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
//    NSLog(@"keyCode :%d",event.keyCode);
    if (([event modifierFlags] & NSCommandKeyMask) == NSCommandKeyMask){
        if ([event keyCode] == 3) { //Command + F
            [self focusSearchField:nil];
        }
    }
}

- (void)pasteShortcutWithEntry:(EShortcutEntry*)entry {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    BOOL success = [pasteboard writeObjects:@[entry.key]];
    if (success) {
        _toastText.stringValue = entry.key;
        [_toastPanel fadeInAnimated:NO];
        [_toastPanel fadeOutAnimated:YES afterDelay:3];
    }
}

- (void)onHandleDoubleClick:(id)sender {
    if (_tableView.clickedColumn > 1) {
        return;
    }
    
    EShortcutEntry* entry = _matchingList[_tableView.clickedRow];
    if (_tableView.clickedColumn == 0) { //clicked shortcut key
        [self pasteShortcutWithEntry:entry];
    } else {
        [self presentDetailEditorWithEntry:entry];
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
        _matchingList = _mappingList;
    }
    return [_matchingList count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    EShortcutEntry* entry = _matchingList[row];
    
    if( [tableColumn.identifier isEqualToString:@"cShortcut"] )
    {
        cellView.textField.stringValue = entry.key;
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:@"cCode"] )
    {
        cellView.textField.stringValue = entry.code;
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

- (void)presentDetailEditorWithEntry:(EShortcutEntry*)entry {
    if (entry == nil) {
        return;
    }
    
    [self.detailEditor initWithMappingEntry:entry];
    self.detailEditor.editMode = DetailEditorModeUpdate;
    [self.detailEditor showWindow:self];
}

- (void)onEditCodeClick:(id)sender
{
    NSButton* btn = sender;
    NSInteger row = [_tableView rowForView:btn];
    EShortcutEntry* entry = _matchingList[row];
    [self presentDetailEditorWithEntry:entry];
}

- (void)onAddEntryClick:(id)sender
{
    EShortcutEntry* entry = [EShortcutEntry new];
    [self.detailEditor initWithMappingEntry:entry];
    self.detailEditor.editMode = DetailEditorModeInsert;
    [self.detailEditor showWindow:self];
}

- (void)onRemoveEntryClick:(id)sender
{
    NSButton* btn = sender;
    NSInteger row = [_tableView rowForView:btn];
    EShortcutEntry* entry = _matchingList[row];
    if (entry) {
        [_mappingList removeObject:entry];
        [self sortMappingList];
        [_tableView reloadData];
        
        [self saveMapping];
    }
}

- (DetailWindowController*)detailEditor
{
    if (_detailEditor == nil) {
        self.detailEditor = [[DetailWindowController alloc] initWithWindowNibName:@"DetailWindowController"];
        _detailEditor.delegate = self;
    }
    return _detailEditor;
}

#pragma mark - DetailWindowEditorDelegate
- (void)onEntryInserted:(EShortcutEntry*)entry {
    if (entry.key.length > 0 && entry.code.length > 0) {
        [_mappingList addObject:entry];
        [self sortMappingList];
        [_tableView reloadData];
        
        [self saveMapping];
    }
}

- (void)onEntryUpdated:(EShortcutEntry*)entry {
    [self sortMappingList];
	[_tableView reloadData];
    
    [self saveMapping];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self saveMapping];
}

#pragma mark - Other
- (void)saveMapping
{
    NSMutableDictionary* newMapping = @{}.mutableCopy;
    for (EShortcutEntry* entry in _mappingList) {
        [newMapping setObject:entry.code forKey:entry.key];
    }
    
    if (_editorType == EditorTypeOC) {
        [_UD saveMappingForOC:newMapping];
    }
    else if(_editorType == EditorTypeSwift)
    {
        [_UD saveMappingForSwift:newMapping];
    }
}

- (void)sortMappingList
{
    if (_mappingList.count == 0) {
        EShortcutEntry* testEntry = [EShortcutEntry new];
        testEntry.key = @"key";
        testEntry.code = @"code";
        [_mappingList addObject:testEntry];
    }
    
    [_mappingList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        EShortcutEntry* entry1 = obj1;
        EShortcutEntry* entry2 = obj2;
        return [entry1.key compare:entry2.key];
    }];
}

@end
