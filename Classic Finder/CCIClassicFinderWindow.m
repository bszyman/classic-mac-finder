//
//  CCIClassicFinderWindow.m
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

#import "CCIClassicFinderWindow.h"
#import "CCIClassicContentView.h"
#import "CCITitleBar.h"
#import "CCIClassicFinderDetailBar.h"
#import "CCIScrollView.h"
#import "CCIScrollContentView.h"
#import "CCIClassicFolder.h"
#import "CCIClassicFile.h"
#import "CFRWindowManager.h"
#import "CFRDirectoryModel.h"
#import "CFRFileModel.h"
#import "CFRAppModel.h"
#import "CCIClassicFinderWindowController.h"
#import "CCIResizeOverlayOutline.h"

@interface CCIClassicFinderWindow () {
    BOOL windowIsActive;
}

@property (nonatomic, strong) CCITitleBar *titlebar;
@property (nonatomic, strong) CCIClassicFinderDetailBar *detailBar;
@property (nonatomic, strong) CCIScrollView *scrollView;
@property (nonatomic, strong) CCIResizeOverlayOutline *resizeOverlay;

@end

@implementation CCIClassicFinderWindow

- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSWindowStyleMask)style
                            backing:(NSBackingStoreType)bufferingType
                              defer:(BOOL)flag
                    withWindowTitle:(NSString *)windowTitle
                           fileList:(NSArray *)fileList
                      andController:(CCIClassicFinderWindowController *)wc
{
    self = [super initWithContentRect:contentRect
                            styleMask:style
                              backing:bufferingType
                                defer:flag];
    
    if (self)
    {
        windowIsActive = YES;
        [self setWindowTitle:windowTitle];
        [self setFileList:fileList];
        [self setWindowController:wc];
        
        [self setBackgroundColor:[NSColor clearColor]];
        
        self.contentView = [[CCIClassicContentView alloc] initWithFrame:self.frame];
        
        NSRect contentArea = [self.contentView contentArea];
        NSRect titlebarFrame = NSMakeRect(0.0,
                                          0.0,
                                          contentArea.size.width,
                                          19.0);
        
        self.titlebar = [[CCITitleBar alloc] initWithFrame:titlebarFrame];
        self.titlebar.titleText = self.windowTitle;
        self.titlebar.windowIsActive = YES;
        [[self titlebar] setDelegate:self.windowController];
        
        if (self.windowController == nil) {
            NSLog(@"window controller is nil");
        }
        
        [self.contentView addSubview:self.titlebar];
        
        NSRect detailFrame = NSMakeRect(0.0, 19.0, contentArea.size.width, 25.0);
        self.detailBar = [[CCIClassicFinderDetailBar alloc] initWithFrame:detailFrame];
        [self.detailBar setNumberOfFileItemsText:self.fileList.count];
        [self.contentView addSubview:self.detailBar];
        
        
        NSRect scrollViewFrame = NSMakeRect(1.0,
                                            44.0,
                                            self.frame.size.width - 3.0,
                                            self.frame.size.height - 44.0 - 2.0);
        
        self.scrollView = [[CCIScrollView alloc] initWithFrame:scrollViewFrame
                                                 andController:self.windowController];
        [self.contentView addSubview:self.scrollView];
        
        NSUInteger iconRow = 0;
        NSUInteger iconCol = 0;
        
        for (NSUInteger x = 0; x < self.fileList.count; x += 1) {
            NSObject *fileSystemItem = [self.fileList objectAtIndex:x];
            
            if ([fileSystemItem isMemberOfClass:[CFRDirectoryModel class]])
            {
                CFRDirectoryModel *directoryItem = (CFRDirectoryModel *)fileSystemItem;
                
                CGFloat iconLeftPosition = (10.0 + (iconCol * 60.0));
                CGFloat frameWidthWithBorder = (self.frame.size.width - 55.0);
                if (iconLeftPosition > frameWidthWithBorder) {
                    iconRow += 1;
                    iconCol = 0;
                    iconLeftPosition = (10.0 + (iconCol * 60.0));
                }
                
                CGFloat iconTopPosition = 15.0 + (iconRow * 60.0);
                
                CGRect folderFrame = NSMakeRect(iconLeftPosition,
                                                iconTopPosition,
                                                55.0,
                                                60.0);
                
                CCIClassicFolder *folderIcon = [[CCIClassicFolder alloc] initWithFrame:folderFrame];
                folderIcon.folderLabel.stringValue = [directoryItem title];
                [folderIcon setDirectoryModel:directoryItem];
                
                [self.scrollView.contentView addSubview:folderIcon];
            } else if ([fileSystemItem isMemberOfClass:[CFRFileModel class]]) {
                CFRFileModel *fileItem = (CFRFileModel *)fileSystemItem;
                
                CGFloat iconLeftPosition = (10.0 + (iconCol * 60.0));
                CGFloat frameWidthWithBorder = (self.frame.size.width - 55.0);
                if (iconLeftPosition > frameWidthWithBorder) {
                    iconRow += 1;
                    iconCol = 0;
                    iconLeftPosition = (10.0 + (iconCol * 60.0));
                }
                
                CGFloat iconTopPosition = 15.0 + (iconRow * 60.0);
                
                CGRect folderFrame = NSMakeRect(iconLeftPosition,
                                                iconTopPosition,
                                                55.0,
                                                60.0);
                
                CCIClassicFile *fileIcon = [[CCIClassicFile alloc] initWithFrame:folderFrame];
                fileIcon.fileLabel.stringValue = [fileItem title];
                fileIcon.representedFile = [fileItem objectPath];
                
                [self.scrollView.contentView addSubview:fileIcon];
            }

            iconCol += 1;
        }
        
        NSRect contentViewSize = self.scrollView.contentView.frame;
        CGFloat newContentHeightSize = ((iconRow * 60.0) < contentViewSize.size.height) ? contentViewSize.size.height : (iconRow * 60.0);
        NSRect newContentViewSize = NSMakeRect(contentViewSize.origin.x, contentViewSize.origin.y, contentViewSize.size.width, newContentHeightSize);
        [self.scrollView resizeContentView:newContentViewSize];
        
        [self setInitialFirstResponder:self.scrollView];
    }
    
    return self;
}

- (void)liveResizeToFrame:(NSRect)frameRect
{
    NSRect overlayPositioning = NSMakeRect(0.0, 0.0, frameRect.size.width, frameRect.size.height);
    
    if ([self resizeOverlay] == nil) {
        CCIResizeOverlayOutline *resizeOverlay = [[CCIResizeOverlayOutline alloc] initWithFrame:overlayPositioning];
        [self setResizeOverlay:resizeOverlay];
        [self.contentView addSubview:[self resizeOverlay]];
    }
    
    [[self resizeOverlay] setFrame:overlayPositioning];
    
    [self setFrame:frameRect
           display:YES
           animate:NO];
}

- (void)finishedResizeToFrame:(NSRect)frameRect
{
    if ([self resizeOverlay] != nil) {
        // remove frame
        [[self resizeOverlay] removeFromSuperview];
        [self setResizeOverlay:nil];
    }
    
    NSRect roundedFrameRect = NSMakeRect(frameRect.origin.x,
                                         frameRect.origin.y,
                                         round(frameRect.size.width),
                                         round(frameRect.size.height));
    
    // Update Title Bar
    [self setFrame:roundedFrameRect
           display:YES
           animate:NO];
    
    // round these otherwise it'll result in subpixel rendering
    // and that looks like crap on non-retina screens.
    //CGFloat newFrameSizeWidthRounded = round(frameRect.size.width);
    //CGFloat newFrameSizeHeightRounded = round(frameRect.size.height);
    
    NSRect titlebarFrame = NSMakeRect(0.0,
                                      0.0,
                                      roundedFrameRect.size.width - 1.0,
                                      19.0);
    [[self titlebar] setFrame:titlebarFrame];
    
    // Update Detail Bar
    NSRect detailFrame = NSMakeRect(0.0,
                                    19.0,
                                    roundedFrameRect.size.width - 1.0,
                                    25.0);
    [[self detailBar] setFrame:detailFrame];
    
    // Update Scroll View
    NSRect scrollViewFrame = NSMakeRect(1.0,
                                        44.0,
                                        roundedFrameRect.size.width - 3.0,
                                        roundedFrameRect.size.height - 44.0 - 2.0);
    [[self scrollView] setFrame:scrollViewFrame];
}

- (void)setWindowActive
{
    windowIsActive = YES;
    
    [self.scrollView setWindowIsActive:windowIsActive];
    [self.titlebar setWindowIsActive:windowIsActive];
}

- (void)setWindowInactive
{
    windowIsActive = NO;
    
    [self.scrollView setWindowIsActive:windowIsActive];
    [self.titlebar setWindowIsActive:windowIsActive];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    NSLog(@"key down = %@", event.characters);
}

- (void)keyUp:(NSEvent *)event
{
    NSLog(@"key up = %@", event.characters);
}

@end
