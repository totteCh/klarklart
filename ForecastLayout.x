#import "ForecastLayout.h"

%hook ForecastLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    ForecastLayout *_self = self;
    NSArray<UICollectionViewLayoutAttributes *> *attributes = %orig;

    CGFloat yOffset = 0;
    BOOL adCellFound = NO;

    for (UICollectionViewLayoutAttributes *attr in attributes) {
        if (attr.representedElementCategory == UICollectionElementCategoryCell) {
            NSIndexPath *indexPath = attr.indexPath;
            UICollectionView *collectionView = _self.collectionView;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

            if ([NSStringFromClass([cell class]) isEqualToString:@"klartapp.AdCell"]) {
                // Store the height of the ad cell and hide it
                yOffset = attr.frame.size.height;
                attr.hidden = YES;
                adCellFound = YES;
            } else if (adCellFound) {
                // Adjust the position of subsequent cells
                CGRect frame = attr.frame;
                frame.origin.y -= yOffset;
                attr.frame = frame;
            }
        }
    }

    return attributes;
}

%end

%ctor {
    %init(ForecastLayout = objc_getClass("klartapp.ForecastLayout"))
}
