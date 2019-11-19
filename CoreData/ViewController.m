//
//  ViewController.m
//  CoreData
//
//  Created by haoran on 2019/11/19.
//  Copyright © 2019 haoran. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Student+CoreDataClass.h"
@interface ViewController ()
{
    NSMutableArray *_dataSource;
    NSManagedObjectContext *_context;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
    self.tableView.rowHeight = 100;
    
    [self createSQLite];
    
    NSFetchRequest *request =[NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSArray *resArray = [_context executeFetchRequest:request error:nil];
    _dataSource  = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
}

//创建数据库
-(void)createSQLite {
    
    //1、创建模型对象
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreData" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    //创建持久化储存助理:数据库
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    //数据库名称和路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"coreData.sqlite"];
     NSLog(@"数据库 path = %@", sqlPath);
    NSURL *sqlURL =  [NSURL fileURLWithPath:sqlPath];
    
    //设置数据库相关信息
    NSError *error;
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlURL options:nil error:&error];
    if (error) {
          NSLog(@"添加数据库失败:%@",error);
    }else{
         NSLog(@"添加数据库成功");
    }
    
    //创建上下文，保存信息，操作数据库
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.persistentStoreCoordinator = store;
    _context = context;
    
}


#pragma mark -- Event Handle

- (IBAction)insertClicked:(id)sender {
    [self insertData]; //增
}
- (IBAction)delegateClicked:(id)sender {
    [self deleteData];//删
}
- (IBAction)updateClicked:(id)sender {
    [self updateData];//更新
}
- (IBAction)readClicked:(id)sender {
    [self readData];//查询
}

- (IBAction)sortClicked:(id)sender {
    [self sort];//排序
}


#pragma mark -- 数据处理
-(void)insertData {
    //1根据Entity名称和NSManagerObjectContext获取一个新的继承NSManagerObject的子类Student
    Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:_context];
    //  2.根据表Student中的键值，给NSManagedObject对象赋值
      student.name = [NSString stringWithFormat:@"Mr-%d",arc4random()%100];
      student.age = arc4random()%20;
      student.sex = arc4random()%2 == 0 ?  @"美女" : @"帅哥" ;
      student.height = arc4random()%180;
      student.number = arc4random()%100;
    
    //查询所有数据的请求
    NSFetchRequest *addRequest = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSArray *resArray = [_context executeFetchRequest:addRequest error:nil];
    _dataSource = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    NSError *error;
    if ([_context save:&error]) {
        NSLog(@"数据插入到数据库成功");
    }else{
         NSLog(@"数据插入到数据库失败");
    }
}

-(void)deleteData {
    
    //创建删除请求
    NSFetchRequest *deleteRequest =[NSFetchRequest fetchRequestWithEntityName:@"Student"];
    //删除条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"age < %d", 10];
    deleteRequest.predicate = pre;
    //返回需要删除的对象数组
    NSArray *deleArray = [_context executeFetchRequest:deleteRequest error:nil];
   //从数据库中删除
    for (Student *student in deleArray) {
        [_context deleteObject:student];
    }
    
    //没有任何条件就是读取所有的数据
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSArray *resArray = [_context executeFetchRequest:request error:nil];
    _dataSource = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    NSError *error;
    if ([_context save:&error]) {
        NSLog(@"删除 age < 10 的数据");
    }else{
         NSLog(@"数据插入到数据库失败");
    }
    
}

-(void)updateData {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"sex = %@", @"帅哥"];
    request.predicate = pre;
    NSArray *resArray = [_context executeFetchRequest:request error:nil];
    
    //修改
    for (Student *student in resArray) {
        student.name = @"且行且曾曦";
    }
    _dataSource = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    //保存
    NSError *error;
    if ([_context save:&error]) {
        NSLog(@"更新数据成功");
    }else{
        NSLog(@"更新数据失败, %@", error);
    }
    
}

-(void)readData {
    /* 谓词的条件指令
        1.比较运算符 > 、< 、== 、>= 、<= 、!=
        例：@"number >= 99"
        
        2.范围运算符：IN 、BETWEEN
        例：@"number BETWEEN {1,5}"
        @"address IN {'shanghai','nanjing'}"
        
        3.字符串本身:SELF
        例：@"SELF == 'APPLE'"
        
        4.字符串相关：BEGINSWITH、ENDSWITH、CONTAINS
        例：  @"name CONTAIN[cd] 'ang'"  //包含某个字符串
        @"name BEGINSWITH[c] 'sh'"    //以某个字符串开头
        @"name ENDSWITH[d] 'ang'"    //以某个字符串结束
        
        5.通配符：LIKE
        例：@"name LIKE[cd] '*er*'"   //*代表通配符,Like也接受[cd].
        @"name LIKE[cd] '???er*'"
        
        *注*: 星号 "*" : 代表0个或多个字符
        问号 "?" : 代表一个字符
        
        6.正则表达式：MATCHES
        例：NSString *regex = @"^A.+e$"; //以A开头，e结尾
        @"name MATCHES %@",regex
        
        注:[c]*不区分大小写 , [d]不区分发音符号即没有重音符号, [cd]既不区分大小写，也不区分发音符号。
        
        7. 合计操作
        ANY，SOME：指定下列表达式中的任意元素。比如，ANY children.age < 18。
        ALL：指定下列表达式中的所有元素。比如，ALL children.age < 18。
        NONE：指定下列表达式中没有的元素。比如，NONE children.age < 18。它在逻辑上等于NOT (ANY ...)。
        IN：等于SQL的IN操作，左边的表达必须出现在右边指定的集合中。比如，name IN { 'Ben', 'Melissa', 'Nick' }。
        
        提示:
        1. 谓词中的匹配指令关键字通常使用大写字母
        2. 谓词中可以使用格式字符串
        3. 如果通过对象的key
        path指定匹配条件，需要使用%K
        
        */
    //创建查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    //查询条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"sex = %@", @"美女"];
    request.predicate = pre;
    
    NSArray *resArray = [_context executeFetchRequest:request error:nil];
    _dataSource = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    NSLog(@"查询所有的美女");
    
}

-(void)sort {
    
    //创建排序请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    NSSortDescriptor *numSort = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    request.sortDescriptors =@[ageSort, numSort];
    
    NSError *error = nil;
    NSArray *resArray = [_context executeFetchRequest:request error:&error];
    _dataSource = [NSMutableArray arrayWithArray:resArray];
    [self.tableView reloadData];
    
    if (error == nil) {
        NSLog(@"按照age和number排序");
    }else{
        NSLog(@"排序失败, %@", error);
    }
}


#pragma mark -- UITableDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * celll = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    
    Student * student = _dataSource[indexPath.row];
    ;
    celll.imageView.image = [UIImage imageNamed:([student.sex isEqualToString:@"美女"] == YES ? @"mei" : @"luo")];
    celll.textLabel.text = [NSString stringWithFormat:@" age = %d \n number = %d \n name = %@ \n sex = %@",student.age, student.number, student.name, student.sex];
    celll.textLabel.numberOfLines = 0;
    
    return celll;
}
@end
