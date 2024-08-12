//
//  InProgressVC.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "InProgressVC.h"

@interface InProgressVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray* inProgressDisplayArray;

@end

@implementation InProgressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.navigationItem.title = @"In Progress Todo's";
    _inProgressDisplayArray = [NSMutableArray new];
    
    if (_inProgressDisplayArray.count == 0) {
        _tableView.hidden = true;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
