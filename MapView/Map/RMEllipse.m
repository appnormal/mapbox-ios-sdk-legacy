//
//  RMEllipse.m
//  MapView
//
//  Created by Rick van der Linde on 08/03/17.
//
//

#import "RMEllipse.h"

#import "RMMapView.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees) / 180.0f)

@implementation RMEllipse
{
    __weak RMMapView *_mapView;
    NSDictionary *_geometry;
    CAShapeLayer *_shapeLayer;
}

#pragma mark - Lifecycle

- (instancetype)initWithView:(RMMapView *)aMapView geometry:(NSDictionary *)geometry
{
    self = [super init];
    if (self) {
        self.masksToBounds = NO;
        
        _mapView = aMapView;
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
    CGFloat latRadians = [[_mapView projection] projectedPointToCoordinate:projectedLocation].latitude * M_PI / 180.0f;
    CGFloat pixelRadiusX = radiusX / cos(latRadians) / [_mapView metersPerPixel];
    CGFloat width = pixelRadiusX * 3.2808399;
    
    CGFloat radiusY = [radii[@"y"] floatValue];
    CGFloat lngRadians = [[_mapView projection] projectedPointToCoordinate:projectedLocation].longitude * M_PI / 180.0f;
    CGFloat pixelRadiusY = radiusY / cos(lngRadians) / [_mapView metersPerPixel];
    CGFloat height = pixelRadiusY * 3.2808399;
    
    CGRect bounds = (CGRect) {
        self.position.x - width / 2.0f,
        self.position.y - height / 2.0f,
        width,
        height
    };
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    transform = CGAffineTransformRotate(transform, DEGREES_TO_RADIANS([_geometry[@"tilt"] floatValue]));
    transform = CGAffineTransformTranslate(transform, -CGRectGetMidX(bounds), -CGRectGetMidY(bounds));
    CGPathAddEllipseInRect(path, &transform, bounds);
    
    if (animated) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = [CATransaction animationDuration];
        pathAnimation.fromValue = [NSValue valueWithPointer:_shapeLayer.path];
        pathAnimation.toValue = [NSValue valueWithPointer:path];
        [_shapeLayer addAnimation:pathAnimation forKey:@"animatePath"];
    }
    
    _shapeLayer.path = path;
    
    CGPathRelease(path);
    
    self.bounds = CGPathGetBoundingBox(_shapeLayer.path);
}

@end
