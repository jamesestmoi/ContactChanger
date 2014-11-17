//
//  main.m
//  ContactChanger
//
//  Created by James Pickering on 11/17/14.
//  Copyright (c) 2014 Wire Tec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#import "NSColor+iOS7Colors.h"

@interface NSTextFieldCell (ABTextField)

@end

@implementation NSTextFieldCell (ABTextField)

- (NSRect) titleRectForBounds:(NSRect)frame {
    
    CGFloat stringHeight       = self.attributedStringValue.size.height;
    NSRect titleRect          = [super titleRectForBounds:frame];
    titleRect.origin.y = frame.origin.y +
    (frame.size.height - stringHeight) / 2.0;
    return titleRect;
}
- (void) drawInteriorWithFrame:(NSRect)cFrame inView:(NSView*)cView {
    [super drawInteriorWithFrame:[self titleRectForBounds:cFrame] inView:cView];
}

@end

@interface ABView : NSView

@property NSTextField *initialsLabel;
- (void)setInitials:(NSString *)initials;

@end

@implementation ABView

+ (NSArray *)colors {
    NSArray *colors = @[[NSColor iOS7orangeColor], [NSColor iOS7yellowColor], [NSColor iOS7greenColor], [NSColor iOS7lightBlueColor], [NSColor iOS7darkBlueColor], [NSColor iOS7purpleColor], [NSColor iOS7pinkColor]];
    return colors;
}

- (id)init {
    self = [super init];
    
    
    
    [self setWantsLayer:YES];
    NSUInteger randomIndex = arc4random() % [[ABView colors] count];
    [self.layer setBackgroundColor:((NSColor *)[[ABView colors] objectAtIndex:randomIndex]).CGColor];
    [self setFrame:NSMakeRect(0, 0, 100, 100)];
    
    self.initialsLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(-2, 0, 104, 100)];
    self.initialsLabel.textColor = [NSColor whiteColor];
    self.initialsLabel.font = [NSFont fontWithName:@"Helvetica Neue Light" size:35];
    self.initialsLabel.backgroundColor = [NSColor clearColor];
    
    self.initialsLabel.bezeled         = NO;
    self.initialsLabel.editable        = NO;
    self.initialsLabel.drawsBackground = NO;
    
    self.initialsLabel.alignment = NSCenterTextAlignment;
    
    [self addSubview:self.initialsLabel];
    
    return self;
}

- (void)setInitials:(NSString *)initials {
    [self.initialsLabel setStringValue:initials];
}

- (NSImage *)imageRepresentation
{
    NSSize mySize = self.bounds.size;
    NSSize imgSize = NSMakeSize( mySize.width, mySize.height );
    
    NSBitmapImageRep *bir = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
    [bir setSize:imgSize];
    [self cacheDisplayInRect:[self bounds] toBitmapImageRep:bir];
    
    NSImage* image = [[NSImage alloc]initWithSize:imgSize];
    [image addRepresentation:bir];
    return image;
}

@end

/**
 * Log without timestamp
 * @param format String to print with format
 * @return void
 */
void JPLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSMutableString *formattedString = [[NSMutableString alloc] initWithFormat: format
                                                                     arguments: args];
    [formattedString appendString:@"\n"];
    va_end(args);
    [[NSFileHandle fileHandleWithStandardOutput]
     writeData: [formattedString dataUsingEncoding: NSNEXTSTEPStringEncoding]];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ABAddressBook *addressBook = [ABAddressBook sharedAddressBook];
        NSMutableArray *people = [[NSMutableArray alloc] init];
        
        for (char a = 'A'; a <= 'Z'; a++)
        {
            ABSearchElement *search = [ABPerson searchElementForProperty:kABFirstNameProperty label:nil key:nil value:[NSString stringWithFormat:@"%c", a] comparison:kABPrefixMatch];
            NSArray *locPeople = [addressBook recordsMatchingSearchElement:search];
            JPLog(@"--------- %c ---------", a);
            for (id person in locPeople) {
                [people addObject:person];
                JPLog(@"%@, %@", [person valueForKey:kABFirstNameProperty], [person valueForKey:kABLastNameProperty]);
            }
        }
        
        

        for (ABPerson *person in people) {
            NSString *firstI = [[[person valueForKey:kABFirstNameProperty] substringToIndex:1] uppercaseString];
            NSString *lastI = [[[person valueForKey:kABLastNameProperty] substringToIndex:1] uppercaseString];
            if (!firstI) {
                firstI = @"";
            }
            if (!lastI) {
                lastI = @"";
            }
            NSString *initials = [NSString stringWithFormat:@"%@%@", firstI, lastI];
            ABView *bgView = [[ABView alloc] init];
            [bgView setInitials:initials];
            NSImage *image = [bgView imageRepresentation];
            [person setImageData:[image TIFFRepresentation]];
        }
        [addressBook save];
    }
    return 0;
}
