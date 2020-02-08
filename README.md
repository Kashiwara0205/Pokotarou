![s_PokotarouLogo](https://user-images.githubusercontent.com/52961642/62843884-46f6c700-bcf8-11e9-8267-b9fad8f34085.png)


[![Gem Version](https://badge.fury.io/rb/pokotarou.svg)](https://badge.fury.io/rb/pokotarou)
[![Build Status](https://travis-ci.org/Kashiwara0205/Pokotarou.svg?branch=master)](https://travis-ci.org/Kashiwara0205/Pokotarou)

## Features

__Pokotarou__ is convinient Mysql seeder of Ruby on Rails.

__Easy to use!!__  
Just use yml file.  
very very very simple!  
You dont' have to write ruby program about seed data!

__Fast speed!!__  
__Pokotarou__ is fast seeder.  
Because contains [Activerecord-import](https://github.com/zdennis/activerecord-import).  
so, always run bulk insert when execute rails db:seed command!

If you use __Pokotarou__ about following table.

|Field|Type|NULL|
|:---|:---|:---|
|id|bigint(20)| NO|
|name|varchar(255)|YES|
|created_at|datetime|NO|
|updated_at|datetime|NO|

__Pokotarou__ can register 10,000 records in 0.41s on average.

## Getting started
Add this line to your application's Gemfile:

```ruby
gem 'pokotarou'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install pokotarou
```

## Basic Usage

Just make yml file.  
If you register data to following prefecture data. 
     
__prefecture table__

|Field|Type|NULL|
|:---|:---|:---|
|id|bigint(20)| NO|
|name|varchar(255)|YES|
|created_at|datetime|NO|
|updated_at|datetime|NO|


__prefecture model__

|Model|
|:---|
|Pref|

First, Please make following yml file your favorite directory of rails project.  
The file name can be anything.  
In my case, made yml file in db directory and named file __pref_data__.  

```yml
Default:
  Pref:
    loop: 3
```

and write following ruby code in seeds.rb.

```ruby
Pokotarou.execute("./db/pref_data.yml")
```

and execute following command!!!!!  

```bash
$ rails db:seed
```

prefecture data is registerd your db.
Let's check with the following code.

```ruby
# You have to get 3
Pref.all.count => 3
```

## Documentaion
You can read a lot more about Pokotarou in its [official docs](https://kashiwara0205.github.io/PokotarouDocs/)

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
