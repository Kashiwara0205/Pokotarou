![s_PokotarouLogo](https://user-images.githubusercontent.com/52961642/62843884-46f6c700-bcf8-11e9-8267-b9fad8f34085.png)


[![Gem Version](https://badge.fury.io/rb/pokotarou.svg)](https://badge.fury.io/rb/pokotarou)
[![Build Status](https://travis-ci.org/Kashiwara0205/Pokotarou.svg?branch=master)](https://travis-ci.org/Kashiwara0205/Pokotarou)

Pokotarou is convenient seeder of 'Ruby on Rails'
In MySql, operation has been confirmed

## Features

### Easy to use
You don't have to write a program for seed
Can be set simply by writing a yml file!

### Fast speed
If it is the following table, 10,000 records can regist in 0.41s on average

|Field|Type|NULL|
|:---|:---|:---|
|id|bigint(20)| NO|
|name|varchar(255)|YES|
|created_at|datetime|NO|
|updated_at|datetime|NO|

## Getting started
Add this line to your application's Gemfile:

```ruby
gem 'pokotarou'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install pokotarou
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Usage

Following yml file become seed data.

Please make following yml file in your favorite dir.

```yml
Default:
  Pref:
    loop: 3
```

and write following ruby code in seeds.rb.

```ruby
Pokotarou.execute("./config_filepath")
```

when you finished writing, then run rails db:seed

```bash
$ rails db:seed
```

As a result, seed data is registerd your db.

## How to set configlation file(.yml)?
explain how to write the configuration file below.

### Model used for explanation
Table name below is 'prefs' and model name is 'Pref'

|Field|Type|NULL|
|:---|:---|:---|
|id|bigint(20)| NO|
|name|varchar(255)|YES|
|created_at|datetime|NO|
|updated_at|datetime|NO|


Table name below is 'members' and model name is 'Member'

|Field|Type|NULL|
|:---|:---|:---|
|id|bigint(20)| NO|
|name|varchar(255)|YES|
|remarks|text|YES|
|birthday|date|YES|
|pref_id|bigint(20)|YES|
|created_at|datetime|NO|
|updated_at|datetime|NO|


### Standerd Setting
The basic setting method is written below

#### Automatic data entry

If there is no definition about col, then automatically prepared data is registrd.

For example, in the case of below, it is registered automatically prepared data three times.

```yml
Default:
  Pref:
    loop: 3
```

also you can set seed_data by yourself.
```yml
Default:
  Pref:
    loop: 3
    col:
      name: "Hokkaido"
```

#### Omitted loop
If you want to register the test data at once, I suggest ommited loop

```yml
Default:
  Pref: 
    col:
      name: ["Hokkaido"]
```

```ruby
["Hokkaido"]
```

#### Array
You can set array_data.

Array data is registerd one by one.

```yml
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
```

#### Maked function
'maked' is very useful function.
it is hash and accumulate data created in the past. 

For example, in the case of below, reffer name of Pref in Default block by maked 

```yml
Default:
  Pref:
    loop: 2
    col:
      name: ["Hokkaido", "Aomori"]
  Member:
    loop: 2
    col:
      name: <maked[:Default][:Pref][:name]>
      pref_id: F|Pref
```

#### Foreign key

**※ If you set association(belongs_to, has_many...), Pokotarou automatically register foreign keys**

' F| ' means foreign key. 'F|' is Model.all.pluck(:id)

For example, in the case of below, Member model record is registerd with pref_id(foregin key).

```yml
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
  Member:
    loop: 3
    col:
      pref_id: F|Pref
```

#### Expression expansion
'< >' means expression expansion.
You can run ruby code in '< >'.

```yml
Default:
  Pref:
    loop: 3
    col:
      name: <["Hokkaido", "Aomori", "Iwate"]>
      created_at: <Date.parse('1997/02/05')>
```

#### Additional method
You can add method and use it in pokotarou

```yml
Default:
  Pref:
    loop: 3
    col:
      name: <pref_name>
```

Prepare the following ruby file

```ruby
def pref_name
  ["Hokkaido", "Aomori", "Iwate"]
end
```

and run the following code in seeds.rb.

```ruby
Pokotarou.import("./method_filepath")
Pokotarou.execute("./config_filepath")
```

As as result, pokotarou can call pref_name method, and seed data is registrd by pref_name method.

#### Multiple blocks

You can use multiple blocks.

```yml
Default:
  Pref:
    loop: 3
Default2:
  Pref:
    loop: 3
```

and, You can change the name of the block

```yml
Hoge:
  Pref:
    loop: 3
Fuga:
  Pref:
    loop: 3
```

### option
Option is useful function.
If you can master it, it may be easier to create test data.

#### Random
Shuffle seed data when regist

```yml
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    option:
      name: ["random"]
```

The following results change from run to run

```ruby
["Aomori", "Iwate", "Iwate"]
```

#### Add_id
Add individual number to seed data of String type

```yml
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    option:
      name: ["add_id"]
```

```ruby
["Hokkaido_0", "Aomori"_1, "Iwate_2"]
```

#### Combine serveral options
Combination of options is possible

```yml
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    option:
      name: ["add_id", "random"]
```

The following results change from run to run

```ruby
["Hokkaido_0", "Iwate_1", "Hokkaido_2"]
```

### Advanced Setting
The advanced setting method is written below

#### Validation

Run validation when regist

```yml
Default:
  Pref:
    loop: 3
    validate: true
```

#### Disable Autoincrement

You can disable the autoincrement setting

If you disable the setting, you can register id data prepared by yourself

```yml
Default:
  Pref:
    loop: 3
    autoincrement: false
    col:
      id: [100, 101, 102]
```

#### Pokotarou Handler

If you want to use configlation yml data in ruby code then you can use "PokotarouHandler"

When you use "PokotarouHandler", can update pokotarou's parameter
in ruby code.


<b>Change Operation</b>

In the following example, the number of loops is changed

```ruby
  handler = Pokotarou.gen_handler("./config_filepath")
  # change loop config
  handler.change_loop(:Default, :Pref, 6)
  Pokotarou.execute(handler.get_data)
```


In the following example, seed data is changed

```ruby
  handler = Pokotarou.gen_handler("./config_filepath")
  # change seed data config number
  handler.change_seed(:Default, :Pref, :name, ["a", "b", "c"])
  Pokotarou.execute(handler.get_data)
```

<b>Delete Operation</b>

In the following example, delete block config

```ruby
  handler = Pokotarou.gen_handler("./config_filepath")
  # delete model config in parameter
  handler.delete_block(:Default)
  Pokotarou.execute(handler.get_data)
```

In the following example, delete model config

```ruby
  handler = Pokotarou.gen_handler("./config_filepath")
  # delete model config in parameter
  handler.delete_model(:Default, :Pref)
  Pokotarou.execute(handler.get_data)
```

In the following example, delete col config

```ruby
  handler = Pokotarou.gen_handler("./config_filepath")
  # delete col config in parameter
  handler.delete_col(:Default, :Pref, :name)
  Pokotarou.execute(handler.get_data)
```

#### Const
You can set const variables by const' key.

```yml
const':
  name: "hoge"
Default:
  Pref:
    loop: 3
  col:
    name: <const[:name]>
```

#### Grouping
Grouping is very useful function.
Especially useful when setting multiple options.


```yml
Default:
  Member:
    grouping: 
      # set columns you want to group
      hoge_g: ["name", "remark"]
    col:
      # you can use "hoge_g" at col
      hoge_g: <['fugafuga!']>
    option:
      # also you can use "hoge_g" at option
      hoge_g: ["add_id"]

```

#### Template
You can set template config by template' key.

The template can be overwritten with the one set later.

```yml
template':
  pref_template:
    loop: 3
    col:
      pref_id: F|Pref
      name: ["hogeta", "fuga", "pokota"]
Pref:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]

Member1:
  Member:
    template: pref_template
  
Member2:
  Member:
    template: pref_template
    col:
      name: ["hogeta2", "fuga2", "pokota2"]
```

#### Return 
You can set return val by return' key.

```yml
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]

return': <maked[:Default][:Pref][:name]>

```

```ruby
 return_val = Pokotarou.execute("filepath")
 puts return_val
```

result
```
Hokkaido
Aomori
Iwate
```
#### Args

You can set args by hash.

```yml
Default:
  Pref: 
    loop: 3
    col:
      name: <args[:name]>
```
```ruby
  Pokotarou.set_args({ name:  ["Hokkaido", "Aomori", "Iwate"] })
  Pokotarou.execute("filepath")
```

### Convert
convert is a convenient function. Will convert the seed data.

#### convert option

|convert   |description                               |
|:---------|------------------------------------------|
| empty    | convert val to empty                     |
| nil      | convert val to nil                       |
| big_text | convert val to big_text("text" * 50)     |
| br_text  | convert val to br_text("text\n" * 5)     |

For example, following configfile register seed data while replacing with nil

```yml
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    convert:
      name: ["nil(0..2)"]
```

```ruby
[nil, nil, nil]
```

a little complex version

```yml
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    convert:
      name: ["empty(0..0)", "nil(1..2)"]
```

```ruby
["", nil, nil]
```