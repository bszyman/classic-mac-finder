//
//  CFRFileModel.m
//  Classic Finder
//
//  Created by Ben Szymanski on 1/11/18.
//  Copyright © 2018 Ben Szymanski. All rights reserved.
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

#import "CFRFileModel.h"
#import "NSString+Hashes.h"

@implementation CFRFileModel

@synthesize title;
@synthesize creationDate;
@synthesize lastModified;
@synthesize objectPath;
@synthesize fileSystemNumber;

@synthesize iconPosition;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self setTitle:@""];
        [self setCreationDate:[NSDate date]];
        [self setLastModified:[NSDate date]];
        [self setObjectPath:[NSURL URLWithString:@"file:///"]];
        [self setIconPosition:NSMakePoint(-1.0, -1.0)];    }
    
    return self;
}


- (NSString *)uniqueID
{
    NSString *unhashedID = [NSString stringWithFormat:@"%f%@", creationDate.timeIntervalSinceReferenceDate, title];
    NSString *hashedID = [unhashedID sha1];
    
    return hashedID;
}

- (NSString *)objectType
{
    return @"file";
}

#pragma mark - NSCODING METHODS

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setIconPosition:[aDecoder decodePointForKey:@"iconPosition"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.uniqueID forKey:@"uniqueID"];
    [aCoder encodePoint:self.iconPosition forKey:@"iconPosition"];
}

@end
