//
//  HuabanModel.h
//  仿花瓣
//
//  Created by Sper on 16/8/12.
//  Copyright © 2016年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMBaseModel.h"

@class File;
@class User;
@class Board;

@interface HuabanModel : WMBaseModel
@property (nonatomic , strong)NSNumber * pin_id;
@property (nonatomic , strong)NSNumber * user_id;
@property (nonatomic , strong)NSNumber * file_id;
@property (nonatomic , strong)NSNumber * board_id;
@property (nonatomic , strong)NSNumber * seq;
@property (nonatomic , strong)NSNumber * media_type;
@property (nonatomic , strong)NSString * source;
@property (nonatomic , strong)NSString * link;
@property (nonatomic , strong)NSString * raw_text;


@property (nonatomic , strong)NSNumber * via;
@property (nonatomic , strong)NSNumber * via_user_id;
@property (nonatomic , strong)NSNumber * original;
@property (nonatomic , strong)NSNumber * created_at;
@property (nonatomic , strong)NSNumber * repin_count;
@property (nonatomic , strong)NSNumber * like_count;
@property (nonatomic , strong)NSNumber * comment_count;
@property (nonatomic , strong)NSNumber * is_private;
@property (nonatomic , strong)NSString * orig_source;
@property (nonatomic , assign)BOOL hide_origin;
@property (nonatomic , assign)BOOL  liked;

@property (nonatomic , assign)CGSize cellSize;
@property (nonatomic , assign)CGFloat fileHeight;
@property (nonatomic , assign)BOOL needUser;

@property (nonatomic , strong) File * file;
@property (nonatomic , strong) User *user;
@property (nonatomic , strong) Board *board;

@end


@interface File : WMBaseModel
@property (nonatomic , strong)NSString * bucket;
@property (nonatomic , strong)NSString * farm;
@property (nonatomic , strong)NSString * key;
@property (nonatomic , strong)NSString * realImageKey;
@property (nonatomic , strong)NSNumber * height;
@property (nonatomic , strong)NSNumber * frames;
@property (nonatomic , strong)NSNumber * width;

@end

@interface User : WMBaseModel
@property (nonatomic , strong)NSString * username;
@property (nonatomic , strong)NSString * urlname;
@property (nonatomic , strong)NSNumber * user_id;
@property (nonatomic , strong)NSNumber * created_at;
@property (nonatomic , strong)NSNumber * board_count;
@property (nonatomic , strong)NSNumber * liked_at;
@property (nonatomic , strong)NSNumber * boards_like_count;
@property (nonatomic , strong)NSNumber * commodity_count;
@property (nonatomic , strong)NSNumber * creations_count;
@property (nonatomic , strong)NSNumber * follower_count;
@property (nonatomic , strong)NSNumber * following_count;
@property (nonatomic , strong)NSNumber * like_count;
@property (nonatomic , strong)NSNumber * pin_count;
@property (nonatomic , strong)NSNumber * seq;
@property (nonatomic , strong)NSString * avatar;

@end

@interface Board : WMBaseModel
@property (nonatomic , strong)NSString *title;
@end

