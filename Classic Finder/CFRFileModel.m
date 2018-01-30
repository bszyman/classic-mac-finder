//
//  CFRFileModel.m
//  Classic Finder
//
//  Created by Ben Szymanski on 1/11/18.
//  Copyright © 2018 Protype Software Ltd. All rights reserved.
//

#import "CFRFileModel.h"
#import "NSString+Hashes.h"

@implementation CFRFileModel

@synthesize title;
@synthesize creationDate;
@synthesize lastModified;
@synthesize objectPath;

@synthesize iconPosition;

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