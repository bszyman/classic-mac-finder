//
//  CCITitleBar.h
//  Classic Finder
//
//  Created by Ben Szymanski on 2/18/17.
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

@interface CCITitleBar : NSControl

@property (nonatomic, copy) NSString *titleText;
@property BOOL showCloseButton;
@property BOOL showMaximizeButton;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (void)setWindowIsActive:(BOOL)windowIsActive;

@end
