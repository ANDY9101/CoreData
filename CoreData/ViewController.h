//
//  ViewController.h
//  CoreData
//
//  Created by haoran on 2019/11/19.
//  Copyright © 2019 haoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

