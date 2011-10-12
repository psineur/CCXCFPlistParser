//
//  XCFPlistParserTests.m
//  XCFPlistParserTests
//
//  Created by Stepan Generalov on 08.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XCFPlistParserTests.h"
#import "XCFPlistParser.h"
#import "cocos2d.h"

@implementation XCFPlistParserTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testCreatingParserFromFile
{
    NSBundle *bundle = [NSBundle mainBundle];
    STAssertNotNil(bundle, @"Bundle is nil");
    
    NSString *path = [bundle pathForResource:@"Info" ofType: @"plist"];
    STAssertNotNil(path, @"Info.plist not found");
    
    XCFPlistParser *parser = [XCFPlistParser parserWithFile:@"CTHUDLayout.xcf.plist"];
    STAssertNotNil(parser, @"Parser creation failed");
    
    CGSize s = [parser documentSize];
    STAssertTrue(s.width == 480 && s.height == 320, @"Size = { %f, %f }", s.width, s.height);
}

- (void)testCreatingParserFromDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dict setObject:[NSNumber numberWithInt: 200] forKey:@"Width"];
    [dict setObject:[NSNumber numberWithInt: 100] forKey:@"Height"];
    
    NSMutableArray *layers = [NSMutableArray arrayWithCapacity: 3];
    [layers addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
                                                            [NSNumber numberWithInt: 22 ], 
                                                            [NSNumber numberWithInt: 3 ],
                                                            [NSNumber numberWithInt: 112 ], 
                                                            [NSNumber numberWithInt: 40 ],
                                                            @"LayerNumberOne", nil] 
                                                  forKeys:[NSArray arrayWithObjects:@"X", @"Y", @"Width", @"Height", @"Name", nil] ]];
    
    [layers addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
                                                           [NSNumber numberWithInt: 0 ], 
                                                           [NSNumber numberWithInt: 0 ],
                                                           [NSNumber numberWithInt: 156 ], 
                                                           [NSNumber numberWithInt: 43 ],
                                                           @"LayerNumberTwo", nil] 
                                                  forKeys:[NSArray arrayWithObjects:@"X", @"Y", @"Width", @"Height", @"Name", nil] ]];
    
    [layers addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
                                                           [NSNumber numberWithInt: 22 ], 
                                                           [NSNumber numberWithInt: 13 ],
                                                           [NSNumber numberWithInt: 126 ], 
                                                           [NSNumber numberWithInt: 17 ],
                                                           @"LayerNumberThree", nil] 
                                                  forKeys:[NSArray arrayWithObjects:@"X", @"Y", @"Width", @"Height", @"Name", nil] ]];
    [dict setObject:layers forKey:@"Layers"];
    
    XCFPlistParser *parser = [XCFPlistParser parserWithDictionary: dict];
    STAssertNotNil(parser, @"Parser creation failed");
    
    CGSize s = [parser documentSize];
    STAssertTrue(s.width == 200.0f && s.height == 100.0f, @"Size = { %f, %f }", s.width, s.height);
    
    STAssertTrue( CGSizeEqualToSize( [parser sizeForLayerWithName:@"LayerNumberOne"], CGSizeMake(112.0f, 40.0f) ), @"" );
    STAssertTrue( CGSizeEqualToSize( [parser sizeForLayerWithName:@"LayerNumberTwo"], CGSizeMake(156.0f, 43.0f) ), @"" );
    STAssertTrue( CGSizeEqualToSize( [parser sizeForLayerWithName:@"LayerNumberThree"], CGSizeMake(126.0f, 17.0f) ), @"" );
    
    STAssertTrue( CGPointEqualToPoint([parser positionForLayerWithName:@"LayerNumberOne" ], ccp(22.0f, 3.0f)), @"" );
    STAssertTrue( CGPointEqualToPoint([parser positionForLayerWithName:@"LayerNumberTwo" ], ccp(0, 0)), @"" );
    STAssertTrue( CGPointEqualToPoint([parser positionForLayerWithName:@"LayerNumberThree" ], ccp(22.0f, 13.0f)), @"" );
    
//    STAssertTrue( CGPointEqualToPoint([parser positionForLayerWithName:@"LayerNumberOne" transformCoordinatesToLeftBottom:YES], ccp(22.0f, 57.0f)), @"" );
//    STAssertTrue( CGPointEqualToPoint([parser positionForLayerWithName:@"LayerNumberTwo" transformCoordinatesToLeftBottom:YES], ccp(0, 57.0f)), @"" );
//    STAssertTrue( CGPointEqualToPoint([parser positionForLayerWithName:@"LayerNumberThree" transformCoordinatesToLeftBottom:YES], ccp(22.0f, 70.0f)), @"" );
    
    CCNode *n1 = [CCNode node];
    CCNode *n2 = [CCNode node];
    CCNode *n3 = [CCNode node];
    n1.contentSize = CGSizeMake(112.0f, 40.0f);
    n2.contentSize = CGSizeMake(156.0f, 43.0f);
    n3.contentSize = CGSizeMake(126.0f, 17.0f);
    
    CCNode *n1hd = [CCNode node];
    CCNode *n2hd = [CCNode node];
    CCNode *n3hd = [CCNode node];
    n1hd.contentSize = CGSizeMake( 0.5f * n1.contentSize.width, 0.5f * n1.contentSize.height);
    n2hd.contentSize = CGSizeMake( 0.5f * n2.contentSize.width, 0.5f * n2.contentSize.height);
    n3hd.contentSize = CGSizeMake( 0.5f * n3.contentSize.width, 0.5f * n3.contentSize.height);
    
    [parser transformNode:n1 forLayerWithName:@"LayerNumberOne"];
    [parser transformNode:n2 forLayerWithName:@"LayerNumberTwo"];
    [parser transformNode:n3 forLayerWithName:@"LayerNumberThree"];
    
    [parser transformNode:n1hd forLayerWithName:@"LayerNumberOne"];
    [parser transformNode:n2hd forLayerWithName:@"LayerNumberTwo"];
    [parser transformNode:n3hd forLayerWithName:@"LayerNumberThree"];
    
    STAssertTrue(n1.scaleX == n1.scaleY == n1.scale == 1.0f, @"");
    STAssertTrue(n2.scaleX == n2.scaleY == n2.scale == 1.0f, @"");
    STAssertTrue(n3.scaleX == n3.scaleY == n3.scale == 1.0f, @"");
    
    STAssertTrue(n1hd.scale == 2.0f, @"n1hd scaleX = %f, scaleY=%f, scale = %f", n1hd.scaleX, n1hd.scaleY, n1hd.scale);
    STAssertTrue(n2hd.scale == 2.0f, @"n2hd scaleX = %f, scaleY=%f, scale = %f", n2hd.scaleX, n2hd.scaleY, n2hd.scale);
    STAssertTrue(n3hd.scale == 2.0f, @"n3hd scaleX = %f, scaleY=%f, scale = %f", n3hd.scaleX, n3hd.scaleY, n3hd.scale);    
}

- (void) testZOrderFromFile
{
    NSBundle *bundle = [NSBundle mainBundle];
    STAssertNotNil(bundle, @"Bundle is nil");
    
    NSString *path = [bundle pathForResource:@"Info" ofType: @"plist"];
    STAssertNotNil(path, @"Info.plist not found");
    
    XCFPlistParser *parser = [XCFPlistParser parserWithFile:@"CTHUDLayout.xcf.plist"];
    STAssertNotNil(parser, @"Parser creation failed");
    
    CGSize s = [parser documentSize];
    STAssertTrue(s.width == 480 && s.height == 320, @"Size = { %f, %f }", s.width, s.height);
    
    NSInteger z1 = [parser zOrderForLayerWithName: @"CTHUDIndicatorCoins"];
    NSInteger z2 = [parser zOrderForLayerWithName: @"NOT PARSED - coin icon"];
    NSInteger z3 = [parser zOrderForLayerWithName: @"CTHUDIndicatorWood"];
    NSInteger zNone = [parser zOrderForLayerWithName:@"No such layer should exist."];
    
    STAssertTrue(z1 == 1, @"", @"Wrong z = %d", z1);
    STAssertTrue(z2 == 2, @"", @"Wrong z = %d", z2);
    STAssertTrue(z3 == 3, @"", @"Wrong z = %d", z3);
    STAssertTrue(zNone == -1, @"No such layer should exist. Z = %d", zNone);
    
}

- (void) testAllLayersNames
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dict setObject:[NSNumber numberWithInt: 200] forKey:@"Width"];
    [dict setObject:[NSNumber numberWithInt: 100] forKey:@"Height"];
    
    NSMutableArray *layers = [NSMutableArray arrayWithCapacity: 3];
    [layers addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
                                                           [NSNumber numberWithInt: 22 ], 
                                                           [NSNumber numberWithInt: 3 ],
                                                           [NSNumber numberWithInt: 112 ], 
                                                           [NSNumber numberWithInt: 40 ],
                                                           @"LayerNumberOne", nil] 
                                                  forKeys:[NSArray arrayWithObjects:@"X", @"Y", @"Width", @"Height", @"Name", nil] ]];
    
    [layers addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
                                                           [NSNumber numberWithInt: 0 ], 
                                                           [NSNumber numberWithInt: 0 ],
                                                           [NSNumber numberWithInt: 156 ], 
                                                           [NSNumber numberWithInt: 43 ],
                                                           @"LayerNumberTwo", nil] 
                                                  forKeys:[NSArray arrayWithObjects:@"X", @"Y", @"Width", @"Height", @"Name", nil] ]];
    
    [layers addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
                                                           [NSNumber numberWithInt: 22 ], 
                                                           [NSNumber numberWithInt: 13 ],
                                                           [NSNumber numberWithInt: 126 ], 
                                                           [NSNumber numberWithInt: 17 ],
                                                           @"LayerNumberThree", nil] 
                                                  forKeys:[NSArray arrayWithObjects:@"X", @"Y", @"Width", @"Height", @"Name", nil] ]];
    [dict setObject:layers forKey:@"Layers"];
    
    XCFPlistParser *parser = [XCFPlistParser parserWithDictionary: dict];
    STAssertNotNil(parser, @"Parser creation failed");
    
    STAssertTrue([[parser layersNames] count] == 3, @"layerNames count = %d",[[parser layersNames] count] );
    STAssertTrue([[[parser layersNames] objectAtIndex: 0] isEqual: @"LayerNumberOne"], @"LayerName[0] = %@", [[parser layersNames] objectAtIndex: 0] );
    STAssertTrue([[[parser layersNames] objectAtIndex: 1] isEqual: @"LayerNumberTwo"], @"LayerName[1] = %@", [[parser layersNames] objectAtIndex: 1] );
    STAssertTrue([[[parser layersNames] objectAtIndex: 2] isEqual: @"LayerNumberThree"], @"LayerName[2] = %@", [[parser layersNames] objectAtIndex: 2] );
}

- (void) testAllLayersPositions
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dict setObject:[NSNumber numberWithInt: 200] forKey:@"Width"];
    [dict setObject:[NSNumber numberWithInt: 100] forKey:@"Height"];
    
    NSMutableArray *layers = [NSMutableArray arrayWithCapacity: 3];
    [layers addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
                                                           [NSNumber numberWithInt: 22 ], 
                                                           [NSNumber numberWithInt: 3 ],
                                                           [NSNumber numberWithInt: 112 ], 
                                                           [NSNumber numberWithInt: 40 ],
                                                           @"LayerNumberOne", nil] 
                                                  forKeys:[NSArray arrayWithObjects:@"X", @"Y", @"Width", @"Height", @"Name", nil] ]];
    
    [layers addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
                                                           [NSNumber numberWithInt: 0 ], 
                                                           [NSNumber numberWithInt: 0 ],
                                                           [NSNumber numberWithInt: 156 ], 
                                                           [NSNumber numberWithInt: 43 ],
                                                           @"LayerNumberTwo", nil] 
                                                  forKeys:[NSArray arrayWithObjects:@"X", @"Y", @"Width", @"Height", @"Name", nil] ]];
    
    [layers addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
                                                           [NSNumber numberWithInt: 22 ], 
                                                           [NSNumber numberWithInt: 13 ],
                                                           [NSNumber numberWithInt: 126 ], 
                                                           [NSNumber numberWithInt: 17 ],
                                                           @"LayerNumberThree", nil] 
                                                  forKeys:[NSArray arrayWithObjects:@"X", @"Y", @"Width", @"Height", @"Name", nil] ]];
    [dict setObject:layers forKey:@"Layers"];
    
    XCFPlistParser *parser = [XCFPlistParser parserWithDictionary: dict];
    STAssertNotNil(parser, @"Parser creation failed");
    
    STAssertTrue([[parser allLayersPositions] count] == 3, @"layer positions count = %d",[[parser allLayersPositions] count] );
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    CGPoint point1 = [[[parser allLayersPositions] objectAtIndex:0] CGPointValue];
    CGPoint point2 = [[[parser allLayersPositions] objectAtIndex:1] CGPointValue];
    CGPoint point3 = [[[parser allLayersPositions] objectAtIndex:2] CGPointValue];
#elif defined (__MAC_OS_X_VERSION_MAX_ALLOWED)
    NSPoint point1 = [[[parser allLayersPositions] objectAtIndex:0] pointValue];
    NSPoint point2 = [[[parser allLayersPositions] objectAtIndex:1] pointValue];
    NSPoint point3 = [[[parser allLayersPositions] objectAtIndex:2] pointValue];
#endif
    
    STAssertTrue(point1.x == 22.0f && point1.y == 3.0f, @"Point 1 = {%f, %f}", point1.x, point1.y);
    STAssertTrue(point2.x == 0.0f && point2.y == 0.0f, @"Point 2 = {%f, %f}", point2.x, point2.y);
    STAssertTrue(point3.x == 22.0f && point3.y == 13.0f, @"Point 3 = {%f, %f}", point3.x, point3.y);
}

@end
