//
//  main.m
//  KanjiParser
//
//  Created by Ewan Leaver on 21/04/2014.
//  Copyright (c) 2014 Ewan Leaver. All rights reserved.
//

#import "Home.h"
#import "Deck.h"
#import "Character.h"
#import "StudyDetails.h"
#import "TempStudyDetails.h"
#import "XMLParser.h"

NSManagedObjectContext *context;

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    //NSString *path = @"KanjiDB";
    //path = [path stringByDeletingPathExtension];
    NSString *path = @"KanjiDB";
    
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSLog(@"%@", managedObjectModel());
        
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

void createCharacters() {
    
    XMLParser *parser = [XMLParser alloc];
    
    NSMutableDictionary *kanjiDic = [parser loadXML];
    
    for (id key in kanjiDic) {
        
        //NSLog(@"key: %@, value: %@", key, [kanjiDic objectForKey:key]);
        
        // !! Character for everything parsed. Study details for anything else. !!
        
        Character *character = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Character"
                                inManagedObjectContext:context];
        character.id_num = kanjiDic[key][0];
        
        character.literal = kanjiDic[key][1];
        
        character.jlpt = kanjiDic[key][2];
        
        
        NSData *arrayData;
        
        arrayData = [NSKeyedArchiver archivedDataWithRootObject:[kanjiDic[key][3] valueForKey:@"description"]];
        character.reading_kun = arrayData;
        
        arrayData = [NSKeyedArchiver archivedDataWithRootObject:[kanjiDic[key][4] valueForKey:@"description"]];
        character.reading_on = arrayData;
        
        arrayData = [NSKeyedArchiver archivedDataWithRootObject:[kanjiDic[key][5] valueForKey:@"description"]];
        character.reading_pin = arrayData;
        
        arrayData = [NSKeyedArchiver archivedDataWithRootObject:[kanjiDic[key][6] valueForKey:@"description"]];
        character.meaning = arrayData;
        
        
        //            NSString *readings_kun = [[kanjiDic[key][3] valueForKey:@"description"] componentsJoinedByString:@", "];
        //            character.reading_kun = readings_kun;
        //
        //            NSString *readings_on = [[kanjiDic[key][4] valueForKey:@"description"] componentsJoinedByString:@", "];
        //            character.reading_on = readings_on;
        //
        //            NSString *readings_pin = [[kanjiDic[key][5] valueForKey:@"description"] componentsJoinedByString:@", "];
        //            character.reading_pin = readings_pin;
        //
        //            NSString *meanings = [[kanjiDic[key][6] valueForKey:@"description"] componentsJoinedByString:@", "];
        //            character.meaning = meanings;
        
        StudyDetails *studyDetails = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"StudyDetails"
                                      inManagedObjectContext:context];
        
        studyDetails.lastStudied = nil;
        studyDetails.intervalNum = 0;
        studyDetails.interval = 0;
        studyDetails.quality = nil;
        studyDetails.eFactor = [NSNumber numberWithDouble:2.5]; // Default value
        studyDetails.character = character;
        character.studyDetails = studyDetails;
        
        TempStudyDetails *tempStudyDetails = [NSEntityDescription
                                              insertNewObjectForEntityForName:@"TempStudyDetails"
                                              inManagedObjectContext:context];
        tempStudyDetails.isStudying = false;
        tempStudyDetails.numCorrect = 0;
        tempStudyDetails.numIncorrect = 0;
        tempStudyDetails.studyDetails = studyDetails;
        studyDetails.tempStudyDetails = tempStudyDetails;
        
    }
    
}

void createDecks() {

    // Create our home object (contains all the decks)
    Home *home = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Home"
                  inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest;
    NSEntityDescription *entity;
    
    NSMutableSet *cardsInDeck = [[NSMutableSet alloc] init];
    NSMutableArray *results;
    
    NSError *error;
    Character *ch;
    
    NSDictionary *bubbleColour;
    NSData *bubbleColourData;
    
    //
    // Build test deck
    //
    Deck *testDeck = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Deck"
                    inManagedObjectContext:context];
    
    testDeck.name = @"Review";
    
    bubbleColour = @{
                                   @"r" : @65,
                                   @"g" : @142,
                                   @"b" : @255,
                                   };
    
    bubbleColourData = [NSKeyedArchiver archivedDataWithRootObject:bubbleColour];
    testDeck.bubbleColour = bubbleColourData;
    
    int i = 1000;
    while (i < 1020) {
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription
                  entityForName:@"Character" inManagedObjectContext:context];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id_num == %@", [NSString stringWithFormat:@"%d",i]]];
        [fetchRequest setEntity:entity];
        
        results = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
        
        //NSLog(@"%lu cards found",(unsigned long)[results count]);
        for (int k=0; k<[results count]; k++) {
            ch = [results objectAtIndex:k];
            
            [cardsInDeck addObject:ch];
        }
        
        i++;
    }
    
    testDeck.cardsInDeck = cardsInDeck;
    testDeck.numToStudy = [NSNumber numberWithLong:[cardsInDeck count]];
    
    [home addAvailableDecksObject:testDeck];
   
    //
    // Build deck for N3
    //
    Deck *jlptN4 = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Deck"
                    inManagedObjectContext:context];
    
    jlptN4.name = @"JLPT N4";
    
    bubbleColour = @{
                     @"r" : @200,
                     @"g" : @140,
                     @"b" : @255,
                     };
    
    bubbleColourData = [NSKeyedArchiver archivedDataWithRootObject:bubbleColour];
    jlptN4.bubbleColour = bubbleColourData;
    
    // Create and execute fetch request for all cards at N3 level
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Character" inManagedObjectContext:context];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"jlpt == %@", @"4"]];
    [fetchRequest setEntity:entity];
    
    results = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    
    cardsInDeck = [[NSMutableSet alloc] init];
    NSLog(@"%lu cards found",(unsigned long)[results count]);
    for (int k=0; k<[results count]; k++) {
        ch = [results objectAtIndex:k];
        
        [cardsInDeck addObject:ch];
        //[deckArray addObject:[NSNumber numberWithInt:ch.id_num.intValue]];
    }
    jlptN4.cardsInDeck = cardsInDeck;
    jlptN4.numToStudy = [NSNumber numberWithLong:[cardsInDeck count]];
    
    [home addAvailableDecksObject:jlptN4];
    
    //
    // Build deck for N3
    //
    Deck *jlptN3 = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Deck"
                    inManagedObjectContext:context];
    
    jlptN3.name = @"JLPT N3";
    
    bubbleColour = @{
       @"r" : @100,
       @"g" : @240,
       @"b" : @120,
    };
    
    bubbleColourData = [NSKeyedArchiver archivedDataWithRootObject:bubbleColour];
    jlptN3.bubbleColour = bubbleColourData;
    
    // Create and execute fetch request for all cards at N3 level
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
                                   entityForName:@"Character" inManagedObjectContext:context];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"jlpt == %@", @"3"]];
    [fetchRequest setEntity:entity];
    
    results = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    
    cardsInDeck = [[NSMutableSet alloc] init];
    NSLog(@"%lu cards found",(unsigned long)[results count]);
    for (int k=0; k<[results count]; k++) {
        ch = [results objectAtIndex:k];
        
        [cardsInDeck addObject:ch];
        //[deckArray addObject:[NSNumber numberWithInt:ch.id_num.intValue]];
    }
    jlptN3.cardsInDeck = cardsInDeck;
    jlptN3.numToStudy = [NSNumber numberWithLong:[cardsInDeck count]];
    
    [home addAvailableDecksObject:jlptN3];
    
    
    //
    // Build deck for JLPT N2
    //
    Deck *jlptN2 = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Deck"
                    inManagedObjectContext:context];
    
    jlptN2.name = @"JLPT N2";

    bubbleColour = @{
       @"r" : @255,
       @"g" : @139,
       @"b" : @88,
    };
    
    bubbleColourData = [NSKeyedArchiver archivedDataWithRootObject:bubbleColour];
    jlptN2.bubbleColour = bubbleColourData;
    
    // Create and execute fetch request for all cards at N2 level
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
                                   entityForName:@"Character" inManagedObjectContext:context];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"jlpt == %@", @"2"]];
    [fetchRequest setEntity:entity];
    
    error = nil;
    results = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    
    cardsInDeck = [[NSMutableSet alloc] init];
    NSLog(@"%lu cards found",(unsigned long)[results count]);
    for (int k=0; k<[results count]; k++) {
        ch = [results objectAtIndex:k];
        
        [cardsInDeck addObject:ch];
        //[deckArray addObject:[NSNumber numberWithInt:ch.id_num.intValue]];
    }
    jlptN2.cardsInDeck = cardsInDeck;
    jlptN2.numToStudy = [NSNumber numberWithLong:[cardsInDeck count]];
    
    // Add deck to home object
    [home addAvailableDecksObject:jlptN2];
    
    
    //
    // Build deck for N1
    //
    Deck *jlptN1 = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Deck"
                    inManagedObjectContext:context];
    
    jlptN1.name = @"JLPT N1";
    
    bubbleColour = @{
                     @"r" : @255,
                     @"g" : @83,
                     @"b" : @91,
                     };
    
    bubbleColourData = [NSKeyedArchiver archivedDataWithRootObject:bubbleColour];
    jlptN1.bubbleColour = bubbleColourData;
    
    // Create and execute fetch request for all cards at N3 level
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Character" inManagedObjectContext:context];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"jlpt == %@", @"1"]];
    [fetchRequest setEntity:entity];
    
    results = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    
    cardsInDeck = [[NSMutableSet alloc] init];
    NSLog(@"%lu cards found",(unsigned long)[results count]);
    for (int k=0; k<[results count]; k++) {
        ch = [results objectAtIndex:k];
        
        [cardsInDeck addObject:ch];
        //[deckArray addObject:[NSNumber numberWithInt:ch.id_num.intValue]];
    }
    jlptN1.cardsInDeck = cardsInDeck;
    jlptN1.numToStudy = [NSNumber numberWithLong:[cardsInDeck count]];
    
    [home addAvailableDecksObject:jlptN1];
    
    
    
    NSLog(@"Decks objects added.");
    
//    NSSet *inserts = [context insertedObjects];
//    
//    if ([inserts count]) {
//        error = nil;
//        
//        if ([context obtainPermanentIDsForObjects:[inserts allObjects] error:&error] == NO) {
//            NSLog(@"BAM! %@",error);
//        }
//    }
//    
//    if (![context save:&error]) {
//        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//    }
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        context = managedObjectContext();
        
        // Custom code here...
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        // Create all character objects
        createCharacters();
        
        // Let's create some sample decks to populate the app.
        createDecks();
        
        error = nil;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        
//        [Chars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            Character *character = [NSEntityDescription
//                                              insertNewObjectForEntityForName:@"Character"
//                                              inManagedObjectContext:context];
//            character.literal = [obj objectForKey:@"literal"];
//            character.reading_kun = [obj objectForKey:@"reading_kun"];
//            character.reading_on = [obj objectForKey:@"reading_on"];
//            StudyDetails *studyDetails = [NSEntityDescription
//                                                    insertNewObjectForEntityForName:@"StudyDetails"
//                                                    inManagedObjectContext:context];
//            studyDetails.lastStudied = [NSDate dateWithString:[obj objectForKey:@"lastStudied"]];
//            studyDetails.jlpt = [obj objectForKey:@"jlpt"];
//            studyDetails.character = character;
//            character.studyDetails = studyDetails;
//            NSError *error;
//            if (![context save:&error]) {
//                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//            }
//        }];
        
        // Test listing all Characters from the store
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Character"
//                                                  inManagedObjectContext:context];
//        [fetchRequest setEntity:entity];
//        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//        for (Character *character in fetchedObjects) {
//            NSLog(@"Literal: %@", character.literal);
//            StudyDetails *studyDetails = character.studyDetails;
//            NSLog(@"jlpt: %@", studyDetails.jlpt);
//        }
        
    }
    NSLog(@"Good night");
    return 0;
}

