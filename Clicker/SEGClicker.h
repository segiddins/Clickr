//
//  SEGClicker.h
//  Clicker
//
//  Created by Samuel E. Giddins on 11/17/12.
//  Copyright (c) 2012 Samuel E. Giddins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SEGClicker : NSObject

- (id)initWithField:(NSString *)field andHomeTeam:(NSString *)homeTeam andAwayTeam:(NSString *)awayTeam andGrade:(NSInteger)grade;

-(void)newGame;
-(void)newHalfInning;
-(void)newInning;
-(void)newBatter;
-(void)gameStateHasChanged;
-(NSString *)getScore:(int)inningHalf :(int)inning;
-(void)setScore:(int)inningHalf :(int)inning:(int)score;

@property NSInteger strikes;
@property NSInteger outs;
@property NSInteger balls;
@property NSInteger inning;
@property Boolean   isTopOfInning;
@property NSInteger homeTeamRuns;
@property NSInteger awayTeamRuns;
@property NSInteger currentPitcherWalks;
@property (strong) NSString *fieldName;
@property (strong) NSString *homeName;
@property (strong) NSString *awayName;
@property NSInteger gradeLevel;

//prefs
//@property NSInteger gradeLevel;

@end