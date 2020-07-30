//
//  CCIScrollView.h
//  Classic Scrolling2
//
//  Created by Ben Szymanski on 11/12/17.
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

#import <Cocoa/Cocoa.h>

@class CCIScrollContentContainer;
@class CCIScrollContentView;
@class CCIClassicFinderWindowController;

@interface CCIScrollView : NSView

@property (nonatomic, strong) CCIScrollContentView *contentView;
@property (nonatomic, strong) CCIScrollContentContainer *contentViewContainer;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (instancetype)initWithFrame:(NSRect)frameRect
                andController:(CCIClassicFinderWindowController *)wc;

- (void)performScrollAction:(id)sender;
- (void)resizeContentView:(NSRect)newFrame;
- (void)setWindowIsActive:(BOOL)windowIsActive;

@end
