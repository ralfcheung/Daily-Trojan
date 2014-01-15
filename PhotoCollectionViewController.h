//
//  PhotoCollectionViewController.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 8/25/13.
//
//

#import <UIKit/UIKit.h>
#import "FlickrPhoto.h"
#import "RFQuiltLayout.h"

typedef void (^FlickrSearchCompletionBlock)(NSMutableArray *results);

@interface PhotoCollectionViewController : UIViewController<RFQuiltLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@end
