//
//  RMEllipse.m
//  MapView
//
//  Created by Rick van der Linde on 08/03/17.
//
//

#import "RMEllipse.h"

#import "RMAnnotation.h"
#import "RMGlobalConstants.h"
#import "RMEllipseAnnotation.h"
#import "RMMapView.h"
#import "RMMarker.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees) / 180.0f)

@implementation RMEllipse
{
    __weak RMMapView *_mapView;
    NSDictionary *_geometry;
    CAShapeLayer *_shapeLayer;
}

#pragma mark - Lifecycle

- (instancetype)initWithView:(RMMapView *)aMapView annotation:(RMEllipseAnnotation *)annotation geometry:(NSDictionary *)geometry
{
    self = [super init];
    if (self) {
        self.affineTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([geometry[@"tilt"] floatValue]));
        self.masksToBounds = NO;
        
        _mapView = aMapView;
        self.annotation = annotation;
        _geometry = [geometry copy];
        
        _shapeLayer = [CAShapeLayer new];
        _shapeLayer.lineWidth = [_geometry[@"options"][@"stroke"] floatValue];
        [self addSublayer:_shapeLayer];
        
        [self updateEllipsePathAnimated:NO];
    }
    return self;
}

#pragma mark - Setters

@dynamic color;

- (void)setColor:(UIColor *)color
{
    NSDictionary *options = _geometry[@"options"];
    _shapeLayer.fillColor = [color colorWithAlphaComponent:[options[@"fillOpacity"] floatValue]].CGColor;
    _shapeLayer.strokeColor = [color colorWithAlphaComponent:[options[@"opacity"] floatValue]].CGColor;
}

#pragma mark - Overrides

- (void)setPosition:(CGPoint)position animated:(BOOL)animated
{
    [self setPosition:position];
    [self updateEllipsePathAnimated:animated];
}

#pragma mark - Draw

- (void)updateEllipsePathAnimated:(BOOL)animated
{
    NSDictionary *radii = _geometry[@"radii"];
    
    CGFloat radiusX = [radii[@"x"] floatValue];
    CGFloat pixelRadiusX = radiusX / [_mapView metersPerPixel];
    CGFloat width = pixelRadiusX * 3.2808399;
    
    CGFloat radiusY = [radii[@"y"] floatValue];
    CGFloat pixelRadiusY = radiusY / [_mapView metersPerPixel];
    CGFloat height = pixelRadiusY * 3.2808399;
    
    CGRect bounds = (CGRect) {
        CGPointZero,
        width,
        height
    };
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, nil, bounds);
    
    if (animated) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = [CATransaction animationDuration];
        pathAnimation.fromValue = [NSValue valueWithPointer:_shapeLayer.path];
        pathAnimation.toValue = [NSValue valueWithPointer:path];
        [_shapeLayer addAnimation:pathAnimation forKey:@"animatePath"];
    }
    
    _shapeLayer.path = path;
    self.bounds = CGPathGetBoundingBox(_shapeLayer.path);
    CGPathRelease(path);
    
    CGFloat x = CGRectGetMinX(self.frame);
    CGFloat y = CGRectGetMinY(self.frame);
    width = CGRectGetWidth(self.frame);
    height = CGRectGetHeight(self.frame);
    
    CLLocationCoordinate2D coordinate1 = [_mapView pixelToCoordinate:CGPointMake(x, y)];
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:coordinate1.latitude longitude:coordinate1.longitude];
    
    CLLocationCoordinate2D coordinate2 = [_mapView pixelToCoordinate:CGPointMake(x + width, y)];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:coordinate2.latitude longitude:coordinate2.longitude];
    
    CLLocationCoordinate2D coordinate3 = [_mapView pixelToCoordinate:CGPointMake(x + width, y + height)];
    CLLocation *location3 = [[CLLocation alloc] initWithLatitude:coordinate3.latitude longitude:coordinate3.longitude];
    
    CLLocationCoordinate2D coordinate4 = [_mapView pixelToCoordinate:CGPointMake(x, y + height)];
    CLLocation *location4 = [[CLLocation alloc] initWithLatitude:coordinate4.latitude longitude:coordinate4.longitude];
    
    [self.annotation setBoundingBoxFromLocations:@[location1, location2, location3, location4]];
}

@end
