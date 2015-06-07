//
//  TNBBaseMovieItem.m
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBBaseMovieItem.h"

@interface TNBBaseMovieItem()

@property (nonatomic, strong, readwrite) NSNumber *id;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSNumber *voteAverage;

@property (nonatomic, strong, readwrite) NSString *originalLanguage;
@property (nonatomic, strong, readwrite) NSString *originalTitle;

@property (nonatomic, strong, readwrite) NSString *overView;

@property (nonatomic, strong, readwrite) NSString *posterPath;
@property (nonatomic, strong, readwrite) NSString *backdropPath;



@end

@implementation TNBBaseMovieItem

- (id)initWithDictionary: (NSDictionary *)dictionary {
	self = [self init];
	if (self) {
		self.id = DYNAMIC_CAST(dictionary[@"id"], NSNumber);
		self.title = DYNAMIC_CAST(dictionary[@"id"], NSString);
		self.voteAverage = DYNAMIC_CAST(dictionary[@"id"], NSNumber);

		self.originalLanguage = DYNAMIC_CAST(dictionary[@"original_language"], NSString);
		self.originalTitle = DYNAMIC_CAST(dictionary[@"original_title"], NSString);

		self.overView = DYNAMIC_CAST(dictionary[@"overview"], NSString);

		self.posterPath = DYNAMIC_CAST(dictionary[@"poster_path"], NSString);
		self.backdropPath = DYNAMIC_CAST(dictionary[@"backdrop_path"], NSString);
	}

	return self;
}

@end
