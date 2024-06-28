#import <UIKit/UIKit.h>

// Hook into the method where the ad cell is inserted into the collection view
%hook ForecastViewController

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = %orig;

    // Check if this is the ad cell
    if ([NSStringFromClass([cell class]) isEqualToString:@"klartapp.AdCell"]) {
        // Trigger layout update to adjust cell positions
        [collectionView.collectionViewLayout invalidateLayout];
    }

    return cell;
}

%end

%ctor {
    %init(ForecastViewController = objc_getClass("klartapp.ForecastViewController"))
}
