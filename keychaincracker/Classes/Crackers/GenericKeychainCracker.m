//
//  GenericKeychainCracker.m
//  keychaincracker
//
//  Created by Elangovan Ayyasamy on 10/05/21.
//  Copyright © 2021 Krisna Pranav. All rights reserved.
//

#import "GenericKeychainCracker.h"
#import "ConcreteKeychainCracker.h"
#import "KeychainCracker.hpp"
#import <list>
#import <string>
#import <iostream>

NS_ASSUME_NONNULL_BEGIN

@interface GenericKeychainCracker()

@property( atomic, readwrite, assign ) GenericKeychainCrackerImplementation implementation;
@property( atomic, readwrite, strong ) ConcreteKeychainCracker            * objcCracker;
@property( atomic, readwrite, assign ) XS::KeychainCracker                * cxxCracker;

- ( std::list< std::string > )stringArrayToStringList: ( NSArray< NSString * > * )array;

@end

NS_ASSUME_NONNULL_END

@implementation GenericKeychainCracker

- ( nullable instancetype )init
{
    return [ self initWithKeychain: @"" passwords: @[] implementation: GenericKeychainCrackerImplementationObjectiveC ];
}

- ( nullable instancetype )initWithKeychain: ( NSString * )keychain passwords: ( NSArray< NSString * > * )passwords implementation: ( GenericKeychainCrackerImplementation )imp
{
    if( ( self = [ super init ] ) )
    {
        self.implementation = imp;
        
        if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
        {
            self.objcCracker = [ [ ConcreteKeychainCracker alloc ] initWithKeychain: keychain passwords: passwords ];
        }
        else
        {
            self.cxxCracker = new XS::KeychainCracker( keychain.UTF8String, [ self stringArrayToStringList: passwords ] );
        }
    }
    
    return self;
}

- ( nullable instancetype )initWithKeychain: ( NSString * )keychain passwords: ( NSArray< NSString * > * )passwords
{
    return [ self initWithKeychain: keychain passwords: passwords implementation: GenericKeychainCrackerImplementationObjectiveC ];
}

- ( void )dealloc
{
    delete self.cxxCracker;
}

- ( std::list< std::string > )stringArrayToStringList: ( NSArray< NSString * > * )array
{
    NSString               * str;
    std::list< std::string > l;
    
    for( str in array )
    {
        l.push_back( str.UTF8String );
    }
    
    return l;
}

- ( void )crack: ( void ( ^ )( BOOL passwordFound, NSString * _Nullable password ) )completion
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        [ self.objcCracker crack: completion ];
    }
    else
    {
        self.cxxCracker->crack
        (
         [ completion ]( bool found, const std::string & password )
         {
             completion( found, [ NSString stringWithUTF8String: password.c_str() ] );
         }
         );
    }
}

- ( void )stop
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        [ self.objcCracker stop ];
    }
    else
    {
        self.cxxCracker->stop();
    }
}

- ( NSString * )message
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        return self.objcCracker.message;
    }
    
    return [ NSString stringWithUTF8String: self.cxxCracker->message().c_str() ];
}

- ( double )progress
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        return self.objcCracker.progress;
    }
    
    return self.cxxCracker->progress();
}

- ( BOOL )progressIsIndeterminate
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        return self.objcCracker.progressIsIndeterminate;
    }
    
    return self.cxxCracker->progressIsIndeterminate();
}

- ( NSUInteger )secondsRemaining
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        return self.objcCracker.secondsRemaining;
    }
    
    return self.cxxCracker->secondsRemaining();
}

- ( NSUInteger )maxThreads
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        return self.objcCracker.maxThreads;
    }
    
    return self.cxxCracker->maxThreads();
}

- ( NSUInteger )maxCharsForCaseVariants
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        return self.objcCracker.maxCharsForCaseVariants;
    }
    
    return self.cxxCracker->maxCharsForCaseVariants();
}

- ( NSUInteger )maxCharsForCommonSubstitutions
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        return self.objcCracker.maxCharsForCommonSubstitutions;
    }
    
    return self.cxxCracker->maxCharsForCommonSubstitutions();
}

- ( void )setMaxThreads: ( NSUInteger )value
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        self.objcCracker.maxThreads = value;
    }
    else
    {
        self.cxxCracker->maxThreads( value );
    }
}

- ( void )setMaxCharsForCaseVariants: ( NSUInteger )value
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        self.objcCracker.maxCharsForCaseVariants = value;
    }
    else
    {
        self.cxxCracker->maxCharsForCaseVariants( value );
    }
}

- ( void )setMaxCharsForCommonSubstitutions: ( NSUInteger )value
{
    if( self.implementation == GenericKeychainCrackerImplementationObjectiveC )
    {
        self.objcCracker.maxCharsForCommonSubstitutions = value;
    }
    else
    {
        self.cxxCracker->maxCharsForCommonSubstitutions( value );
    }
}

@end
