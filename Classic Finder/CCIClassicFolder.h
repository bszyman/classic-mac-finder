//
//  CCIClassicFolder.h
//  Classic Finder
//
//  Created by Ben Szymanski on 2/19/17.
//  Copyright © 2017 Protype Software Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CCIClassicFolder : NSControl

@property (nonatomic, copy) NSURL *representingDirectory;
@property (nonatomic, strong) NSTextField *folderLabel;

- (void)selectFolder;
- (void)unselectFolder;

@end
