//
//  CCIClassicFolder.m
//  Classic Finder
//
//  Created by Ben Szymanski on 2/19/17.
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

#import "CCIClassicFolder.h"
#import "CCIClassicFolderIcon.h"
#import "CFRWindowManager.h"
#import "AppDelegate.h"
#import "CCIClassicFinderWindow.h"
#import "CCIClassicFinderWindowController.h"
#import "CCIApplicationStyles.h"
#import "CFRFloppyDisk.h"
#import "CFRDirectoryModel.h"

@interface CCIClassicFolder ()

@property (nonatomic, copy) NSString *folderTitle;
@property (nonatomic, strong) CCIClassicFolderIcon *iconImage;

@property BOOL folderSelected;
@property BOOL folderOpened;

@end

@implementation CCIClassicFolder

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        [self setFolderSelected:NO];
        [self setFolderOpened:NO];
        
        NSRect folderIconFrame = NSMakeRect(14.5, 2.0, 31.0, 25.0);
        self.iconImage = [[CCIClassicFolderIcon alloc] initWithFrame:folderIconFrame];
        
        [self addSubview:self.iconImage];
        
        NSRect folderLabelFrame = NSMakeRect(2.0, 35.0, 54.0, 50.0);
        self.folderLabel = [[NSTextField alloc] initWithFrame:folderLabelFrame];
        self.folderLabel.alignment = NSTextAlignmentCenter;
        self.folderLabel.font = [NSFont fontWithName:@"Geneva" size:10.0];
        self.folderLabel.bordered = NO;
        self.folderLabel.selectable = NO;
        self.folderLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.folderLabel.drawsBackground = YES;
        self.folderLabel.maximumNumberOfLines = 5;
        self.folderLabel.usesSingleLineMode = NO;
        
        [self addSubview:self.folderLabel];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    // Drawing code here.
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
    CCIClassicFinderWindowController *wc = event.window.windowController;
    [wc selectedNewFolder:self];
}

- (void)mouseUp:(NSEvent *)event
{
    if (event.clickCount == 2)
    {
        [CFRFloppyDisk restoreDirectoryProperties:[self directoryModel]];
        NSPoint persistedWindowPosition = [[self directoryModel] windowPosition];
        
        if ((persistedWindowPosition.x == -1.0) &&
            (persistedWindowPosition.y == -1.0))
        {
            // We assume the window position hasn't been
            // previously set if windowPosition = (-1, -1).
            // We will just do a generic offset of 30 px
            // from the parent/calling window...
            
            NSRect windowFrame = event.window.frame;
            CGFloat xPos = windowFrame.origin.x + 30.0;
            CGFloat yPos = windowFrame.origin.y - 30.0;
            
            NSPoint newWindowPosition = NSMakePoint(xPos, yPos);
            [[self directoryModel] setWindowPosition:newWindowPosition];
        } else {
            // Handle overflow
            // if the last-recorded position of the window is somewhere off-screen,
            // reposition it so that it is visible on screen
            // handy for cases when switching between a large desktop monitor and
            // a smaller built-in laptop screen
            NSRect mainScreenFrame = [[NSScreen mainScreen] frame];
            
            // window horizontal position is out of right-side of screen
            if (persistedWindowPosition.x > (mainScreenFrame.size.width) - 30.0) {
                NSPoint currentWindowPosition = [[self directoryModel] windowPosition];
                NSPoint newWindowPosition = NSMakePoint(mainScreenFrame.size.width - 500.0, currentWindowPosition.y);
                [[self directoryModel] setWindowPosition:newWindowPosition];
            }
            
            // window vertical position is below bottom of screen
            if (persistedWindowPosition.y > (mainScreenFrame.size.height) - 30.0) {
                NSPoint currentWindowPosition = [[self directoryModel] windowPosition];
                NSPoint newWindowPosition = NSMakePoint(currentWindowPosition.x, mainScreenFrame.size.height - 300.0);
                [[self directoryModel] setWindowPosition:newWindowPosition];
            }
            
            // window horizontal position is out of left-side of screen
            if (persistedWindowPosition.x < 0.0) {
                NSPoint currentWindowPosition = [[self directoryModel] windowPosition];
                NSPoint newWindowPosition = NSMakePoint(30.0, currentWindowPosition.y);
                [[self directoryModel] setWindowPosition:newWindowPosition];
            }
            
            // window vertical position is above top of screen
            if (persistedWindowPosition.y < 0.0) {
                NSPoint currentWindowPosition = [[self directoryModel] windowPosition];
                NSPoint newWindowPosition = NSMakePoint(currentWindowPosition.x, 30.0);
                [[self directoryModel] setWindowPosition:newWindowPosition];
            }
        }

        [self setOpenItemState];
        
        NSWindowController *finderWindow = [CFRWindowManager.sharedInstance createWindowForDirectory:[self directoryModel]];
        [finderWindow showWindow:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:event.window.windowController
                                                 selector:@selector(closeOpenedFolder:)
                                                     name:NSWindowWillCloseNotification
                                                   object:finderWindow.window];
    }
}

- (void)normalFolderTitleTextColor
{
    self.folderLabel.backgroundColor = [[CCIApplicationStyles instance] whiteColor];
    self.folderLabel.textColor = [[CCIApplicationStyles instance] blackColor];
}

- (void)reverseFolderTitleTextColor
{
    self.folderLabel.backgroundColor = [[CCIApplicationStyles instance] blackColor];
    self.folderLabel.textColor = [[CCIApplicationStyles instance] whiteColor];
}

- (void)selectItem
{
    [self setFolderSelected:YES];
    [self reverseFolderTitleTextColor];
    [[self iconImage] selectFolder];
    [self setNeedsDisplay:YES];
}

- (void)deselectItem
{
    [self setFolderSelected:NO];
    [self normalFolderTitleTextColor];
    [[self iconImage] unselectFolder];
    [self setNeedsDisplay:YES];
}

- (void)setOpenItemState
{
    [self setFolderOpened:YES];
    [[self iconImage] openFolder];
    [self setNeedsDisplay:YES];
}

- (void)setCloseItemState
{
    [self setFolderOpened:NO];
    [[self iconImage] closeFolder];
    [self setNeedsDisplay:YES];
}

@end
