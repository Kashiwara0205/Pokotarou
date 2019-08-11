![s_Pokotarou2](https://user-images.githubusercontent.com/52961642/62829303-9cb66b00-bc35-11e9-8660-e5ea752631e2.png)  
[![Gem Version](https://badge.fury.io/rb/pokotarou.svg)](https://badge.fury.io/rb/pokotarou)
[![Build Status](https://travis-ci.org/Tamatebako0205/Pokotarou.svg?branch=master)](https://travis-ci.org/Tamatebako0205/Pokotarou)

Pokotarou is convenient seeder of 'Ruby on Rails'
Currently only mysql supported

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

Set following configration_file in somewhere.

```yml
Default:
  Pref:
    loop: 3
```

execute the following ruby code in seeds.rb.

```ruby
Pokotarou.execute("./config_filepath")
```

run rails db:seed

```bash
$ rails db:seed
```

finish

### Configration file

Introduce how to write config file

#### Model used for explanation
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


#### Basic
If there is no column definition, prepared data is registerd.

Registered 3 times in the following cases.

and id column is basically registerd by autoincrement.

```yml
Default:
  Pref:
    loop: 3
```

Also you can set seed_data by yourself.

```yml
Default:
  Pref:
    loop: 3
    col:
      name: "Hokkaido"
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

#### Maked data
'maked' is very useful function.

Registration is possible using registerd data

Use maked in different model area in the following cases.

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

Use maked in same model area in the following cases.

```yml
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
  Member:
    loop: 3
    col:
      name: ["Tarou", "Jirou", "Saburou"]
      remarks: <maked[:Default][:Member][:name]>
      pref_id: F|Pref

```

Use maked in diffrent block area in the following cases.

```yml
Default:
  Pref: 
    loop: 2
    col:
      name: ["Hokkaido", "Aomori"]
Default2:
  Member:
    loop: 2
    col:
      name: <maked[:Default][:Pref][:name]>
      pref_id: F|Pref
```

#### Foreign key

**※ If you set association(belongs_to, has_many...), Pokotarou automatically register foreign keys**

' F| ' means foreign key.

In the following source code, id of Pref is registerd with Member

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
'< >' means expression expansion

You can run ruby code in '< >'

```yml
Default:
  Pref:
    loop: 3
    col:
      name: <["Hokkaido", "Aomori", "Iwate"]>
      created_at: <Date.parse('1997/02/05')>
```

#### Add method
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

and execute the following source code in seeds.rb.

```ruby
Pokotarou.import("./method_filepath")
Pokotarou.execute("./config_filepath")
```


#### Use multiple blocks

Registration is possible using two blocks

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

if you use Pokotarou handler, can update pokotarou's parameter


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

#### Convert seed data

You can convert seed data

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

complex version

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
