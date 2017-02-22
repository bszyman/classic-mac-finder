//
//  CCIClassicFinderDetailBar.m
//  Classic Finder
//
//  Created by Ben Szymanski on 2/19/17.
//  Copyright © 2017 Protype Software Ltd. All rights reserved.
//

#import "CCIClassicFinderDetailBar.h"

typedef NS_ENUM(NSUInteger, FileSizeMetrics) {
    kByteMetric,
    kKilobyteMetric,
    kMegabyteMetric,
    kGigabyteMetric,
    kTerabyteMetric
};

@interface CCIClassicFinderDetailBar ()

@property (nonatomic, strong) NSTextField *itemCountTextField;
@property (nonatomic, strong) NSTextField *usedSpaceTextField;
@property (nonatomic, strong) NSTextField *availableSpaceTextField;

@end

@implementation CCIClassicFinderDetailBar

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        
        // http://stackoverflow.com/questions/1626139/how-do-you-find-how-much-disk-space-is-left-in-cocoa
        
        NSError *getAttributesErr = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/"
                                                                                               error:&getAttributesErr];
        
        if (getAttributesErr != nil) {
            NSLog(@"ClasicFinderDetailBar - %@", getAttributesErr);
        }
        
        NSNumber *freeSpace = [fileAttributes objectForKey:NSFileSystemFreeSize];
        NSString *freeSpaceFormattedText = [self formattedFreeSpace:[freeSpace integerValue]];
        
        NSNumber *totalSpace = [fileAttributes objectForKey:NSFileSystemSize];
        NSString *totalSpaceFormattedText = [self formattedTotalSpace:[totalSpace integerValue]];
        
        
        self.itemCountTextField = [[NSTextField alloc] init];
        self.itemCountTextField.frame = NSMakeRect(7.0, 5.0, 170.0, 17.0);
        self.itemCountTextField.stringValue = @"4 items";
        self.itemCountTextField.bordered = NO;
        self.itemCountTextField.selectable = NO;
        self.itemCountTextField.font = [NSFont systemFontOfSize:10.0];
        
        [self addSubview:self.itemCountTextField];
        
        
        self.usedSpaceTextField = [[NSTextField alloc] init];
        self.usedSpaceTextField.frame = NSMakeRect(((self.frame.size.width / 2.0) - (170.0 / 2.0)), 5.0, 170.0, 17.0);
        self.usedSpaceTextField.stringValue = totalSpaceFormattedText;
        self.usedSpaceTextField.alignment = NSTextAlignmentCenter;
        self.usedSpaceTextField.bordered = NO;
        self.usedSpaceTextField.selectable = NO;
        self.usedSpaceTextField.font = [NSFont systemFontOfSize:10.0];
        
        [self addSubview:self.usedSpaceTextField];
        
        
        self.availableSpaceTextField = [[NSTextField alloc] init];
        self.availableSpaceTextField.frame = NSMakeRect((self.frame.size.width - 170.0 - 7.0), 5.0, 170.0, 17.0);
        self.availableSpaceTextField.stringValue = freeSpaceFormattedText;
        self.availableSpaceTextField.alignment = NSTextAlignmentRight;
        self.availableSpaceTextField.bordered = NO;
        self.availableSpaceTextField.selectable = NO;
        self.availableSpaceTextField.font = [NSFont systemFontOfSize:10.0];
        
        [self addSubview:self.availableSpaceTextField];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSColor *blackColor = [NSColor colorWithCalibratedWhite:0.0
                                                      alpha:1.0];
    [blackColor setFill];
    NSRectFill(NSMakeRect(0.0, 0.0, self.frame.size.width, self.frame.size.height));
    
    NSColor *whiteColor = [NSColor colorWithCalibratedWhite:1.0
                                                      alpha:1.0];
    [whiteColor setFill];
    NSRectFill(NSMakeRect(1.0, 0.0, self.frame.size.width - 2.0, self.frame.size.height - 1.0));
}

- (BOOL)isFlipped
{
    return YES;
}

- (FileSizeMetrics)determineFileSizeMetric:(NSInteger)fileSize
{
    FileSizeMetrics selectedMetric = kByteMetric;
    
    if (fileSize < 1024) {
        selectedMetric = kByteMetric;
    } else if ((fileSize >= 1024) && (fileSize < 1048576)) {
        selectedMetric = kKilobyteMetric;
    } else if ((fileSize >= 1048576) && (fileSize < 1073741824)) {
        selectedMetric = kMegabyteMetric;
    } else if ((fileSize >= 1073741824) && (fileSize < 1099511627776)) {
        selectedMetric = kGigabyteMetric;
    } else if (fileSize >= 1099511627776) {
        selectedMetric = kTerabyteMetric;
    }
    
    return selectedMetric;
}

- (NSString *)formattedFreeSpace:(NSInteger) freeSpace
{
    NSString *formattedString = @"";
    FileSizeMetrics metric = [self determineFileSizeMetric:freeSpace];
    
    switch (metric) {
        case kByteMetric:
            formattedString = [NSString stringWithFormat:@"%ld bytes available", (long)freeSpace];
            break;
        case kKilobyteMetric:
            formattedString = [NSString stringWithFormat:@"%ld KB available", (long)(freeSpace / 1024)];
            break;
        case kMegabyteMetric:
            formattedString = [NSString stringWithFormat:@"%ld MB available", (long)(freeSpace / 1048576)];
            break;
        case kGigabyteMetric:
            formattedString = [NSString stringWithFormat:@"%ld GB available", (long)(freeSpace / 1073741824)];
            break;
        case kTerabyteMetric:
            formattedString = [NSString stringWithFormat:@"%ld TB available", (long)(freeSpace / 1099511627776)];
            break;
    }
    
    return formattedString;
}

- (NSString *)formattedTotalSpace:(NSInteger) totalSpace
{
    NSString *formattedString = @"";
    FileSizeMetrics metric = [self determineFileSizeMetric:totalSpace];
    
    switch (metric) {
        case kByteMetric:
            formattedString = [NSString stringWithFormat:@"%ld bytes total", (long)totalSpace];
            break;
        case kKilobyteMetric:
            formattedString = [NSString stringWithFormat:@"%ld KB total", (long)(totalSpace / 1024)];
            break;
        case kMegabyteMetric:
            formattedString = [NSString stringWithFormat:@"%ld MB total", (long)(totalSpace / 1048576)];
            break;
        case kGigabyteMetric:
            formattedString = [NSString stringWithFormat:@"%ld GB total", (long)(totalSpace / 1073741824)];
            break;
        case kTerabyteMetric:
            formattedString = [NSString stringWithFormat:@"%ld TB total", (long)(totalSpace / 1099511627776)];
            break;
    }
    
    return formattedString;
}

- (void)setNumberOfFileItemsText:(NSInteger) numberOfItems
{
    NSString *formattedText = @"";
    
    if (numberOfItems == 1) {
        formattedText = [NSString stringWithFormat:@"%ld item", numberOfItems];
    } else {
        formattedText = [NSString stringWithFormat:@"%ld items", numberOfItems];
    }
    
    self.itemCountTextField.stringValue = formattedText;
}




@end
