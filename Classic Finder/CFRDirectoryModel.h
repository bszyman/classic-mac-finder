//
//  CFRDirectoryModel.h
//  Classic Finder
//
//  Created by Ben Szymanski on 1/11/18.
//  Copyright © 2018 Protype Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFRFileSystemObject.h"

@interface CFRDirectoryModel : NSObject <CFRFileSystemObject, NSCoding>

@property NSSize windowDimensions;
@property NSPoint windowPosition;

@end