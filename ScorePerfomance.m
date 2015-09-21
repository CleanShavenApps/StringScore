//
//  ScorePerfomance.m
//  StringScore
//
//  Created by Wieland Morgenstern on 22.02.13.
//  Copyright (c) 2013 Wieland Morgenstern. All rights reserved.
//

#import "ScorePerfomance.h"

#import "NSString+Score.h"

@implementation ScorePerfomance

- (id)init {
    if (self = [super init]) {
//        NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"random words" ofType:@"txt"];

        // this is a command line tool, how to include the text file?
        NSString *path = @"/Users/wm/Documents/random words 1000.txt";

        NSString *file = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];


        NSMutableArray *array = [NSMutableArray array];

        __block NSString *previous = [@"" retain];
        __block NSString *prevprevious = [@"" retain];

        // make groups of three
        [file enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {

            NSString *current = [NSString stringWithFormat:@"%@ %@ %@", prevprevious, previous, line];
            [array addObject:current];
            [prevprevious release];
            prevprevious = [previous retain];
            [previous release];
            previous = [line retain];

        }];
        
        self.randomWords = array;

        [self testXbyX];
    }
    return self;
}

- (void)testXbyX {

    NSDate *start = [NSDate date];

    for (NSString *word in self.randomWords) {
        @autoreleasepool {
            [self testRandomWordsWarmupWithString:word];
        }
    }

    
    NSTimeInterval timeInterval = fabs([start timeIntervalSinceNow]);
    NSLog(@"random words X random words: %@ (%ld)", @(timeInterval), self.randomWords.count * self.randomWords.count);
}

- (void)testRandomWordsWarmupWithString:(NSString *)testString {
    NSCharacterSet *invalidCharacterSet = [testString invalidCharacterSet];
    NSString *decomposedString = [testString decomposedStringWithInvalidCharacterSet:invalidCharacterSet];

    NSNumber *fuzziness = @(0.8);

    [self.randomWords enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
        [testString scoreAgainst:word fuzziness:fuzziness
                         options:(NSStringScoreOptionFavorSmallerWords & NSStringScoreOptionReducedLongStringPenalty)
             invalidCharacterSet:invalidCharacterSet
                decomposedString:decomposedString];
    }];
    
}

@end
