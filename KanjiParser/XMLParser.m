//
//  XMLParser.m
//  KanjiParser
//
//  Created by Ewan Leaver on 18/05/2014.
//  Copyright (c) 2014 Ewan Leaver. All rights reserved.
//

#import "XMLParser.h"
#import "TBXML.h"

@implementation XMLParser

int count;
int charCount;

- (NSMutableDictionary *)loadXML {
    
//    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"kanjidic2" ofType:@"xml"];
//
//    NSData *myData = [NSData dataWithContentsOfFile:dataPath];
//    
//    TBXML *sourceXML = [[TBXML alloc] initWithXMLData:myData error:nil];
//    
//    NSLog(@"Path: %@", dataPath);
//    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
//        NSLog(@"Where is the file?");
//    }
    
    TBXML *sourceXML = [[TBXML alloc] initWithXMLFile:@"kanjidic2.xml" error:nil];
    
    TBXMLElement *rootElement = sourceXML.rootXMLElement;
    
    if (rootElement == nil) {
        NSLog(@"Root element unknown!");
    }
    
    NSMutableDictionary *kanjiDic = [self traverseElement:rootElement];
    
    NSLog(@"Good morning");
    
    return kanjiDic;
    
}

- (NSMutableDictionary *)traverseElement:(TBXMLElement *)element {
    
    charCount = 0;
    
    NSArray *keys = [NSArray arrayWithObjects:@"id_num", @"lit", @"JLPT", @"read_kun", @"read_on", @"read_pin", @"meaning", nil];
    NSMutableArray *kanji = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *kanjiDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil, keys, nil];
    
    while (true) {
        do {
            
            if ([[TBXML elementName:element] isEqualToString:@"kanjidic2"]) {
                
                NSLog(@"%@",[TBXML elementName:element]);
                
                // Check the element has child elements...
                if (element->firstChild) {
                    
                    NSLog(@"Beginning character traversal...");
                    
                    // if the element has child elements, process them
                    //[self traverseElement:element->firstChild];
                    
                    element = element->firstChild; // Starting at the child element
                    
                    do {
                        
                        // Process character
                        kanji = [self traverseChar:element->firstChild];
                        
                        // Process the received NSArray for character
                        NSString *idNum = [NSString stringWithFormat:@"%d", charCount];
                        
                        [kanjiDic setObject:kanji forKey:idNum];
                        
                    } while ((element = element->nextSibling)); // Else move onto next sibling
                    
                }
                break;
                
            }
            //NSLog(@"%@",[TBXML elementName:element]);
            
        } while ((element = element->nextSibling)); // Else move onto next sibling
        
        //NSLog(@"%p", [NSThread currentThread]);
        NSLog(@"Found: %d kanji", charCount);
        NSLog(@"Added: %lu kanji", (unsigned long)[kanjiDic count]);
        break;
    }
    
    return kanjiDic;
    
}

- (NSMutableArray *)traverseChar:(TBXMLElement *)element {
    
    //NSString *idNum = @"null";
    NSString *id_num = @"null";
    NSString *lit = @"null";
    NSString *JLPT = @"null";
    NSMutableArray *read_pin = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray *read_kun = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray *read_on = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray *meaning = [[NSMutableArray alloc] initWithObjects:nil];
    
    do {
        
        if ([[TBXML elementName:element] isEqualToString:@"literal"]) {
            
            charCount++;
            
            id_num = [NSString stringWithFormat:@"%d", charCount];
            
            lit = [TBXML textForElement:element];
    
        } else if ([[TBXML elementName:element] isEqualToString:@"misc"]) {
            
            TBXMLElement *jlptElement = [TBXML childElementNamed:@"jlpt" parentElement:element];
            
            // If there is a JLPT level, set it. Otherwise will remain null.
            if (jlptElement != nil) {
                //NSLog(@"%@",[TBXML textForElement:JLPTelem]);
                JLPT = [TBXML textForElement:jlptElement];
            }
        
        } else if ([[TBXML elementName:element] isEqualToString:@"reading_meaning"]) {
            
            //NSLog(@"%@",[TBXML elementName:element]);
            TBXMLElement *rmElement = [TBXML childElementNamed:@"rmgroup" parentElement:element];
            TBXMLElement *subElement = rmElement->firstChild; // Going down two levels
            
            //NSLog(@"%@",[TBXML elementName:subElement]);
            
            do {
                //NSLog(@"%@",[TBXML elementName:subElement]);
                
                if ([[TBXML elementName:subElement] isEqualToString:@"reading"]) {

                    TBXMLAttribute *attribute = subElement->firstAttribute;
                    
//                    NSLog(@"%@->%@ = %@",
//                          [TBXML elementName:subElement],
//                          [TBXML attributeName:attribute],
//                          [TBXML attributeValue:attribute]);
                    
                    if ([[TBXML attributeValue:attribute] isEqualToString:@"pinyin"]) {
                        //NSLog(@"Pinyin reading: %@", [TBXML textForElement:subElement]);
                        [read_pin addObject:[TBXML textForElement:subElement]];
                    } else if ([[TBXML attributeValue:attribute] isEqualToString:@"ja_kun"]) {
                        //NSLog(@"Kun reading: %@", [TBXML textForElement:subElement]);
                        [read_kun addObject:[TBXML textForElement:subElement]];
                    } else if ([[TBXML attributeValue:attribute] isEqualToString:@"ja_on"]) {
                        //NSLog(@"On reading: %@", [TBXML textForElement:subElement]);
                        [read_on addObject:[TBXML textForElement:subElement]];
                    }
                    
                } else if ([[TBXML elementName:subElement] isEqualToString:@"meaning"]) {
                
                    TBXMLAttribute *attribute = subElement->firstAttribute;
                    
                    // Only for English meanings... (no attribute)
                    if (!attribute) {
                        [meaning addObject:[TBXML textForElement:subElement]];
                    }
                    
                }
                
                
            } while ((subElement = subElement->nextSibling)); // Else move onto next sibling
            
            
        }
        
        
        
        
    } while ((element = element->nextSibling)); // Else move onto next sibling
    
    NSMutableArray *kanji = [[NSMutableArray alloc] initWithObjects:id_num, lit, JLPT, read_kun, read_on, read_pin, meaning, nil];
    
    return kanji;
    
}

@end
