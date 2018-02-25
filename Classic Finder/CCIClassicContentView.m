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
    
    NSRect viewFrame = self.frame;
    
    if (windowIsResizing) {
        [[[CCIApplicationStyles instance] blackColor] setStroke];
        
        if (windowTopPath == nil) {
            windowTopPath = [[NSBezierPath alloc] init];
            [windowTopPath moveToPoint:NSMakePoint(0.0, 0.0)];
            [windowTopPath lineToPoint:NSMakePoint(self.frame.size.width, 0.0)];
        }
        
        [windowTopPath stroke];
        
        
        if (windowLeftPath == nil) {
            windowLeftPath = [[NSBezierPath alloc] init];
            [windowLeftPath moveToPoint:NSMakePoint(0.0, 0.0)];
            [windowLeftPath lineToPoint:NSMakePoint(0.0, self.frame.size.height)];
        }
        
        [windowLeftPath stroke];
        
        if (windowRightPath == nil) {
            windowRightPath = [[NSBezierPath alloc] init];
            [windowRightPath moveToPoint:NSMakePoint(self.frame.size.width, 0.0)];
            [windowRightPath lineToPoint:NSMakePoint(self.frame.size.width, self.frame.size.height)];
        }
        
        [windowRightPath stroke];
        
        if (windowBottomPath == nil) {
            windowBottomPath = [[NSBezierPath alloc] init];
            [windowBottomPath moveToPoint:NSMakePoint(0.0, self.frame.size.height)];
            [windowBottomPath lineToPoint:NSMakePoint(self.frame.size.width, self.frame.size.height)];
        }
        
        [windowBottomPath stroke];
        
        if (menuBarBottomPath == nil) {
            menuBarBottomPath = [[NSBezierPath alloc] init];
            [menuBarBottomPath moveToPoint:NSMakePoint(0.0, 19.0)];
            [menuBarBottomPath lineToPoint:NSMakePoint(self.frame.size.width, 19.0)];
        }
        
        [menuBarBottomPath stroke];
        
        if (verticalScrollbarLeftPath == nil) {
            verticalScrollbarLeftPath = [[NSBezierPath alloc] init];
            [verticalScrollbarLeftPath moveToPoint:NSMakePoint(self.frame.size.width - 20.0, 19.0)];
            [verticalScrollbarLeftPath lineToPoint:NSMakePoint(self.frame.size.width - 20.0, self.frame.size.height)];
        }
        
        [verticalScrollbarLeftPath stroke];
        
        if (horizontalScrollbarTopPath == nil) {
            horizontalScrollbarTopPath = [[NSBezierPath alloc] init];
            [horizontalScrollbarTopPath moveToPoint:NSMakePoint(0.0, self.frame.size.height - 20.0)];
            [horizontalScrollbarTopPath lineToPoint:NSMakePoint(self.frame.size.width, self.frame.size.height - 20.0)];
        }
        
        [horizontalScrollbarTopPath stroke];
        
        
    } else {
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
