//
//  RMEllipseAnnotation.h
//  MapView
//
//  Created by Rick van der Linde on 08/03/17.
//
//

#import "RMShapeAnnotation.h"

@interface RMEllipseAnnotation : RMShapeAnnotation

@property (strong, nonatomic) UIColor *color;

- (instancetype)initWithMapView:(RMMapView *)aMapView geometry:(NSDictionary *)geometry;

@end
