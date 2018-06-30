//
//  CCIResizeOverlayOutline.m
//  Classic Finder
//
//  Created by Ben Szymanski on 3/25/18.
//  Copyright © 2018 Protype Software Ltd. All rights reserved.
//

#import "CCIResizeOverlayOutline.h"
#import "CCIApplicationStyles.h"

@interface CCIResizeOverlayOutline() {
    NSBezierPath *windowTopPath;
    NSBezierPath *windowLeftPath;
    NSBezierPath *windowRightPath;
    NSBezierPath *windowBottomPath;
    NSBezierPath *menuBarBottomPath;
    NSBezierPath *verticalScrollbarLeftPath;
    NSBezierPath *horizontalScrollbarTopPath;
}

@end

@implementation CCIResizeOverlayOutline

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
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
}

- (BOOL)isFlipped
{
    return YES;
}

@end
