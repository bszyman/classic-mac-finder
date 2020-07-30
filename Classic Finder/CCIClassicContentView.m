//
//  CCIClassicContentView.m
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

#import "CCIClassicContentView.h"
#import "CCIApplicationStyles.h"

@interface CCIClassicContentView() {
    BOOL windowIsResizing;
    
    NSBezierPath *windowTopPath;
    NSBezierPath *windowLeftPath;
    NSBezierPath *windowRightPath;
    NSBezierPath *windowBottomPath;
    NSBezierPath *menuBarBottomPath;
    NSBezierPath *verticalScrollbarLeftPath;
    NSBezierPath *horizontalScrollbarTopPath;
}

@end

@implementation CCIClassicContentView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        windowIsResizing = NO;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (!windowIsResizing) {
        NSRect viewFrame = self.frame;
        [[[CCIApplicationStyles instance] blackColor] setFill];
        
        NSRectFill(NSMakeRect(1.0,
                              1.0,
                              viewFrame.size.width - 1.0,
                              viewFrame.size.height - 1.0));
        //
        //
        //        [[[CCIApplicationStyles instance] whiteColor] setFill];
        //
        NSRectFill(NSMakeRect(0.0,
                              0.0,
                              viewFrame.size.width - 1.0,
                              viewFrame.size.height - 1.0));
    }
    
}

- (NSRect)contentArea
{
    NSRect contentFrame = NSMakeRect(0.0,
                                     0.0,
                                     self.frame.size.width - 1.0,
                                     self.frame.size.height - 1.0);
    
    return contentFrame;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)setWindowIsResizing:(BOOL)resizing
{
    windowIsResizing = resizing;
}

@end
