//
//  XCFPlistParser.m
//
//  Created by Stepan Generalov on 08.09.11.
//  Copyright 2011 Stepan Generalov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "XCFPlistParser.h"

@implementation XCFPlistParser

#pragma mark Init/DeInit

+ (id) parserWithFile: (NSString *) filename
{
    return [[[self alloc] initWithFile: filename] autorelease];
}

+ (id) parserWithDictionary: (NSDictionary *) dict
{
    return [[[self alloc] initWithDictionary: dict] autorelease];
}

- (id) initWithFile: (NSString *) filename
{
    NSString *extension = [filename pathExtension];
    filename = [filename stringByDeletingPathExtension];
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType: extension];
    
    return [self initWithDictionary: [NSDictionary dictionaryWithContentsOfFile: path] ];
}


- (id) initWithDictionary: (NSDictionary *) dict
{
    if ( (self = [super init]) )
    {
        _dict = [dict retain];
        if (!_dict)
        {
            [self release];
            return nil;
        }
    }
    
    return self;
}

- (void) dealloc
{
    [_dict release], _dict = nil;
    
    [super dealloc];
}

#pragma mark XCF Info
- (CGSize) documentSize
{
    int width = [[_dict valueForKey:@"Width"] intValue];
    int height = [[_dict valueForKey:@"Height"] intValue];
    
    return CGSizeMake((CGFloat)width, (CGFloat)height); 
}

#pragma mark Layers Info

- (NSDictionary *) dictionaryForLayerWithName: (NSString *) layerName
{
    NSAssert(layerName, @"XCFPlistParser#dictionaryForLayerWithName: layerName is nil!");
    
    NSArray *layers = [_dict objectForKey:@"Layers"];
    
    if ([layers isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *layerDict in layers)
        {
            if ([layerDict isKindOfClass:[NSDictionary class]] && [[layerDict objectForKey: @"Name"] isEqual:layerName])
                return layerDict;
        }
    }
    
    
    return nil;
}

- (NSArray *) layersNames
{
    NSArray *layers = [_dict objectForKey:@"Layers"];
    NSMutableArray *layersNames = [NSMutableArray arrayWithCapacity:[layers count]];    
    
    if ([layers isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *layerDict in layers)
        {
            if ( [layerDict isKindOfClass:[NSDictionary class]] )
                [layersNames addObject: [layerDict objectForKey: @"Name"]];
        }
    }
    
    return layersNames;
}

- (NSArray *) allLayersPositions
{
    NSArray *layers = [_dict objectForKey:@"Layers"];
    NSMutableArray *layersPositions = [NSMutableArray arrayWithCapacity:[layers count]];    
    
    if ([layers isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *layerDict in layers)
        {
            if ( [layerDict isKindOfClass:[NSDictionary class]] )
            {
                int x = [[layerDict valueForKey:@"X"] intValue];
                int y = [[layerDict valueForKey:@"Y"] intValue];
                
                CGPoint p = CGPointMake((CGFloat)x, (CGFloat)y);
                
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
                NSValue *value = [NSValue valueWithCGPoint:p];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
                // TODO: not tested
                NSValue *value = [NSValue valueWithPoint: NSPointFromCGPoint(p) ];
#endif
                [layersPositions addObject:value];                
            }
        }
    }
    
    return layersPositions;
}

/** Returns zOrder of the layer with given name. Or -1 if no such layer exist. */
- (NSInteger) zOrderForLayerWithName: (NSString *) layerName
{
    NSDictionary *layerDict = [self dictionaryForLayerWithName: layerName];
    if (layerDict)
    {
        NSArray *layers = [_dict objectForKey:@"Layers"];
        
        if ([layers isKindOfClass:[NSArray class]])
        {
            return [layers indexOfObject:layerDict];
        }
    }
    
    return -1;
}

- (CGSize) sizeForLayerWithName: (NSString *) layerName
{
    
    NSDictionary *layerDict = [self dictionaryForLayerWithName: layerName];
    if (layerDict)
    {
        int width = [[layerDict valueForKey:@"Width"] intValue];
        int height = [[layerDict valueForKey:@"Height"] intValue];
        
        return CGSizeMake((CGFloat)width, (CGFloat)height);
    }
    
    return CGSizeZero;
}

- (CGPoint) positionForLayerWithName: (NSString *) layerName
{
    
    NSDictionary *layerDict = [self dictionaryForLayerWithName: layerName];
    if (layerDict)
    {
        int x = [[layerDict valueForKey:@"X"] intValue];
        int y = [[layerDict valueForKey:@"Y"] intValue];
        
        CGPoint p = CGPointMake((CGFloat)x, (CGFloat)y);
        
//        if (transformCoordinates)
//        {
//            CGSize docSize = [self documentSize];
//            CGSize layerSize = [self sizeForLayerWithName: layerName];
//            
//            p.y = docSize.height - p.y - layerSize.height;
//        }
        
        return p;
    }
    
    return CGPointZero;
}

- (void) transformNode: (CCNode *) node forLayerWithName: (NSString *) layerName
{
    NSAssert(node, @"XCFPlistParser#transformNode:forLayerWithName: node is nil!");
    
    CGPoint p = [self positionForLayerWithName:layerName];
    CGSize layerSize = [self sizeForLayerWithName: layerName ];
    CGSize nodeSize = node.contentSize;
    
    // Set position.
    node.anchorPoint = ccp(0, 0);
    node.position = p;
    
    // Crash if contentSize is zero.
    if ( !nodeSize.width || !nodeSize.height)
        NSAssert(NO, @"XCFPlistParser#transformNode:forLayerWithName: node.contentSize is zero!");
    
    // Scale to fit the layer size.
    node.scaleX = layerSize.width / nodeSize.width;
    node.scaleY = layerSize.height / nodeSize.height;
}

@end
