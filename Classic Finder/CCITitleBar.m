//
//  CCITitleBar.m
//  Classic Finder
//
//  Created by Ben Szymanski on 2/18/17.
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

#import "CCITitleBar.h"
#import "CCICloseButton.h"
#import "CCIMaximizeButton.h"
#import "CCIApplicationStyles.h"
#import "CCIClassicTitlebarDelegate.h"

@interface CCITitleBar () {
    id delegate;
    BOOL windowIsActive;
}

@property (nonatomic, strong) CCICloseButton *closeButton;
@property (nonatomic, strong) CCIMaximizeButton *maximizeButton;

@property NSPoint originalMouseCoordinates;

@end

@implementation CCITitleBar

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        self.showCloseButton = YES;
        self.showMaximizeButton = YES;
        self.windowIsActive = YES;
        
        [self addCloseButtonToTitlebar];
        [self addMaximizeButtonToTitlebar];
    }
    
    return self;
}

- (void)setFrame:(NSRect)frame
{
    [super setFrame: frame];
    
    // Set new Maximize button position
    NSRect maximizeButtonFrame = NSMakeRect(frame.size.width - 8.0 - 13.0, 4.0, 13.0, 11.0);
    [[self maximizeButton] setFrame:maximizeButtonFrame];
}

- (BOOL)windowIsActive
{
    return windowIsActive;
}

- (id)delegate
{
    return delegate;
}

- (void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}

- (void)setWindowIsActive:(BOOL)pWindowIsActive
{
    windowIsActive = pWindowIsActive;
    
    if (self.windowIsActive) {
        self.closeButton.hidden = NO;
        self.maximizeButton.hidden = NO;
    } else {
        self.closeButton.hidden = YES;
        self.maximizeButton.hidden = YES;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (self.windowIsActive) {
        [self drawOutlinesAndShadows];
        [self drawTextureLines];
        [self drawTitleText];
    } else {
        [self drawInactiveOutlines];
        [self drawTitleText];
    }
}

- (void)addCloseButtonToTitlebar
{
    if (self.showCloseButton) {
        NSRect frame = NSMakeRect(8.0, 4.0, 13.0, 11.0);
        self.closeButton = [[CCICloseButton alloc] initWithFrame:frame];
        
        [self addSubview:self.closeButton];
    }
}

- (void)addMaximizeButtonToTitlebar
{
    if (self.showMaximizeButton) {
        NSRect frame = NSMakeRect(self.frame.size.width - 8.0 - 13.0, 4.0, 13.0, 11.0);
        self.maximizeButton = [[CCIMaximizeButton alloc] initWithFrame:frame];
        
        [self addSubview:self.maximizeButton];
    }
}

- (void)mouseDown:(NSEvent *)event
{
    self.originalMouseCoordinates = event.locationInWindow;
}

- (void)mouseUp:(NSEvent *)event
{
    if ([[self delegate] respondsToSelector:@selector(titlebarDidFinishDetectingWindowPositionChange:)]) {
        [[self delegate] titlebarDidFinishDetectingWindowPositionChange:self];
    }
}

- (void)mouseDragged:(NSEvent *)event
{
    NSPoint newCoordinates = event.locationInWindow;
    
    CGFloat deltaX = newCoordinates.x - self.originalMouseCoordinates.x;
    CGFloat deltaY = newCoordinates.y - self.originalMouseCoordinates.y;
    
    if (event.window != nil) {
        NSRect activeWindowFrame = event.window.frame;
        
        activeWindowFrame.origin.x += deltaX;
        activeWindowFrame.origin.y += deltaY;
        
        [event.window setFrame:activeWindowFrame
                       display:YES
                       animate:NO];
    }
}

- (void)drawOutlinesAndShadows
{
    [[[CCIApplicationStyles instance] lightGrayColor] setFill];
    NSRectFill(NSMakeRect(0.0, 0.0, self.frame.size.width, self.frame.size.height));
    
    
    [[[CCIApplicationStyles instance] blackColor] setStroke];
    
    NSBezierPath *titlebarOutline = [[NSBezierPath alloc] init];
    [titlebarOutline moveToPoint:NSMakePoint(0.5, 0.5)];
    [titlebarOutline lineToPoint:NSMakePoint(0.5, 18.5)];
    [titlebarOutline lineToPoint:NSMakePoint(self.frame.size.width - 0.5, 18.5)];
    [titlebarOutline lineToPoint:NSMakePoint(self.frame.size.width - 0.5, 0.5)];
    [titlebarOutline lineToPoint: NSMakePoint(0.5, 0.5)];
    [titlebarOutline stroke];
    
    [[[CCIApplicationStyles instance] lightPurpleColor] setStroke];
    
    NSBezierPath *titlebarHighlight = [[NSBezierPath alloc] init];
    [titlebarHighlight moveToPoint:NSMakePoint(1.5, 1.5)];
    [titlebarHighlight lineToPoint:NSMakePoint(1.5, 17.5)];
    [titlebarHighlight lineToPoint:NSMakePoint(self.frame.size.width - 1.5, 17.5)];
    [titlebarHighlight stroke];
    
    [[[CCIApplicationStyles instance] midPurpleColor] setStroke];
    
    NSBezierPath *titlebarShadow = [[NSBezierPath alloc] init];
    [titlebarShadow moveToPoint:NSMakePoint(1.0, 1.5)];
    [titlebarShadow lineToPoint:NSMakePoint(self.frame.size.width - 1.5, 1.5)];
    [titlebarShadow lineToPoint:NSMakePoint(self.frame.size.width - 1.5, 17.5)];
    [titlebarShadow stroke];

}

- (void)drawInactiveOutlines
{
    // White Background
    [[[CCIApplicationStyles instance] whiteColor] setFill];
    NSRectFill(NSMakeRect(0.0, 0.0, self.frame.size.width, self.frame.size.height));
    
    // Black Box Border
    [[[CCIApplicationStyles instance] blackColor] setStroke];
    
    NSBezierPath *titlebarOutline = [[NSBezierPath alloc] init];
    [titlebarOutline moveToPoint:NSMakePoint(0.5, 0.5)];
    [titlebarOutline lineToPoint:NSMakePoint(0.5, 18.5)];
    [titlebarOutline lineToPoint:NSMakePoint(self.frame.size.width - 0.5, 18.5)];
    [titlebarOutline lineToPoint:NSMakePoint(self.frame.size.width - 0.5, 0.5)];
    [titlebarOutline lineToPoint: NSMakePoint(0.5, 0.5)];
    [titlebarOutline stroke];
}

- (void)drawTextureLines
{
    CGFloat textureLineStartPos = 0.0;
    
    [NSGraphicsContext saveGraphicsState];
    [[[CCIApplicationStyles instance] darkGrayColor] setStroke];
    
    NSAffineTransform *textureTransform = [NSAffineTransform transform];
    [textureTransform translateXBy:2.5 yBy:4.5];
    [textureTransform concat];
    
    for (NSUInteger x = 0; x < 6; x++) {
        NSBezierPath *line = [[NSBezierPath alloc] init];
        [line moveToPoint:NSMakePoint(0.0, textureLineStartPos)];
        [line lineToPoint:NSMakePoint(self.frame.size.width - 5.0, textureLineStartPos)];
        [line stroke];
        
        textureLineStartPos += 2.0;
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawTitleText
{
    [NSGraphicsContext saveGraphicsState];
    
    NSAffineTransform *titleTextTransform = [NSAffineTransform transform];
    [titleTextTransform translateXBy:2.0 yBy:0.0];
    [titleTextTransform concat];
    
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    [titleStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *fontAttributes = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:11.0],
                                     NSParagraphStyleAttributeName: titleStyle};
    
    NSSize titleTextSize = [self.titleText sizeWithAttributes:fontAttributes];
    CGFloat textWidth = titleTextSize.width + 12.0;
    
    if (self.windowIsActive) {
        [[[CCIApplicationStyles instance] lightGrayColor] setFill];
        NSRectFill(NSMakeRect(((self.frame.size.width - textWidth) / 2.0), 2.0, textWidth, 15.0));
    } else {
        [[[CCIApplicationStyles instance] whiteColor] setFill];
        NSRectFill(NSMakeRect(((self.frame.size.width - textWidth) / 2.0), 2.0, textWidth, 15.0));
    }
    
    [[[CCIApplicationStyles instance] blackColor] setFill];
    
    NSRect titleTextRect = NSMakeRect(((self.frame.size.width - textWidth) / 2.0), 1.5, textWidth, 15.0);
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:self.titleText
                                                                attributes:fontAttributes];
    [title drawInRect:titleTextRect];
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
