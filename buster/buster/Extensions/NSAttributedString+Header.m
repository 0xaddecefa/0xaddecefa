//
//  NSAttributedString+Header.m
//  buster
//
//  Created by Tamas Nemeth on 10/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSAttributedString+Header.h"
#import "NSArray+BlocksKit.h"


@implementation NSString (arrayFormat)

//can handle only NSObject parameters %@
+ (id)stringWithFormat:(NSString *)format array:(NSArray*) arguments;
{
	NSString *result = format;
	for (NSObject *item in arguments) {
		NSRange range = [result rangeOfString:@"%@"];
		if (range.location != NSNotFound) {
			result = [result stringByReplacingOccurrencesOfString:@"%@" withString:item.description options:0 range:range];
		}
	}

	return result;
}

- (NSArray *)allRangeOfSubString:(NSString *)subString {
	NSMutableArray *array = [NSMutableArray array];
	NSRange searchRange = NSMakeRange(0,self.length);
	NSRange foundRange;
	while (searchRange.location < self.length) {
		searchRange.length = self.length-searchRange.location;
		foundRange = [self rangeOfString:@"%@" options:0 range:searchRange];
		if (foundRange.location != NSNotFound) {
			[array addObject:[NSValue valueWithRange:foundRange]];
			searchRange.location = foundRange.location+foundRange.length;
		} else {
			break;
		}
	}
	return [array copy];
}

@end

@implementation NSAttributedString (Header)

+ (NSAttributedString *)attributedStringWithFormat: (NSString *)formatString
											values: (NSArray *)values
										specifiers: (NSArray *)specifiers {

	assert(values.count + 1 == specifiers.count);
	NSArray *locations = [formatString allRangeOfSubString:@"%@"];
	assert(locations.count <= values.count);

	__block int index = 0;
	__block int offset = 0;
	locations = [locations bk_map:^id(id obj) {
		NSValue *currentValue = DYNAMIC_CAST(obj, NSValue);
		NSString *currentReplaceString = [values[index] description];
		index++;
		if (currentValue) {
			NSRange currentRange = [currentValue rangeValue];
			currentRange.location +=offset;
			currentRange.length = currentReplaceString.length;
			offset +=currentReplaceString.length - 2;
			NSValue *updatedValue = [NSValue valueWithRange:currentRange];
			return updatedValue;
		}
		return obj;
	}];

	NSString *string = [NSString stringWithFormat:formatString array:values];
	__block NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:specifiers[0]];

	index = 0;
	for (NSObject *value in locations) {
		NSValue *currentValue = DYNAMIC_CAST(value, NSValue);
		if (currentValue) {
			NSRange currentRange = [currentValue rangeValue];
			[mutableAttributedString addAttributes:specifiers[index+1] range:currentRange];
			index++;
		}
	}
	//    [locations bk_apply:^(id obj) {
	//        NSValue *currentValue = DYNAMIC_CAST(obj, NSValue);
	//        if (currentValue) {
	//            NSRange currentRange = [currentValue rangeValue];
	//            [mutableAttributedString addAttributes:specifiers[index+1] range:currentRange];
	//            index++;
	//        }
	//    }];

	return [mutableAttributedString copy];
}

@end
