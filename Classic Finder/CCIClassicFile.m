//
//  CCIClassicFile.m
//  Classic Finder
//
//  Created by Ben Szymanski on 10/4/17.
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

#import "CCIClassicFile.h"
#import "CCIClassicFileIcon.h"
#import "CFRFileSystemOperations.h"
#import "CCIClassicFinderWindowController.h"
#import "CCIApplicationStyles.h"

@interface CCIClassicFile()

@property (nonatomic, copy) NSString *fileTitle;
@property (nonatomic, strong) CCIClassicFileIcon *iconImage;
@property BOOL fileSelected;

@end

@implementation CCIClassicFile

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self)
    {
        self.fileSelected = NO;
        
        NSRect fileIconFrame = NSMakeRect(18.5, 2.0, 31.0, 31.0);
        self.iconImage = [[CCIClassicFileIcon alloc] initWithFrame:fileIconFrame];
        
        [self addSubview:self.iconImage];
        
        NSRect fileLabelFrame = NSMakeRect(2.0, 35.0, 54.0, 24.0);
        self.fileLabel = [[NSTextField alloc] initWithFrame:fileLabelFrame];
        self.fileLabel.alignment = NSTextAlignmentCenter;
        self.fileLabel.font = [NSFont fontWithName:@"Geneva" size:10.0];
        self.fileLabel.bordered = NO;
        self.fileLabel.selectable = NO;
        self.fileLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.fileLabel.drawsBackground = YES;
        
        [self addSubview:self.fileLabel];
    }
    
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//
//    // Drawing code here.
//}

- (BOOL)isFlipped
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
    CCIClassicFinderWindowController *wc = event.window.windowController;
    [wc selectedNewFile:self];
}

- (void)mouseUp:(NSEvent *)event
{
    if (event.clickCount == 2)
    {
        [CFRFileSystemOperations openFileAtURL:self.representedFile];
    }
}

- (void)normalFileTitleTextColor
{
    self.fileLabel.backgroundColor = [[CCIApplicationStyles instance] whiteColor];
    self.fileLabel.textColor = [[CCIApplicationStyles instance] blackColor];
}

- (void)reverseFileTitleTextColor
{
    self.fileLabel.backgroundColor = [[CCIApplicationStyles instance] blackColor];
    self.fileLabel.textColor = [[CCIApplicationStyles instance] whiteColor];
}

- (void)selectItem
{
    self.fileSelected = YES;
    [self reverseFileTitleTextColor];
    [self.iconImage selectFile];
    [self setNeedsDisplay:YES];
}

- (void)deselectItem
{
    self.fileSelected = NO;
    [self normalFileTitleTextColor];
    [self.iconImage deselectFile];
    [self setNeedsDisplay:YES];
}


- (void)setOpenItemState
{
    // this method is not used on this icon
}

- (void)setCloseItemState
{
    // this method is not used on this icon
}

@end
