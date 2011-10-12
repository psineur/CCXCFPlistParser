//
//  XCFPlistParser.h
//
//  Created by Stepan Generalov on 08.09.11.
//  Copyright 2011 Stepan Generalov.
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface XCFPlistParser : NSObject
{
    NSDictionary *_dict;
}

#pragma mark Creation/Init

/** Creates parser that holds info from given dictionary. Returns nil if dict is nil. */
+ (id) parserWithDictionary: (NSDictionary *) dict;

/** Inits parser that holds info from given dictionary. Returns nil if dict is nil. */
- (id) initWithDictionary: (NSDictionary *) dict;

/** Returns parser that holds info from given filename. Returns nil if file failed to parse. */
+ (id) parserWithFile: (NSString *) filename;

/** Inits parser that holds info from given filename. Returns nil if file failed to parse. */
- (id) initWithFile: (NSString *) filename;

#pragma mark XCF Info

/** Returns size of the whole document (XCF canvas size). */
- (CGSize) documentSize;

#pragma mark Multiple Layers Info

/** Returns array of NSStrings of all layers names in the xcf.plist. */
- (NSArray *) layersNames;

/** Returns array of positions of all layers.
 *
 * Returned array is NSArray of NSValues created with CGPoint or NSPoint, 
 * depending on your system (Mac/iOS).
 */
- (NSArray *) allLayersPositions;

#pragma mark Single layer Info

/** Returns zOrder of the layer with given name. Or -1 if no such layer exist. */
- (NSInteger) zOrderForLayerWithName: (NSString *) layerName;

/** Returns size of the layer with given name or CGSizeZero if no such layer exist. */
- (CGSize) sizeForLayerWithName: (NSString *) layerName;

/** Returns position of the layer with given name or CGPointZero if no such layer exist.
 *
 * Returned position will be in cocos2d format, where ccp(0,0) is at the left bottom corner.  
 */
- (CGPoint) positionForLayerWithName: (NSString *) layerName;

/** Transforms given node to fill the rectangle of layer in xcf with given layerName.
 * We can get only size & position of layer in xcf file, so only scale & position
 * will be used for transform. Rotation not supported.
 * Coordinate system is leftBottom - cocos2d.
 *
 * Throws an assertion if node.contentSize.width or height is zero.
 */
- (void) transformNode: (CCNode *) node forLayerWithName: (NSString *) layerName;

@end
