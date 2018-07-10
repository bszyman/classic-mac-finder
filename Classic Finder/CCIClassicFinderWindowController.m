//
//  CCIClassicFinderWindowController.m
//  Classic Finder
//
//  Created by Ben Szymanski on 10/5/17.
//  Copyright © 2017 Ben Szymanski. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CCIClassicFinderWindowController.h"
#import "CCIClassicFinderWindow.h"
#import "CFRFileSystemOperations.h"
#import "CFRWindowManager.h"
#import "CCIFinderIconProtocol.h"
#import "CCIClassicFile.h"
#import "CCIClassicFolder.h"
#import "CFRFileSystemUtils.h"
#import "CFRDirectoryModel.h"
#import "CFRFloppyDisk.h"
#import "CCIClassicContentView.h"

@interface CCIClassicFinderWindowController ()

@property (nonatomic, copy) NSString *windowDirectoryName;
@property (nonatomic, copy) NSArray *fileList;
@property (nonatomic, strong) NSMutableArray *selectedFiles;

@end

@implementation CCIClassicFinderWindowController

- (instancetype)initForDirectory:(CFRDirectoryModel *)directoryModel
{
    self = [super init];
    
    if (self) {
        NSString *directoryName = [CFRFileSystemUtils determineDirectoryNameForURL:directoryModel.objectPath];
        
        self.directoryModel = directoryModel;
        self.windowDirectoryName = directoryName;
        self.fileList = [CFRFileSystemOperations getListingForDirectory:self.directoryModel.objectPath];
        self.selectedFiles = [[NSMutableArray alloc] initWithCapacity:50];
        
        NSUInteger windowStyleMask = NSWindowStyleMaskBorderless;
        NSRect initalContentRect = NSMakeRect(self.directoryModel.windowPosition.x,
                                              self.directoryModel.windowPosition.y,
                                              self.directoryModel.windowDimensions.width,
                                              self.directoryModel.windowDimensions.height);
        
        // https://stackoverflow.com/a/33229421/5096725
        CCIClassicFinderWindow *finderWindow = [[CCIClassicFinderWindow alloc] initWithContentRect:initalContentRect
                                                                                         styleMask:windowStyleMask
                                                                                           backing:NSBackingStoreBuffered
                                                                                             defer:YES
                                                                                   withWindowTitle:self.windowDirectoryName
                                                                                          fileList:self.fileList
                                                                                     andController:self];

        [finderWindow setDelegate:[CFRWindowManager sharedInstance]];
        [finderWindow setWindowController:self];
        [self setWindow:finderWindow];
        
        [finderWindow makeKeyAndOrderFront:self];
        
        NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
        
        [dc addObserver:self
               selector:@selector(windowDidResignMain:)
                   name:NSWindowDidResignMainNotification
                 object:finderWindow];
        
        [dc addObserver:self
               selector:@selector(windowDidBecomeMain:)
                   name:NSWindowDidBecomeMainNotification
                 object:finderWindow];
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    CCIClassicFinderWindow *finderWindow = (CCIClassicFinderWindow *)self.window;
    [finderWindow setWindowActive];
}

- (void)windowDidResignMain:(NSNotification *)notification
{
    CCIClassicFinderWindow *finderWindow = (CCIClassicFinderWindow *)self.window;
    [finderWindow setWindowInactive];
}

- (void)closeOpenedFolder:(NSNotification *)notification
{
    CCIClassicFinderWindow *closingWindow = (CCIClassicFinderWindow *)[notification object];
    CCIClassicFinderWindowController *closingWindowController = closingWindow.windowController;
    
    for (CCIClassicFolder *folder in self.selectedFiles) {
        if (folder.directoryModel.objectPath == closingWindowController.directoryModel.objectPath) {
            [folder setCloseItemState];
            //NSLog(@"closing folder... %@", closingWindowController.representedDirectory);
        }
    }
}

- (void)selectedNewFile:(CCIClassicFile *)file
{
    for (CCIClassicFile *file in self.selectedFiles) {
        [file deselectItem];
    }
    
    [self.selectedFiles removeAllObjects];
    
    [file selectItem];
    [self.selectedFiles addObject:file];
}

- (void)selectedNewFolder:(CCIClassicFolder *)folder
{
    for (CCIClassicFolder *folder in self.selectedFiles) {
        [folder deselectItem];
    }
    
    [self.selectedFiles removeAllObjects];
    
    [folder selectItem];
    [self.selectedFiles addObject:folder];
}

- (void)deselectAllItems
{
    NSMutableArray *selectedFiles = [self selectedFiles];
    
    for (CCIClassicFile *file in selectedFiles) {
        [file deselectItem];
    }
    
    [self.selectedFiles removeAllObjects];
}

#pragma mark - TITLEBAR DELEGATE METHODS

- (void)titlebarDidFinishDetectingWindowPositionChange:(CCITitleBar *)sender
{
    NSPoint currentPosition = self.window.frame.origin;
    
    [[self directoryModel] setWindowPosition:currentPosition];
    [CFRFloppyDisk persistDirectoryProperties:[self directoryModel]];
}

#pragma mark - WINDOW GRIP BUTTON DELEGATE METHODS

- (void)gripButtonDidFinishDraggingToCoordinates:(NSPoint)pointDraggedTo
{
    CGFloat newWidth = pointDraggedTo.x - self.window.frame.origin.x;
    CGFloat newHeight = (self.window.frame.origin.y + self.window.frame.size.height) - pointDraggedTo.y;
    
    // this because the mac's coordinate system starts in the lower left
    // we need to reposition the origin coordinate on the y axis
    // by determining the offset between the current y coord and the new
    // y coord
    CGFloat yOriginOffset = self.window.frame.origin.y - (self.window.frame.origin.y - pointDraggedTo.y);
    
    NSRect newWindowFrame = NSMakeRect(self.window.frame.origin.x, yOriginOffset, newWidth, newHeight);
    
    CCIClassicFinderWindow *wcWindow = (CCIClassicFinderWindow *)[self window];
    [wcWindow finishedResizeToFrame:newWindowFrame];
    
    [[self directoryModel] setWindowDimensions:NSMakeSize(newWidth, newHeight)];
    
    
    
    NSPoint currentPosition = self.window.frame.origin;
    [[self directoryModel] setWindowPosition:currentPosition];
    
    
    
    
    [CFRFloppyDisk persistDirectoryProperties:[self directoryModel]];
    
    
    
    CCIClassicContentView *contentView = (CCIClassicContentView *)self.window.contentView;
    [contentView setWindowIsResizing:NO];
    [contentView setNeedsDisplay:YES];
}

- (void)gripButtonIsDraggingToCoordinates:(NSPoint)pointDraggedTo
{
    CCIClassicContentView *contentView = (CCIClassicContentView *)self.window.contentView;
    [contentView setWindowIsResizing:YES];
    [contentView setNeedsDisplay:YES];
    
    
    
    CGFloat newWidth = pointDraggedTo.x - self.window.frame.origin.x;
    CGFloat newHeight = (self.window.frame.origin.y + self.window.frame.size.height) - pointDraggedTo.y;
    
    // this because the mac's coordinate system starts in the lower left
    // we need to reposition the origin coordinate on the y axis
    // by determining the offset between the current y coord and the new
    // y coord
    CGFloat yOriginOffset = self.window.frame.origin.y - (self.window.frame.origin.y - pointDraggedTo.y);
    
    NSRect newWindowFrame = NSMakeRect(self.window.frame.origin.x, yOriginOffset, fabs(newWidth), newHeight);
    
    CCIClassicFinderWindow *wcWindow = (CCIClassicFinderWindow *)[self window];
    [wcWindow liveResizeToFrame:newWindowFrame];
}

@end
