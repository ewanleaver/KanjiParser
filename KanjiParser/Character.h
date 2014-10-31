//
//  Character.h
//  deck
//
//  Created by Ewan Leaver on 30/10/2014.
//  Copyright (c) 2014 Ewan Leaver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StudyDetails;

@interface Character : NSManagedObject

@property (nonatomic, retain) NSString * id_num;
@property (nonatomic, retain) NSString * jlpt;
@property (nonatomic, retain) NSString * literal;
@property (nonatomic, retain) id meaning;
@property (nonatomic, retain) id reading_kun;
@property (nonatomic, retain) id reading_on;
@property (nonatomic, retain) id reading_pin;
@property (nonatomic, retain) NSSet *decks;
@property (nonatomic, retain) StudyDetails *studyDetails;
@end

@interface Character (CoreDataGeneratedAccessors)

- (void)addDecksObject:(NSManagedObject *)value;
- (void)removeDecksObject:(NSManagedObject *)value;
- (void)addDecks:(NSSet *)values;
- (void)removeDecks:(NSSet *)values;

@end
