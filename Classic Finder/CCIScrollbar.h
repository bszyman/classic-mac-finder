//
//  CCIScrollbar.h
//  Classic Scrolling2
//
//  Created by Ben Szymanski on 11/12/17.
//  Copyright © 2017 Ben Szymanski. All rights reserved.
//
//
// This file is part of Classic Finder.
//
// Classic Finder is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Classic Finder is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Classic Finder.  If not, see <http://www.gnu.org/licenses/>.

#import <Cocoa/Cocoa.h>

@class CCIScrollView;

typedef NS_ENUM(NSUInteger, ScrollDirection) {
    Horizontal,
    Vertical
};

@interface CCIScrollbar : NSControl

+ (CCIScrollbar *)horizontalScrollbarForScrollView:(CCIScrollView *)scrollView
                                withMaxContentSize:(CGFloat)maxContentSize;
+ (CCIScrollbar *)verticalScrollbarForScrollView:(CCIScrollView *)scrollView
                              withMaxContentSize:(CGFloat)maxContentSize;
- (void)setScrollerYPosition:(CGFloat)yPOS;
- (void)setScrollerXPosition:(CGFloat)xPOS;
- (void)updateMaxContentSize:(CGFloat)newMaxContentSize;

@end
