//
//  Deck.h
//  deck
//
//  Created by Ewan Leaver on 30/10/2014.
//  Copyright (c) 2014 Ewan Leaver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Character;

@interface Deck : NSManagedObject

@property (nonatomic, retain) id bubbleColour;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numToStudy;
@property (nonatomic, retain) NSSet *cardsInDeck;
@property (nonatomic, retain) NSManagedObject *home;
@end

@interface Deck (CoreDataGeneratedAccessors)

- (void)addCardsInDeckObject:(Character *)value;
- (void)removeCardsInDeckObject:(Character *)value;
- (void)addCardsInDeck:(NSSet *)values;
- (void)removeCardsInDeck:(NSSet *)values;

@end
