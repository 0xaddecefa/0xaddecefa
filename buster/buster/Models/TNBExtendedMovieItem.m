//
//  TNBExtendedMovieItem.m
//  buster
//
//  Created by Tamas Nemeth on 08/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBExtendedMovieItem.h"
#import "NSArray+BlocksKit.h"

@interface TNBExtendedMovieItem()

@property (nonatomic, strong, readwrite) NSString *tagline;
@property (nonatomic, strong, readwrite) NSDate	*releaseDate;

@property (nonatomic, strong, readwrite) NSArray *spokenLanguages;
@property (nonatomic, strong, readwrite) NSArray *productionCountries;
@property (nonatomic, strong, readwrite) NSArray *productionCompanies;
@property (nonatomic, strong, readwrite) NSArray *genres;

@end

@implementation TNBExtendedMovieItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	self = [super initWithDictionary:dictionary];
	if (self) {

		self.tagline = DYNAMIC_CAST(dictionary[@"tagline"], NSString);

		NSString *releaseDateStr = DYNAMIC_CAST(dictionary[@"release_date"], NSString);
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"YYYY-MM-dd";
		self.releaseDate = [dateFormatter dateFromString:releaseDateStr];


		self.productionCompanies = [TNBExtendedMovieItem nameListOfItems: dictionary[@"production_companies"]];
		self.productionCountries = [TNBExtendedMovieItem nameListOfItems: dictionary[@"production_countries"]];
		self.spokenLanguages = [TNBExtendedMovieItem nameListOfItems: dictionary[@"spoken_languages"]];


	}
	return self;
}

//array is an array of dictionaries. Each dictionary should have "name" as key
+ (NSArray *)nameListOfItems:(NSArray *)array {
	array = DYNAMIC_CAST(array, NSArray);
	NSArray *filteredArray = [array bk_select:^BOOL(id obj) {
		NSDictionary *dictionary = DYNAMIC_CAST(obj, NSDictionary);
		return dictionary[@"name"] != nil;
	}];

	filteredArray = [filteredArray bk_map:^id(id obj) {
		NSDictionary *dictionary = DYNAMIC_CAST(obj, NSDictionary);
		return dictionary[@"name"];
	}];

	return filteredArray;
}

@end
