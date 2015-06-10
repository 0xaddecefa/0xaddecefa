//
//  TNBExtendedMovieItem.h
//  buster
//
//  Created by Tamas Nemeth on 08/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBBaseMovieItem.h"

@interface TNBExtendedMovieItem : TNBBaseMovieItem
@property (nonatomic, strong, readonly) NSString *tagline;
@property (nonatomic, strong, readonly) NSDate *releaseDate;

@property (nonatomic, strong, readonly) NSArray	*spokenLanguages;
@property (nonatomic, strong, readonly) NSArray *productionCountries;
@property (nonatomic, strong, readonly) NSArray *productionCompanies;
@property (nonatomic, strong, readonly) NSArray *genres;

@end
