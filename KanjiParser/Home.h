//
//  Home.h
//  deck
//
//  Created by Ewan Leaver on 30/10/2014.
//  Copyright (c) 2014 Ewan Leaver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Deck;

@interface Home : NSManagedObject

@property (nonatomic, retain) NSNumber * numDecks;
@property (nonatomic, retain) NSSet *availableDecks;
@end

@interface Home (CoreDataGeneratedAccessors)

- (void)addAvailableDecksObject:(Deck *)value;
- (void)removeAvailableDecksObject:(Deck *)value;
- (void)addAvailableDecks:(NSSet *)values;
- (void)removeAvailableDecks:(NSSet *)values;

@end
