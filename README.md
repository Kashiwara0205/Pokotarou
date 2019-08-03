![s_PokotarouLogo](https://user-images.githubusercontent.com/52961642/61586183-ef59b580-aba8-11e9-83b0-19eac7339982.png)  
[![Gem Version](https://badge.fury.io/rb/pokotarou.svg)](https://badge.fury.io/rb/pokotarou)
[![Build Status](https://travis-ci.org/Tamatebako0205/Pokotarou.svg?branch=master)](https://travis-ci.org/Tamatebako0205/Pokotarou)

Pokotarou is convenient seeder of 'Ruby on Rails' that uses .yml
Currently only mysql supported

## Features

### Easy to use
Currently can be used only for simple configuration file settings
You don't have to write a program for seeder

### Fast speed
If it is the following table, 10,000 records can regist in 0.4s on average
Also, If you enable 'optimize option', 10,000 records can regist in 0.23s on average

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
Introduce how to execute and write configuration file.
If you want to know more information file settings,  please refer to the test

### Extecute
After write configuration file, execute the following source code in seeds.rb of Ruby on Rails

```
Pokotarou.execute(ConfigrationFilePath)
```
### Configration file

Introduce how to write yml configuration file

#### Definition for explanation
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


#### Default data
If there is no column definition, prepared data is registerd three times
id column is basically registerd by autoincrement

```
Default:
  Pref:
    loop: 3
```


In the following source code, id, created_at, updated_at will be registerd with the prepared data

```
Default:
  Pref:
    loop: 3
    col:
      name: "Hokkaido"
```

#### Array
Array data is registerd one by one

```
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
```

#### Maked data
Registration is possible using registerd data

```
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

```
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

```
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

What a means is ' F| ' foreign key
In the following source code, Foreign key of prefectures is registerd

```
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
What a means is '< >' expression expansion
You can run ruby code in '< >'

```
Default:
  Pref:
    loop: 3
    col:
      name: <["Hokkaido", "Aomori", "Iwate"]>
      created_at: <Date.parse('1997/02/05')>
```

#### Add method
You can add method and use it in pokotarou

```
Default:
  Pref:
    loop: 3
    col:
      name: <pref_name>
```

Prepare the following ruby file
```
def pref_name
  ["Hokkaido", "Aomori", "Iwate"]
end
```
and execute the following source code in seeds.rb of Ruby on Rails

```
Pokotarou.import(MethodFilePath)
Pokotarou.execute(ConfigrationFilePath)
```


#### Use multiple blocks

Registration is possible using two blocks

```
Default:
  Pref:
    loop: 3
Default2:
  Pref:
    loop: 3
```

and, You can change the name of the block

```
Hoge:
  Pref:
    loop: 3
Fuga:
  Pref:
    loop: 3
```


#### Random
Shuffle seed data when regist

```
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    option:
      name: ["random"]
```

The following results change from run to run

```
["Aomori", "Iwate", "Iwate"]
```

#### Add_id
Add individual number to seed data of String type

```
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    option:
      name: ["add_id"]
```

```
["Hokkaido_0", "Aomori"_1, "Iwate_2"]
```

#### Combine serveral options
Combination of options is possible

```
Default:
  Pref:
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    option:
      name: ["add_id", "random"]
```

The following results change from run to run

```
["Hokkaido_0", "Iwate_1", "Hokkaido_2"]
```

#### Validation

Run validation when regist

```
Default:
  Pref:
    loop: 3
    validate: true
```

#### Autoincrement

You can disable the autoincrement setting

If you disable the setting, you can register id data prepared by myself

```
Default:
  Pref:
    loop: 3
    autoincrement: false
    col:
      id: [100, 101, 102]
```

#### Optimize

If you enable 'optimize', Pokotarou Run a query builder, but disable validation

```
Default:
  Pref:
    loop: 3
    optimaize: true
```

#### Pokotarou Handler

if you use Pokotarou handler, can update pokotarou's parameter

In the following example, the number of loops is changed

```
  handler = Pokotarou.gen_handler("ConfigrationFilePath")
  # change loop number
  handler.change_loop(:Default, :Pref, 6)
  Pokotarou.execute(handler.get_data)
```

In the following example, delete class in parameter

```
  handler = Pokotarou.gen_handler("ConfigrationFilePath")
  # delete class in parameter
  handler.delete(:Default, :Member)
  Pokotarou.execute(handler.get_data)
```

#### Convert seed data

You can convert seed data

```
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    convert:
      name: ["nil(0..2)"]
```

```
[nil, nil, nil]
```

complex version

```
Default:
  Pref: 
    loop: 3
    col:
      name: ["北海道", "青森県", "岩手県"]
    convert:
      name: ["empty(0..0)", "nil(1..2)"]
```

```
["", nil, nil]
```

|convert   |description                               |
|:---------|------------------------------------------|
| empty    | convert val to empty                     |
| nil      | convert val to nil                       |
| big_text | convert val to big_text("text" * 50)     |
| br_text  | convert val to br_text("text\n" * 5)     |